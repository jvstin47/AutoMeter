import 'dart:math';
import '../models/fare_config.dart';

class FareBreakdown {
  final double baseFare;
  final double distanceKm;
  final double chargeableDistanceKm;
  final double perKmRate;
  final double distanceFare;
  final int waitingDurationSeconds;
  final int waitingMinutes;
  final double waitingRatePerMin;
  final double waitingFare;
  final double totalFare;

  const FareBreakdown({
    required this.baseFare,
    required this.distanceKm,
    double? chargeableDistanceKm,
    required this.perKmRate,
    required this.distanceFare,
    required this.waitingDurationSeconds,
    required this.waitingMinutes,
    required this.waitingRatePerMin,
    required this.waitingFare,
    required this.totalFare,
  }) : chargeableDistanceKm = chargeableDistanceKm ?? distanceKm;

  @override
  String toString() {
    return 'FareBreakdown(base: ₹$baseFare, dist: ${distanceKm.toStringAsFixed(2)}km (chargeable: ${chargeableDistanceKm.toStringAsFixed(2)}km) @ ₹$perKmRate = ₹$distanceFare, wait: ${waitingMinutes}m @ ₹$waitingRatePerMin = ₹$waitingFare, total: ₹$totalFare)';
  }
}

class FareEngine {
  /// Pure fare calculation engine
  /// Takes distance in km, waiting time in seconds, and configurable fare rates.
  static FareBreakdown calculate({
    required double distanceKm,
    required int waitingSeconds,
    required FareConfig config,
    bool roundToNearestRupee = true,
  }) {
    final sanitizedDistance = distanceKm < 0 ? 0.0 : distanceKm;
    final sanitizedWaiting = waitingSeconds < 0 ? 0 : waitingSeconds;

    final baseFare = config.baseFare;

    // Support both pure flat base + distance, or minimum fare with included distance
    final chargeableDistance = config.minDistanceKm > 0
        ? max(0.0, sanitizedDistance - config.minDistanceKm)
        : sanitizedDistance;

    final distanceFare = chargeableDistance * config.perKmRate;

    // Waiting minutes rounded up per minute interval once started (standard auto meter convention)
    final waitingMinutes = sanitizedWaiting > 0 ? (sanitizedWaiting / 60.0).ceil() : 0;
    final waitingFare = waitingMinutes * config.waitingRatePerMin;

    final rawTotal = baseFare + distanceFare + waitingFare;
    
    // Sensible rounding for Indian Rupees: round to nearest rupee or keep 2 decimals
    final totalFare = roundToNearestRupee 
        ? rawTotal.roundToDouble()
        : double.parse(rawTotal.toStringAsFixed(2));

    return FareBreakdown(
      baseFare: double.parse(baseFare.toStringAsFixed(2)),
      distanceKm: sanitizedDistance,
      chargeableDistanceKm: chargeableDistance,
      perKmRate: config.perKmRate,
      distanceFare: double.parse(distanceFare.toStringAsFixed(2)),
      waitingDurationSeconds: sanitizedWaiting,
      waitingMinutes: waitingMinutes,
      waitingRatePerMin: config.waitingRatePerMin,
      waitingFare: double.parse(waitingFare.toStringAsFixed(2)),
      totalFare: totalFare,
    );
  }
}
