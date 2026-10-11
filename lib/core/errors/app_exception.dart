/// Base exception class for all AutoMeter domain and infrastructure errors.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

/// Errors related to device GPS and location positioning.
class LocationException extends AppException {
  final bool isPermissionDenied;
  final bool isGpsDisabled;

  const LocationException(
    super.message, {
    super.code,
    super.details,
    this.isPermissionDenied = false,
    this.isGpsDisabled = false,
  });

  factory LocationException.permissionDenied() {
    return const LocationException(
      'Location permission was denied. Please enable GPS permissions in settings.',
      code: 'LOCATION_PERMISSION_DENIED',
      isPermissionDenied: true,
    );
  }

  factory LocationException.serviceDisabled() {
    return const LocationException(
      'Location services are turned off on your device. Please turn on GPS.',
      code: 'LOCATION_SERVICE_DISABLED',
      isGpsDisabled: true,
    );
  }
}

/// Errors related to local persistent storage (SharedPreferences / SQLite).
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.details});
}

/// Errors related to network connectivity and transport.
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

/// Errors returned by backend REST / Supabase APIs.
class ApiException extends AppException {
  final int? statusCode;

  const ApiException(super.message, {super.code, super.details, this.statusCode});
}

/// Errors related to UPI and payment flows.
class PaymentException extends AppException {
  const PaymentException(super.message, {super.code, super.details});

  factory PaymentException.invalidUpiId(String upiId) {
    return PaymentException(
      'Invalid UPI ID format: "$upiId". Must be formatted as username@bank.',
      code: 'INVALID_UPI_ID',
    );
  }

  factory PaymentException.appLaunchFailed(String uri) {
    return PaymentException(
      'Failed to launch UPI payment app on this device.',
      code: 'UPI_LAUNCH_FAILED',
      details: uri,
    );
  }
}

/// Errors related to fare calculation or trip lifecycle state transitions.
class TripException extends AppException {
  const TripException(super.message, {super.code, super.details});

  factory TripException.invalidStateTransition(String current, String target) {
    return TripException(
      'Cannot transition trip state from $current to $target.',
      code: 'INVALID_TRIP_STATE',
    );
  }
}
