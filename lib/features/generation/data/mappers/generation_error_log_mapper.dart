import 'package:injectable/injectable.dart';
import 'package:xcards/app/networking/entities/entities.dart';
import 'package:xcards/features/generation/domain/model/generation_error_log_model.dart';

/// Mapper for converting between [GenerationErrorLogEntity]
/// and [GenerationErrorLogModel]
@injectable
class GenerationErrorLogMapper {
  const GenerationErrorLogMapper();

  /// Convert entity to domain model
  static GenerationErrorLogModel toModel(GenerationErrorLogEntity entity) =>
      GenerationErrorLogModel(
        id: entity.id,
        userId: entity.userId,
        model: entity.model,
        sourceTextHash: entity.sourceTextHash,
        sourceTextLength: entity.sourceTextLength,
        errorCode: entity.errorCode,
        errorMessage: entity.errorMessage,
        createdAt: entity.createdAt,
      );

  /// Convert domain model to entity
  static GenerationErrorLogEntity toEntity(GenerationErrorLogModel model) =>
      GenerationErrorLogEntity(
        id: model.id,
        userId: model.userId,
        model: model.model,
        sourceTextHash: model.sourceTextHash,
        sourceTextLength: model.sourceTextLength,
        errorCode: model.errorCode,
        errorMessage: model.errorMessage,
        createdAt: model.createdAt,
      );

  /// Convert list of entities to list of models
  static List<GenerationErrorLogModel> toModelList(
    List<GenerationErrorLogEntity> entities,
  ) => entities.map(toModel).toList();

  /// Convert list of models to list of entities
  static List<GenerationErrorLogEntity> toEntityList(
    List<GenerationErrorLogModel> models,
  ) => models.map(toEntity).toList();
}
