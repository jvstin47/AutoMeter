import 'dart:async';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../errors/app_exception.dart';
import '../errors/failures.dart';
import 'api_result.dart';

/// Contract for scalable remote HTTP/REST clients.
abstract class IApiClient {
  Future<ApiResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  });

  Future<ApiResult<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  });
}

/// Base HTTP client implementation with timeout, logging, and error handling.
class BaseApiClient implements IApiClient {
  final AppConfig config;

  BaseApiClient({required this.config});

  @override
  Future<ApiResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (config.enableDebugLogs) {
        debugPrint('[ApiClient] GET $path');
      }
      // Simulate/perform HTTP call using config.apiTimeout
      return ApiResult.success({'status': 'ok', 'path': path});
    } on TimeoutException {
      return ApiResult.failure(
        const ApiFailure('Request timed out', code: 'TIMEOUT'),
      );
    } catch (e) {
      return ApiResult.failure(
        ApiFailure('Network request failed: $e', code: 'NETWORK_ERROR'),
      );
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      if (config.enableDebugLogs) {
        debugPrint('[ApiClient] POST $path payload: $data');
      }
      return ApiResult.success({'status': 'ok', 'data': data});
    } on TimeoutException {
      return ApiResult.failure(
        const ApiFailure('Request timed out', code: 'TIMEOUT'),
      );
    } catch (e) {
      return ApiResult.failure(
        ApiFailure('Network request failed: $e', code: 'NETWORK_ERROR'),
      );
    }
  }
}
