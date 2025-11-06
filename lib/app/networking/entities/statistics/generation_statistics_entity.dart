import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xcards/app/networking/entities/statistics/model_statistics_entity.dart';

part 'generation_statistics_entity.freezed.dart';
part 'generation_statistics_entity.g.dart';

/// Aggregated statistics about AI generation performance
///
/// Returned from: GET /rest/v1/rpc/get_generation_statistics
@freezed
abstract class GenerationStatisticsEntity with _$GenerationStatisticsEntity {
  const factory GenerationStatisticsEntity({
    /// Total number of generation sessions
    @JsonKey(name: 'total_generations') required int totalGenerations,

    /// Total flashcards generated across all sessions
    @JsonKey(name: 'total_flashcards_generated')
    required int totalFlashcardsGenerated,

    /// Total flashcards accepted (edited + unedited)
    @JsonKey(name: 'total_flashcards_accepted')
    required int totalFlashcardsAccepted,

    /// Overall acceptance rate as percentage
    @JsonKey(name: 'acceptance_rate') required double acceptanceRate,

    /// Average rate of unedited acceptance as percentage
    @JsonKey(name: 'average_unedited_rate') required double averageUneditedRate,

    /// Average generation duration in milliseconds
    @JsonKey(name: 'average_generation_duration')
    required int averageGenerationDuration,

    /// Statistics broken down by model
    @JsonKey(name: 'by_model') required List<ModelStatisticsEntity> byModel,
  }) = _GenerationStatisticsEntity;

  factory GenerationStatisticsEntity.fromJson(Map<String, dynamic> json) =>
      _$GenerationStatisticsEntityFromJson(json);
}
