import '../datasources/local_storage_datasource.dart';
import '../datasources/remote_datasource.dart';
import '../models/trip_model.dart';

/// Contract for managing trips offline and synchronizing with remote cloud storage.
abstract class ITripRepository {
  List<TripModel> getAllTrips();
  Future<void> saveTrip(TripModel trip);
  Future<void> updateTripPayment({
    required String tripId,
    required String paymentMethod,
    required String paymentStatus,
    String? paymentReference,
  });
  Future<void> saveActiveTripState(Map<String, dynamic>? state);
  Map<String, dynamic>? getActiveTripState();
  Future<int> syncAllUnsynced();
  Future<bool> syncTrip(TripModel trip);
}

/// Offline-first repository implementation for trips.
class TripRepository implements ITripRepository {
  final ILocalStorageDataSource _localDataSource;
  final IRemoteDataSource _remoteDataSource;

  TripRepository({
    required ILocalStorageDataSource localDataSource,
    required IRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  List<TripModel> getAllTrips() {
    return _localDataSource.getTrips();
  }

  @override
  Future<void> saveTrip(TripModel trip) async {
    await _localDataSource.saveTrip(trip);
  }

  @override
  Future<void> updateTripPayment({
    required String tripId,
    required String paymentMethod,
    required String paymentStatus,
    String? paymentReference,
  }) async {
    await _localDataSource.updateTripPayment(
      tripId: tripId,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      paymentReference: paymentReference,
    );
  }

  @override
  Future<void> saveActiveTripState(Map<String, dynamic>? state) async {
    await _localDataSource.saveActiveTripState(state);
  }

  @override
  Map<String, dynamic>? getActiveTripState() {
    return _localDataSource.getActiveTripState();
  }

  @override
  Future<bool> syncTrip(TripModel trip) async {
    final result = await _remoteDataSource.syncTrip(trip);
    if (result.isSuccess) {
      await _localDataSource.markTripSynced(trip.id);
      return true;
    }
    return false;
  }

  @override
  Future<int> syncAllUnsynced() async {
    final trips = _localDataSource.getTrips();
    final result = await _remoteDataSource.syncAllUnsynced(
      trips,
      (id) => _localDataSource.markTripSynced(id),
    );
    return result.getOrElse(() => 0);
  }
}
