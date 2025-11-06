import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xcards/app/utils/date_time_converter.dart';

part 'generation_entity.freezed.dart';
part 'generation_entity.g.dart';

/// Generation entity matching the Supabase database schema
///
/// Stores AI generation logs for metrics and analytics
@freezed
abstract class GenerationEntity with _$GenerationEntity {
  const factory GenerationEntity({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String model,
    @JsonKey(name: 'source_text_hash') required String sourceTextHash,
    @JsonKey(name: 'source_text_length') required int sourceTextLength,
    @JsonKey(name: 'generated_count') required int generatedCount,
    @JsonKey(name: 'generation_duration') required int generationDuration,
    @JsonKey(name: 'created_at')
    @DateTimeConverter()
    required DateTime createdAt,
    @JsonKey(name: 'accepted_unedited_count') int? acceptedUneditedCount,
    @JsonKey(name: 'accepted_edited_count') int? acceptedEditedCount,
  }) = _GenerationEntity;

  factory GenerationEntity.fromJson(Map<String, dynamic> json) =>
      _$GenerationEntityFromJson(json);
}
