import '../data/datasources/local_storage_datasource.dart';
import '../data/models/driver_profile.dart';
import '../data/models/fare_config.dart';
import '../data/models/trip_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Legacy storage service facade wrapping [LocalStorageDataSource]
/// to ensure backward compatibility across the codebase and test suites.
class StorageService {
  final LocalStorageDataSource _dataSource;

  StorageService(SharedPreferences prefs)
      : _dataSource = LocalStorageDataSource(prefs);

  static Future<StorageService> init() async {
    final ds = await LocalStorageDataSource.init();
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  ILocalStorageDataSource get dataSource => _dataSource;

  DriverProfile getDriverProfile() => _dataSource.getDriverProfile();
  Future<void> saveDriverProfile(DriverProfile profile) =>
      _dataSource.saveDriverProfile(profile);

  FareConfig getFareConfig() => _dataSource.getFareConfig();
  Future<void> saveFareConfig(FareConfig config) =>
      _dataSource.saveFareConfig(config);

  bool isDemoMode() => _dataSource.isDemoMode();
  Future<void> setDemoMode(bool enabled) => _dataSource.setDemoMode(enabled);

  String getThemeMode() => _dataSource.getThemeMode();
  Future<void> saveThemeMode(String mode) => _dataSource.saveThemeMode(mode);

  List<TripModel> getTrips() => _dataSource.getTrips();
  Future<void> saveTrip(TripModel trip) => _dataSource.saveTrip(trip);
  Future<void> updateTripPayment({
    required String tripId,
    required String paymentMethod,
    required String paymentStatus,
    String? paymentReference,
  }) =>
      _dataSource.updateTripPayment(
        tripId: tripId,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        paymentReference: paymentReference,
      );

  Future<void> markTripSynced(String tripId) => _dataSource.markTripSynced(tripId);

  Future<void> saveActiveTripState(Map<String, dynamic>? state) =>
      _dataSource.saveActiveTripState(state);
  Map<String, dynamic>? getActiveTripState() => _dataSource.getActiveTripState();

  Future<void> resetDemoData() => _dataSource.resetDemoData();
}
