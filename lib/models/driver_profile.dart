import '../core/constants/app_defaults.dart';

class DriverProfile {
  final String name;
  final String upiId;
  final String vehicleNumber;

  const DriverProfile({
    this.name = AppDefaults.driverName,
    this.upiId = AppDefaults.upiId,
    this.vehicleNumber = AppDefaults.vehicleNumber,
  });

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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'upi_id': upiId,
      'vehicle_number': vehicleNumber,
    };
  }

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    return DriverProfile(
      name: json['name'] as String? ?? AppDefaults.driverName,
      upiId: json['upi_id'] as String? ?? AppDefaults.upiId,
      vehicleNumber: json['vehicle_number'] as String? ?? AppDefaults.vehicleNumber,
    );
  }
}
