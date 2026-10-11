/// Centralized reusable input validation logic for forms and domain entities.
class Validators {
  /// Validates driver full name.
  static String? validateDriverName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Driver name is required';
    }
    if (value.trim().length < 2) {
      return 'Driver name must be at least 2 characters';
    }
    return null;
  }

  /// Validates standard Indian UPI ID (VPA).
  static String? validateUpiId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UPI ID is required for digital payments';
    }
    final trimmed = value.trim();
    final regex = RegExp(r'^[a-zA-Z0-9.\-_]{2,256}@[a-zA-Z]{2,64}$');
    if (!regex.hasMatch(trimmed)) {
      return 'Enter a valid UPI ID (e.g. driver@oksbi or phone@paytm)';
    }
    return null;
  }

  /// Validates Indian vehicle registration plate number (e.g. KA-01-AB-1234).
  static String? validateVehicleNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vehicle registration number is required';
    }
    final trimmed = value.trim().toUpperCase();
    if (trimmed.length < 5) {
      return 'Enter a valid vehicle registration number';
    }
    return null;
  }

  /// Validates positive monetary amounts or tariff rates.
  static String? validatePositiveAmount(String? value, {required String fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid numeric amount';
    }
    if (parsed < 0) {
      return '$fieldName cannot be negative';
    }
    return null;
  }
}
