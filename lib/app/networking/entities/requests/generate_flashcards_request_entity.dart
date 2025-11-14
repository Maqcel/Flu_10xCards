import 'package:json_annotation/json_annotation.dart';

part 'generate_flashcards_request_entity.g.dart';

/// Request entity for generating flashcards from text
///
/// Used with: POST /generate_flashcards
@JsonSerializable()
class GenerateFlashcardsRequestEntity {
  const GenerateFlashcardsRequestEntity({
    required this.sourceText,
    this.targetCount = 10,
  });

  factory GenerateFlashcardsRequestEntity.fromJson(Map<String, dynamic> json) =>
      _$GenerateFlashcardsRequestEntityFromJson(json);

  /// Source text to generate flashcards from (1,000-10,000 characters)
  @JsonKey(name: 'source_text')
  final String sourceText;

  /// Target number of flashcards to generate (5-20)
  @JsonKey(name: 'target_count')
  final int targetCount;

  Map<String, dynamic> toJson() =>
      _$GenerateFlashcardsRequestEntityToJson(this);
}
