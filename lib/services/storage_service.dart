import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/driver_profile.dart';
import '../models/fare_config.dart';
import '../models/trip_model.dart';

class StorageService {
  static const String _keyTrips = 'smart_meter_trips';
  static const String _keyProfile = 'smart_meter_driver_profile';
  static const String _keyConfig = 'smart_meter_fare_config';
  static const String _keyDemoMode = 'smart_meter_demo_mode_enabled';
  static const String _keyThemeMode = 'smart_meter_theme_mode';
  static const String _keyActiveTrip = 'smart_meter_active_trip_state';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Driver Profile
  DriverProfile getDriverProfile() {
    final jsonStr = _prefs.getString(_keyProfile);
    if (jsonStr == null) return const DriverProfile();
    try {
      return DriverProfile.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return const DriverProfile();
    }
  }

  Future<void> saveDriverProfile(DriverProfile profile) async {
    await _prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  // Fare Config
  FareConfig getFareConfig() {
    final jsonStr = _prefs.getString(_keyConfig);
    if (jsonStr == null) return const FareConfig();
    try {
      return FareConfig.fromJson(jsonDecode(jsonStr));
    } catch (_) {
      return const FareConfig();
    }
  }

  Future<void> saveFareConfig(FareConfig config) async {
    await _prefs.setString(_keyConfig, jsonEncode(config.toJson()));
  }

  // Demo Mode
  bool isDemoMode() {
    return _prefs.getBool(_keyDemoMode) ?? true; // Default to Demo Mode for instant testability
  }

  Future<void> setDemoMode(bool enabled) async {
    await _prefs.setBool(_keyDemoMode, enabled);
  }

  // Theme Mode
  String getThemeMode() {
    return _prefs.getString(_keyThemeMode) ?? 'amoled'; // Default to AMOLED Dark Mode
  }

  Future<void> saveThemeMode(String mode) async {
    await _prefs.setString(_keyThemeMode, mode);
  }

  // Trips CRUD
  List<TripModel> getTrips() {
    final jsonStr = _prefs.getString(_keyTrips);
    if (jsonStr == null) return [];
    try {
      final List decoded = jsonDecode(jsonStr);
      return decoded.map((item) => TripModel.fromJson(item as Map<String, dynamic>)).toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime)); // Reverse chronological
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTrip(TripModel trip) async {
    final trips = getTrips();
    final index = trips.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      trips[index] = trip;
    } else {
      trips.insert(0, trip);
    }
    await _saveTripsList(trips);
  }

  Future<void> updateTripPayment({
    required String tripId,
    required String paymentMethod,
    required String paymentStatus,
    String? paymentReference,
  }) async {
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
  }

  Future<void> markTripSynced(String tripId) async {
    final trips = getTrips();
    final index = trips.indexWhere((t) => t.id == tripId);
    if (index >= 0) {
      trips[index] = trips[index].copyWith(isSynced: true);
      await _saveTripsList(trips);
    }
  }

  Future<void> _saveTripsList(List<TripModel> trips) async {
    final encoded = jsonEncode(trips.map((t) => t.toJson()).toList());
    await _prefs.setString(_keyTrips, encoded);
  }

  // Crash recovery / Active trip state
  Future<void> saveActiveTripState(Map<String, dynamic>? state) async {
    if (state == null) {
      await _prefs.remove(_keyActiveTrip);
    } else {
      await _prefs.setString(_keyActiveTrip, jsonEncode(state));
    }
  }

  Map<String, dynamic>? getActiveTripState() {
    final jsonStr = _prefs.getString(_keyActiveTrip);
    if (jsonStr == null) return null;
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Reset Demo Data (Clears prototype trips & restores defaults)
  Future<void> resetDemoData() async {
    await _prefs.remove(_keyTrips);
    await _prefs.remove(_keyActiveTrip);
    await saveDriverProfile(const DriverProfile());
    await saveFareConfig(const FareConfig());
    await setDemoMode(true);
  }
}
