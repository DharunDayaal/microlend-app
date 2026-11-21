import 'package:dio/dio.dart';

/// The only error type your repositories and UI need to catch.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? code; // TOKEN_EXPIRED, FORBIDDEN, NO_INTERNET, ...

  const ApiException({this.statusCode, required this.message, this.code});

  bool get isNetworkError => statusCode == null;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;

  /// Reads `code` from { code } or { error: { code } }.
  static String? codeFrom(dynamic data) {
    if (data is! Map) return null;
    if (data['code'] is String) return data['code'] as String;
    if (data['type'] is String) return data['type'] as String;
    return null;
  }

  static String? _messageFrom(dynamic data) {
    if (data is! Map) return null;
    if (data['message'] is String) return data['message'] as String;
    final err = data['error'];
    if (err is Map && err['message'] is String) return err['message'] as String;
    return null;
  }

  factory ApiException.fromDio(DioException e) {
    final res = e.response;
    if (res != null) {
      return ApiException(
        statusCode: res.statusCode,
        message:
            _messageFrom(res.data) ??
            'Something went wrong (${res.statusCode})',
        code: codeFrom(res.data),
      );
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Request timed out. Check your connection and try again.',
          code: 'TIMEOUT',
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection',
          code: 'NO_INTERNET',
        );
      default:
        return const ApiException(
          message: 'Something went wrong. Try again.',
          code: 'UNKNOWN',
        );
    }
  }

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
