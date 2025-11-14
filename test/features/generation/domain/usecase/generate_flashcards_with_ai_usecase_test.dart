import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_message.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_model_config.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_response.dart';
import 'package:xcards/features/ai_integration/domain/usecase/generate_with_ai_usecase.dart';
import 'package:xcards/features/generation/domain/repository/generation_repository.dart';
import 'package:xcards/features/generation/domain/usecase/generate_flashcards_with_ai_usecase.dart';

class MockGenerateWithAiUseCase extends Mock implements GenerateWithAiUseCase {}

class MockGenerationRepository extends Mock implements GenerationRepository {}

class FakeAiMessage extends Fake implements AiMessage {}

class FakeAiModelConfig extends Fake implements AiModelConfig {}

class FakeAppFailure extends Fake implements AppFailure {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAiMessage());
    registerFallbackValue(FakeAiModelConfig());
    registerFallbackValue(FakeAppFailure());
  });

  group('GenerateFlashcardsWithAiUseCase', () {
    late GenerateFlashcardsWithAiUseCase useCase;
    late MockGenerateWithAiUseCase mockGenerateWithAi;
    late MockGenerationRepository mockGenerationRepository;

    setUp(() {
      mockGenerateWithAi = MockGenerateWithAiUseCase();
      mockGenerationRepository = MockGenerationRepository();
      useCase = GenerateFlashcardsWithAiUseCase(
        mockGenerateWithAi,
        mockGenerationRepository,
      );

      // Mock logGenerationError as fire-and-forget
      when(
        () => mockGenerationRepository.logGenerationError(
          model: any(named: 'model'),
          sourceText: any(named: 'sourceText'),
          failure: any(named: 'failure'),
        ),
      ).thenAnswer((_) async {});
    });

    group('call', () {
      final validSourceText = 'A' * 1500; // 1500 characters

      test('returns flashcards when AI response is valid JSON', () async {
        // Arrange
        const responseContent = '''
{
  "flashcards": [
    {
      "front": "What is Flutter?",
      "back": "A UI toolkit by Google"
    },
    {
      "front": "What is Dart?",
      "back": "A programming language for Flutter"
    }
  ]
}
''';

        const aiResponse = AiResponse(
          id: 'test-id',
          content: responseContent,
          model: 'openai/gpt-4o-mini',
          usage: AiUsage(
            promptTokens: 100,
            completionTokens: 50,
            totalTokens: 150,
          ),
        );

        when(
          () => mockGenerateWithAi(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) async => const Right(aiResponse));

        // Mock generation record creation
        when(
          () => mockGenerationRepository.createGenerationRecord(
            generationId: any(named: 'generationId'),
            model: any(named: 'model'),
            sourceText: any(named: 'sourceText'),
            generatedCount: any(named: 'generatedCount'),
            generationDuration: any(named: 'generationDuration'),
          ),
        ).thenAnswer((_) async => const Right(unit));

        // Act
        final result = await useCase(
          sourceText: validSourceText,
          targetCount: 10,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((l) => fail('Should return Right'), (record) {
          // Unpack tuple
          final (generationId, flashcards) = record;

          expect(generationId, 'test-generation-id');
          expect(flashcards.length, 2);
          expect(flashcards[0].front, 'What is Flutter?');
          expect(flashcards[0].back, 'A UI toolkit by Google');
          expect(flashcards[1].front, 'What is Dart?');
          expect(flashcards[1].back, 'A programming language for Flutter');
        });

        verify(
          () => mockGenerateWithAi(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        ).called(1);

        verify(
          () => mockGenerationRepository.createGenerationRecord(
            generationId: any(named: 'generationId'),
            model: any(named: 'model'),
            sourceText: validSourceText,
            generatedCount: 2,
            generationDuration: any(named: 'generationDuration'),
          ),
        ).called(1);
      });

      test('returns validation error when source text is too short', () async {
        // Arrange
        final shortText = 'A' * 500; // 500 characters (< 1000 minimum)

        // Act
        final result = await useCase(sourceText: shortText, targetCount: 10);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            validation: (message) {
              expect(message, contains('1,000 and 10,000'));
            },
            network: (_) => fail('Wrong failure type'),
            server: (_) => fail('Wrong failure type'),
            unauthorized: (_) => fail('Wrong failure type'),
            notFound: (_) => fail('Wrong failure type'),
            cache: (_) => fail('Wrong failure type'),
            unexpected: (_) => fail('Wrong failure type'),
            aiRateLimitExceeded: (_) => fail('Wrong failure type'),
            aiInsufficientCredits: (_) => fail('Wrong failure type'),
            aiModelUnavailable: (_, __) => fail('Wrong failure type'),
            aiInvalidResponse: (_) => fail('Wrong failure type'),
            aiTimeout: (_) => fail('Wrong failure type'),
          );
        }, (r) => fail('Should return Left'));

        verifyNever(
          () => mockGenerateWithAi(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        );
      });

      test('returns validation error when source text is too long', () async {
        // Arrange
        final longText = 'A' * 15000; // 15000 characters (> 10000 maximum)

        // Act
        final result = await useCase(sourceText: longText, targetCount: 10);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            validation: (message) {
              expect(message, contains('1,000 and 10,000'));
            },
            network: (_) => fail('Wrong failure type'),
            server: (_) => fail('Wrong failure type'),
            unauthorized: (_) => fail('Wrong failure type'),
            notFound: (_) => fail('Wrong failure type'),
            cache: (_) => fail('Wrong failure type'),
            unexpected: (_) => fail('Wrong failure type'),
            aiRateLimitExceeded: (_) => fail('Wrong failure type'),
            aiInsufficientCredits: (_) => fail('Wrong failure type'),
            aiModelUnavailable: (_, __) => fail('Wrong failure type'),
            aiInvalidResponse: (_) => fail('Wrong failure type'),
            aiTimeout: (_) => fail('Wrong failure type'),
          );
        }, (r) => fail('Should return Left'));

        verifyNever(
          () => mockGenerateWithAi(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        );
      });

      test('returns validation error when target count is too low', () async {
        // Act
        final result = await useCase(
          sourceText: validSourceText,
          targetCount: 3, // < 5 minimum
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            validation: (message) {
              expect(message, contains('between 5 and 20'));
            },
            network: (_) => fail('Wrong failure type'),
            server: (_) => fail('Wrong failure type'),
            unauthorized: (_) => fail('Wrong failure type'),
            notFound: (_) => fail('Wrong failure type'),
            cache: (_) => fail('Wrong failure type'),
            unexpected: (_) => fail('Wrong failure type'),
            aiRateLimitExceeded: (_) => fail('Wrong failure type'),
            aiInsufficientCredits: (_) => fail('Wrong failure type'),
            aiModelUnavailable: (_, __) => fail('Wrong failure type'),
            aiInvalidResponse: (_) => fail('Wrong failure type'),
            aiTimeout: (_) => fail('Wrong failure type'),
          );
        }, (r) => fail('Should return Left'));

        verifyNever(
          () => mockGenerateWithAi(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        );
      });

      test('returns validation error when target count is too high', () async {
        // Act
        final result = await useCase(
          sourceText: validSourceText,
          targetCount: 25, // > 20 maximum
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            validation: (message) {
              expect(message, contains('between 5 and 20'));
            },
            network: (_) => fail('Wrong failure type'),
            server: (_) => fail('Wrong failure type'),
            unauthorized: (_) => fail('Wrong failure type'),
            notFound: (_) => fail('Wrong failure type'),
            cache: (_) => fail('Wrong failure type'),
            unexpected: (_) => fail('Wrong failure type'),
            aiRateLimitExceeded: (_) => fail('Wrong failure type'),
            aiInsufficientCredits: (_) => fail('Wrong failure type'),
            aiModelUnavailable: (_, __) => fail('Wrong failure type'),
            aiInvalidResponse: (_) => fail('Wrong failure type'),
            aiTimeout: (_) => fail('Wrong failure type'),
          );
        }, (r) => fail('Should return Left'));

        verifyNever(
          () => mockGenerateWithAi(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        );
      });

      test('returns aiInvalidResponse when JSON is malformed', () async {
        // Arrange
        const responseContent = 'This is not valid JSON';

        const aiResponse = AiResponse(
          id: 'test-id',
          content: responseContent,
          model: 'openai/gpt-4o-mini',
          usage: AiUsage(
            promptTokens: 100,
            completionTokens: 50,
            totalTokens: 150,
          ),
        );

        when(
          () => mockGenerateWithAi(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) async => const Right(aiResponse));

        // Act
        final result = await useCase(
          sourceText: validSourceText,
          targetCount: 10,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            aiInvalidResponse: (message) {
              expect(message, contains('parse'));
            },
            network: (_) => fail('Wrong failure type'),
            server: (_) => fail('Wrong failure type'),
            validation: (_) => fail('Wrong failure type'),
            unauthorized: (_) => fail('Wrong failure type'),
            notFound: (_) => fail('Wrong failure type'),
            cache: (_) => fail('Wrong failure type'),
            unexpected: (_) => fail('Wrong failure type'),
            aiRateLimitExceeded: (_) => fail('Wrong failure type'),
            aiInsufficientCredits: (_) => fail('Wrong failure type'),
            aiModelUnavailable: (_, __) => fail('Wrong failure type'),
            aiTimeout: (_) => fail('Wrong failure type'),
          );
        }, (r) => fail('Should return Left'));
      });

      test(
        'returns aiInvalidResponse when flashcards array is empty',
        () async {
          // Arrange
          const responseContent = '''
{
  "flashcards": []
}
''';

          const aiResponse = AiResponse(
            id: 'test-id',
            content: responseContent,
            model: 'openai/gpt-4o-mini',
            usage: AiUsage(
              promptTokens: 100,
              completionTokens: 50,
              totalTokens: 150,
            ),
          );

          when(
            () => mockGenerateWithAi(
              messages: any(named: 'messages'),
              config: any(named: 'config'),
            ),
          ).thenAnswer((_) async => const Right(aiResponse));

          // Act
          final result = await useCase(
            sourceText: validSourceText,
            targetCount: 10,
          );

          // Assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            failure.when(
              aiInvalidResponse: (message) {
                expect(message, contains('No flashcards'));
              },
              network: (_) => fail('Wrong failure type'),
              server: (_) => fail('Wrong failure type'),
              validation: (_) => fail('Wrong failure type'),
              unauthorized: (_) => fail('Wrong failure type'),
              notFound: (_) => fail('Wrong failure type'),
              cache: (_) => fail('Wrong failure type'),
              unexpected: (_) => fail('Wrong failure type'),
              aiRateLimitExceeded: (_) => fail('Wrong failure type'),
              aiInsufficientCredits: (_) => fail('Wrong failure type'),
              aiModelUnavailable: (_, __) => fail('Wrong failure type'),
              aiTimeout: (_) => fail('Wrong failure type'),
            );
          }, (r) => fail('Should return Left'));
        },
      );

      test(
        'returns aiInvalidResponse when flashcard has empty front',
        () async {
          // Arrange
          const responseContent = '''
{
  "flashcards": [
    {
      "front": "",
      "back": "Some answer"
    }
  ]
}
''';

          const aiResponse = AiResponse(
            id: 'test-id',
            content: responseContent,
            model: 'openai/gpt-4o-mini',
            usage: AiUsage(
              promptTokens: 100,
              completionTokens: 50,
              totalTokens: 150,
            ),
          );

          when(
            () => mockGenerateWithAi(
              messages: any(named: 'messages'),
              config: any(named: 'config'),
            ),
          ).thenAnswer((_) async => const Right(aiResponse));

          // Act
          final result = await useCase(
            sourceText: validSourceText,
            targetCount: 10,
          );

          // Assert
          expect(result.isLeft(), true);
          result.fold((failure) {
            failure.when(
              aiInvalidResponse: (message) {
                expect(message, contains('empty'));
              },
              network: (_) => fail('Wrong failure type'),
              server: (_) => fail('Wrong failure type'),
              validation: (_) => fail('Wrong failure type'),
              unauthorized: (_) => fail('Wrong failure type'),
              notFound: (_) => fail('Wrong failure type'),
              cache: (_) => fail('Wrong failure type'),
              unexpected: (_) => fail('Wrong failure type'),
              aiRateLimitExceeded: (_) => fail('Wrong failure type'),
              aiInsufficientCredits: (_) => fail('Wrong failure type'),
              aiModelUnavailable: (_, __) => fail('Wrong failure type'),
              aiTimeout: (_) => fail('Wrong failure type'),
            );
          }, (r) => fail('Should return Left'));
        },
      );

      test('forwards AI service failures', () async {
        // Arrange
        const testFailure = AppFailure.network(message: 'Network error');
        when(
          () => mockGenerateWithAi(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) async => const Left(testFailure));

        // Act
        final result = await useCase(
          sourceText: validSourceText,
          targetCount: 10,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, equals(testFailure));
        }, (r) => fail('Should return Left'));
      });

      test('includes additional context in prompt when provided', () async {
        // Arrange
        const responseContent = '''
{
  "flashcards": [
    {
      "front": "Question",
      "back": "Answer"
    }
  ]
}
''';

        const aiResponse = AiResponse(
          id: 'test-id',
          content: responseContent,
          model: 'openai/gpt-4o-mini',
          usage: AiUsage(
            promptTokens: 100,
            completionTokens: 50,
            totalTokens: 150,
          ),
        );

        when(
          () => mockGenerateWithAi(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) async => const Right(aiResponse));

        // Mock generation record creation
        when(
          () => mockGenerationRepository.createGenerationRecord(
            generationId: any(named: 'generationId'),
            model: any(named: 'model'),
            sourceText: any(named: 'sourceText'),
            generatedCount: any(named: 'generatedCount'),
            generationDuration: any(named: 'generationDuration'),
          ),
        ).thenAnswer((_) async => const Right(unit));

        // Act
        await useCase(
          sourceText: validSourceText,
          targetCount: 10,
          additionalContext: 'Focus on technical details',
        );

        // Assert
        verify(
          () => mockGenerateWithAi(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        ).called(1);

        verify(
          () => mockGenerationRepository.createGenerationRecord(
            generationId: any(named: 'generationId'),
            model: any(named: 'model'),
            sourceText: validSourceText,
            generatedCount: 1,
            generationDuration: any(named: 'generationDuration'),
          ),
        ).called(1);
      });
    });
  });
}
