import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xcards/features/counter/domain/model/counter_model.dart';
import 'package:xcards/features/counter/presentation/cubit/counter_cubit.dart';

void main() {
  group('CounterCubit', () {
    late CounterCubit cubit;

    setUp(() {
      cubit = CounterCubit();
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is CounterState.initial()', () {
      expect(cubit.state, equals(const CounterState.initial()));
    });

    group('increment', () {
      blocTest<CounterCubit, CounterState>(
        'emits [data(count: 1)] when called from initial state',
        build: () => cubit,
        act: (cubit) => cubit.increment(),
        expect: () => [const CounterState.data(CounterModel(count: 1))],
      );

      blocTest<CounterCubit, CounterState>(
        'emits [data(count: 6)] when called from data state with count 5',
        build: () => cubit,
        seed: () => const CounterState.data(CounterModel(count: 5)),
        act: (cubit) => cubit.increment(),
        expect: () => [const CounterState.data(CounterModel(count: 6))],
      );

      blocTest<CounterCubit, CounterState>(
        'emits [data(count: 1)] when called from data state with count 0',
        build: () => cubit,
        seed: () => const CounterState.data(CounterModel(count: 0)),
        act: (cubit) => cubit.increment(),
        expect: () => [const CounterState.data(CounterModel(count: 1))],
      );

      blocTest<CounterCubit, CounterState>(
        'emits [data(count: 0)] when called from data state with count -1',
        build: () => cubit,
        seed: () => const CounterState.data(CounterModel(count: -1)),
        act: (cubit) => cubit.increment(),
        expect: () => [const CounterState.data(CounterModel(count: 0))],
      );

      blocTest<CounterCubit, CounterState>(
        'increments multiple times correctly',
        build: () => cubit,
        act: (cubit) {
          cubit
            ..increment()
            ..increment()
            ..increment();
        },
        expect: () => [
          const CounterState.data(CounterModel(count: 1)),
          const CounterState.data(CounterModel(count: 2)),
          const CounterState.data(CounterModel(count: 3)),
        ],
      );
    });

    group('decrement', () {
      blocTest<CounterCubit, CounterState>(
        'emits [data(count: -1)] when called from initial state',
        build: () => cubit,
        act: (cubit) => cubit.decrement(),
        expect: () => [const CounterState.data(CounterModel(count: -1))],
      );

      blocTest<CounterCubit, CounterState>(
        'emits [data(count: 4)] when called from data state with count 5',
        build: () => cubit,
        seed: () => const CounterState.data(CounterModel(count: 5)),
        act: (cubit) => cubit.decrement(),
        expect: () => [const CounterState.data(CounterModel(count: 4))],
      );

      blocTest<CounterCubit, CounterState>(
        'emits [data(count: -1)] when called from data state with count 0',
        build: () => cubit,
        seed: () => const CounterState.data(CounterModel(count: 0)),
        act: (cubit) => cubit.decrement(),
        expect: () => [const CounterState.data(CounterModel(count: -1))],
      );

      blocTest<CounterCubit, CounterState>(
        'decrements multiple times correctly',
        build: () => cubit,
        act: (cubit) {
          cubit
            ..decrement()
            ..decrement()
            ..decrement();
        },
        expect: () => [
          const CounterState.data(CounterModel(count: -1)),
          const CounterState.data(CounterModel(count: -2)),
          const CounterState.data(CounterModel(count: -3)),
        ],
      );
    });

    group('reset', () {
      blocTest<CounterCubit, CounterState>(
        'emits [initial] when called from data state',
        build: () => cubit,
        seed: () => const CounterState.data(CounterModel(count: 42)),
        act: (cubit) => cubit.reset(),
        expect: () => [const CounterState.initial()],
      );

      blocTest<CounterCubit, CounterState>(
        'emits [initial] when called from initial state',
        build: () => cubit,
        act: (cubit) => cubit.reset(),
        expect: () => [const CounterState.initial()],
      );

      blocTest<CounterCubit, CounterState>(
        'resets after multiple increments',
        build: () => cubit,
        act: (cubit) {
          cubit
            ..increment()
            ..increment()
            ..increment()
            ..reset();
        },
        expect: () => [
          const CounterState.data(CounterModel(count: 1)),
          const CounterState.data(CounterModel(count: 2)),
          const CounterState.data(CounterModel(count: 3)),
          const CounterState.initial(),
        ],
      );
    });

    group('combined operations', () {
      blocTest<CounterCubit, CounterState>(
        'handles increment and decrement sequence correctly',
        build: () => cubit,
        act: (cubit) {
          cubit
            ..increment()
            ..increment()
            ..decrement();
        },
        expect: () => [
          const CounterState.data(CounterModel(count: 1)),
          const CounterState.data(CounterModel(count: 2)),
          const CounterState.data(CounterModel(count: 1)),
        ],
      );

      blocTest<CounterCubit, CounterState>(
        'handles decrement and increment sequence correctly',
        build: () => cubit,
        act: (cubit) {
          cubit
            ..decrement()
            ..decrement()
            ..increment();
        },
        expect: () => [
          const CounterState.data(CounterModel(count: -1)),
          const CounterState.data(CounterModel(count: -2)),
          const CounterState.data(CounterModel(count: -1)),
        ],
      );

      blocTest<CounterCubit, CounterState>(
        'handles increment, reset, and increment again',
        build: () => cubit,
        act: (cubit) {
          cubit
            ..increment()
            ..reset()
            ..increment();
        },
        expect: () => [
          const CounterState.data(CounterModel(count: 1)),
          const CounterState.initial(),
          const CounterState.data(CounterModel(count: 1)),
        ],
      );

      blocTest<CounterCubit, CounterState>(
        'reaches zero from positive number through decrements',
        build: () => cubit,
        seed: () => const CounterState.data(CounterModel(count: 2)),
        act: (cubit) {
          cubit
            ..decrement()
            ..decrement();
        },
        expect: () => [
          const CounterState.data(CounterModel(count: 1)),
          const CounterState.data(CounterModel(count: 0)),
        ],
      );

      blocTest<CounterCubit, CounterState>(
        'reaches zero from negative number through increments',
        build: () => cubit,
        seed: () => const CounterState.data(CounterModel(count: -2)),
        act: (cubit) {
          cubit
            ..increment()
            ..increment();
        },
        expect: () => [
          const CounterState.data(CounterModel(count: -1)),
          const CounterState.data(CounterModel(count: 0)),
        ],
      );
    });
  });
}
