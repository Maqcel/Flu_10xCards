// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xcards/app/di/injection.dart';
import 'package:xcards/features/counter/domain/model/counter_model.dart';
import 'package:xcards/features/counter/presentation/cubit/counter_cubit.dart';
import 'package:xcards/features/counter/presentation/view/counter_page.dart';
import 'package:xcards/features/counter/presentation/view/counter_view.dart';

import '../../../../helpers/helpers.dart';

class MockCounterCubit extends MockCubit<CounterState>
    implements CounterCubit {}

void main() {
  group('CounterPage', () {
    late CounterCubit mockCounterCubit;

    setUp(() {
      mockCounterCubit = MockCounterCubit();
      getIt.registerFactory<CounterCubit>(() => mockCounterCubit);
    });

    tearDown(() async {
      await getIt.unregister<CounterCubit>();
    });

    testWidgets('renders CounterView', (tester) async {
      when(() => mockCounterCubit.state).thenReturn(CounterState.initial());
      await tester.pumpApp(CounterPage());
      expect(find.byType(CounterView), findsOneWidget);
    });
  });

  group('CounterView', () {
    late CounterCubit mockCounterCubit;

    setUp(() {
      mockCounterCubit = MockCounterCubit();
    });

    testWidgets('renders current count from initial state', (tester) async {
      when(() => mockCounterCubit.state).thenReturn(CounterState.initial());
      await tester.pumpApp(
        BlocProvider.value(value: mockCounterCubit, child: const CounterView()),
      );
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders current count from data state', (tester) async {
      const state = CounterState.data(CounterModel(count: 42));
      when(() => mockCounterCubit.state).thenReturn(state);
      await tester.pumpApp(
        BlocProvider.value(value: mockCounterCubit, child: const CounterView()),
      );
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('calls increment when increment button is tapped', (
      tester,
    ) async {
      when(() => mockCounterCubit.state).thenReturn(CounterState.initial());
      when(() => mockCounterCubit.increment()).thenReturn(null);
      await tester.pumpApp(
        BlocProvider.value(value: mockCounterCubit, child: const CounterView()),
      );
      await tester.tap(find.byIcon(Icons.add));
      verify(() => mockCounterCubit.increment()).called(1);
    });

    testWidgets('calls decrement when decrement button is tapped', (
      tester,
    ) async {
      when(() => mockCounterCubit.state).thenReturn(CounterState.initial());
      when(() => mockCounterCubit.decrement()).thenReturn(null);
      await tester.pumpApp(
        BlocProvider.value(value: mockCounterCubit, child: const CounterView()),
      );
      await tester.tap(find.byIcon(Icons.remove));
      verify(() => mockCounterCubit.decrement()).called(1);
    });
  });
}
