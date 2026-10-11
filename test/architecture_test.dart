import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_fare_meter/core/config/app_config.dart';
import 'package:smart_fare_meter/core/config/env_config.dart';
import 'package:smart_fare_meter/core/errors/app_exception.dart';
import 'package:smart_fare_meter/core/errors/failures.dart';
import 'package:smart_fare_meter/core/network/api_result.dart';
import 'package:smart_fare_meter/core/utils/validators.dart';
import 'package:smart_fare_meter/data/datasources/local_storage_datasource.dart';
import 'package:smart_fare_meter/data/datasources/remote_datasource.dart';
import 'package:smart_fare_meter/data/models/trip_model.dart';
import 'package:smart_fare_meter/data/repositories/trip_repository.dart';
import 'package:smart_fare_meter/providers/trip_provider.dart';
import 'package:smart_fare_meter/services/storage_service.dart';

void main() {
  group('Environment and Configuration Tests', () {
    test('EnvConfig defaults to development mode', () {
      expect(EnvConfig.environment, AppEnvironment.development);
      expect(EnvConfig.hasSupabaseCredentials, isFalse);
    });

    test('AppConfig initializes cleanly from factory', () {
      final config = AppConfig.development();
      expect(config.environment, AppEnvironment.development);
      expect(config.isSupabaseConfigured, isFalse);
      expect(config.apiTimeout, const Duration(seconds: 10));
    });
  });

  group('Error and Failure Mapping Tests', () {
    test('LocationException maps to LocationFailure with correct message and code', () {
      final exception = LocationException.permissionDenied();
      final failure = LocationFailure.fromException(exception);

      expect(failure.code, 'LOCATION_PERMISSION_DENIED');
      expect(failure.message, contains('Location permission was denied'));
    });

    test('PaymentException formats invalid UPI message', () {
      final exception = PaymentException.invalidUpiId('bad-upi');
      final failure = PaymentFailure.fromException(exception);

      expect(failure.code, 'INVALID_UPI_ID');
      expect(failure.message, contains('bad-upi'));
    });

    test('ApiResult handles success and failure branching', () {
      final successResult = ApiResult<String>.success('payload');
      final failureResult = ApiResult<String>.failure(const GeneralFailure('failed'));

      expect(successResult.isSuccess, isTrue);
      expect(successResult.data, 'payload');
      expect(successResult.when(onSuccess: (d) => d, onFailure: (f) => 'err'), 'payload');

      expect(failureResult.isSuccess, isFalse);
      expect(failureResult.when(onSuccess: (d) => d, onFailure: (f) => f.message), 'failed');
      expect(failureResult.getOrElse(() => 'fallback'), 'fallback');
    });
  });

  group('Validators Tests', () {
    test('Validates driver name correctly', () {
      expect(Validators.validateDriverName(null), isNotNull);
      expect(Validators.validateDriverName(''), isNotNull);
      expect(Validators.validateDriverName('A'), isNotNull);
      expect(Validators.validateDriverName('Ramesh Kumar'), isNull);
    });

    test('Validates UPI ID correctly', () {
      expect(Validators.validateUpiId(null), isNotNull);
      expect(Validators.validateUpiId(''), isNotNull);
      expect(Validators.validateUpiId('invalidupi'), isNotNull);
      expect(Validators.validateUpiId('driver@oksbi'), isNull);
      expect(Validators.validateUpiId('9876543210@paytm'), isNull);
    });

    test('Validates vehicle registration plate number', () {
      expect(Validators.validateVehicleNumber(null), isNotNull);
      expect(Validators.validateVehicleNumber(''), isNotNull);
      expect(Validators.validateVehicleNumber('KA'), isNotNull);
      expect(Validators.validateVehicleNumber('KA-01-AB-4022'), isNull);
    });

    test('Validates positive monetary amount', () {
      expect(Validators.validatePositiveAmount(null, fieldName: 'Fare'), isNotNull);
      expect(Validators.validatePositiveAmount('abc', fieldName: 'Fare'), isNotNull);
      expect(Validators.validatePositiveAmount('-15', fieldName: 'Fare'), isNotNull);
      expect(Validators.validatePositiveAmount('30.00', fieldName: 'Fare'), isNull);
      expect(Validators.validatePositiveAmount('0', fieldName: 'Distance'), isNull);
    });
  });

  group('Data Layer and Repository Tests', () {
    test('LocalStorageDataSource and TripRepository store and retrieve trips', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final local = LocalStorageDataSource(prefs);
      final remote = SupabaseRemoteDataSource(config: AppConfig.development());
      final repo = TripRepository(localDataSource: local, remoteDataSource: remote);

      final trip = TripModel(
        id: 'test-trip-001',
        startTime: DateTime.now().subtract(const Duration(minutes: 10)),
        endTime: DateTime.now(),
        distanceKm: 2.5,
        waitingDurationSeconds: 60,
        tripDurationSeconds: 600,
        baseFare: 30.0,
        distanceFare: 37.5,
        waitingFare: 1.5,
        totalFare: 69.0,
        createdAt: DateTime.now(),
      );

      await repo.saveTrip(trip);
      final trips = repo.getAllTrips();
      expect(trips.length, 1);
      expect(trips.first.id, 'test-trip-001');

      await repo.updateTripPayment(
        tripId: 'test-trip-001',
        paymentMethod: 'upi',
        paymentStatus: 'confirmed',
      );

      final updatedTrips = repo.getAllTrips();
      expect(updatedTrips.first.paymentMethod, 'upi');
      expect(updatedTrips.first.paymentStatus, 'confirmed');
    });

    test('TripProvider handles settings persistence and analytics', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await StorageService.init();
      final provider = TripProvider(storage);

      await provider.saveSettings(
        name: 'Suresh Gowda',
        upiId: 'suresh@ybl',
        vehicleNumber: 'KA-04-EF-9999',
        baseFare: 35.0,
        perKmRate: 18.0,
        waitingRatePerMin: 2.0,
        minDistanceKm: 2.0,
      );

      expect(provider.driverProfile.name, 'Suresh Gowda');
      expect(provider.driverProfile.upiId, 'suresh@ybl');
      expect(provider.driverProfile.vehicleNumber, 'KA-04-EF-9999');
      expect(provider.fareConfig.baseFare, 35.0);
      expect(provider.fareConfig.perKmRate, 18.0);
      expect(provider.fareConfig.waitingRatePerMin, 2.0);
      expect(provider.fareConfig.minDistanceKm, 2.0);
    });
  });
}
