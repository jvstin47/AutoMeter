import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip_model.dart';

class SupabaseService {
  // Default prototype placeholders or configurable credentials
  static String? supabaseUrl;
  static String? supabaseAnonKey;
  static bool _isInitialized = false;

  static bool get isConfigured =>
      supabaseUrl != null &&
      supabaseUrl!.isNotEmpty &&
      supabaseAnonKey != null &&
      supabaseAnonKey!.isNotEmpty;

  static Future<void> initialize({String? url, String? anonKey}) async {
    if (url != null && anonKey != null && url.isNotEmpty && anonKey.isNotEmpty) {
      supabaseUrl = url;
      supabaseAnonKey = anonKey;
      try {
        await Supabase.initialize(
          url: url,
          anonKey: anonKey,
        );
        _isInitialized = true;
      } catch (e) {
        debugPrint('Supabase init error: $e');
        _isInitialized = false;
      }
    }
  }

  /// Syncs a single trip to Supabase
  static Future<bool> syncTrip(TripModel trip) async {
    if (!_isInitialized) return false;
    try {
      final client = Supabase.instance.client;
      await client.from('trips').upsert(trip.toSupabaseMap());
      return true;
    } catch (e) {
      debugPrint('Error syncing trip to Supabase: $e');
      return false;
    }
  }

  /// Syncs all un-synced trips
  static Future<int> syncAllUnsynced(List<TripModel> trips, Function(String id) onSynced) async {
    if (!_isInitialized) return 0;
    int count = 0;
    for (final trip in trips) {
      if (!trip.isSynced) {
        final success = await syncTrip(trip);
        if (success) {
          onSynced(trip.id);
          count++;
        }
      }
    }
    return count;
  }
}
