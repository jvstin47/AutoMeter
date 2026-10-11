import '../datasources/local_storage_datasource.dart';
import '../models/driver_profile.dart';
import '../models/fare_config.dart';

/// Contract for driver and meter settings management.
abstract class ISettingsRepository {
  DriverProfile getDriverProfile();
  Future<void> saveDriverProfile(DriverProfile profile);

  FareConfig getFareConfig();
  Future<void> saveFareConfig(FareConfig config);

  bool isDemoMode();
  Future<void> setDemoMode(bool enabled);

  Future<void> resetAllDemoData();
}

/// Repository implementation for driver and meter settings.
class SettingsRepository implements ISettingsRepository {
  final ILocalStorageDataSource _localDataSource;

  SettingsRepository({required ILocalStorageDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  DriverProfile getDriverProfile() => _localDataSource.getDriverProfile();

  @override
  Future<void> saveDriverProfile(DriverProfile profile) =>
      _localDataSource.saveDriverProfile(profile);

  @override
  FareConfig getFareConfig() => _localDataSource.getFareConfig();

  @override
  Future<void> saveFareConfig(FareConfig config) =>
      _localDataSource.saveFareConfig(config);

  @override
  bool isDemoMode() => _localDataSource.isDemoMode();

  @override
  Future<void> setDemoMode(bool enabled) =>
      _localDataSource.setDemoMode(enabled);

  @override
  Future<void> resetAllDemoData() => _localDataSource.resetDemoData();
}
