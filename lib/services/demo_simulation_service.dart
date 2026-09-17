import 'dart:async';
import 'dart:math';
import 'location_service.dart';

enum DemoVehicleState {
  driving,
  waitingAtSignal,
}

class DemoSimulationService {
  Timer? _timer;
  final _streamController = StreamController<LocationDataPoint>.broadcast();
  Stream<LocationDataPoint> get locationStream => _streamController.stream;

  DemoVehicleState _state = DemoVehicleState.driving;
  double _speedMultiplier = 1.0;
  bool _isRunning = false;

  // Starting location (e.g. MG Road, Bengaluru)
  double _currentLat = 12.9716;
  double _currentLng = 77.5946;

  DemoVehicleState get state => _state;
  double get speedMultiplier => _speedMultiplier;
  bool get isRunning => _isRunning;

  void setSpeedMultiplier(double multiplier) {
    _speedMultiplier = multiplier;
  }

  void toggleSignalStop() {
    if (_state == DemoVehicleState.driving) {
      _state = DemoVehicleState.waitingAtSignal;
    } else {
      _state = DemoVehicleState.driving;
    }
  }

  void setVehicleState(DemoVehicleState newState) {
    _state = newState;
  }

  void startSimulation() {
    stopSimulation();
    _isRunning = true;
    _state = DemoVehicleState.driving;

    // Tick every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _tick();
    });

    // Send initial point
    _tick();
  }

  void _tick() {
    final now = DateTime.now();
    double speedKmh = 0.0;
    bool isStationary = true;

    if (_state == DemoVehicleState.driving) {
      // Base driving speed around 30 km/h + minor fluctuations
      final randomFluctuation = (Random().nextDouble() * 6.0) - 3.0;
      speedKmh = (30.0 + randomFluctuation) * _speedMultiplier;
      isStationary = false;

      // Move coordinates forward in a small trajectory (~0.0001 deg per sec at 30 km/h)
      final distancePerSecKm = (speedKmh / 3600.0);
      final latDelta = (distancePerSecKm / 111.0); // approx degrees latitude
      final lngDelta = (distancePerSecKm / (111.0 * cos(_currentLat * pi / 180.0)));

      _currentLat += latDelta;
      _currentLng += lngDelta;
    } else {
      // Waiting at signal / stopped
      speedKmh = 0.0;
      isStationary = true;
    }

    final point = LocationDataPoint(
      latitude: _currentLat,
      longitude: _currentLng,
      speedKmh: speedKmh,
      accuracyMeters: 5.0,
      timestamp: now,
      isStationary: isStationary,
    );

    _streamController.add(point);
  }

  void stopSimulation() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  void dispose() {
    stopSimulation();
    _streamController.close();
  }
}
