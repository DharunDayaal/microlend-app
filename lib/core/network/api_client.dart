import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/core/network/api_endpoints.dart';
import 'package:micro_lending_app/core/storage/token_storage.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/network/api_log_interceptor.dart';
import 'package:micro_lending_app/core/network/auth_interceptor.dart';
import 'package:micro_lending_app/core/network/response_cache.dart';

class ApiClient {
  ApiClient._() {
    final options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);

    final refreshDio = Dio(options.copyWith())
      ..interceptors.add(ApiLogInterceptor());

    _dio.interceptors.addAll([
      ApiLogInterceptor(),
      AuthInterceptor(
        dio: _dio,
        refreshDio: refreshDio,
        storage: TokenStorage.instance,
        onSessionExpired: () => onSessionExpired?.call(),
      ),
    ]);
  }

  static final ApiClient instance = ApiClient._();

  /// For tests: a client over [dio] with no interceptors.
  @visibleForTesting
  ApiClient.withDio(Dio dio) : _dio = dio;

  late final Dio _dio;

  /// Set in bootstrap. Told how long each request took and how it ended
  /// (null error = answered), to judge the connection.
  void Function(Duration elapsed, ApiException? error)? onResult;

  /// Set in bootstrap. Keeps the last answer to each GET so screens still
  /// open when the network is down.
  ResponseCache? cache;

  /// Set once in main(): send the user to the login screen.
  void Function()? onSessionExpired;

  Options _opts(bool auth, [Map<String, String>? headers]) =>
      Options(extra: {kSkipAuth: !auth}, headers: headers);

  /// When the network fails (no connection or timeout), returns the last
  /// saved answer for the same request if there is one.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) async {
    final store = auth ? cache : null; // only signed-in data is kept
    final key = cacheKey(path, query);
    try {
      final data = await _send(
        () => _dio.get(path, queryParameters: query, options: _opts(auth)),
      );
      if (store != null) unawaited(store.write(key, data));
      return data;
    } on ApiException catch (e) {
      if (store == null || !e.isNetworkError) rethrow;
      final saved = await store.read(key);
      if (saved == null) rethrow;
      return saved;
    }
  }

  /// Path plus sorted query, so the same request always has the same key.
  @visibleForTesting
  static String cacheKey(String path, Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return path;
    final keys = query.keys.toList()..sort();
    return '$path?${keys.map((k) => '$k=${query[k]}').join('&')}';
  }

  Future<dynamic> post(
    String path, {
    Object? data,
    bool auth = true,
    Map<String, String>? headers,
  }) => _send(() => _dio.post(path, data: data, options: _opts(auth, headers)));

  Future<dynamic> put(String path, {Object? data, bool auth = true}) =>
      _send(() => _dio.put(path, data: data, options: _opts(auth)));

  Future<dynamic> patch(String path, {Object? data, bool auth = true}) =>
      _send(() => _dio.patch(path, data: data, options: _opts(auth)));

  Future<dynamic> delete(String path, {Object? data, bool auth = true}) =>
      _send(() => _dio.delete(path, data: data, options: _opts(auth)));

  /// Returns the response body, or throws ApiException.
  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    final watch = Stopwatch()..start();
    try {
      final data = (await call()).data;
      onResult?.call(watch.elapsed, null);
      return data;
    } on DioException catch (e) {
      final error = ApiException.fromDio(e);
      onResult?.call(watch.elapsed, error);
      throw error;
    }
  }
}
