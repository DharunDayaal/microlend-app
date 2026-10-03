import 'package:dio/dio.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';

class ApiLogInterceptor extends Interceptor {
  static const _startKey = '_started_at';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startKey] = DateTime.now();
    final body = options.data is Map<String, dynamic>
        ? options.data as Map<String, dynamic>
        : null;
    AppLogger.request(options.method, options.path, body: body);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final o = response.requestOptions;
    AppLogger.response(o.method, o.path, response.statusCode ?? 0, _elapsed(o));
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final o = err.requestOptions;
    final status = err.response?.statusCode;
    if (status != null) {
      AppLogger.response(o.method, o.path, status, _elapsed(o));
    } else {
      AppLogger.warning(
        '✕ ${o.method} ${o.path} (${err.type.name})',
        tag: 'API',
      );
    }
    handler.next(err);
  }

  Duration _elapsed(RequestOptions o) {
    final started = o.extra[_startKey];
    return started is DateTime
        ? DateTime.now().difference(started)
        : Duration.zero;
  }
}
