import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';
import 'package:xcards/features/generation/domain/repository/generation_repository.dart';

part 'generation_cubit.freezed.dart';
part 'generation_state.dart';

@injectable
class GenerationCubit extends Cubit<GenerationState> {
  GenerationCubit(this._repository) : super(const GenerationState());

  final GenerationRepository _repository;

  Future<void> generate({required String text}) async {
    if (text.length < 1000 || text.length > 10000) {
      emit(
        state.copyWith(
          status: GenerationStatus.failure,
          failure: const AppFailure.validation(message: 'Invalid text length'),
        ),
      );
      return;
    }
    emit(state.copyWith(status: GenerationStatus.loading, sourceText: text));
    final result = await _repository.generate(sourceText: text);
    result.fold(
      (l) => emit(state.copyWith(status: GenerationStatus.failure, failure: l)),
      (r) => emit(
        state.copyWith(
          status: GenerationStatus.ready,
          proposals: r.proposals,
          generationId: r.generationId,
        ),
      ),
    );
  }

  void swipeAccept(int index) {
    final proposal = state.proposals[index];
    emit(
      state.copyWith(
        accepted: [...state.accepted, proposal],
        proposals: [...state.proposals]..removeAt(index),
      ),
    );
  }

  void swipeReject(int index) {
    emit(state.copyWith(proposals: [...state.proposals]..removeAt(index)));
  }

  void editProposal(int index, FlashcardProposalEntity updated) {
    final updatedProposals = [...state.proposals];
    updatedProposals[index] = updated;
    emit(state.copyWith(proposals: updatedProposals));
  }

  Future<void> saveAccepted() async {
    if (state.generationId == null || state.accepted.isEmpty) return;
    emit(state.copyWith(status: GenerationStatus.saving));
    final res = await _repository.saveFlashcards(
      generationId: state.generationId!,
      accepted: state.accepted,
    );
    await _repository.updateStats(
      generationId: state.generationId!,
      acceptedUnedited: state.accepted.length,
      acceptedEdited: state.edited.length,
    );
    res.fold(
      (l) => emit(state.copyWith(status: GenerationStatus.failure, failure: l)),
      (r) => emit(state.copyWith(status: GenerationStatus.success)),
    );
  }
}
