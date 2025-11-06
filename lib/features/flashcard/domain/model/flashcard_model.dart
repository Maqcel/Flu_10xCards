import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xcards/app/networking/entities/utils/flashcard_source.dart';

part 'flashcard_model.freezed.dart';

/// Domain model for a flashcard
///
/// Represents a flashcard in the business logic layer.
/// This model is independent of database/API serialization concerns.
@freezed
abstract class FlashcardModel with _$FlashcardModel {
  const factory FlashcardModel({
    required String id,
    required String userId,
    required String front,
    required String back,
    required FlashcardSource source,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? generationId,
  }) = _FlashcardModel;
}
