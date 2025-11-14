import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xcards/features/generation/presentation/cubit/generation_cubit.dart';
import 'package:xcards/features/generation/presentation/widgets/step1_input_view.dart';

import '../../../../helpers/helpers.dart';

class MockGenerationCubit extends MockCubit<GenerationState>
    implements GenerationCubit {}

void main() {
  group('Step1InputView', () {
    late GenerationCubit mockGenerationCubit;

    setUp(() {
      mockGenerationCubit = MockGenerationCubit();
      when(() => mockGenerationCubit.state).thenReturn(const GenerationState());
    });

    testWidgets('renders TextField with hint text', (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step1InputView(),
        ),
      );

      expect(
        find.text('Paste your text here (1,000 - 10,000 characters)'),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('displays character counter', (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step1InputView(),
        ),
      );

      expect(find.textContaining('0 / 10,000 characters'), findsOneWidget);
    });

    testWidgets('displays minimum characters message when text is too short', (
      tester,
    ) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step1InputView(),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Short text');
      await tester.pump();

      expect(find.text('Minimum 1,000 characters required'), findsOneWidget);
    });

    testWidgets('hides minimum message when text is long enough', (
      tester,
    ) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step1InputView(),
        ),
      );

      final longText = List.filled(100, 'Valid text ').join();
      await tester.enterText(find.byType(TextField), longText);
      await tester.pump();

      expect(find.text('Minimum 1,000 characters required'), findsNothing);
    });

    testWidgets('generate button is disabled when text is too short', (
      tester,
    ) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step1InputView(),
        ),
      );

      final generateButton = find.widgetWithText(
        ElevatedButton,
        'Generate Flashcards',
      );
      expect(generateButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(generateButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('generate button is enabled when text length is valid', (
      tester,
    ) async {
      when(
        () => mockGenerationCubit.generateWithAI(text: any(named: 'text')),
      ).thenAnswer((_) async {});

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step1InputView(),
        ),
      );

      final validText = List.filled(100, 'Valid text ').join();
      await tester.enterText(find.byType(TextField), validText);
      await tester.pump();

      final generateButton = find.widgetWithText(
        ElevatedButton,
        'Generate Flashcards',
      );
      expect(generateButton, findsOneWidget);

      final button = tester.widget<ElevatedButton>(generateButton);
      expect(button.onPressed, isNotNull);
    });

    testWidgets('calls cubit.generate when button is tapped with valid text', (
      tester,
    ) async {
      final validText = List.filled(100, 'Valid text ').join();
      when(
        () => mockGenerationCubit.generateWithAI(text: any(named: 'text')),
      ).thenAnswer((_) async {});

      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step1InputView(),
        ),
      );

      await tester.enterText(find.byType(TextField), validText);
      await tester.pump();

      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Generate Flashcards'),
      );
      await tester.pump();

      verify(
        () => mockGenerationCubit.generateWithAI(text: any(named: 'text')),
      ).called(1);
    });

    testWidgets('character counter updates as user types', (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: mockGenerationCubit,
          child: const Step1InputView(),
        ),
      );

      expect(find.textContaining('0 / 10,000 characters'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Hello World');
      await tester.pump();

      expect(find.textContaining('11 / 10,000 characters'), findsOneWidget);
    });

    // Note: Text exceeding limit test omitted as TextField enforces maxLength
  });
}
