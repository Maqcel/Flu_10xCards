import 'package:injectable/injectable.dart';
import 'package:xcards/app/networking/entities/entities.dart';
import 'package:xcards/features/generation/domain/model/generation_model.dart';

/// Mapper for converting between [GenerationEntity]
/// and [GenerationModel]
@injectable
class GenerationMapper {
  const GenerationMapper();

  /// Convert entity to domain model
  static GenerationModel toModel(GenerationEntity entity) => GenerationModel(
    id: entity.id,
    userId: entity.userId,
    model: entity.model,
    sourceTextHash: entity.sourceTextHash,
    sourceTextLength: entity.sourceTextLength,
    generatedCount: entity.generatedCount,
    generationDuration: entity.generationDuration,
    createdAt: entity.createdAt,
    acceptedUneditedCount: entity.acceptedUneditedCount,
    acceptedEditedCount: entity.acceptedEditedCount,
  );

  /// Convert domain model to entity
  static GenerationEntity toEntity(GenerationModel model) => GenerationEntity(
    id: model.id,
    userId: model.userId,
    model: model.model,
    sourceTextHash: model.sourceTextHash,
    sourceTextLength: model.sourceTextLength,
    generatedCount: model.generatedCount,
    generationDuration: model.generationDuration,
    createdAt: model.createdAt,
    acceptedUneditedCount: model.acceptedUneditedCount,
    acceptedEditedCount: model.acceptedEditedCount,
  );

  /// Convert list of entities to list of models
  static List<GenerationModel> toModelList(List<GenerationEntity> entities) =>
      entities.map(toModel).toList();

  /// Convert list of models to list of entities
  static List<GenerationEntity> toEntityList(List<GenerationModel> models) =>
      models.map(toEntity).toList();
}
