import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_flashcard_request_entity.freezed.dart';
part 'create_flashcard_request_entity.g.dart';

/// Request entity for creating a single flashcard
///
/// Used with: POST /rest/v1/flashcards
@freezed
abstract class CreateFlashcardRequestEntity
    with _$CreateFlashcardRequestEntity {
  const factory CreateFlashcardRequestEntity({
    /// Front of the flashcard (question/prompt) - 1-200 characters
    required String front,

    /// Back of the flashcard (answer) - 1-500 characters
    required String back,

    /// Source type: 'manual', 'ai-full', 'ai-edited'
    required String source,

    /// Optional reference to generation session (for AI-generated flashcards)
    @JsonKey(name: 'generation_id') String? generationId,
  }) = _CreateFlashcardRequestEntity;

  factory CreateFlashcardRequestEntity.fromJson(Map<String, dynamic> json) =>
      _$CreateFlashcardRequestEntityFromJson(json);
}
