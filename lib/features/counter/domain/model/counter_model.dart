import 'package:freezed_annotation/freezed_annotation.dart';

part 'counter_model.freezed.dart';

/// Domain model for Counter feature
@freezed
abstract class CounterModel with _$CounterModel {
  const factory CounterModel({@Default(0) int count}) = _CounterModel;
}
