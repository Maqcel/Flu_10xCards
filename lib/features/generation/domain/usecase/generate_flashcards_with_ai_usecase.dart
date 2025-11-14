import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_message.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_model_config.dart';
import 'package:xcards/features/ai_integration/domain/usecase/generate_with_ai_usecase.dart';
import 'package:xcards/features/generation/domain/repository/generation_repository.dart';

/// Use case for generating flashcards using AI
///
/// This use case orchestrates AI generation of flashcards from source text.
/// It handles prompt engineering, JSON schema definition, parsing of AI responses,
/// and creating generation records for tracking and analytics.
@injectable
class GenerateFlashcardsWithAiUseCase {
  GenerateFlashcardsWithAiUseCase(
    this._generateWithAi,
    this._generationRepository,
  );

  final GenerateWithAiUseCase _generateWithAi;
  final GenerationRepository _generationRepository;

  /// Generate flashcards from source text using AI
  ///
  /// [sourceText] - The text to generate flashcards from (1,000-10,000 chars)
  /// [targetCount] - Number of flashcards to generate (default: 10)
  /// [additionalContext] - Optional additional context for generation
  ///
  /// Returns Either:
  /// - Left(AppFailure) if generation failed
  /// - Right((generationId, flashcards)) if generation succeeded
  ///   where generationId is the UUID of the created generation record
  Future<Either<AppFailure, (String, List<FlashcardProposalEntity>)>> call({
    required String sourceText,
    int targetCount = 10,
    String? additionalContext,
  }) async {
    // Start measuring generation time
    final stopwatch = Stopwatch()..start();
    // Validate input
    if (sourceText.length < 1000 || sourceText.length > 10000) {
      const failure = AppFailure.validation(
        message: 'Source text must be between 1,000 and 10,000 characters',
      );
      // Log validation error (fire and forget)
      await _generationRepository.logGenerationError(
        model: AiModelConfig.deepseekChimeraFree.modelId,
        sourceText: sourceText,
        failure: failure,
      );
      return const Left(failure);
    }

    if (targetCount < 5 || targetCount > 20) {
      const failure = AppFailure.validation(
        message: 'Target count must be between 5 and 20',
      );
      // Log validation error (fire and forget)
      await _generationRepository.logGenerationError(
        model: AiModelConfig.deepseekChimeraFree.modelId,
        sourceText: sourceText,
        failure: failure,
      );
      return const Left(failure);
    }

    // Build messages
    final messages = [
      AiMessage(role: AiMessageRole.system, content: _buildSystemPrompt()),
      AiMessage(
        role: AiMessageRole.user,
        content: _buildUserPrompt(sourceText, targetCount, additionalContext),
      ),
    ];

    // Configure with JSON Schema for structured output
    // Using DeepSeek Chimera (free model) as default
    final config = AiModelConfig.deepseekChimeraFree.copyWith(
      responseFormat: _buildFlashcardsJsonSchema(),
    );

    // Call AI
    final result = await _generateWithAi(messages: messages, config: config);

    // Stop measuring time
    stopwatch.stop();
    final generationDuration = stopwatch.elapsedMilliseconds;

    // If AI generation failed, log error and return
    if (result.isLeft()) {
      final failure = result.fold(
        (f) => f,
        (_) => throw StateError('Unreachable'),
      );

      // Log AI generation error (fire and forget)
      await _generationRepository.logGenerationError(
        model: config.modelId,
        sourceText: sourceText,
        failure: failure,
      );

      return Left(failure);
    }

    // Extract AI response
    final aiResponse = result.getOrElse(() => throw StateError('Unreachable'));

    // Parse flashcards from AI response
    final flashcardsResult = _parseFlashcardsFromResponse(aiResponse.content);

    // If parsing failed, log error and return
    if (flashcardsResult.isLeft()) {
      final failure = flashcardsResult.fold(
        (f) => f,
        (_) => throw StateError('Unreachable'),
      );

      // Log parsing error (fire and forget)
      await _generationRepository.logGenerationError(
        model: config.modelId,
        sourceText: sourceText,
        failure: failure,
      );

      return Left(failure);
    }

    // Extract flashcards
    final flashcards = flashcardsResult.getOrElse(
      () => throw StateError('Unreachable'),
    );

    // Extract generationId from OpenRouter metadata
    final generationId = aiResponse.id;

    // Create generation record in database
    final generationResult = await _generationRepository.createGenerationRecord(
      generationId: generationId,
      model: config.modelId,
      sourceText: sourceText,
      generatedCount: flashcards.length,
      generationDuration: generationDuration,
    );

    // If creating generation record failed, log error and return
    if (generationResult.isLeft()) {
      final failure = generationResult.fold(
        (f) => f,
        (_) => throw StateError('Unreachable'),
      );

      // Log database error (fire and forget)
      // Note: This is a database issue, not AI issue, but we still log it
      await _generationRepository.logGenerationError(
        model: config.modelId,
        sourceText: sourceText,
        failure: failure,
      );

      return Left(failure);
    }

    // Return success with tuple of (generationId, flashcards)
    return Right((generationId, flashcards));
  }

  /// Build system prompt for AI
  String _buildSystemPrompt() {
    return '''
You are an expert educational content creator specializing in creating effective flashcards for spaced repetition learning.

Your task is to generate high-quality flashcards that:
- Follow the minimum information principle (one concept per card)
- Use clear, concise language
- Include mnemonics when helpful
- Vary question formats for better retention
- Are appropriately structured for learning

Generate flashcards in Polish language unless the source text is clearly in another language.

IMPORTANT: You must respond ONLY with valid JSON matching the provided schema. Do not include any explanatory text before or after the JSON.
''';
  }

  /// Build user prompt for AI
  String _buildUserPrompt(
    String sourceText,
    int targetCount,
    String? additionalContext,
  ) {
    final buffer = StringBuffer()
      ..writeln(
        'Generate exactly $targetCount flashcards from the following text:',
      )
      ..writeln()
      ..writeln('--- SOURCE TEXT ---')
      ..writeln(sourceText)
      ..writeln('--- END SOURCE TEXT ---');

    if (additionalContext != null && additionalContext.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Additional context:')
        ..writeln(additionalContext);
    }

    buffer
      ..writeln()
      ..writeln('Requirements:')
      ..writeln('- Create exactly $targetCount flashcards')
      ..writeln('- Each flashcard must have a clear question/prompt (front)')
      ..writeln('- Each flashcard must have a complete answer (back)')
      ..writeln('- Cover the most important concepts from the text')
      ..writeln('- Ensure diversity in question formats')
      ..writeln('- Use the same language as the source text')
      ..writeln()
      ..writeln('Return the result as JSON matching the provided schema.');

    return buffer.toString();
  }

  /// Build JSON Schema for structured outputs
  ///
  /// This schema ensures AI returns properly formatted flashcards
  Map<String, dynamic> _buildFlashcardsJsonSchema() {
    return {
      'type': 'json_schema',
      'json_schema': {
        'name': 'flashcards_generation',
        'strict': true,
        'schema': {
          'type': 'object',
          'properties': {
            'flashcards': {
              'type': 'array',
              'description': 'Array of generated flashcards',
              'items': {
                'type': 'object',
                'properties': {
                  'front': {
                    'type': 'string',
                    'description':
                        'The question or prompt side of the flashcard',
                  },
                  'back': {
                    'type': 'string',
                    'description':
                        'The answer or explanation side of the flashcard',
                  },
                },
                'required': ['front', 'back'],
                'additionalProperties': false,
              },
            },
          },
          'required': ['flashcards'],
          'additionalProperties': false,
        },
      },
    };
  }

  /// Parse flashcards from AI response
  Either<AppFailure, List<FlashcardProposalEntity>>
  _parseFlashcardsFromResponse(String content) {
    try {
      final json = jsonDecode(content) as Map<String, dynamic>;
      final flashcardsJson = json['flashcards'] as List<dynamic>?;

      if (flashcardsJson == null || flashcardsJson.isEmpty) {
        return const Left(
          AppFailure.aiInvalidResponse(
            message: 'No flashcards returned in AI response',
          ),
        );
      }

      final flashcards = flashcardsJson
          .map(
            (e) => FlashcardProposalEntity.fromJson(e as Map<String, dynamic>),
          )
          .toList();

      // Validate that all flashcards have non-empty front and back
      final allValid = flashcards.every(
        (f) => f.front.trim().isNotEmpty && f.back.trim().isNotEmpty,
      );

      if (!allValid) {
        return const Left(
          AppFailure.aiInvalidResponse(
            message: 'Some flashcards have empty front or back',
          ),
        );
      }

      return Right(flashcards);
    } on FormatException catch (e) {
      return Left(
        AppFailure.aiInvalidResponse(
          message: 'Failed to parse AI response as JSON: ${e.message}',
        ),
      );
    } catch (e) {
      return Left(
        AppFailure.aiInvalidResponse(message: 'Failed to parse flashcards: $e'),
      );
    }
  }
}
