import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:xcards/app/networking/entities/requests/create_error_log_request_entity.dart';
import 'package:xcards/app/networking/entities/requests/create_flashcard_request_entity.dart';
import 'package:xcards/app/networking/entities/requests/create_generation_request_entity.dart';
import 'package:xcards/features/generation/data/dto/update_generation_stats_dto.dart';

part 'generation_service_data_source.g.dart';

@RestApi()
abstract class GenerationServiceDataSource {
  factory GenerationServiceDataSource(Dio dio, {String baseUrl}) =
      _GenerationServiceDataSource;

  @POST('/rest/v1/flashcards')
  @Header('Content-Type: application/json')
  Future<void> batchInsert(@Body() List<CreateFlashcardRequestEntity> body);

  @POST('/rest/v1/generations')
  @Header('Content-Type: application/json')
  Future<void> createGeneration(@Body() CreateGenerationRequestEntity body);

  @POST('/rest/v1/generation_error_logs')
  @Header('Content-Type: application/json')
  Future<void> createErrorLog(@Body() CreateErrorLogRequestEntity body);

  @PATCH('/rest/v1/generations')
  @Header('Content-Type: application/json')
  Future<void> updateStats(
    @Query('id') String idFilter,
    @Body() UpdateGenerationStatsDto body,
  );
}
