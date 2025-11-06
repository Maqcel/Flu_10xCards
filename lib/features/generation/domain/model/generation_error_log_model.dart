import 'package:freezed_annotation/freezed_annotation.dart';

part 'generation_error_log_model.freezed.dart';

/// Domain model for a generation error log
///
/// Represents an error that occurred during AI generation.
@freezed
abstract class GenerationErrorLogModel with _$GenerationErrorLogModel {
  const factory GenerationErrorLogModel({
    required String id,
    required String userId,
    required String model,
    required String sourceTextHash,
    required int sourceTextLength,
    required String errorCode,
    required String errorMessage,
    required DateTime createdAt,
  }) = _GenerationErrorLogModel;
}
