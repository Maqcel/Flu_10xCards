part of 'generation_cubit.dart';

enum GenerationStatus {
  initial,
  validating,
  loading,
  ready,
  saving,
  success,
  failure,
}

@freezed
abstract class GenerationState with _$GenerationState {
  const factory GenerationState({
    @Default(GenerationStatus.initial) GenerationStatus status,
    @Default('') String sourceText,
    @Default(<FlashcardProposalEntity>[])
    List<FlashcardProposalEntity> proposals,
    @Default(<FlashcardProposalEntity>[])
    List<FlashcardProposalEntity> accepted,

    /// Set of accepted flashcards that were edited (identified by front+back)
    @Default(<String>{}) Set<String> editedIds,
    AppFailure? failure,
    String? generationId,
  }) = _GenerationState;
}
