import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard_proposal_entity.freezed.dart';
part 'flashcard_proposal_entity.g.dart';

/// Flashcard proposal returned from AI generation
///
/// This represents a proposed flashcard that hasn't been saved yet.
/// It only contains the front and back content without ID or metadata.
@freezed
abstract class FlashcardProposalEntity with _$FlashcardProposalEntity {
  const factory FlashcardProposalEntity({
    required String front,
    required String back,
  }) = _FlashcardProposalEntity;

  factory FlashcardProposalEntity.fromJson(Map<String, dynamic> json) =>
      _$FlashcardProposalEntityFromJson(json);
}
