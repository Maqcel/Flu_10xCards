import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_statistics_entity.freezed.dart';
part 'model_statistics_entity.g.dart';

/// Statistics for a specific LLM model
///
/// Part of GenerationStatisticsEntity response
@freezed
abstract class ModelStatisticsEntity with _$ModelStatisticsEntity {
  const factory ModelStatisticsEntity({
    /// Model identifier (e.g., 'openai/gpt-4-turbo')
    required String model,

    /// Number of generations using this model
    required int count,

    /// Average acceptance rate for this model (percentage)
    @JsonKey(name: 'avg_acceptance_rate') required double avgAcceptanceRate,
  }) = _ModelStatisticsEntity;

  factory ModelStatisticsEntity.fromJson(Map<String, dynamic> json) =>
      _$ModelStatisticsEntityFromJson(json);
}
