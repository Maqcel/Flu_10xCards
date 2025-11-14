// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';
import 'package:xcards/features/generation/presentation/cubit/generation_cubit.dart';
import 'package:xcards/features/generation/presentation/widgets/flashcard_swipe_card.dart';
import 'package:xcards/features/generation/presentation/widgets/step2_proposals_view.dart';

import '../../../../helpers/helpers.dart';

class MockGenerationCubit extends MockCubit<GenerationState>
    implements GenerationCubit {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const FlashcardProposalEntity(front: 'test', back: 'test'),
    );
  });

  group('Step2ProposalsView', () {
    late GenerationCubit mockGenerationCubit;

    setUp(() {
      mockGenerationCubit = MockGenerationCubit();
    });

    testWidgets('displays empty state when no proposals', (tester) async {
      when(() => mockGenerationCubit.state).thenReturn(
        GenerationState(
          status: GenerationStatus.initial,
          sourceText: '',
          proposals: [],
          accepted: [],
          editedIds: {},
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step2ProposalsView(),
        ),
      );

      expect(find.text('All proposals reviewed!'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('displays FlashcardSwipeCard when proposals exist', (
      tester,
    ) async {
      const proposals = [
        FlashcardProposalEntity(front: 'Front 1', back: 'Back 1'),
        FlashcardProposalEntity(front: 'Front 2', back: 'Back 2'),
      ];

      when(() => mockGenerationCubit.state).thenReturn(
        GenerationState(
          status: GenerationStatus.ready,
          sourceText: 'test',
          proposals: proposals,
          accepted: [],
          editedIds: {},
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step2ProposalsView(),
        ),
      );

      expect(find.byType(FlashcardSwipeCard), findsOneWidget);
    });

    testWidgets('displays counter panel with correct counts', (tester) async {
      const proposals = [
        FlashcardProposalEntity(front: 'Front 1', back: 'Back 1'),
      ];
      const accepted = [
        FlashcardProposalEntity(front: 'Front 2', back: 'Back 2'),
      ];
      const editedIds = {'Front 3|Back 3'};

      when(() => mockGenerationCubit.state).thenReturn(
        GenerationState(
          status: GenerationStatus.ready,
          sourceText: 'test',
          proposals: proposals,
          accepted: accepted,
          editedIds: editedIds,
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step2ProposalsView(),
        ),
      );

      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Edited'), findsOneWidget);
      expect(find.text('Remaining'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(3)); // All counters show 1
    });

    testWidgets('cancel button pops navigation', (tester) async {
      when(() => mockGenerationCubit.state).thenReturn(
        GenerationState(
          status: GenerationStatus.ready,
          sourceText: 'test',
          proposals: [],
          accepted: [],
          editedIds: {},
        ),
      );

      bool popped = false;
      await tester.pumpApp(
        Navigator(
          onPopPage: (route, dynamic result) {
            popped = true;
            return route.didPop(result);
          },
          pages: [
            MaterialPage<void>(
              child: BlocProvider.value(
                value: mockGenerationCubit,
                child: const Step2ProposalsView(),
              ),
            ),
          ],
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('save button is disabled when no accepted/edited flashcards', (
      tester,
    ) async {
      when(() => mockGenerationCubit.state).thenReturn(
        GenerationState(
          status: GenerationStatus.ready,
          sourceText: 'test',
          proposals: [
            const FlashcardProposalEntity(front: 'Front 1', back: 'Back 1'),
          ],
          accepted: [],
          editedIds: {},
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step2ProposalsView(),
        ),
      );

      final saveButton = find.textContaining('Save');
      expect(saveButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(
        find.ancestor(of: saveButton, matching: find.byType(ElevatedButton)),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('save button is enabled when there are accepted flashcards', (
      tester,
    ) async {
      const accepted = [
        FlashcardProposalEntity(front: 'Front 1', back: 'Back 1'),
      ];

      when(() => mockGenerationCubit.state).thenReturn(
        GenerationState(
          status: GenerationStatus.ready,
          sourceText: 'test',
          proposals: [],
          accepted: accepted,
          editedIds: {},
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step2ProposalsView(),
        ),
      );

      final saveButton = find.textContaining('Save (1)');
      expect(saveButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(
        find.ancestor(of: saveButton, matching: find.byType(ElevatedButton)),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls cubit.saveAccepted when save button is tapped', (
      tester,
    ) async {
      const accepted = [
        FlashcardProposalEntity(front: 'Front 1', back: 'Back 1'),
      ];

      when(() => mockGenerationCubit.state).thenReturn(
        GenerationState(
          status: GenerationStatus.ready,
          sourceText: 'test',
          proposals: [],
          accepted: accepted,
          editedIds: {},
        ),
      );
      when(() => mockGenerationCubit.saveAccepted()).thenAnswer((_) async {});

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step2ProposalsView(),
        ),
      );

      await tester.tap(find.textContaining('Save (1)'));
      await tester.pump();

      verify(() => mockGenerationCubit.saveAccepted()).called(1);
    });

    testWidgets('save button displays correct count', (tester) async {
      const accepted = [
        FlashcardProposalEntity(front: 'Front 1', back: 'Back 1'),
        FlashcardProposalEntity(front: 'Front 2', back: 'Back 2'),
        FlashcardProposalEntity(front: 'Front 3', back: 'Back 3'),
      ];
      const editedIds = {'Front 3|Back 3'};

      when(() => mockGenerationCubit.state).thenReturn(
        GenerationState(
          status: GenerationStatus.ready,
          sourceText: 'test',
          proposals: [],
          accepted: accepted,
          editedIds: editedIds,
        ),
      );

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step2ProposalsView(),
        ),
      );

      expect(find.text('Save (3)'), findsOneWidget);
    });

    // Note: Edit dialog tests omitted due to TextEditingController lifecycle complexities
    // Dialog functionality is tested in integration tests
  });
}
