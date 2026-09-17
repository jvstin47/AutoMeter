import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_defaults.dart';
import '../core/utils/distance_calculator.dart';
import '../models/driver_profile.dart';
import '../models/fare_config.dart';
import '../models/trip_model.dart';
import 'demo_simulation_service.dart';
import 'fare_engine.dart';
import 'location_service.dart';
import 'payment_service.dart';
import 'storage_service.dart';
import 'supabase_service.dart';

enum TripState {
  idle,
  active,
  stopped,
  paymentPending,
  completed,
}

class TripManager extends ChangeNotifier {
  final StorageService _storageService;
  final LocationService _locationService = LocationService();
  final DemoSimulationService _demoSimulationService = DemoSimulationService();

  TripState _state = TripState.idle;
  TripState get state => _state;

  // Active Trip State
  String? _activeTripId;
  DateTime? _tripStartTime;
  DateTime? _tripEndTime;
  int _tripDurationSeconds = 0;
  int _waitingDurationSeconds = 0;
  double _distanceKm = 0.0;
  double _currentSpeedKmh = 0.0;
  bool _isStationary = false;

  double? _startLat;
  double? _startLng;
  double? _lastLat;
  double? _lastLng;

  Timer? _tripTimer;
  StreamSubscription<LocationDataPoint>? _locationSubscription;

  // Configuration & Profile
  FareConfig _fareConfig = const FareConfig();
  DriverProfile _driverProfile = const DriverProfile();
  bool _isDemoMode = true;

  // Completed / Reviewing Trip
  TripModel? _currentTrip;
  FareBreakdown _currentBreakdown = const FareBreakdown(
    baseFare: AppDefaults.baseFare,
    distanceKm: 0.0,
    perKmRate: AppDefaults.perKmRate,
    distanceFare: 0.0,
    waitingDurationSeconds: 0,
    waitingMinutes: 0,
    waitingRatePerMin: AppDefaults.waitingRatePerMin,
    waitingFare: 0.0,
    totalFare: AppDefaults.baseFare,
  );

  // Trips & Analytics
  List<TripModel> _trips = [];
  bool _isGpsSignalWeak = false;
  bool _wasRestoredFromCrash = false;
  bool _isSyncing = false;

  TripManager(this._storageService) {
    _init();
  }

  // Getters
  String? get activeTripId => _activeTripId;
  DateTime? get tripStartTime => _tripStartTime;
  int get tripDurationSeconds => _tripDurationSeconds;
  int get waitingDurationSeconds => _waitingDurationSeconds;
  double get distanceKm => _distanceKm;
  double get currentSpeedKmh => _currentSpeedKmh;
  bool get isStationary => _isStationary;
  bool get isGpsSignalWeak => _isGpsSignalWeak;
  bool get wasRestoredFromCrash => _wasRestoredFromCrash;
  bool get isSyncing => _isSyncing;
  int get unsyncedTripCount => _trips.where((t) => !t.isSynced).length;
  FareConfig get fareConfig => _fareConfig;
  DriverProfile get driverProfile => _driverProfile;
  bool get isDemoMode => _isDemoMode;
  TripModel? get currentTrip => _currentTrip;
  FareBreakdown get currentBreakdown => _currentBreakdown;
  List<TripModel> get trips => _trips;
  DemoSimulationService get demoService => _demoSimulationService;

  void acknowledgeCrashRecovery() {
    _wasRestoredFromCrash = false;
  }

  // Today's Analytics
  double get todayEarnings {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _trips
        .where((t) {
          final tDate = DateTime(t.startTime.year, t.startTime.month, t.startTime.day);
          return tDate == today && t.paymentStatus == 'confirmed';
        })
        .fold(0.0, (sum, t) => sum + t.totalFare);
  }

  int get todayTripCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _trips
        .where((t) {
          final tDate = DateTime(t.startTime.year, t.startTime.month, t.startTime.day);
          return tDate == today;
        })
        .length;
  }

  double get todayDistanceKm {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _trips
        .where((t) {
          final tDate = DateTime(t.startTime.year, t.startTime.month, t.startTime.day);
          return tDate == today;
        })
        .fold(0.0, (sum, t) => sum + t.distanceKm);
  }

  int get todayWaitingMinutes {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final totalSeconds = _trips
        .where((t) {
          final tDate = DateTime(t.startTime.year, t.startTime.month, t.startTime.day);
          return tDate == today;
        })
        .fold(0, (sum, t) => sum + t.waitingDurationSeconds);
    return (totalSeconds / 60).ceil();
  }

  void _init() {
    _driverProfile = _storageService.getDriverProfile();
    _fareConfig = _storageService.getFareConfig();
    _isDemoMode = _storageService.isDemoMode();
    _trips = _storageService.getTrips();
    _recalculateFare();

    // Check crash recovery
    final recoveredState = _storageService.getActiveTripState();
    if (recoveredState != null && recoveredState['state'] == 'active') {
      _restoreActiveTrip(recoveredState);
    }
  }

  void _restoreActiveTrip(Map<String, dynamic> data) {
    try {
      _activeTripId = data['id'];
      _tripStartTime = DateTime.parse(data['start_time']);
      _distanceKm = (data['distance_km'] as num).toDouble();
      _waitingDurationSeconds = (data['waiting_seconds'] as num).toInt();
      _startLat = (data['start_lat'] as num?)?.toDouble();
      _startLng = (data['start_lng'] as num?)?.toDouble();
      _lastLat = (data['last_lat'] as num?)?.toDouble();
      _lastLng = (data['last_lng'] as num?)?.toDouble();
      _tripDurationSeconds = DateTime.now().difference(_tripStartTime!).inSeconds;
      _state = TripState.active;
      _wasRestoredFromCrash = true;
      _recalculateFare();
      _startTrackingStream();
      _startTripTimer();
      notifyListeners();
    } catch (_) {
      _storageService.saveActiveTripState(null);
    }
  }

  void _recalculateFare() {
    _currentBreakdown = FareEngine.calculate(
      distanceKm: _distanceKm,
      waitingSeconds: _waitingDurationSeconds,
      config: _fareConfig,
    );
  }

  Future<void> setDemoMode(bool enabled) async {
    _isDemoMode = enabled;
    await _storageService.setDemoMode(enabled);
    if (_state == TripState.active) {
      // Switch tracking stream mid-flight if needed
      await _stopTrackingStream();
      await _startTrackingStream();
    }
    notifyListeners();
  }

  Future<void> updateDriverProfile(DriverProfile profile) async {
    _driverProfile = profile;
    await _storageService.saveDriverProfile(profile);
    notifyListeners();
  }

  Future<void> updateFareConfig(FareConfig config) async {
    _fareConfig = config;
    await _storageService.saveFareConfig(config);
    _recalculateFare();
    notifyListeners();
  }

  // --- TRIP LIFECYCLE ---

  Future<void> startTrip() async {
    if (_state == TripState.active) return; // Prevent double start

    _activeTripId = const Uuid().v4();
    _tripStartTime = DateTime.now();
    _tripEndTime = null;
    _tripDurationSeconds = 0;
    _waitingDurationSeconds = 0;
    _distanceKm = 0.0;
    _currentSpeedKmh = 0.0;
    _isStationary = false;
    _startLat = null;
    _startLng = null;
    _lastLat = null;
    _lastLng = null;

    _recalculateFare();
    _state = TripState.active;

    await _storageService.saveActiveTripState({
      'id': _activeTripId,
      'start_time': _tripStartTime!.toIso8601String(),
      'distance_km': _distanceKm,
      'waiting_seconds': _waitingDurationSeconds,
      'start_lat': _startLat,
      'start_lng': _startLng,
      'last_lat': _lastLat,
      'last_lng': _lastLng,
      'state': 'active',
    });

    _startTripTimer();
    await _startTrackingStream();

    notifyListeners();
  }

  void _startTripTimer() {
    _tripTimer?.cancel();
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state != TripState.active) {
        timer.cancel();
        return;
      }

      _tripDurationSeconds++;

      // If stationary, accumulate waiting time
      if (_isStationary) {
        _waitingDurationSeconds++;
      }

      _recalculateFare();

      // Periodically persist active state for crash resilience
      if (_tripDurationSeconds % 5 == 0) {
        _storageService.saveActiveTripState({
          'id': _activeTripId,
          'start_time': _tripStartTime!.toIso8601String(),
          'distance_km': _distanceKm,
          'waiting_seconds': _waitingDurationSeconds,
          'start_lat': _startLat,
          'start_lng': _startLng,
          'last_lat': _lastLat,
          'last_lng': _lastLng,
          'state': 'active',
        });
      }

      notifyListeners();
    });
  }

  Future<void> _startTrackingStream() async {
    await _stopTrackingStream();

    if (_isDemoMode) {
      _demoSimulationService.startSimulation();
      _locationSubscription = _demoSimulationService.locationStream.listen(_onLocationUpdate);
    } else {
      final started = await _locationService.startTracking();
      if (started) {
        _locationSubscription = _locationService.locationStream.listen(_onLocationUpdate);
      } else {
        // Fallback to demo mode if GPS unavailable on device
        debugPrint('Falling back to simulation mode due to GPS permission');
        _demoSimulationService.startSimulation();
        _locationSubscription = _demoSimulationService.locationStream.listen(_onLocationUpdate);
      }
    }
  }

  void _onLocationUpdate(LocationDataPoint point) {
    if (_state != TripState.active) return;

    _currentSpeedKmh = point.speedKmh;
    _isStationary = point.isStationary;

    if (_startLat == null) {
      _startLat = point.latitude;
      _startLng = point.longitude;
      _lastLat = point.latitude;
      _lastLng = point.longitude;
    } else if (_lastLat != null && _lastLng != null) {
      final deltaKm = DistanceCalculator.haversineKm(
        _lastLat!,
        _lastLng!,
        point.latitude,
        point.longitude,
      );

      // Only accumulate if vehicle actually moved
      if (deltaKm > 0.001) {
        _distanceKm += deltaKm;
        _lastLat = point.latitude;
        _lastLng = point.longitude;
      }
    }

    _recalculateFare();
    notifyListeners();
  }

  Future<void> _stopTrackingStream() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    await _locationService.stopTracking();
    _demoSimulationService.stopSimulation();
  }

  Future<TripModel> stopTrip() async {
    _tripEndTime = DateTime.now();
    _tripTimer?.cancel();
    _tripTimer = null;
    await _stopTrackingStream();

    _recalculateFare();

    final completedTrip = TripModel(
      id: _activeTripId ?? const Uuid().v4(),
      startTime: _tripStartTime ?? DateTime.now(),
      endTime: _tripEndTime,
      distanceKm: double.parse(_distanceKm.toStringAsFixed(2)),
      waitingDurationSeconds: _waitingDurationSeconds,
      tripDurationSeconds: _tripDurationSeconds,
      baseFare: _currentBreakdown.baseFare,
      distanceFare: _currentBreakdown.distanceFare,
      waitingFare: _currentBreakdown.waitingFare,
      totalFare: _currentBreakdown.totalFare,
      paymentMethod: 'unselected',
      paymentStatus: 'pending',
      paymentReference: PaymentService.generateTransactionRef(_activeTripId ?? 'TRIP'),
      startLatitude: _startLat,
      startLongitude: _startLng,
      endLatitude: _lastLat,
      endLongitude: _lastLng,
      isSynced: false,
      isDemo: _isDemoMode,
      createdAt: DateTime.now(),
    );

    _currentTrip = completedTrip;
    _state = TripState.paymentPending;

    // Save preliminary trip in local storage
    await _storageService.saveTrip(completedTrip);
    await _storageService.saveActiveTripState(null);

    _trips = _storageService.getTrips();
    notifyListeners();

    return completedTrip;
  }

  // Demo interactive helpers for presentation
  void toggleDemoTrafficStop() {
    _demoSimulationService.toggleSignalStop();
    _isStationary = _demoSimulationService.state == DemoVehicleState.waitingAtSignal;
    notifyListeners();
  }

  void setDemoSpeedMultiplier(double mult) {
    _demoSimulationService.setSpeedMultiplier(mult);
    notifyListeners();
  }

  // --- PAYMENT CONFIRMATION ---

  Future<void> confirmPayment({
    required String paymentMethod, // 'upi' or 'cash'
    required String paymentStatus, // 'confirmed'
  }) async {
    if (_currentTrip == null) return;

    final updatedTrip = _currentTrip!.copyWith(
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
    );

    _currentTrip = updatedTrip;
    _state = TripState.completed;

    await _storageService.saveTrip(updatedTrip);
    _trips = _storageService.getTrips();

    // Trigger background sync to Supabase if configured
    SupabaseService.syncTrip(updatedTrip).then((synced) {
      if (synced) {
        _storageService.markTripSynced(updatedTrip.id);
        _trips = _storageService.getTrips();
        notifyListeners();
      }
    });

    notifyListeners();
  }

  Future<int> syncAllPendingTrips() async {
    if (_isSyncing) return 0;
    _isSyncing = true;
    notifyListeners();

    try {
      final syncedCount = await SupabaseService.syncAllUnsynced(_trips, (syncedId) {
        _storageService.markTripSynced(syncedId);
      });
      _trips = _storageService.getTrips();
      _isSyncing = false;
      notifyListeners();
      return syncedCount;
    } catch (_) {
      _isSyncing = false;
      notifyListeners();
      return 0;
    }
  }

  void dismissSummaryAndReset() {
    _state = TripState.idle;
    _activeTripId = null;
    _tripStartTime = null;
    _tripEndTime = null;
    _tripDurationSeconds = 0;
    _waitingDurationSeconds = 0;
    _distanceKm = 0.0;
    _currentSpeedKmh = 0.0;
    _isStationary = false;
    _currentTrip = null;
    _recalculateFare();
    notifyListeners();
  }

  Future<void> resetAllDemoData() async {
    await _storageService.resetDemoData();
    _trips.clear();
    _driverProfile = const DriverProfile();
    _fareConfig = const FareConfig();
    _isDemoMode = true;
    dismissSummaryAndReset();
  }

  @override
  void dispose() {
    _tripTimer?.cancel();
    _locationSubscription?.cancel();
    _locationService.dispose();
    _demoSimulationService.dispose();
    super.dispose();
  }
}
