/// Application environment configuration.
/// Manages separation of environment variables from source code.
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment fromString(String env) {
    switch (env.toLowerCase().trim()) {
      case 'prod':
      case 'production':
        return AppEnvironment.production;
      case 'stage':
      case 'staging':
        return AppEnvironment.staging;
      case 'dev':
      case 'development':
      default:
        return AppEnvironment.development;
    }
  }
}

/// Centralized configuration parsed from environment variables (`--dart-define`).
class EnvConfig {
  /// Active environment name (default: development)
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  /// Supabase project URL for cloud sync
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase Anonymous Public Key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Optional custom API base URL for government transport backend or custom telemetry
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Request timeout in milliseconds (default: 10000ms / 10s)
  static const int apiTimeoutMs = int.fromEnvironment(
    'API_TIMEOUT_MS',
    defaultValue: 10000,
  );

  /// Enable or disable verbose debug logging
  static const bool enableDebugLogs = bool.fromEnvironment(
    'ENABLE_DEBUG_LOGS',
    defaultValue: true,
  );

  /// Parsed active environment enum
  static AppEnvironment get environment => AppEnvironment.fromString(appEnv);

  /// Whether Supabase credentials are provided and valid
  static bool get hasSupabaseCredentials =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  /// Whether we are running in production mode
  static bool get isProduction => environment == AppEnvironment.production;
}
