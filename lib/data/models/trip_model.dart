import 'package:flutter/foundation.dart';

/// Immutable trip record capturing lifecycle metrics, telemetry, and payment state.
@immutable
class TripModel {
  /// Unique identifier (UUID v4)
  final String id;

  /// Trip start timestamp
  final DateTime startTime;

  /// Trip conclusion timestamp (null if still active)
  final DateTime? endTime;

  /// Total distance traveled in kilometers
  final double distanceKm;

  /// Accumulated stationary/waiting time in seconds
  final int waitingDurationSeconds;

  /// Total elapsed trip time in seconds
  final int tripDurationSeconds;

  /// Fixed base fare component (INR)
  final double baseFare;

  /// Running distance fare component (INR)
  final double distanceFare;

  /// Accumulated waiting fare component (INR)
  final double waitingFare;

  /// Final regulated total fare (INR)
  final double totalFare;

  /// Payment channel: 'upi', 'cash', 'unselected'
  final String paymentMethod;

  /// Transaction state: 'not_started', 'pending', 'confirmed'
  final String paymentStatus;

  /// NPCI UPI transaction reference (e.g. MTR-ABC123)
  final String? paymentReference;

  /// GPS start coordinate
  final double? startLatitude;
  final double? startLongitude;

  /// GPS destination coordinate
  final double? endLatitude;
  final double? endLongitude;

  /// Cloud synchronization status
  final bool isSynced;

  /// Whether generated during simulation demo mode
  final bool isDemo;

  /// Local creation timestamp
  final DateTime createdAt;

  const TripModel({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.distanceKm,
    required this.waitingDurationSeconds,
    required this.tripDurationSeconds,
    required this.baseFare,
    required this.distanceFare,
    required this.waitingFare,
    required this.totalFare,
    this.paymentMethod = 'unselected',
    this.paymentStatus = 'not_started',
    this.paymentReference,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.isSynced = false,
    this.isDemo = false,
    required this.createdAt,
  });

  /// Creates a copy with modified attributes.
  TripModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    double? distanceKm,
    int? waitingDurationSeconds,
    int? tripDurationSeconds,
    double? baseFare,
    double? distanceFare,
    double? waitingFare,
    double? totalFare,
    String? paymentMethod,
    String? paymentStatus,
    String? paymentReference,
    double? startLatitude,
    double? startLongitude,
    double? endLatitude,
    double? endLongitude,
    bool? isSynced,
    bool? isDemo,
    DateTime? createdAt,
  }) {
    return TripModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceKm: distanceKm ?? this.distanceKm,
      waitingDurationSeconds: waitingDurationSeconds ?? this.waitingDurationSeconds,
      tripDurationSeconds: tripDurationSeconds ?? this.tripDurationSeconds,
      baseFare: baseFare ?? this.baseFare,
      distanceFare: distanceFare ?? this.distanceFare,
      waitingFare: waitingFare ?? this.waitingFare,
      totalFare: totalFare ?? this.totalFare,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentReference: paymentReference ?? this.paymentReference,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
      isSynced: isSynced ?? this.isSynced,
      isDemo: isDemo ?? this.isDemo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts this trip model to a local JSON representation.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'distance_km': distanceKm,
      'waiting_duration_seconds': waitingDurationSeconds,
      'trip_duration_seconds': tripDurationSeconds,
      'base_fare': baseFare,
      'distance_fare': distanceFare,
      'waiting_fare': waitingFare,
      'total_fare': totalFare,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'payment_reference': paymentReference,
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
      'end_latitude': endLatitude,
      'end_longitude': endLongitude,
      'is_synced': isSynced,
      'is_demo': isDemo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Converts this trip model to a Supabase database row mapping.
  Map<String, dynamic> toSupabaseMap() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'distance': distanceKm,
      'waiting_time': waitingDurationSeconds,
      'duration': tripDurationSeconds,
      'base_fare': baseFare,
      'distance_fare': distanceFare,
      'waiting_fare': waitingFare,
      'total_fare': totalFare,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'payment_reference': paymentReference,
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
      'end_latitude': endLatitude,
      'end_longitude': endLongitude,
      'is_demo': isDemo,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Safely deserializes a [TripModel] from a JSON map with type coercion.
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time'] as String) : null,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ??
          (json['distance'] as num?)?.toDouble() ??
          0.0,
      waitingDurationSeconds: (json['waiting_duration_seconds'] as num?)?.toInt() ??
          (json['waiting_time'] as num?)?.toInt() ??
          0,
      tripDurationSeconds: (json['trip_duration_seconds'] as num?)?.toInt() ??
          (json['duration'] as num?)?.toInt() ??
          0,
      baseFare: (json['base_fare'] as num?)?.toDouble() ?? 0.0,
      distanceFare: (json['distance_fare'] as num?)?.toDouble() ?? 0.0,
      waitingFare: (json['waiting_fare'] as num?)?.toDouble() ?? 0.0,
      totalFare: (json['total_fare'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? 'unselected',
      paymentStatus: json['payment_status'] as String? ?? 'not_started',
      paymentReference: json['payment_reference'] as String?,
      startLatitude: (json['start_latitude'] as num?)?.toDouble(),
      startLongitude: (json['start_longitude'] as num?)?.toDouble(),
      endLatitude: (json['end_latitude'] as num?)?.toDouble(),
      endLongitude: (json['end_longitude'] as num?)?.toDouble(),
      isSynced: json['is_synced'] as bool? ?? false,
      isDemo: json['is_demo'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
