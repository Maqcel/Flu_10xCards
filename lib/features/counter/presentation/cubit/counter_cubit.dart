import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:xcards/features/counter/domain/model/counter_model.dart';

part 'counter_state.dart';
part 'counter_cubit.freezed.dart';

@injectable
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(const CounterState.initial());

  void increment() {
    state.when(
      initial: () => emit(const CounterState.data(CounterModel(count: 1))),
      data: (model) =>
          emit(CounterState.data(CounterModel(count: model.count + 1))),
    );
  }

  void decrement() {
    state.when(
      initial: () => emit(const CounterState.data(CounterModel(count: -1))),
      data: (model) =>
          emit(CounterState.data(CounterModel(count: model.count - 1))),
    );
  }

  void reset() => emit(const CounterState.initial());
}
