import 'dart:math';

class DistanceCalculator {
  static const double earthRadiusKm = 6371.0;

  /// Computes distance in kilometers between two GPS coordinates using Haversine formula
  static double haversineKm(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final dLat = _degreesToRadians(endLat - startLat);
    final dLng = _degreesToRadians(endLng - startLng);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(startLat)) *
            cos(_degreesToRadians(endLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  /// Validates if an incremental movement makes physical sense for an auto-rickshaw
  /// (e.g. not a teleportation glitch of > 90 km/h)
  static bool isValidMovement({
    required double distanceKm,
    required Duration timeElapsed,
    required double accuracyMeters,
    double maxSpeedKmh = 90.0,
    double maxAccuracyMeters = 35.0,
  }) {
    if (accuracyMeters > maxAccuracyMeters) {
      return false; // Skip poor GPS fixes
    }

    final seconds = timeElapsed.inMilliseconds / 1000.0;
    if (seconds <= 0.05) return false;

    final speedKmh = (distanceKm / (seconds / 3600.0));
    if (speedKmh > maxSpeedKmh) {
      return false; // Impossible velocity jump, reject GPS spike
    }

    return true;
  }
}
