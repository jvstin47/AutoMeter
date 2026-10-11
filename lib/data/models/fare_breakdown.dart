import 'package:flutter/foundation.dart';
import '../../core/constants/app_defaults.dart';

/// Immutable breakdown of all tariff calculation components.
@immutable
class FareBreakdown {
  /// Base flag-down fare
  final double baseFare;

  /// Total billable distance in kilometers
  final double distanceKm;

  /// Applied per-km rate
  final double perKmRate;

  /// Computed distance fare component
  final double distanceFare;

  /// Total waiting duration in seconds
  final int waitingDurationSeconds;

  /// Billable ceil-rounded waiting minutes
  final int waitingMinutes;

  /// Applied per-minute waiting rate
  final double waitingRatePerMin;

  /// Computed waiting fare component
  final double waitingFare;

  /// Final total fare amount
  final double totalFare;

  const FareBreakdown({
    required this.baseFare,
    required this.distanceKm,
    required this.perKmRate,
    required this.distanceFare,
    required this.waitingDurationSeconds,
    required this.waitingMinutes,
    required this.waitingRatePerMin,
    required this.waitingFare,
    required this.totalFare,
  });

  /// Default zero/initial breakdown
  factory FareBreakdown.initial({
    double baseFare = AppDefaults.baseFare,
    double perKmRate = AppDefaults.perKmRate,
    double waitingRatePerMin = AppDefaults.waitingRatePerMin,
  }) {
    return FareBreakdown(
      baseFare: baseFare,
      distanceKm: 0.0,
      perKmRate: perKmRate,
      distanceFare: 0.0,
      waitingDurationSeconds: 0,
      waitingMinutes: 0,
      waitingRatePerMin: waitingRatePerMin,
      waitingFare: 0.0,
      totalFare: baseFare,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fare': baseFare,
      'distance_km': distanceKm,
      'per_km_rate': perKmRate,
      'distance_fare': distanceFare,
      'waiting_duration_seconds': waitingDurationSeconds,
      'waiting_minutes': waitingMinutes,
      'waiting_rate_per_min': waitingRatePerMin,
      'waiting_fare': waitingFare,
      'total_fare': totalFare,
    };
  }

  factory FareBreakdown.fromJson(Map<String, dynamic> json) {
    return FareBreakdown(
      baseFare: (json['base_fare'] as num?)?.toDouble() ?? AppDefaults.baseFare,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      perKmRate: (json['per_km_rate'] as num?)?.toDouble() ?? AppDefaults.perKmRate,
      distanceFare: (json['distance_fare'] as num?)?.toDouble() ?? 0.0,
      waitingDurationSeconds: (json['waiting_duration_seconds'] as num?)?.toInt() ?? 0,
      waitingMinutes: (json['waiting_minutes'] as num?)?.toInt() ?? 0,
      waitingRatePerMin:
          (json['waiting_rate_per_min'] as num?)?.toDouble() ?? AppDefaults.waitingRatePerMin,
      waitingFare: (json['waiting_fare'] as num?)?.toDouble() ?? 0.0,
      totalFare: (json['total_fare'] as num?)?.toDouble() ?? AppDefaults.baseFare,
    );
  }
}
