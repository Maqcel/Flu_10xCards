import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xcards/app/config/env.dart';

@module
abstract class SupabaseModule {
  @preResolve
  @LazySingleton()
  Future<SupabaseClient> provideSupabaseClient() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      storageOptions: const StorageClientOptions(retryAttempts: 3),
    );

    return Supabase.instance.client;
  }
}
