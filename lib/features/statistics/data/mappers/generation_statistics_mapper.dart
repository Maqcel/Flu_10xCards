import 'package:injectable/injectable.dart';
import 'package:xcards/app/networking/entities/entities.dart';
import 'package:xcards/features/statistics/data/mappers/model_statistics_mapper.dart';
import 'package:xcards/features/statistics/domain/model/generation_statistics_model.dart';

/// Mapper for converting between [GenerationStatisticsEntity]
/// and [GenerationStatisticsModel]
@injectable
class GenerationStatisticsMapper {
  const GenerationStatisticsMapper();

  /// Convert entity to domain model
  static GenerationStatisticsModel toModel(GenerationStatisticsEntity entity) =>
      GenerationStatisticsModel(
        totalGenerations: entity.totalGenerations,
        totalFlashcardsGenerated: entity.totalFlashcardsGenerated,
        totalFlashcardsAccepted: entity.totalFlashcardsAccepted,
        acceptanceRate: entity.acceptanceRate,
        averageUneditedRate: entity.averageUneditedRate,
        averageGenerationDuration: entity.averageGenerationDuration,
        byModel: ModelStatisticsMapper.toModelList(entity.byModel),
      );

  /// Convert domain model to entity
  static GenerationStatisticsEntity toEntity(GenerationStatisticsModel model) =>
      GenerationStatisticsEntity(
        totalGenerations: model.totalGenerations,
        totalFlashcardsGenerated: model.totalFlashcardsGenerated,
        totalFlashcardsAccepted: model.totalFlashcardsAccepted,
        acceptanceRate: model.acceptanceRate,
        averageUneditedRate: model.averageUneditedRate,
        averageGenerationDuration: model.averageGenerationDuration,
        byModel: ModelStatisticsMapper.toEntityList(model.byModel),
      );
}
