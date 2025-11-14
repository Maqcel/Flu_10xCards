import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/features/ai_integration/data/data_source/openrouter_data_source.dart';
import 'package:xcards/features/ai_integration/data/dto/openrouter_message_dto.dart';
import 'package:xcards/features/ai_integration/data/dto/openrouter_request_dto.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_message.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_model_config.dart';
import 'package:xcards/features/ai_integration/domain/model/ai_response.dart';

/// Service for communicating with OpenRouter AI API
abstract class OpenRouterService {
  /// Generate AI response from messages
  Future<Either<AppFailure, AiResponse>> generateResponse({
    required List<AiMessage> messages,
    required AiModelConfig config,
  });
}

@LazySingleton(as: OpenRouterService)
class OpenRouterServiceImpl implements OpenRouterService {
  OpenRouterServiceImpl(this._dataSource);

  final OpenRouterDataSource _dataSource;

  @override
  Future<Either<AppFailure, AiResponse>> generateResponse({
    required List<AiMessage> messages,
    required AiModelConfig config,
  }) async {
    try {
      // Convert domain messages to DTOs
      final messageDtos = messages
          .map(
            (msg) => OpenRouterMessageDto(
              role: msg.role.toApiString(),
              content: msg.content,
            ),
          )
          .toList();

      // Build request DTO
      final request = OpenRouterRequestDto(
        model: config.modelId,
        messages: messageDtos,
        temperature: config.temperature,
        maxTokens: config.maxTokens,
        responseFormat: config.responseFormat,
      );

      // Call API
      final responseDto = await _dataSource.createChatCompletion(request);

      // Transform response DTO to domain model
      if (responseDto.choices.isEmpty) {
        return const Left(
          AppFailure.aiInvalidResponse(message: 'No choices returned from AI'),
        );
      }

      final choice = responseDto.choices.first;
      final aiResponse = AiResponse(
        id: responseDto.id,
        content: choice.message.content,
        model: responseDto.model,
        usage: AiUsage(
          promptTokens: responseDto.usage.promptTokens,
          completionTokens: responseDto.usage.completionTokens,
          totalTokens: responseDto.usage.totalTokens,
        ),
      );

      return Right(aiResponse);
    } on DioException catch (e) {
      return Left(_handleDioException(e));
    } catch (e) {
      return Left(AppFailure.unexpected(message: 'Unexpected error: $e'));
    }
  }

  /// Handle Dio exceptions and convert to AppFailure
  AppFailure _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;

    switch (statusCode) {
      case 400:
        return AppFailure.aiInvalidResponse(
          message:
              e.response?.data?['error']?['message'] as String? ??
              'Invalid request to AI API',
        );
      case 401:
        return AppFailure.unauthorized(message: 'Invalid OpenRouter API key');
      case 402:
        return AppFailure.aiInsufficientCredits(
          message: 'Insufficient credits in OpenRouter account',
        );
      case 429:
        return AppFailure.aiRateLimitExceeded(
          message: 'Rate limit exceeded. Please try again later.',
        );
      case 503:
        final model = e.requestOptions.data?['model'] as String? ?? 'unknown';
        return AppFailure.aiModelUnavailable(
          model: model,
          message: 'Model is currently unavailable',
        );
      default:
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout) {
          return AppFailure.aiTimeout(
            message:
                'Request timed out after ${e.requestOptions.receiveTimeout?.inSeconds ?? 60}s',
          );
        }

        if (e.type == DioExceptionType.connectionError) {
          return AppFailure.network(message: 'Connection error: ${e.message}');
        }

        return AppFailure.server(
          message:
              e.response?.data?['error']?['message'] as String? ??
              e.message ??
              'Server error',
        );
    }
  }
}
