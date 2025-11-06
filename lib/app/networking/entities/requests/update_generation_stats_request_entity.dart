import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_generation_stats_request_entity.freezed.dart';
part 'update_generation_stats_request_entity.g.dart';

/// Request entity for updating generation acceptance statistics
///
/// Used with: PATCH /rest/v1/generations?id=eq.generation_id
@freezed
abstract class UpdateGenerationStatsRequestEntity
    with _$UpdateGenerationStatsRequestEntity {
  const factory UpdateGenerationStatsRequestEntity({
    /// Number of flashcards accepted without editing
    @JsonKey(name: 'accepted_unedited_count')
    required int acceptedUneditedCount,

    /// Number of flashcards accepted after editing
    @JsonKey(name: 'accepted_edited_count') required int acceptedEditedCount,
  }) = _UpdateGenerationStatsRequestEntity;

  factory UpdateGenerationStatsRequestEntity.fromJson(
    Map<String, dynamic> json,
  ) => _$UpdateGenerationStatsRequestEntityFromJson(json);
}
