import 'package:json_annotation/json_annotation.dart';

part 'create_generation_request_entity.g.dart';

/// Request entity for creating a generation record
///
/// Used with: POST /rest/v1/generations
@JsonSerializable()
class CreateGenerationRequestEntity {
  const CreateGenerationRequestEntity({
    required this.id,
    required this.userId,
    required this.model,
    required this.sourceTextLength,
    required this.sourceTextHash,
    required this.generatedCount,
    required this.generationDuration,
    this.acceptedUneditedCount,
    this.acceptedEditedCount,
  });

  factory CreateGenerationRequestEntity.fromJson(Map<String, dynamic> json) =>
      _$CreateGenerationRequestEntityFromJson(json);

  /// Generation ID from OpenRouter (e.g., 'gen-xxxx')
  final String id;

  /// User ID (required by Supabase, use dummy for development without auth)
  @JsonKey(name: 'user_id')
  final String userId;

  /// Model used for generation (e.g., 'tngtech/deepseek-r1t2-chimera:free')
  final String model;

  /// Length of source text in characters (1000-10000)
  @JsonKey(name: 'source_text_length')
  final int sourceTextLength;

  /// SHA-256 hash of source text for deduplication
  @JsonKey(name: 'source_text_hash')
  final String sourceTextHash;

  /// Number of flashcards generated
  @JsonKey(name: 'generated_count')
  final int generatedCount;

  /// Generation time in milliseconds
  @JsonKey(name: 'generation_duration')
  final int generationDuration;

  /// Optional: Number of flashcards accepted without editing (updated later)
  @JsonKey(name: 'accepted_unedited_count')
  final int? acceptedUneditedCount;

  /// Optional: Number of flashcards accepted after editing (updated later)
  @JsonKey(name: 'accepted_edited_count')
  final int? acceptedEditedCount;

  Map<String, dynamic> toJson() => _$CreateGenerationRequestEntityToJson(this);
}
