import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_response.freezed.dart';

/// Domain model for AI response
@freezed
abstract class AiResponse with _$AiResponse {
  const factory AiResponse({
    required String id,
    required String content,
    required String model,
    required AiUsage usage,
  }) = _AiResponse;
}

/// Token usage information from AI response
@freezed
abstract class AiUsage with _$AiUsage {
  const factory AiUsage({
    required int promptTokens,
    required int completionTokens,
    required int totalTokens,
  }) = _AiUsage;
}
