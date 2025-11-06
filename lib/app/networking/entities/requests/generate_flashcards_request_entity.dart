import 'package:freezed_annotation/freezed_annotation.dart';

part 'generate_flashcards_request_entity.freezed.dart';
part 'generate_flashcards_request_entity.g.dart';

/// Request entity for generating flashcards from text
///
/// Used with: POST /rest/v1/rpc/generate_flashcards
@freezed
abstract class GenerateFlashcardsRequestEntity
    with _$GenerateFlashcardsRequestEntity {
  const factory GenerateFlashcardsRequestEntity({
    /// Source text to generate flashcards from (1,000-10,000 characters)
    @JsonKey(name: 'source_text') required String sourceText,

    /// OpenRouter model identifier (e.g., 'openai/gpt-4-turbo')
    required String model,

    /// Number of flashcards to generate (5-20, default: 10)
    @JsonKey(name: 'target_count') int? targetCount,
  }) = _GenerateFlashcardsRequestEntity;

  factory GenerateFlashcardsRequestEntity.fromJson(Map<String, dynamic> json) =>
      _$GenerateFlashcardsRequestEntityFromJson(json);
}
