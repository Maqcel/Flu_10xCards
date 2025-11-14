import 'package:envied/envied.dart';

part 'env.g.dart';

// Development environment
@Envied(path: '.env.development', name: 'DevelopmentEnv', obfuscate: true)
abstract class DevelopmentEnv {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _DevelopmentEnv.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _DevelopmentEnv.supabaseAnonKey;

  @EnviedField(varName: 'OPENROUTER_API_KEY')
  static final String openRouterApiKey = _DevelopmentEnv.openRouterApiKey;
}

// Staging environment
@Envied(path: '.env.staging', name: 'StagingEnv', obfuscate: true)
abstract class StagingEnv {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _StagingEnv.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _StagingEnv.supabaseAnonKey;

  @EnviedField(varName: 'OPENROUTER_API_KEY')
  static final String openRouterApiKey = _StagingEnv.openRouterApiKey;
}

// Production environment
@Envied(path: '.env.production', name: 'ProductionEnv', obfuscate: true)
abstract class ProductionEnv {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _ProductionEnv.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _ProductionEnv.supabaseAnonKey;

  @EnviedField(varName: 'OPENROUTER_API_KEY')
  static final String openRouterApiKey = _ProductionEnv.openRouterApiKey;
}

// Unified Env class that selects the right environment
class Env {
  // Set this based on your flavor/build configuration
  // For development, set isDevelopment = true
  // For staging, set isStaging = true
  // For production, set both to false
  static const bool isDevelopment = true;
  static const bool isStaging = false;

  static String get supabaseUrl {
    if (isDevelopment) return DevelopmentEnv.supabaseUrl;
    if (isStaging) return StagingEnv.supabaseUrl;
    return ProductionEnv.supabaseUrl;
  }

  static String get supabaseAnonKey {
    if (isDevelopment) return DevelopmentEnv.supabaseAnonKey;
    if (isStaging) return StagingEnv.supabaseAnonKey;
    return ProductionEnv.supabaseAnonKey;
  }

  static String get openRouterApiKey {
    if (isDevelopment) return DevelopmentEnv.openRouterApiKey;
    if (isStaging) return StagingEnv.openRouterApiKey;
    return ProductionEnv.openRouterApiKey;
  }
}
