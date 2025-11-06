import 'package:injectable/injectable.dart';
import 'package:xcards/app/networking/entities/entities.dart';
import 'package:xcards/features/flashcard/domain/model/flashcard_model.dart';

/// Mapper for converting between [FlashcardEntity]
/// and [FlashcardModel]
@injectable
class FlashcardMapper {
  const FlashcardMapper();

  /// Convert entity to domain model
  static FlashcardModel toModel(FlashcardEntity entity) => FlashcardModel(
    id: entity.id,
    userId: entity.userId,
    front: entity.front,
    back: entity.back,
    source: FlashcardSource.fromString(entity.source),
    generationId: entity.generationId,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  /// Convert domain model to entity
  static FlashcardEntity toEntity(FlashcardModel model) => FlashcardEntity(
    id: model.id,
    userId: model.userId,
    front: model.front,
    back: model.back,
    source: model.source.value,
    generationId: model.generationId,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
  );

  /// Convert list of entities to list of models
  static List<FlashcardModel> toModelList(List<FlashcardEntity> entities) =>
      entities.map(toModel).toList();

  /// Convert list of models to list of entities
  static List<FlashcardEntity> toEntityList(List<FlashcardModel> models) =>
      models.map(toEntity).toList();
}
