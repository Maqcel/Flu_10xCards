import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/app/networking/entities/requests/create_error_log_request_entity.dart';
import 'package:xcards/app/networking/entities/requests/create_flashcard_request_entity.dart';
import 'package:xcards/app/networking/entities/requests/create_generation_request_entity.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';
import 'package:xcards/features/generation/data/data_source/generation_service_data_source.dart';
import 'package:xcards/features/generation/data/dto/update_generation_stats_dto.dart';
import 'package:xcards/features/generation/domain/repository/generation_repository.dart';

@LazySingleton(as: GenerationRepository)
class GenerationRepositoryImpl implements GenerationRepository {
  GenerationRepositoryImpl(this._remote);

  final GenerationServiceDataSource _remote;

  @override
  Future<Either<AppFailure, Unit>> saveFlashcards({
    required String? generationId,
    required List<FlashcardProposalEntity> accepted,
    required List<FlashcardProposalEntity> editedFlashcards,
  }) async {
    try {
      // TODO: Replace with actual user_id from auth when authentication is implemented
      const dummyUserId = '00000000-0000-0000-0000-000000000000';

      // Create a set of edited flashcard IDs (front+back) for quick lookup
      final editedIds = editedFlashcards
          .map((e) => '${e.front}|${e.back}')
          .toSet();

      await _remote.batchInsert(
        accepted.map((e) {
          final flashcardId = '${e.front}|${e.back}';
          return CreateFlashcardRequestEntity(
            front: e.front,
            back: e.back,
            // Determine source: if flashcard ID is in edited set, mark as ai-edited
            source: editedIds.contains(flashcardId) ? 'ai-edited' : 'ai-full',
            generationId: generationId,
            userId: dummyUserId,
          );
        }).toList(),
      );
      return const Right(unit);
    } catch (e) {
      return Left(AppFailure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, Unit>> updateStats({
    required String generationId,
    required int acceptedUnedited,
    required int acceptedEdited,
  }) async {
    try {
      // PostgREST requires filter format: id=eq.value
      await _remote.updateStats(
        'eq.$generationId',
        UpdateGenerationStatsDto(
          acceptedUneditedCount: acceptedUnedited,
          acceptedEditedCount: acceptedEdited,
        ),
      );
      return const Right(unit);
    } catch (e) {
      return Left(AppFailure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, Unit>> createGenerationRecord({
    required String generationId,
    required String model,
    required String sourceText,
    required int generatedCount,
    required int generationDuration,
  }) async {
    try {
      // TODO: Replace with actual user_id from auth when authentication is implemented
      const dummyUserId = '00000000-0000-0000-0000-000000000000';

      // Calculate SHA-256 hash of source text for deduplication
      final bytes = utf8.encode(sourceText);
      final hash = sha256.convert(bytes);
      final sourceTextHash = hash.toString();

      final request = CreateGenerationRequestEntity(
        id: generationId,
        userId: dummyUserId,
        model: model,
        sourceTextLength: sourceText.length,
        sourceTextHash: sourceTextHash,
        generatedCount: generatedCount,
        generationDuration: generationDuration,
      );

      // Create generation record
      await _remote.createGeneration(request);

      return const Right(unit);
    } catch (e) {
      return Left(AppFailure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<void> logGenerationError({
    required String model,
    required String sourceText,
    required AppFailure failure,
  }) async {
    try {
      // TODO: Replace with actual user_id from auth when authentication is implemented
      const dummyUserId = '00000000-0000-0000-0000-000000000000';

      // Calculate SHA-256 hash of source text (same as in createGenerationRecord)
      final bytes = utf8.encode(sourceText);
      final hash = sha256.convert(bytes);
      final sourceTextHash = hash.toString();

      // Map AppFailure to error code
      final errorCode = _mapFailureToErrorCode(failure);
      final errorMessage = _extractErrorMessage(failure);

      final request = CreateErrorLogRequestEntity(
        userId: dummyUserId,
        model: model,
        sourceTextHash: sourceTextHash,
        sourceTextLength: sourceText.length,
        errorCode: errorCode,
        errorMessage: errorMessage,
      );

      // Fire and forget - don't await or throw errors
      // This is best-effort logging, shouldn't break the user flow
      await _remote.createErrorLog(request);
    } catch (e) {
      // Silently ignore logging errors - this is analytics, not critical path
      // In production, you might want to log this to a monitoring service
    }
  }

  /// Map AppFailure to error code for categorization
  String _mapFailureToErrorCode(AppFailure failure) => failure.when(
    network: (_) => 'NETWORK_ERROR',
    server: (_) => 'SERVER_ERROR',
    validation: (_) => 'VALIDATION_ERROR',
    unauthorized: (_) => 'UNAUTHORIZED',
    notFound: (_) => 'NOT_FOUND',
    cache: (_) => 'CACHE_ERROR',
    unexpected: (_) => 'UNEXPECTED_ERROR',
    aiRateLimitExceeded: (_) => 'AI_RATE_LIMIT',
    aiInsufficientCredits: (_) => 'AI_INSUFFICIENT_CREDITS',
    aiModelUnavailable: (__, _) => 'AI_MODEL_UNAVAILABLE',
    aiInvalidResponse: (_) => 'AI_INVALID_RESPONSE',
    aiTimeout: (_) => 'AI_TIMEOUT',
  );

  /// Extract error message from AppFailure
  String _extractErrorMessage(AppFailure failure) => failure.when(
    network: (message) => message ?? 'Network error',
    server: (message) => message ?? 'Server error',
    validation: (message) => message ?? 'Validation error',
    unauthorized: (message) => message ?? 'Unauthorized',
    notFound: (message) => message ?? 'Not found',
    cache: (message) => message ?? 'Cache error',
    unexpected: (message) => message ?? 'Unexpected error',
    aiRateLimitExceeded: (message) => message ?? 'AI rate limit exceeded',
    aiInsufficientCredits: (message) => message ?? 'AI insufficient credits',
    aiModelUnavailable: (model, message) =>
        '${message ?? 'AI model unavailable'} (model: $model)',
    aiInvalidResponse: (message) => message ?? 'AI invalid response',
    aiTimeout: (message) => message ?? 'AI timeout',
  );
}
