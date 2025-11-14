import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/features/ai_integration/data/service/openrouter_service.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_message.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_model_config.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_response.dart';
import 'package:xcards/features/ai_integration/domain/usecase/generate_with_ai_usecase.dart';

class MockOpenRouterService extends Mock implements OpenRouterService {}

class FakeAiMessage extends Fake implements AiMessage {}

class FakeAiModelConfig extends Fake implements AiModelConfig {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAiMessage());
    registerFallbackValue(FakeAiModelConfig());
  });

  group('GenerateWithAiUseCase', () {
    late GenerateWithAiUseCase useCase;
    late MockOpenRouterService mockService;

    setUp(() {
      mockService = MockOpenRouterService();
      useCase = GenerateWithAiUseCase(mockService);
    });

    group('call', () {
      final testMessages = [
        const AiMessage(role: AiMessageRole.system, content: 'You are helpful'),
        const AiMessage(role: AiMessageRole.user, content: 'Hello'),
      ];

      const testResponse = AiResponse(
        id: 'test-id',
        content: 'Hello there!',
        model: 'openai/gpt-4o-mini',
        usage: AiUsage(promptTokens: 10, completionTokens: 20, totalTokens: 30),
      );

      test('returns AiResponse when service call succeeds', () async {
        // Arrange
        when(
          () => mockService.generateResponse(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) async => Right(testResponse));

        // Act
        final result = await useCase(
          messages: testMessages,
          config: AiModelConfig.gpt4oMini,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((l) => fail('Should return Right'), (r) {
          expect(r.id, 'test-id');
          expect(r.content, 'Hello there!');
          expect(r.model, 'openai/gpt-4o-mini');
        });

        verify(
          () => mockService.generateResponse(
            messages: testMessages,
            config: AiModelConfig.gpt4oMini,
          ),
        ).called(1);
      });

      test('uses default config when not provided', () async {
        // Arrange
        when(
          () => mockService.generateResponse(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) async => Right(testResponse));

        // Act
        await useCase(messages: testMessages);

        // Assert
        verify(
          () => mockService.generateResponse(
            messages: testMessages,
            config: AiModelConfig.deepseekChimeraFree, // Default config (free)
          ),
        ).called(1);
      });

      test('returns validation failure when messages list is empty', () async {
        // Act
        final result = await useCase(messages: []);

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<AppFailure>());
          failure.when(
            validation: (message) {
              expect(message, contains('cannot be empty'));
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
          () => mockService.generateResponse(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        );
      });

      test('forwards service failures', () async {
        // Arrange
        const testFailure = AppFailure.network(message: 'Network error');
        when(
          () => mockService.generateResponse(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) async => const Left(testFailure));

        // Act
        final result = await useCase(
          messages: testMessages,
          config: AiModelConfig.gpt4oMini,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, equals(testFailure));
        }, (r) => fail('Should return Left'));
      });

      test('works with different model configs', () async {
        // Arrange
        when(
          () => mockService.generateResponse(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) async => Right(testResponse));

        // Act
        await useCase(
          messages: testMessages,
          config: AiModelConfig.geminiFlashFree,
        );

        // Assert
        verify(
          () => mockService.generateResponse(
            messages: testMessages,
            config: AiModelConfig.geminiFlashFree,
          ),
        ).called(1);
      });

      test('works with custom config', () async {
        // Arrange
        const customConfig = AiModelConfig(
          modelId: 'custom/model',
          temperature: 0.5,
          maxTokens: 1000,
        );

        when(
          () => mockService.generateResponse(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) async => Right(testResponse));

        // Act
        await useCase(messages: testMessages, config: customConfig);

        // Assert
        verify(
          () => mockService.generateResponse(
            messages: testMessages,
            config: customConfig,
          ),
        ).called(1);
      });

      test('accepts messages with all role types', () async {
        // Arrange
        final messagesWithAllRoles = [
          const AiMessage(
            role: AiMessageRole.system,
            content: 'System message',
          ),
          const AiMessage(role: AiMessageRole.user, content: 'User message'),
          const AiMessage(
            role: AiMessageRole.assistant,
            content: 'Assistant message',
          ),
        ];

        when(
          () => mockService.generateResponse(
            messages: any(named: 'messages'),
            config: any(named: 'config'),
          ),
        ).thenAnswer((_) async => Right(testResponse));

        // Act
        final result = await useCase(messages: messagesWithAllRoles);

        // Assert
        expect(result.isRight(), true);
        verify(
          () => mockService.generateResponse(
            messages: messagesWithAllRoles,
            config: any(named: 'config'),
          ),
        ).called(1);
      });
    });
  });
}
