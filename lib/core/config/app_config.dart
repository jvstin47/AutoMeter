import 'env_config.dart';

/// Runtime application configuration singleton.
class AppConfig {
  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String apiBaseUrl;
  final Duration apiTimeout;
  final bool enableDebugLogs;

  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.apiBaseUrl,
    required this.apiTimeout,
    required this.enableDebugLogs,
  });

  /// Factory constructor initializing from [EnvConfig].
  factory AppConfig.fromEnvironment() {
    return AppConfig(
      environment: EnvConfig.environment,
      supabaseUrl: EnvConfig.supabaseUrl,
      supabaseAnonKey: EnvConfig.supabaseAnonKey,
      apiBaseUrl: EnvConfig.apiBaseUrl,
      apiTimeout: Duration(milliseconds: EnvConfig.apiTimeoutMs),
      enableDebugLogs: EnvConfig.enableDebugLogs,
    );
  }

  /// Default development configuration for local tests or fallback.
  factory AppConfig.development() {
    return const AppConfig(
      environment: AppEnvironment.development,
      supabaseUrl: '',
      supabaseAnonKey: '',
      apiBaseUrl: '',
      apiTimeout: Duration(seconds: 10),
      enableDebugLogs: true,
    );
  }

  bool get isSupabaseConfigured =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
}
