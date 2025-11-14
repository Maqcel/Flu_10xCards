import 'package:json_annotation/json_annotation.dart';

part 'create_error_log_request_entity.g.dart';

/// Request entity for creating a generation error log
///
/// Used with: POST /rest/v1/generation_error_logs
@JsonSerializable()
class CreateErrorLogRequestEntity {
  const CreateErrorLogRequestEntity({
    required this.userId,
    required this.model,
    required this.sourceTextHash,
    required this.sourceTextLength,
    required this.errorCode,
    required this.errorMessage,
  });

  factory CreateErrorLogRequestEntity.fromJson(Map<String, dynamic> json) =>
      _$CreateErrorLogRequestEntityFromJson(json);

  /// User ID (required by Supabase, use dummy for development without auth)
  @JsonKey(name: 'user_id')
  final String userId;

  /// Model that was attempted (e.g., 'tngtech/deepseek-r1t2-chimera:free')
  final String model;

  /// SHA-256 hash of source text for deduplication
  @JsonKey(name: 'source_text_hash')
  final String sourceTextHash;

  /// Length of source text in characters (1000-10000)
  @JsonKey(name: 'source_text_length')
  final int sourceTextLength;

  /// Error code for categorization (e.g., 'TIMEOUT', 'INVALID_RESPONSE')
  @JsonKey(name: 'error_code')
  final String errorCode;

  /// Detailed error message for debugging
  @JsonKey(name: 'error_message')
  final String errorMessage;

  Map<String, dynamic> toJson() => _$CreateErrorLogRequestEntityToJson(this);
}
