import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_statistics_model.freezed.dart';

/// Domain model for statistics of a specific LLM model
///
/// Represents performance metrics for an individual AI model.
@freezed
abstract class ModelStatisticsModel with _$ModelStatisticsModel {
  const factory ModelStatisticsModel({
    required String model,
    required int count,
    required double avgAcceptanceRate,
  }) = _ModelStatisticsModel;
}
