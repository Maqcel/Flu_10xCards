import 'package:json_annotation/json_annotation.dart';

part 'update_generation_stats_dto.g.dart';

@JsonSerializable()
class UpdateGenerationStatsDto {
  UpdateGenerationStatsDto({
    required this.acceptedUneditedCount,
    required this.acceptedEditedCount,
  });

  @JsonKey(name: 'accepted_unedited_count')
  final int acceptedUneditedCount;

  @JsonKey(name: 'accepted_edited_count')
  final int acceptedEditedCount;

  Map<String, dynamic> toJson() => _$UpdateGenerationStatsDtoToJson(this);
}
