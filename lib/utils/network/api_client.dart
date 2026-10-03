import 'package:dio/dio.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/local_storage/token_storage.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/network/api_log_interceptor.dart';
import 'package:micro_lending_app/utils/network/auth_interceptor.dart';

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

  late final Dio _dio;

  /// Set once in main(): send the user to the login screen.
  void Function()? onSessionExpired;

  Options _opts(bool auth) => Options(extra: {kSkipAuth: !auth});

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) =>
      _send(() => _dio.get(path, queryParameters: query, options: _opts(auth)));

  Future<dynamic> post(String path, {Object? data, bool auth = true}) =>
      _send(() => _dio.post(path, data: data, options: _opts(auth)));

  Future<dynamic> put(String path, {Object? data, bool auth = true}) =>
      _send(() => _dio.put(path, data: data, options: _opts(auth)));

  Future<dynamic> patch(String path, {Object? data, bool auth = true}) =>
      _send(() => _dio.patch(path, data: data, options: _opts(auth)));

  Future<dynamic> delete(String path, {Object? data, bool auth = true}) =>
      _send(() => _dio.delete(path, data: data, options: _opts(auth)));

  /// Returns the response body, or throws ApiException.
  Future<dynamic> _send(Future<Response<dynamic>> Function() call) async {
    try {
      return (await call()).data;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
