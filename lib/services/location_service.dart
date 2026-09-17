import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../core/constants/app_defaults.dart';
import '../core/utils/distance_calculator.dart';

class LocationDataPoint {
  final double latitude;
  final double longitude;
  final double speedKmh;
  final double accuracyMeters;
  final DateTime timestamp;
  final bool isStationary;

  const LocationDataPoint({
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.accuracyMeters,
    required this.timestamp,
    required this.isStationary,
  });
}

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  final _locationController = StreamController<LocationDataPoint>.broadcast();
  
  Stream<LocationDataPoint> get locationStream => _locationController.stream;

  LocationDataPoint? _lastPoint;
  bool _isTracking = false;

  bool get isTracking => _isTracking;

  /// Check and request GPS location permissions
  static Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Start real device GPS tracking with smoothing
  Future<bool> startTracking() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      debugPrint('Location permission denied or GPS disabled');
      return false;
    }

    _lastPoint = null;
    _isTracking = true;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3, // meters
    );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _processPosition(position);
      },
      onError: (e) {
        debugPrint('GPS stream error: $e');
      },
    );

    return true;
  }

  void _processPosition(Position position) {
    final now = DateTime.now();
    final speedKmh = (position.speed * 3.6).clamp(0.0, 150.0);
    final accuracy = position.accuracy;

    // Filter noisy GPS fixes
    if (accuracy > AppDefaults.maxGpsAccuracyMeters) {
      return;
    }

    if (_lastPoint != null) {
      final elapsed = now.difference(_lastPoint!.timestamp);
      final distKm = DistanceCalculator.haversineKm(
        _lastPoint!.latitude,
        _lastPoint!.longitude,
        position.latitude,
        position.longitude,
      );

      final isValid = DistanceCalculator.isValidMovement(
        distanceKm: distKm,
        timeElapsed: elapsed,
        accuracyMeters: accuracy,
        maxSpeedKmh: AppDefaults.maxReliableSpeedKmh,
      );

      if (!isValid && distKm > 0.05) {
        // Drop GPS jump
        return;
      }
    }

    final isStationary = speedKmh < AppDefaults.minMovingSpeedKmh;

    final dataPoint = LocationDataPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      speedKmh: speedKmh,
      accuracyMeters: accuracy,
      timestamp: now,
      isStationary: isStationary,
    );

    _lastPoint = dataPoint;
    _locationController.add(dataPoint);
  }

  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _lastPoint = null;
    _isTracking = false;
  }

  void dispose() {
    stopTracking();
    _locationController.close();
  }
}
