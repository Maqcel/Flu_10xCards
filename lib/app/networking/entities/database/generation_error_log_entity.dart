import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xcards/app/utils/date_time_converter.dart';

part 'generation_error_log_entity.freezed.dart';
part 'generation_error_log_entity.g.dart';

/// Generation error log entity matching the Supabase database schema
///
/// Stores error logs from AI generation attempts
@freezed
abstract class GenerationErrorLogEntity with _$GenerationErrorLogEntity {
  const factory GenerationErrorLogEntity({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String model,
    @JsonKey(name: 'source_text_hash') required String sourceTextHash,
    @JsonKey(name: 'source_text_length') required int sourceTextLength,
    @JsonKey(name: 'error_code') required String errorCode,
    @JsonKey(name: 'error_message') required String errorMessage,
    @JsonKey(name: 'created_at')
    @DateTimeConverter()
    required DateTime createdAt,
  }) = _GenerationErrorLogEntity;

  factory GenerationErrorLogEntity.fromJson(Map<String, dynamic> json) =>
      _$GenerationErrorLogEntityFromJson(json);
}
