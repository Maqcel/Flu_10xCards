import 'package:injectable/injectable.dart';
import 'package:xcards/app/networking/entities/entities.dart';
import 'package:xcards/features/flashcard/data/mappers/flashcard_proposal_mapper.dart';
import 'package:xcards/features/generation/domain/model/generation_response_model.dart';

/// Mapper for converting between [GenerateFlashcardsResponseEntity]
/// and [GenerationResponseModel]
@injectable
class GenerationResponseMapper {
  const GenerationResponseMapper();

  /// Convert entity to domain model
  static GenerationResponseModel toModel(
    GenerateFlashcardsResponseEntity entity,
  ) => GenerationResponseModel(
    generationId: entity.generationId,
    model: entity.model,
    sourceTextLength: entity.sourceTextLength,
    sourceTextHash: entity.sourceTextHash,
    generatedCount: entity.generatedCount,
    generationDuration: entity.generationDuration,
    proposals: FlashcardProposalMapper.toModelList(entity.proposals),
  );

  /// Convert domain model to entity
  static GenerateFlashcardsResponseEntity toEntity(
    GenerationResponseModel model,
  ) => GenerateFlashcardsResponseEntity(
    generationId: model.generationId,
    model: model.model,
    sourceTextLength: model.sourceTextLength,
    sourceTextHash: model.sourceTextHash,
    generatedCount: model.generatedCount,
    generationDuration: model.generationDuration,
    proposals: FlashcardProposalMapper.toEntityList(model.proposals),
  );
}
