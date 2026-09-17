import '../core/constants/app_defaults.dart';

class FareConfig {
  final double baseFare;
  final double perKmRate;
  final double waitingRatePerMin;
  final double minDistanceKm; // Distance included in base fare (0.0 for pure flat base + distance)
  final String currency;

  const FareConfig({
    this.baseFare = AppDefaults.baseFare,
    this.perKmRate = AppDefaults.perKmRate,
    this.waitingRatePerMin = AppDefaults.waitingRatePerMin,
    this.minDistanceKm = 0.0,
    this.currency = AppDefaults.currency,
  });

  FareConfig copyWith({
    double? baseFare,
    double? perKmRate,
    double? waitingRatePerMin,
    double? minDistanceKm,
    String? currency,
  }) {
    return FareConfig(
      baseFare: baseFare ?? this.baseFare,
      perKmRate: perKmRate ?? this.perKmRate,
      waitingRatePerMin: waitingRatePerMin ?? this.waitingRatePerMin,
      minDistanceKm: minDistanceKm ?? this.minDistanceKm,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fare': baseFare,
      'per_km_rate': perKmRate,
      'waiting_rate_per_min': waitingRatePerMin,
      'min_distance_km': minDistanceKm,
      'currency': currency,
    };
  }

  factory FareConfig.fromJson(Map<String, dynamic> json) {
    return FareConfig(
      baseFare: (json['base_fare'] as num?)?.toDouble() ?? AppDefaults.baseFare,
      perKmRate: (json['per_km_rate'] as num?)?.toDouble() ?? AppDefaults.perKmRate,
      waitingRatePerMin: (json['waiting_rate_per_min'] as num?)?.toDouble() ?? AppDefaults.waitingRatePerMin,
      minDistanceKm: (json['min_distance_km'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? AppDefaults.currency,
    );
  }
}
