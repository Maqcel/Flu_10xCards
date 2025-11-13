import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:xcards/app/networking/entities/requests/create_flashcard_request_entity.dart';
import 'package:xcards/app/networking/entities/requests/generate_flashcards_request_entity.dart';
import 'package:xcards/features/generation/data/dto/generation_response_dto.dart';
import 'package:xcards/features/generation/data/dto/update_generation_stats_dto.dart';

part 'generation_service_data_source.g.dart';

@RestApi()
abstract class GenerationServiceDataSource {
  factory GenerationServiceDataSource(Dio dio, {String baseUrl}) =
      _GenerationServiceDataSource;

  @POST('/rpc/generate_flashcards')
  Future<GenerationResponseDto> generate(
    @Body() GenerateFlashcardsRequestEntity body,
  );

  @POST('/rest/v1/flashcards')
  Future<void> batchInsert(@Body() List<CreateFlashcardRequestEntity> body);

  @PATCH('/rest/v1/generations')
  Future<void> updateStats(
    @Query('id') String idEquals,
    @Body() UpdateGenerationStatsDto body,
  );
}
