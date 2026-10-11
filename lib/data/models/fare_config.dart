import 'package:flutter/foundation.dart';
import '../../core/constants/app_defaults.dart';

/// Immutable configuration for tariff and fare computation.
@immutable
class FareConfig {
  /// Base pickup/flag-down fare in native currency (INR)
  final double baseFare;

  /// Running distance rate per kilometer
  final double perKmRate;

  /// Waiting time rate per minute
  final double waitingRatePerMin;

  /// Initial distance included in the base fare (e.g. 1.5 km in Bangalore/Mumbai)
  final double minDistanceKm;

  /// Currency code or symbol
  final String currency;

  const FareConfig({
    this.baseFare = AppDefaults.baseFare,
    this.perKmRate = AppDefaults.perKmRate,
    this.waitingRatePerMin = AppDefaults.waitingRatePerMin,
    this.minDistanceKm = 0.0,
    this.currency = AppDefaults.currency,
  });

  /// Creates a copy of [FareConfig] with updated properties.
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

  /// Converts this configuration to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'base_fare': baseFare,
      'per_km_rate': perKmRate,
      'waiting_rate_per_min': waitingRatePerMin,
      'min_distance_km': minDistanceKm,
      'currency': currency,
    };
  }

  /// Deserializes a [FareConfig] from a JSON map with safe defaults.
  factory FareConfig.fromJson(Map<String, dynamic> json) {
    return FareConfig(
      baseFare: (json['base_fare'] as num?)?.toDouble() ?? AppDefaults.baseFare,
      perKmRate: (json['per_km_rate'] as num?)?.toDouble() ?? AppDefaults.perKmRate,
      waitingRatePerMin:
          (json['waiting_rate_per_min'] as num?)?.toDouble() ?? AppDefaults.waitingRatePerMin,
      minDistanceKm: (json['min_distance_km'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? AppDefaults.currency,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FareConfig &&
          runtimeType == other.runtimeType &&
          baseFare == other.baseFare &&
          perKmRate == other.perKmRate &&
          waitingRatePerMin == other.waitingRatePerMin &&
          minDistanceKm == other.minDistanceKm &&
          currency == other.currency;

  @override
  int get hashCode =>
      baseFare.hashCode ^
      perKmRate.hashCode ^
      waitingRatePerMin.hashCode ^
      minDistanceKm.hashCode ^
      currency.hashCode;
}
