import 'package:json_annotation/json_annotation.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';
import 'package:xcards/features/generation/domain/repository/generation_repository.dart';

part 'generation_response_dto.g.dart';

/// API response when generating flashcards.
@JsonSerializable(explicitToJson: true)
class GenerationResponseDto {
  GenerationResponseDto({required this.generationId, required this.proposals});

  factory GenerationResponseDto.fromJson(Map<String, dynamic> json) =>
      _$GenerationResponseDtoFromJson(json);

  @JsonKey(name: 'generation_id')
  final String generationId;

  final List<FlashcardProposalEntity> proposals;

  Map<String, dynamic> toJson() => _$GenerationResponseDtoToJson(this);

  GenerationResponse toDomain() =>
      GenerationResponse(generationId: generationId, proposals: proposals);
}
