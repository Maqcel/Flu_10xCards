part of 'counter_cubit.dart';

@freezed
abstract class CounterState with _$CounterState {
  const factory CounterState.initial() = _Initial;
  const factory CounterState.data(CounterModel model) = _Data;
}
