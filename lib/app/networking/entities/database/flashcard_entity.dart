import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xcards/app/utils/date_time_converter.dart';

part 'flashcard_entity.freezed.dart';
part 'flashcard_entity.g.dart';

/// Flashcard entity matching the Supabase database schema
///
/// Source values:
/// - 'ai-full': Accepted without edit
/// - 'ai-edited': Accepted after edit
/// - 'manual': Created manually
@freezed
abstract class FlashcardEntity with _$FlashcardEntity {
  const factory FlashcardEntity({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String front,
    required String back,
    required String source,
    @JsonKey(name: 'created_at')
    @DateTimeConverter()
    required DateTime createdAt,
    @JsonKey(name: 'updated_at')
    @DateTimeConverter()
    required DateTime updatedAt,
    @JsonKey(name: 'generation_id') String? generationId,
  }) = _FlashcardEntity;

  factory FlashcardEntity.fromJson(Map<String, dynamic> json) =>
      _$FlashcardEntityFromJson(json);
}
