import 'package:freezed_annotation/freezed_annotation.dart';

/// Custom JSON converter for DateTime to handle ISO 8601 serialization
///
/// Usage:
/// ```dart
/// @freezed
/// class MyModel with _$MyModel {
///   const factory MyModel({
///     @DateTimeConverter() required DateTime createdAt,
///   }) = _MyModel;
/// }
/// ```
class DateTimeConverter implements JsonConverter<DateTime, String> {
  const DateTimeConverter();

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}
