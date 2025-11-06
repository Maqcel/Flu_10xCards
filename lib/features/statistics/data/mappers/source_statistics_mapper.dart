import 'package:injectable/injectable.dart';
import 'package:xcards/app/networking/entities/entities.dart';
import 'package:xcards/features/statistics/domain/model/source_statistics_model.dart';

/// Mapper for converting between [SourceStatisticsEntity]
/// and [SourceStatisticsModel]
@injectable
class SourceStatisticsMapper {
  const SourceStatisticsMapper();

  /// Convert entity to domain model
  static SourceStatisticsModel toModel(SourceStatisticsEntity entity) =>
      SourceStatisticsModel(count: entity.count, percentage: entity.percentage);

  /// Convert domain model to entity
  static SourceStatisticsEntity toEntity(SourceStatisticsModel model) =>
      SourceStatisticsEntity(count: model.count, percentage: model.percentage);
}
