import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/features/ai_integration/data/service/openrouter_service.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_message.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_model_config.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_response.dart';

/// Use case for generating AI responses
///
/// This use case orchestrates AI generation requests through OpenRouter service.
/// It handles message formatting, model configuration, and error handling.
@injectable
class GenerateWithAiUseCase {
  GenerateWithAiUseCase(this._service);

  final OpenRouterService _service;

  /// Generate AI response from messages
  ///
  /// [messages] - List of messages to send to AI (system, user, assistant)
  /// [config] - Model configuration (defaults to deepseekChimeraFree if not provided)
  ///
  /// Returns Either:
  /// - Left(AppFailure) if generation failed
  /// - Right(AiResponse) if generation succeeded
  ///
  /// Example usage:
  /// ```dart
  /// final result = await generateWithAi(
  ///   messages: [
  ///     AiMessage(role: AiMessageRole.system, content: 'You are a helpful assistant'),
  ///     AiMessage(role: AiMessageRole.user, content: 'Generate flashcards'),
  ///   ],
  ///   config: AiModelConfig.deepseekChimeraFree, // Free model
  /// );
  /// ```
  Future<Either<AppFailure, AiResponse>> call({
    required List<AiMessage> messages,
    AiModelConfig? config,
  }) async {
    // Validate messages
    if (messages.isEmpty) {
      return const Left(
        AppFailure.validation(message: 'Messages list cannot be empty'),
      );
    }

    // Use default config if not provided (DeepSeek Chimera - free model)
    final modelConfig = config ?? AiModelConfig.deepseekChimeraFree;

    // Delegate to service
    return _service.generateResponse(messages: messages, config: modelConfig);
  }
}
