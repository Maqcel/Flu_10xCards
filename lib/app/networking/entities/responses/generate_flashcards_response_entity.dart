import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';

part 'generate_flashcards_response_entity.freezed.dart';
part 'generate_flashcards_response_entity.g.dart';

/// Response entity from flashcard generation
///
/// Returned from: POST /rest/v1/rpc/generate_flashcards
@freezed
abstract class GenerateFlashcardsResponseEntity
    with _$GenerateFlashcardsResponseEntity {
  const factory GenerateFlashcardsResponseEntity({
    /// UUID for tracking this generation session
    @JsonKey(name: 'generation_id') required String generationId,

    /// LLM model used for generation
    required String model,

    /// Character count of input source text
    @JsonKey(name: 'source_text_length') required int sourceTextLength,

    /// SHA-256 hash of source text
    @JsonKey(name: 'source_text_hash') required String sourceTextHash,

    /// Number of flashcards generated
    @JsonKey(name: 'generated_count') required int generatedCount,

    /// Generation time in milliseconds
    @JsonKey(name: 'generation_duration') required int generationDuration,

    /// Array of generated flashcard proposals (not yet saved to database)
    required List<FlashcardProposalEntity> proposals,
  }) = _GenerateFlashcardsResponseEntity;

  factory GenerateFlashcardsResponseEntity.fromJson(
    Map<String, dynamic> json,
  ) => _$GenerateFlashcardsResponseEntityFromJson(json);
}
