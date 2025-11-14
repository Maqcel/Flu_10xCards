import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xcards/app/config/env.dart';
import 'package:xcards/features/ai_integration/data/data_source/openrouter_data_source.dart';
import 'package:xcards/features/generation/data/data_source/generation_service_data_source.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.supabaseUrl,
        headers: {
          'apikey': Env.supabaseAnonKey,
          'Authorization': 'Bearer ${Env.supabaseAnonKey}',
        },
      ),
    );
    return dio;
  }

  @lazySingleton
  GenerationServiceDataSource generationRemote(Dio dio) =>
      GenerationServiceDataSource(dio);

  @lazySingleton
  @Named('openrouter')
  Dio openRouterDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://openrouter.ai/api/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Authorization': 'Bearer ${Env.openRouterApiKey}',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://10xcards.app',
          'X-Title': '10xCards',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
        error: true,
      ),
    );

    return dio;
  }

  @lazySingleton
  OpenRouterDataSource openRouterDataSource(@Named('openrouter') Dio dio) =>
      OpenRouterDataSource(dio);
}
