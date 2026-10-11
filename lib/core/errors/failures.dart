import 'app_exception.dart';

/// Presentation-layer failure abstraction for safe UI rendering.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => message;
}

class LocationFailure extends Failure {
  const LocationFailure(super.message, {super.code});

  factory LocationFailure.fromException(LocationException e) =>
      LocationFailure(e.message, code: e.code);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code});

  factory StorageFailure.fromException(StorageException e) =>
      StorageFailure(e.message, code: e.code);
}

class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure(super.message, {super.code, this.statusCode});

  factory ApiFailure.fromException(ApiException e) =>
      ApiFailure(e.message, code: e.code, statusCode: e.statusCode);
}

class PaymentFailure extends Failure {
  const PaymentFailure(super.message, {super.code});

  factory PaymentFailure.fromException(PaymentException e) =>
      PaymentFailure(e.message, code: e.code);
}

class GeneralFailure extends Failure {
  const GeneralFailure(super.message, {super.code});
}
