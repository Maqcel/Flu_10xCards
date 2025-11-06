import 'package:injectable/injectable.dart';
import 'package:xcards/app/networking/entities/entities.dart';
import 'package:xcards/features/statistics/domain/model/model_statistics_model.dart';

/// Mapper for converting between [ModelStatisticsEntity]
/// and [ModelStatisticsModel]
@injectable
class ModelStatisticsMapper {
  const ModelStatisticsMapper();

  /// Convert entity to domain model
  static ModelStatisticsModel toModel(ModelStatisticsEntity entity) =>
      ModelStatisticsModel(
        model: entity.model,
        count: entity.count,
        avgAcceptanceRate: entity.avgAcceptanceRate,
      );

  /// Convert domain model to entity
  static ModelStatisticsEntity toEntity(ModelStatisticsModel model) =>
      ModelStatisticsEntity(
        model: model.model,
        count: model.count,
        avgAcceptanceRate: model.avgAcceptanceRate,
      );

  /// Convert list of entities to list of models
  static List<ModelStatisticsModel> toModelList(
    List<ModelStatisticsEntity> entities,
  ) => entities.map(toModel).toList();

  /// Convert list of models to list of entities
  static List<ModelStatisticsEntity> toEntityList(
    List<ModelStatisticsModel> models,
  ) => models.map(toEntity).toList();
}
