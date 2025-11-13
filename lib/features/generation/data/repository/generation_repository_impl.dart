import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/app/networking/entities/requests/create_flashcard_request_entity.dart';
import 'package:xcards/app/networking/entities/requests/generate_flashcards_request_entity.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';
import 'package:xcards/features/generation/data/data_source/generation_service_data_source.dart';
import 'package:xcards/features/generation/data/dto/update_generation_stats_dto.dart';
import 'package:xcards/features/generation/domain/repository/generation_repository.dart';

@LazySingleton(as: GenerationRepository)
class GenerationRepositoryImpl implements GenerationRepository {
  GenerationRepositoryImpl(this._remote);

  final GenerationServiceDataSource _remote;

  @override
  Future<Either<AppFailure, GenerationResponse>> generate({
    required String sourceText,
    int targetCount = 10,
  }) async {
    try {
      final dto = await _remote.generate(
        GenerateFlashcardsRequestEntity(
          sourceText: sourceText,
          targetCount: targetCount,
        ),
      );
      return Right(dto.toDomain());
    } catch (e) {
      return Left(AppFailure.unexpected(message: e.toString()));
    }
  }

  @override
  Future<Either<AppFailure, Unit>> saveFlashcards({
    required String generationId,
    required List<FlashcardProposalEntity> accepted,
  }) async {
    try {
      await _remote.batchInsert(
        accepted
            .map(
              (e) => CreateFlashcardRequestEntity(
                front: e.front,
                back: e.back,
                source: 'ai-full',
                generationId: generationId,
              ),
            )
            .toList(),
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
      await _remote.updateStats(
        generationId,
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
}
