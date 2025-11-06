import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_flashcard_request_entity.freezed.dart';
part 'update_flashcard_request_entity.g.dart';

/// Request entity for updating an existing flashcard
///
/// Used with: PATCH /flashcards?id=eq.flashcard_id
/// Note: Only front and back fields can be updated
@freezed
abstract class UpdateFlashcardRequestEntity
    with _$UpdateFlashcardRequestEntity {
  const factory UpdateFlashcardRequestEntity({
    /// Updated front content (optional) - 1-200 characters
    String? front,

    /// Updated back content (optional) - 1-500 characters
    String? back,
  }) = _UpdateFlashcardRequestEntity;

  factory UpdateFlashcardRequestEntity.fromJson(Map<String, dynamic> json) =>
      _$UpdateFlashcardRequestEntityFromJson(json);
}
