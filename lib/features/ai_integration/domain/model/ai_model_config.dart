import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_model_config.freezed.dart';

/// Configuration for AI model requests
@freezed
abstract class AiModelConfig with _$AiModelConfig {
  const factory AiModelConfig({
    required String modelId,
    @Default(0.7) double temperature,
    @Default(2000) int maxTokens,
    Map<String, dynamic>? responseFormat,
  }) = _AiModelConfig;

  /// DeepSeek R1T2 Chimera (free tier) model configuration
  /// Free model with good quality for flashcard generation (default)
  static const deepseekChimeraFree = AiModelConfig(
    modelId: 'tngtech/deepseek-r1t2-chimera:free',
    temperature: 0.7,
    maxTokens: 2000,
  );

  /// OpenAI GPT-4o-mini model configuration
  /// Fast and cost-effective model for most use cases
  static const gpt4oMini = AiModelConfig(
    modelId: 'openai/gpt-4o-mini',
    temperature: 0.7,
    maxTokens: 2000,
  );

  /// Google Gemini Flash 1.5 (free tier) model configuration
  /// Free model with good performance
  static const geminiFlashFree = AiModelConfig(
    modelId: 'google/gemini-flash-1.5:free',
    temperature: 0.7,
    maxTokens: 2000,
  );

  /// OpenAI GPT-4o model configuration
  /// Most capable model for complex tasks
  static const gpt4o = AiModelConfig(
    modelId: 'openai/gpt-4o',
    temperature: 0.7,
    maxTokens: 2000,
  );

  /// Anthropic Claude 3.5 Sonnet model configuration
  /// Great for detailed and nuanced responses
  static const claude35Sonnet = AiModelConfig(
    modelId: 'anthropic/claude-3.5-sonnet',
    temperature: 0.7,
    maxTokens: 2000,
  );
}
