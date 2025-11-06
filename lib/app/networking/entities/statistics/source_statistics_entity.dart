import 'package:freezed_annotation/freezed_annotation.dart';

part 'source_statistics_entity.freezed.dart';
part 'source_statistics_entity.g.dart';

/// Statistics for flashcards from a specific source
///
/// Part of FlashcardStatisticsEntity response
@freezed
abstract class SourceStatisticsEntity with _$SourceStatisticsEntity {
  const factory SourceStatisticsEntity({
    /// Number of flashcards from this source
    required int count,

    /// Percentage of total flashcards
    required double percentage,
  }) = _SourceStatisticsEntity;

  factory SourceStatisticsEntity.fromJson(Map<String, dynamic> json) =>
      _$SourceStatisticsEntityFromJson(json);
}
