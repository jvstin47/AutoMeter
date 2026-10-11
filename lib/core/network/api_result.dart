import '../errors/failures.dart';

/// Type-safe Result container for asynchronous API and repository operations.
class ApiResult<T> {
  final T? data;
  final Failure? failure;
  final bool isSuccess;

  const ApiResult._({this.data, this.failure, required this.isSuccess});

  factory ApiResult.success(T data) {
    return ApiResult._(data: data, isSuccess: true);
  }

  factory ApiResult.failure(Failure failure) {
    return ApiResult._(failure: failure, isSuccess: false);
  }

  /// Transforms the result depending on whether it is success or failure.
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    } else {
      return onFailure(failure ?? const GeneralFailure('Unknown operation failure'));
    }
  }

  /// Fold helper with fallback.
  T getOrElse(T Function() fallback) {
    if (isSuccess && data != null) {
      return data as T;
    }
    return fallback();
  }
}
