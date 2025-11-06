import 'package:freezed_annotation/freezed_annotation.dart';

part 'generation_model.freezed.dart';

/// Domain model for an AI generation session
///
/// Represents a completed or in-progress flashcard generation session.
@freezed
abstract class GenerationModel with _$GenerationModel {
  const factory GenerationModel({
    required String id,
    required String userId,
    required String model,
    required String sourceTextHash,
    required int sourceTextLength,
    required int generatedCount,
    required int generationDuration,
    required DateTime createdAt,
    int? acceptedUneditedCount,
    int? acceptedEditedCount,
  }) = _GenerationModel;
}
