// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';
import 'package:xcards/features/generation/presentation/cubit/generation_cubit.dart';
import 'package:xcards/features/generation/presentation/view/generation_view.dart';
import 'package:xcards/features/generation/presentation/widgets/step1_input_view.dart';
import 'package:xcards/features/generation/presentation/widgets/step2_proposals_view.dart';

import '../../../../helpers/helpers.dart';

class MockGenerationCubit extends MockCubit<GenerationState>
    implements GenerationCubit {}

void main() {
  group('GenerationView', () {
    late GenerationCubit mockGenerationCubit;

    setUp(() {
      mockGenerationCubit = MockGenerationCubit();
    });

    testWidgets('displays Step1InputView in initial state', (tester) async {
      when(() => mockGenerationCubit.state).thenReturn(const GenerationState());

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const GenerationView(),
        ),
      );

      expect(find.byType(Step1InputView), findsOneWidget);
      expect(find.byType(Step2ProposalsView), findsNothing);
    });

    testWidgets('displays CircularProgressIndicator in loading state', (
      tester,
    ) async {
      when(() => mockGenerationCubit.state).thenReturn(
        const GenerationState(
          status: GenerationStatus.loading,
          sourceText: 'test text',
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const GenerationView(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Step1InputView), findsNothing);
      expect(find.byType(Step2ProposalsView), findsNothing);
    });

    testWidgets('displays Step2ProposalsView in ready state', (tester) async {
      const proposals = [
        FlashcardProposalEntity(front: 'Front 1', back: 'Back 1'),
        FlashcardProposalEntity(front: 'Front 2', back: 'Back 2'),
      ];

      when(() => mockGenerationCubit.state).thenReturn(
        const GenerationState(
          status: GenerationStatus.ready,
          sourceText: 'test text',
          proposals: proposals,
          generationId: 'test-id',
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const GenerationView(),
        ),
      );

      expect(find.byType(Step2ProposalsView), findsOneWidget);
      expect(find.byType(Step1InputView), findsNothing);
    });

    testWidgets('displays error SnackBar when status is failure', (
      tester,
    ) async {
      whenListen(
        mockGenerationCubit,
        Stream.fromIterable([
          const GenerationState(),
          GenerationState(
            status: GenerationStatus.failure,
            failure: AppFailure.unexpected(),
          ),
        ]),
        initialState: const GenerationState(),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const GenerationView(),
        ),
      );

      // Trigger the listener by advancing frames
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Failed to generate flashcards. Please try again.'),
        findsOneWidget,
      );
    });

    // Note: Success SnackBar test omitted due to AutoRouter context requirement
    // The success flow with navigation is tested in integration tests
  });
}
