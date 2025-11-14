import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:xcards/features/ai_integration/data/dto/openrouter_request_dto.dart';
import 'package:xcards/features/ai_integration/data/dto/openrouter_response_dto.dart';

part 'openrouter_data_source.g.dart';

/// Data source for OpenRouter AI API
@RestApi(baseUrl: 'https://openrouter.ai/api/v1')
abstract class OpenRouterDataSource {
  factory OpenRouterDataSource(Dio dio, {String baseUrl}) =
      _OpenRouterDataSource;

  @POST('/chat/completions')
  @Header('Content-Type: application/json')
  Future<OpenRouterResponseDto> createChatCompletion(
    @Body() OpenRouterRequestDto request,
  );
}
