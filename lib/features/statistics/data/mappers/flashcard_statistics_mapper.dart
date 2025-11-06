import 'package:injectable/injectable.dart';
import 'package:xcards/app/networking/entities/entities.dart';
import 'package:xcards/features/statistics/data/mappers/source_statistics_mapper.dart';
import 'package:xcards/features/statistics/domain/model/flashcard_statistics_model.dart';

/// Mapper for converting between [FlashcardStatisticsEntity]
/// and [FlashcardStatisticsModel]
@injectable
class FlashcardStatisticsMapper {
  const FlashcardStatisticsMapper();

  /// Convert entity to domain model
  static FlashcardStatisticsModel toModel(FlashcardStatisticsEntity entity) =>
      FlashcardStatisticsModel(
        totalFlashcards: entity.totalFlashcards,
        bySource: entity.bySource.map(
          (key, value) => MapEntry(key, SourceStatisticsMapper.toModel(value)),
        ),
        aiTotalPercentage: entity.aiTotalPercentage,
        createdLast7Days: entity.createdLast7Days,
        createdLast30Days: entity.createdLast30Days,
      );

  /// Convert domain model to entity
  static FlashcardStatisticsEntity toEntity(FlashcardStatisticsModel model) =>
      FlashcardStatisticsEntity(
        totalFlashcards: model.totalFlashcards,
        bySource: model.bySource.map(
          (key, value) => MapEntry(key, SourceStatisticsMapper.toEntity(value)),
        ),
        aiTotalPercentage: model.aiTotalPercentage,
        createdLast7Days: model.createdLast7Days,
        createdLast30Days: model.createdLast30Days,
      );
}
