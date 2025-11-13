import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';
import 'package:xcards/features/generation/presentation/widgets/flashcard_swipe_card.dart';

import '../../../../helpers/helpers.dart';

void main() {
  group('FlashcardSwipeCard', () {
    const testProposal = FlashcardProposalEntity(
      front: 'Test Front',
      back: 'Test Back',
    );

    testWidgets('displays front side by default', (tester) async {
      await tester.pumpApp(
        FlashcardSwipeCard(
          proposal: testProposal,
          onSwipeLeft: () {},
          onSwipeRight: () {},
          onEdit: () {},
        ),
      );

      expect(find.text('Test Front'), findsOneWidget);
      expect(find.text('Test Back'), findsNothing);
      expect(find.text('Front side (tap to flip)'), findsOneWidget);
    });

    testWidgets('flips to back side when tapped', (tester) async {
      await tester.pumpApp(
        FlashcardSwipeCard(
          proposal: testProposal,
          onSwipeLeft: () {},
          onSwipeRight: () {},
          onEdit: () {},
        ),
      );

      // Tap the card to flip
      await tester.tap(find.byType(Card));
      await tester.pump();

      expect(find.text('Test Back'), findsOneWidget);
      expect(find.text('Test Front'), findsNothing);
      expect(find.text('Back side'), findsOneWidget);
    });

    testWidgets('flips back to front when tapped again', (tester) async {
      await tester.pumpApp(
        FlashcardSwipeCard(
          proposal: testProposal,
          onSwipeLeft: () {},
          onSwipeRight: () {},
          onEdit: () {},
        ),
      );

      // Flip to back
      await tester.tap(find.byType(Card));
      await tester.pump();
      expect(find.text('Test Back'), findsOneWidget);

      // Flip back to front
      await tester.tap(find.byType(Card));
      await tester.pump();
      expect(find.text('Test Front'), findsOneWidget);
      expect(find.text('Front side (tap to flip)'), findsOneWidget);
    });

    testWidgets('displays action buttons', (tester) async {
      await tester.pumpApp(
        FlashcardSwipeCard(
          proposal: testProposal,
          onSwipeLeft: () {},
          onSwipeRight: () {},
          onEdit: () {},
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('calls onSwipeLeft when reject button is tapped', (
      tester,
    ) async {
      bool leftCalled = false;

      await tester.pumpApp(
        FlashcardSwipeCard(
          proposal: testProposal,
          onSwipeLeft: () => leftCalled = true,
          onSwipeRight: () {},
          onEdit: () {},
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(leftCalled, isTrue);
    });

    testWidgets('calls onSwipeRight when accept button is tapped', (
      tester,
    ) async {
      bool rightCalled = false;

      await tester.pumpApp(
        FlashcardSwipeCard(
          proposal: testProposal,
          onSwipeLeft: () {},
          onSwipeRight: () => rightCalled = true,
          onEdit: () {},
        ),
      );

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(rightCalled, isTrue);
    });

    testWidgets('calls onEdit when edit button is tapped', (tester) async {
      bool editCalled = false;

      await tester.pumpApp(
        FlashcardSwipeCard(
          proposal: testProposal,
          onSwipeLeft: () {},
          onSwipeRight: () {},
          onEdit: () => editCalled = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      expect(editCalled, isTrue);
    });

    testWidgets('displays Dismissible widget for swipe gestures', (
      tester,
    ) async {
      await tester.pumpApp(
        FlashcardSwipeCard(
          proposal: testProposal,
          onSwipeLeft: () {},
          onSwipeRight: () {},
          onEdit: () {},
        ),
      );

      expect(find.byType(Dismissible), findsOneWidget);
    });

    // Note: Swipe gesture tests omitted due to layout
    // complexities in test environment
    // Swipe functionality is tested in integration tests
  });
}
