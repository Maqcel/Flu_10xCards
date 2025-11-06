import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xcards/features/flashcard/domain/model/flashcard_proposal_model.dart';

part 'generation_response_model.freezed.dart';

/// Domain model for the response from flashcard generation
///
/// Contains metadata about the generation and the proposed flashcards.
@freezed
abstract class GenerationResponseModel with _$GenerationResponseModel {
  const factory GenerationResponseModel({
    required String generationId,
    required String model,
    required int sourceTextLength,
    required String sourceTextHash,
    required int generatedCount,
    required int generationDuration,
    required List<FlashcardProposalModel> proposals,
  }) = _GenerationResponseModel;
}
