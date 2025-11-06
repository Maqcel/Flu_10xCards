import 'package:freezed_annotation/freezed_annotation.dart';

part 'flashcard_proposal_model.freezed.dart';

/// Domain model for a flashcard proposal from AI generation
///
/// Represents a proposed flashcard that hasn't been saved yet.
/// Used in the generation review flow before acceptance.
@freezed
abstract class FlashcardProposalModel with _$FlashcardProposalModel {
  const factory FlashcardProposalModel({
    required String front,
    required String back,
  }) = _FlashcardProposalModel;
}
