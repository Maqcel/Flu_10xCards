import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xcards/features/statistics/domain/model/model_statistics_model.dart';

part 'generation_statistics_model.freezed.dart';

/// Domain model for aggregated AI generation statistics
///
/// Provides insights into generation performance and acceptance rates.
@freezed
abstract class GenerationStatisticsModel with _$GenerationStatisticsModel {
  const factory GenerationStatisticsModel({
    required int totalGenerations,
    required int totalFlashcardsGenerated,
    required int totalFlashcardsAccepted,
    required double acceptanceRate,
    required double averageUneditedRate,
    required int averageGenerationDuration,
    required List<ModelStatisticsModel> byModel,
  }) = _GenerationStatisticsModel;
}
