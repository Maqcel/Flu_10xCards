import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';
import 'package:xcards/features/generation/domain/repository/generation_repository.dart';
import 'package:xcards/features/generation/domain/usecase/generate_flashcards_with_ai_usecase.dart';

part 'generation_cubit.freezed.dart';
part 'generation_state.dart';

@injectable
class GenerationCubit extends Cubit<GenerationState> {
  GenerationCubit(this._repository, this._generateFlashcardsWithAi)
    : super(const GenerationState());

  final GenerationRepository _repository;
  final GenerateFlashcardsWithAiUseCase _generateFlashcardsWithAi;

  /// Generate flashcards using AI (OpenRouter)
  ///
  /// Flow:
  /// 1. Validate source text (1,000-10,000 characters)
  /// 2. Call OpenRouter API to generate flashcards
  /// 3. Create generation record in database (for analytics)
  /// 4. Return flashcards as proposals for user review
  ///
  /// The generationId is created immediately and used when saving flashcards.
  Future<void> generateWithAI({
    required String text,
    int targetCount = 10,
    String? additionalContext,
  }) async {
    // Validate input
    if (text.length < 1000 || text.length > 10000) {
      emit(
        state.copyWith(
          status: GenerationStatus.failure,
          failure: const AppFailure.validation(
            message: 'Source text must be between 1,000 and 10,000 characters',
          ),
        ),
      );
      return;
    }

    // Start loading
    emit(state.copyWith(status: GenerationStatus.loading, sourceText: text));

    // Generate with AI
    final result = await _generateFlashcardsWithAi(
      sourceText: text,
      targetCount: targetCount,
      additionalContext: additionalContext,
    );

    // Handle result
    result.fold(
      (failure) => emit(
        state.copyWith(status: GenerationStatus.failure, failure: failure),
      ),
      (record) {
        // Unpack tuple: (generationId, proposals)
        final (generationId, proposals) = record;
        emit(
          state.copyWith(
            status: GenerationStatus.ready,
            proposals: proposals,
            generationId: generationId, // Now we have generationId from DB
          ),
        );
      },
    );
  }

  /// Accept a flashcard proposal by swiping
  ///
  /// Moves the flashcard from proposals to accepted list.
  /// Preserves edit history if the flashcard was edited.
  void swipeAccept(int index) {
    final proposal = state.proposals[index];

    emit(
      state.copyWith(
        accepted: [...state.accepted, proposal],
        proposals: [...state.proposals]..removeAt(index),
      ),
    );
  }

  /// Reject a flashcard proposal by swiping
  ///
  /// Removes the flashcard from proposals list.
  void swipeReject(int index) {
    emit(state.copyWith(proposals: [...state.proposals]..removeAt(index)));
  }

  /// Edit a flashcard proposal
  ///
  /// Updates the proposal in place and marks it as edited.
  /// The edited status is tracked using flashcard ID (front+back).
  void editProposal(int index, FlashcardProposalEntity updated) {
    final original = state.proposals[index];
    final updatedProposals = [...state.proposals];
    updatedProposals[index] = updated;

    // Create flashcard ID from front+back for tracking
    final flashcardId = '${original.front}|${original.back}';

    // Add to edited IDs set
    final updatedEditedIds = {...state.editedIds, flashcardId};

    emit(
      state.copyWith(proposals: updatedProposals, editedIds: updatedEditedIds),
    );
  }

  /// Save accepted flashcards to database
  ///
  /// This saves all accepted flashcards and updates generation statistics.
  /// Flashcards are marked as 'ai-full' or 'ai-edited' based on edit history.
  Future<void> saveAccepted() async {
    if (state.accepted.isEmpty) return;

    emit(state.copyWith(status: GenerationStatus.saving));

    // Build list of edited flashcards from accepted list using editedIds
    final editedFlashcards = state.accepted
        .where((fc) => state.editedIds.contains('${fc.front}|${fc.back}'))
        .toList();

    // Save flashcards with generation record ID
    final res = await _repository.saveFlashcards(
      generationId: state.generationId,
      accepted: state.accepted,
      editedFlashcards: editedFlashcards,
    );

    // If we have a generationId, also update stats
    if (state.generationId != null) {
      await _repository.updateStats(
        generationId: state.generationId!,
        acceptedUnedited: state.accepted.length - editedFlashcards.length,
        acceptedEdited: editedFlashcards.length,
      );
    }

    res.fold(
      (l) => emit(state.copyWith(status: GenerationStatus.failure, failure: l)),
      (r) => emit(state.copyWith(status: GenerationStatus.success)),
    );
  }
}
