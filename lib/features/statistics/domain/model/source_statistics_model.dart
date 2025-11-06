import 'package:freezed_annotation/freezed_annotation.dart';

part 'source_statistics_model.freezed.dart';

/// Domain model for statistics of flashcards from a specific source
///
/// Represents count and percentage breakdown by source type.
@freezed
abstract class SourceStatisticsModel with _$SourceStatisticsModel {
  const factory SourceStatisticsModel({
    required int count,
    required double percentage,
  }) = _SourceStatisticsModel;
}
