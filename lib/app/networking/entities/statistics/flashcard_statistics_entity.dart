import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xcards/app/networking/entities/statistics/source_statistics_entity.dart';

part 'flashcard_statistics_entity.freezed.dart';
part 'flashcard_statistics_entity.g.dart';

/// Aggregated statistics about flashcard sources and usage
///
/// Returned from: GET /get_flashcard_statistics
@freezed
abstract class FlashcardStatisticsEntity with _$FlashcardStatisticsEntity {
  const factory FlashcardStatisticsEntity({
    /// Total number of flashcards
    @JsonKey(name: 'total_flashcards') required int totalFlashcards,

    /// Statistics broken down by source type
    @JsonKey(name: 'by_source')
    required Map<String, SourceStatisticsEntity> bySource,

    /// Combined percentage of AI-generated flashcards (ai-full + ai-edited)
    @JsonKey(name: 'ai_total_percentage') required double aiTotalPercentage,

    /// Number of flashcards created in the last 7 days
    @JsonKey(name: 'created_last_7_days') required int createdLast7Days,

    /// Number of flashcards created in the last 30 days
    @JsonKey(name: 'created_last_30_days') required int createdLast30Days,
  }) = _FlashcardStatisticsEntity;

  factory FlashcardStatisticsEntity.fromJson(Map<String, dynamic> json) =>
      _$FlashcardStatisticsEntityFromJson(json);
}
