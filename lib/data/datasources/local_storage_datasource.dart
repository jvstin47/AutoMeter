import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/errors/app_exception.dart';
import '../models/driver_profile.dart';
import '../models/fare_config.dart';
import '../models/trip_model.dart';

/// Interface for local persistent data storage.
abstract class ILocalStorageDataSource {
  DriverProfile getDriverProfile();
  Future<void> saveDriverProfile(DriverProfile profile);

  FareConfig getFareConfig();
  Future<void> saveFareConfig(FareConfig config);

  bool isDemoMode();
  Future<void> setDemoMode(bool enabled);

  String getThemeMode();
  Future<void> saveThemeMode(String mode);

  List<TripModel> getTrips();
  Future<void> saveTrip(TripModel trip);
  Future<void> updateTripPayment({
    required String tripId,
    required String paymentMethod,
    required String paymentStatus,
    String? paymentReference,
  });
  Future<void> markTripSynced(String tripId);

  Future<void> saveActiveTripState(Map<String, dynamic>? state);
  Map<String, dynamic>? getActiveTripState();

  Future<void> resetDemoData();
}

/// SharedPreferences implementation of [ILocalStorageDataSource] with robust error handling.
class LocalStorageDataSource implements ILocalStorageDataSource {
  final SharedPreferences _prefs;

  LocalStorageDataSource(this._prefs);

  static Future<LocalStorageDataSource> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return LocalStorageDataSource(prefs);
    } catch (e) {
      throw StorageException('Failed to initialize SharedPreferences: $e');
    }
  }

  @override
  DriverProfile getDriverProfile() {
    final jsonStr = _prefs.getString(StorageKeys.driverProfile);
    if (jsonStr == null) return const DriverProfile();
    try {
      return DriverProfile.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      return const DriverProfile();
    }
  }

  @override
  Future<void> saveDriverProfile(DriverProfile profile) async {
    try {
      await _prefs.setString(StorageKeys.driverProfile, jsonEncode(profile.toJson()));
    } catch (e) {
      throw StorageException('Failed to save driver profile: $e');
    }
  }

  @override
  FareConfig getFareConfig() {
    final jsonStr = _prefs.getString(StorageKeys.fareConfig);
    if (jsonStr == null) return const FareConfig();
    try {
      return FareConfig.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      return const FareConfig();
    }
  }

  @override
  Future<void> saveFareConfig(FareConfig config) async {
    try {
      await _prefs.setString(StorageKeys.fareConfig, jsonEncode(config.toJson()));
    } catch (e) {
      throw StorageException('Failed to save fare configuration: $e');
    }
  }

  @override
  bool isDemoMode() {
    return _prefs.getBool(StorageKeys.demoMode) ?? true;
  }

  @override
  Future<void> setDemoMode(bool enabled) async {
    try {
      await _prefs.setBool(StorageKeys.demoMode, enabled);
    } catch (e) {
      throw StorageException('Failed to update demo mode: $e');
    }
  }

  @override
  String getThemeMode() {
    return _prefs.getString(StorageKeys.themeMode) ?? 'amoled';
  }

  @override
  Future<void> saveThemeMode(String mode) async {
    try {
      await _prefs.setString(StorageKeys.themeMode, mode);
    } catch (e) {
      throw StorageException('Failed to persist theme mode: $e');
    }
  }

  @override
  List<TripModel> getTrips() {
    final jsonStr = _prefs.getString(StorageKeys.trips);
    if (jsonStr == null) return [];
    try {
      final List decoded = jsonDecode(jsonStr) as List;
      return decoded
          .map((item) => TripModel.fromJson(item as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime));
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveTrip(TripModel trip) async {
    try {
      final trips = getTrips();
      final index = trips.indexWhere((t) => t.id == trip.id);
      if (index >= 0) {
        trips[index] = trip;
      } else {
        trips.insert(0, trip);
      }
      await _saveTripsList(trips);
    } catch (e) {
      throw StorageException('Failed to save trip ${trip.id}: $e');
    }
  }

  @override
  Future<void> updateTripPayment({
    required String tripId,
    required String paymentMethod,
    required String paymentStatus,
    String? paymentReference,
  }) async {
    try {
      final trips = getTrips();
      final index = trips.indexWhere((t) => t.id == tripId);
      if (index >= 0) {
        trips[index] = trips[index].copyWith(
          paymentMethod: paymentMethod,
          paymentStatus: paymentStatus,
          paymentReference: paymentReference,
        );
        await _saveTripsList(trips);
      }
    } catch (e) {
      throw StorageException('Failed to update trip payment: $e');
    }
  }

  @override
  Future<void> markTripSynced(String tripId) async {
    try {
      final trips = getTrips();
      final index = trips.indexWhere((t) => t.id == tripId);
      if (index >= 0) {
        trips[index] = trips[index].copyWith(isSynced: true);
        await _saveTripsList(trips);
      }
    } catch (e) {
      throw StorageException('Failed to mark trip synced: $e');
    }
  }

  Future<void> _saveTripsList(List<TripModel> trips) async {
    final encoded = jsonEncode(trips.map((t) => t.toJson()).toList());
    await _prefs.setString(StorageKeys.trips, encoded);
  }

  @override
  Future<void> saveActiveTripState(Map<String, dynamic>? state) async {
    try {
      if (state == null) {
        await _prefs.remove(StorageKeys.activeTrip);
      } else {
        await _prefs.setString(StorageKeys.activeTrip, jsonEncode(state));
      }
    } catch (e) {
      throw StorageException('Failed to persist active trip recovery state: $e');
    }
  }

  @override
  Map<String, dynamic>? getActiveTripState() {
    final jsonStr = _prefs.getString(StorageKeys.activeTrip);
    if (jsonStr == null) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> resetDemoData() async {
    try {
      await _prefs.remove(StorageKeys.trips);
      await _prefs.remove(StorageKeys.activeTrip);
      await saveDriverProfile(const DriverProfile());
      await saveFareConfig(const FareConfig());
      await setDemoMode(true);
    } catch (e) {
      throw StorageException('Failed to reset demo data: $e');
    }
  }
}
