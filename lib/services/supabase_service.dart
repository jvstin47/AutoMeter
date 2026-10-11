import 'package:flutter/foundation.dart';
import '../core/config/env_config.dart';
import '../data/datasources/remote_datasource.dart';
import '../data/models/trip_model.dart';
import '../core/config/app_config.dart';

/// Service facade for Supabase database operations.
/// Leverages [EnvConfig] and [SupabaseRemoteDataSource].
class SupabaseService {
  static SupabaseRemoteDataSource? _remoteDataSource;

  static bool get isConfigured =>
      _remoteDataSource != null && _remoteDataSource!.isAvailable;

  static Future<void> initialize({String? url, String? anonKey}) async {
    final effectiveUrl = url ?? EnvConfig.supabaseUrl;
    final effectiveKey = anonKey ?? EnvConfig.supabaseAnonKey;

    if (effectiveUrl.isNotEmpty && effectiveKey.isNotEmpty) {
      final config = AppConfig(
        environment: EnvConfig.environment,
        supabaseUrl: effectiveUrl,
        supabaseAnonKey: effectiveKey,
        apiBaseUrl: EnvConfig.apiBaseUrl,
        apiTimeout: Duration(milliseconds: EnvConfig.apiTimeoutMs),
        enableDebugLogs: EnvConfig.enableDebugLogs,
      );
      _remoteDataSource = SupabaseRemoteDataSource(config: config);
      await _remoteDataSource!.initialize(url: effectiveUrl, anonKey: effectiveKey);
    }
  }

  /// Syncs a single trip to Supabase
  static Future<bool> syncTrip(TripModel trip) async {
    if (_remoteDataSource == null || !_remoteDataSource!.isAvailable) {
      return false;
    }
    final result = await _remoteDataSource!.syncTrip(trip);
    return result.isSuccess;
  }

  /// Syncs all un-synced trips
  static Future<int> syncAllUnsynced(
    List<TripModel> trips,
    void Function(String id) onSynced,
  ) async {
    if (_remoteDataSource == null || !_remoteDataSource!.isAvailable) {
      return 0;
    }
    final result = await _remoteDataSource!.syncAllUnsynced(trips, onSynced);
    return result.getOrElse(() => 0);
  }
}
