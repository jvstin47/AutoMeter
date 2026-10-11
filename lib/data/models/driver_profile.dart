import 'package:flutter/foundation.dart';
import '../../core/constants/app_defaults.dart';

/// Immutable driver profile information for meter ownership & UPI payments.
@immutable
class DriverProfile {
  /// Registered driver full name
  final String name;

  /// Merchant / Personal UPI VPA address (e.g. driver@oksbi)
  final String upiId;

  /// Regional Transport Office (RTO) vehicle registration number
  final String vehicleNumber;

  const DriverProfile({
    this.name = AppDefaults.driverName,
    this.upiId = AppDefaults.upiId,
    this.vehicleNumber = AppDefaults.vehicleNumber,
  });

  /// Creates a copy of [DriverProfile] with updated fields.
  DriverProfile copyWith({
    String? name,
    String? upiId,
    String? vehicleNumber,
  }) {
    return DriverProfile(
      name: name ?? this.name,
      upiId: upiId ?? this.upiId,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
    );
  }

  /// Converts this profile to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'upi_id': upiId,
      'vehicle_number': vehicleNumber,
    };
  }

  /// Deserializes a [DriverProfile] from a JSON map with defaults.
  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      name: json['name'] as String? ?? AppDefaults.driverName,
      upiId: json['upi_id'] as String? ?? AppDefaults.upiId,
      vehicleNumber: json['vehicle_number'] as String? ?? AppDefaults.vehicleNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverProfile &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          upiId == other.upiId &&
          vehicleNumber == other.vehicleNumber;

  @override
  int get hashCode => name.hashCode ^ upiId.hashCode ^ vehicleNumber.hashCode;
}
