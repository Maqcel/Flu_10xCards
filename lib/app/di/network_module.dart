import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:xcards/app/config/env.dart';
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
}
