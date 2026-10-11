import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_result.dart';
import '../models/trip_model.dart';

/// Contract for remote cloud synchronization data source.
abstract class IRemoteDataSource {
  bool get isAvailable;
  Future<ApiResult<bool>> syncTrip(TripModel trip);
  Future<ApiResult<int>> syncAllUnsynced(
    List<TripModel> trips,
    void Function(String id) onSynced,
  );
}

/// Supabase implementation of [IRemoteDataSource].
class SupabaseRemoteDataSource implements IRemoteDataSource {
  final AppConfig config;
  bool _isInitialized = false;

  SupabaseRemoteDataSource({required this.config});

  @override
  bool get isAvailable => _isInitialized && config.isSupabaseConfigured;

  /// Initializes Supabase client with given credentials.
  Future<void> initialize({String? url, String? anonKey}) async {
    final activeUrl = url ?? config.supabaseUrl;
    final activeKey = anonKey ?? config.supabaseAnonKey;

    if (activeUrl.trim().isNotEmpty && activeKey.trim().isNotEmpty) {
      try {
        await Supabase.initialize(url: activeUrl, anonKey: activeKey);
        _isInitialized = true;
      } catch (e) {
        debugPrint('[SupabaseRemoteDataSource] Init failed: $e');
        _isInitialized = false;
      }
    }
  }

  @override
  Future<ApiResult<bool>> syncTrip(TripModel trip) async {
    if (!isAvailable) {
      return ApiResult.failure(
        const ApiFailure('Supabase is not configured or offline', code: 'UNCONFIGURED'),
      );
    }

    try {
      final client = Supabase.instance.client;
      await client.from('trips').upsert(trip.toSupabaseMap());
      return ApiResult.success(true);
    } catch (e) {
      debugPrint('[SupabaseRemoteDataSource] Error syncing trip: $e');
      return ApiResult.failure(
        ApiFailure('Failed to sync trip to Supabase: $e', code: 'SYNC_ERROR'),
      );
    }
  }

  @override
  Future<ApiResult<int>> syncAllUnsynced(
    List<TripModel> trips,
    void Function(String id) onSynced,
  ) async {
    if (!isAvailable) {
      return ApiResult.failure(
        const ApiFailure('Supabase is not configured or offline', code: 'UNCONFIGURED'),
      );
    }

    int syncedCount = 0;
    for (final trip in trips) {
      if (!trip.isSynced) {
        final result = await syncTrip(trip);
        if (result.isSuccess) {
          onSynced(trip.id);
          syncedCount++;
        }
      }
    }
    return ApiResult.success(syncedCount);
  }
}
