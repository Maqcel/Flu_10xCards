import 'package:dartz/dartz.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';

/// Contract for Generation feature data operations.
///
/// This repository handles AI-based flashcard generation using OpenRouter API.
/// All generation operations create records in Supabase for analytics.
abstract class GenerationRepository {
  /// Save accepted flashcards to the database
  ///
  /// [generationId] - ID of the generation record (from createGenerationRecord)
  /// [accepted] - List of flashcards accepted by the user
  /// [editedFlashcards] - List of flashcards that were edited before acceptance
  Future<Either<AppFailure, Unit>> saveFlashcards({
    required String? generationId,
    required List<FlashcardProposalEntity> accepted,
    required List<FlashcardProposalEntity> editedFlashcards,
  });

  /// Update generation statistics after user accepts/edits flashcards
  ///
  /// [generationId] - ID of the generation record to update
  /// [acceptedUnedited] - Number of flashcards accepted without editing
  /// [acceptedEdited] - Number of flashcards accepted after editing
  Future<Either<AppFailure, Unit>> updateStats({
    required String generationId,
    required int acceptedUnedited,
    required int acceptedEdited,
  });

  /// Create a generation record for AI-generated flashcards
  ///
  /// This should be called immediately after AI generation succeeds.
  /// Uses the generationId from OpenRouter as the primary key.
  ///
  /// [generationId] - Unique ID from OpenRouter (e.g., 'gen-xxxx')
  /// [model] - AI model used (e.g., 'tngtech/deepseek-r1t2-chimera:free')
  /// [sourceText] - Original text used for generation
  /// [generatedCount] - Number of flashcards generated
  /// [generationDuration] - Time taken to generate (milliseconds)
  Future<Either<AppFailure, Unit>> createGenerationRecord({
    required String generationId,
    required String model,
    required String sourceText,
    required int generatedCount,
    required int generationDuration,
  });

  /// Log a generation error for analytics and debugging
  ///
  /// This is fire-and-forget - errors in logging won't break the user flow.
  /// Used for tracking AI failures, timeouts, and other generation issues.
  Future<void> logGenerationError({
    required String model,
    required String sourceText,
    required AppFailure failure,
  });
}
