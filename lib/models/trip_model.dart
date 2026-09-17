class TripModel {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final double distanceKm;
  final int waitingDurationSeconds;
  final int tripDurationSeconds;
  final double baseFare;
  final double distanceFare;
  final double waitingFare;
  final double totalFare;
  final String paymentMethod; // 'upi', 'cash', 'unselected'
  final String paymentStatus; // 'not_started', 'pending', 'confirmed'
  final String? paymentReference;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final bool isSynced;
  final bool isDemo;
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

  /// Supabase database row mapping
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

  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time'] as String) : null,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? (json['distance'] as num?)?.toDouble() ?? 0.0,
      waitingDurationSeconds: (json['waiting_duration_seconds'] as num?)?.toInt() ?? (json['waiting_time'] as num?)?.toInt() ?? 0,
      tripDurationSeconds: (json['trip_duration_seconds'] as num?)?.toInt() ?? (json['duration'] as num?)?.toInt() ?? 0,
      baseFare: (json['base_fare'] as num).toDouble(),
      distanceFare: (json['distance_fare'] as num).toDouble(),
      waitingFare: (json['waiting_fare'] as num).toDouble(),
      totalFare: (json['total_fare'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String? ?? 'unselected',
      paymentStatus: json['payment_status'] as String? ?? 'not_started',
      paymentReference: json['payment_reference'] as String?,
      startLatitude: (json['start_latitude'] as num?)?.toDouble(),
      startLongitude: (json['start_longitude'] as num?)?.toDouble(),
      endLatitude: (json['end_latitude'] as num?)?.toDouble(),
      endLongitude: (json['end_longitude'] as num?)?.toDouble(),
      isSynced: json['is_synced'] as bool? ?? false,
      isDemo: json['is_demo'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }
}
