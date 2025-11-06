import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xcards/features/statistics/domain/model/source_statistics_model.dart';

part 'flashcard_statistics_model.freezed.dart';

/// Domain model for aggregated flashcard statistics
///
/// Provides insights into flashcard sources and creation patterns.
@freezed
abstract class FlashcardStatisticsModel with _$FlashcardStatisticsModel {
  const factory FlashcardStatisticsModel({
    required int totalFlashcards,
    required Map<String, SourceStatisticsModel> bySource,
    required double aiTotalPercentage,
    required int createdLast7Days,
    required int createdLast30Days,
  }) = _FlashcardStatisticsModel;
}
