import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_defaults.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/distance_calculator.dart';

/// Telemetry coordinate point captured during active trip tracking.
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

/// Abstract contract for location telemetry services.
abstract class ILocationService {
  Stream<LocationDataPoint> get locationStream;
  bool get isTracking;
  Future<bool> startTracking();
  Future<void> stopTracking();
  void dispose();
}

/// Hardware GPS tracking service implementing [ILocationService].
/// Includes speed calculation, noise filtering, and GPS jump rejection.
class LocationService implements ILocationService {
  StreamSubscription<Position>? _positionSubscription;
  final _locationController = StreamController<LocationDataPoint>.broadcast();

  @override
  Stream<LocationDataPoint> get locationStream => _locationController.stream;

  LocationDataPoint? _lastPoint;
  bool _isTracking = false;

  @override
  bool get isTracking => _isTracking;

  /// Check and request device GPS location permissions.
  static Future<bool> checkAndRequestPermission() async {
    try {
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
    } catch (e) {
      debugPrint('[LocationService] Permission check error: $e');
      return false;
    }
  }

  @override
  Future<bool> startTracking() async {
    final hasPermission = await checkAndRequestPermission();
    if (!hasPermission) {
      debugPrint('[LocationService] Permission denied or GPS service disabled');
      return false;
    }

    _lastPoint = null;
    _isTracking = true;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3, // meters
    );

    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _processPosition,
        onError: (e) {
          debugPrint('[LocationService] GPS stream error: $e');
          _locationController.addError(
            LocationException('Location stream interrupted: $e', details: e),
          );
        },
      );
      return true;
    } catch (e) {
      debugPrint('[LocationService] Failed to start position stream: $e');
      _isTracking = false;
      return false;
    }
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

  @override
  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _lastPoint = null;
    _isTracking = false;
  }

  @override
  void dispose() {
    stopTracking();
    _locationController.close();
  }
}
