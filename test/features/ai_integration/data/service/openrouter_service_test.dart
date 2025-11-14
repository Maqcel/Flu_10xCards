import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/features/ai_integration/data/data_source/openrouter_data_source.dart';
import 'package:xcards/features/ai_integration/data/dto/openrouter_request_dto.dart';
import 'package:xcards/features/ai_integration/data/dto/openrouter_response_dto.dart';
import 'package:xcards/features/ai_integration/data/service/openrouter_service.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_message.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_model_config.dart';

class MockOpenRouterDataSource extends Mock implements OpenRouterDataSource {}

class FakeOpenRouterRequestDto extends Fake implements OpenRouterRequestDto {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOpenRouterRequestDto());
  });

  group('OpenRouterService', () {
    late OpenRouterService service;
    late MockOpenRouterDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockOpenRouterDataSource();
      service = OpenRouterServiceImpl(mockDataSource);
    });

    group('generateResponse', () {
      final testMessages = [
        const AiMessage(role: AiMessageRole.system, content: 'You are helpful'),
        const AiMessage(role: AiMessageRole.user, content: 'Hello'),
      ];

      const testConfig = AiModelConfig.deepseekChimeraFree;

      test('returns AiResponse when API call succeeds', () async {
        // Arrange
        final responseDto = OpenRouterResponseDto(
          id: 'test-id',
          model: 'openai/gpt-4o-mini',
          choices: [
            ChoiceDto(
              index: 0,
              message: MessageDto(role: 'assistant', content: 'Hello there!'),
              finishReason: 'stop',
            ),
          ],
          usage: UsageDto(
            promptTokens: 10,
            completionTokens: 20,
            totalTokens: 30,
          ),
          created: 1234567890,
        );

        when(
          () => mockDataSource.createChatCompletion(any()),
        ).thenAnswer((_) async => responseDto);

        // Act
        final result = await service.generateResponse(
          messages: testMessages,
          config: testConfig,
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((l) => fail('Should return Right'), (r) {
          expect(r.id, 'test-id');
          expect(r.content, 'Hello there!');
          expect(r.model, 'openai/gpt-4o-mini');
          expect(r.usage.promptTokens, 10);
          expect(r.usage.completionTokens, 20);
          expect(r.usage.totalTokens, 30);
        });

        verify(() => mockDataSource.createChatCompletion(any())).called(1);
      });

      test('returns aiInvalidResponse when choices array is empty', () async {
        // Arrange
        final responseDto = OpenRouterResponseDto(
          id: 'test-id',
          model: 'openai/gpt-4o-mini',
          choices: [], // Empty choices
          usage: UsageDto(
            promptTokens: 10,
            completionTokens: 20,
            totalTokens: 30,
          ),
          created: 1234567890,
        );

        when(
          () => mockDataSource.createChatCompletion(any()),
        ).thenAnswer((_) async => responseDto);

        // Act
        final result = await service.generateResponse(
          messages: testMessages,
          config: testConfig,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure, isA<AppFailure>());
          failure.when(
            aiInvalidResponse: (message) {
              expect(message, contains('No choices returned'));
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

      test('handles 400 Bad Request error', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: {
              'error': {'message': 'Invalid request format'},
            },
          ),
        );

        when(
          () => mockDataSource.createChatCompletion(any()),
        ).thenThrow(dioException);

        // Act
        final result = await service.generateResponse(
          messages: testMessages,
          config: testConfig,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            aiInvalidResponse: (message) {
              expect(message, contains('Invalid request'));
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

      test('handles 401 Unauthorized error', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 401,
          ),
        );

        when(
          () => mockDataSource.createChatCompletion(any()),
        ).thenThrow(dioException);

        // Act
        final result = await service.generateResponse(
          messages: testMessages,
          config: testConfig,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            unauthorized: (message) {
              expect(message, contains('Invalid OpenRouter API key'));
            },
            network: (_) => fail('Wrong failure type'),
            server: (_) => fail('Wrong failure type'),
            validation: (_) => fail('Wrong failure type'),
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
      });

      test('handles 402 Insufficient Credits error', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 402,
          ),
        );

        when(
          () => mockDataSource.createChatCompletion(any()),
        ).thenThrow(dioException);

        // Act
        final result = await service.generateResponse(
          messages: testMessages,
          config: testConfig,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            aiInsufficientCredits: (message) {
              expect(message, contains('Insufficient credits'));
            },
            network: (_) => fail('Wrong failure type'),
            server: (_) => fail('Wrong failure type'),
            validation: (_) => fail('Wrong failure type'),
            unauthorized: (_) => fail('Wrong failure type'),
            notFound: (_) => fail('Wrong failure type'),
            cache: (_) => fail('Wrong failure type'),
            unexpected: (_) => fail('Wrong failure type'),
            aiRateLimitExceeded: (_) => fail('Wrong failure type'),
            aiModelUnavailable: (_, __) => fail('Wrong failure type'),
            aiInvalidResponse: (_) => fail('Wrong failure type'),
            aiTimeout: (_) => fail('Wrong failure type'),
          );
        }, (r) => fail('Should return Left'));
      });

      test('handles 429 Rate Limit Exceeded error', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 429,
          ),
        );

        when(
          () => mockDataSource.createChatCompletion(any()),
        ).thenThrow(dioException);

        // Act
        final result = await service.generateResponse(
          messages: testMessages,
          config: testConfig,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            aiRateLimitExceeded: (message) {
              expect(message, contains('Rate limit exceeded'));
            },
            network: (_) => fail('Wrong failure type'),
            server: (_) => fail('Wrong failure type'),
            validation: (_) => fail('Wrong failure type'),
            unauthorized: (_) => fail('Wrong failure type'),
            notFound: (_) => fail('Wrong failure type'),
            cache: (_) => fail('Wrong failure type'),
            unexpected: (_) => fail('Wrong failure type'),
            aiInsufficientCredits: (_) => fail('Wrong failure type'),
            aiModelUnavailable: (_, __) => fail('Wrong failure type'),
            aiInvalidResponse: (_) => fail('Wrong failure type'),
            aiTimeout: (_) => fail('Wrong failure type'),
          );
        }, (r) => fail('Should return Left'));
      });

      test('handles 503 Model Unavailable error', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(
            path: '/test',
            data: {'model': 'openai/gpt-4o-mini'},
          ),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 503,
          ),
        );

        when(
          () => mockDataSource.createChatCompletion(any()),
        ).thenThrow(dioException);

        // Act
        final result = await service.generateResponse(
          messages: testMessages,
          config: testConfig,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            aiModelUnavailable: (model, message) {
              expect(model, 'openai/gpt-4o-mini');
              expect(message, contains('unavailable'));
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
            aiInvalidResponse: (_) => fail('Wrong failure type'),
            aiTimeout: (_) => fail('Wrong failure type'),
          );
        }, (r) => fail('Should return Left'));
      });

      test('handles connection timeout error', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(
            path: '/test',
            receiveTimeout: const Duration(seconds: 60),
          ),
          type: DioExceptionType.receiveTimeout,
        );

        when(
          () => mockDataSource.createChatCompletion(any()),
        ).thenThrow(dioException);

        // Act
        final result = await service.generateResponse(
          messages: testMessages,
          config: testConfig,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            aiTimeout: (message) {
              expect(message, contains('timed out'));
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
            aiInvalidResponse: (_) => fail('Wrong failure type'),
          );
        }, (r) => fail('Should return Left'));
      });

      test('handles connection error', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/test'),
          type: DioExceptionType.connectionError,
          message: 'Connection failed',
        );

        when(
          () => mockDataSource.createChatCompletion(any()),
        ).thenThrow(dioException);

        // Act
        final result = await service.generateResponse(
          messages: testMessages,
          config: testConfig,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            network: (message) {
              expect(message, contains('Connection'));
            },
            server: (_) => fail('Wrong failure type'),
            validation: (_) => fail('Wrong failure type'),
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
      });

      test('handles unexpected error', () async {
        // Arrange
        when(
          () => mockDataSource.createChatCompletion(any()),
        ).thenThrow(Exception('Unexpected error'));

        // Act
        final result = await service.generateResponse(
          messages: testMessages,
          config: testConfig,
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold((failure) {
          failure.when(
            unexpected: (message) {
              expect(message, contains('Unexpected error'));
            },
            network: (_) => fail('Wrong failure type'),
            server: (_) => fail('Wrong failure type'),
            validation: (_) => fail('Wrong failure type'),
            unauthorized: (_) => fail('Wrong failure type'),
            notFound: (_) => fail('Wrong failure type'),
            cache: (_) => fail('Wrong failure type'),
            aiRateLimitExceeded: (_) => fail('Wrong failure type'),
            aiInsufficientCredits: (_) => fail('Wrong failure type'),
            aiModelUnavailable: (_, __) => fail('Wrong failure type'),
            aiInvalidResponse: (_) => fail('Wrong failure type'),
            aiTimeout: (_) => fail('Wrong failure type'),
          );
        }, (r) => fail('Should return Left'));
      });
    });
  });
}
