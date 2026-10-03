import 'package:dio/dio.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/local_storage/token_storage.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

const String kSkipAuth = 'skipAuth'; // public routes: login, OTP, register
const String kRetried = 'retried'; // set after one retry, prevents loops

class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.dio,
    required this.refreshDio,
    required this.storage,
    required this.onSessionExpired,
  });

  final Dio dio;
  final Dio refreshDio;
  final TokenStorage storage;
  final void Function() onSessionExpired;

  /// Shared by all requests that fail at the same time. The server rotates
  /// the refresh token and detects reuse, so two parallel refreshes with the
  /// same token would look like a stolen token. Only one refresh may run.
  Future<bool>? _refreshing;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[kSkipAuth] != true) {
      final token = await storage.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;

    if (err.response?.statusCode != 401 || req.extra[kSkipAuth] == true) {
      return handler.next(err);
    }

    final code = ApiException.codeFrom(err.response?.data);

    if (code == 'TOKEN_EXPIRED') {
      // Already retried once and still expired: give up.
      if (req.extra[kRetried] == true) {
        await _endSession();
        return handler.next(err);
      }

      // If another request already refreshed while this one was in flight,
      // the stored token differs from the one this request sent. Just retry.
      final current = await storage.accessToken;
      final alreadyRefreshed =
          current != null && req.headers['Authorization'] != 'Bearer $current';

      final ok = alreadyRefreshed || await _refresh();
      if (!ok) return handler.next(err);

      try {
        req.extra[kRetried] = true;
        final response = await dio.fetch(req); // onRequest adds the new token
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    // Token is broken or the account was deactivated: refreshing won't help.
    if (code == 'TOKEN_INVALID' ||
        code == 'TOKEN_MISSING' ||
        code == 'ACCOUNT_INACTIVE') {
      await _endSession();
    }

    handler.next(err);
  }

  Future<bool> _refresh() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<bool> _doRefresh() async {
    final refreshToken = await storage.refreshToken;
    if (refreshToken == null) {
      await _endSession();
      return false;
    }

    try {
      final res = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(extra: {kSkipAuth: true}),
      );

      final tokens = _extractTokens(res.data);
      final newAccess = tokens?['access_token'];
      final newRefresh = tokens?['refresh_token'];

      if (newAccess is! String || newRefresh is! String) {
        AppLogger.error('Refresh response missing tokens', tag: 'Auth');
        return false;
      }

      await storage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );
      AppLogger.info('Access token refreshed', tag: 'Auth');
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Refresh token rejected (expired, revoked, reuse detected): log out.
      if (status == 401 || status == 403) {
        await _endSession();
      }
      // No status = no network. Keep the session so the user can retry later.
      return false;
    } catch (e, st) {
      AppLogger.error('Refresh failed', tag: 'Auth', error: e, stack: st);
      return false;
    }
  }

  /// Matches: { success, message, data: { tokens: { access_token, refresh_token } } }
  static Map? _extractTokens(dynamic body) {
    if (body is! Map) return null;
    final data = body['data'];
    if (data is! Map) return null;
    final tokens = data['tokens'];
    return tokens is Map ? tokens : null;
  }

  Future<void> _endSession() async {
    if (!await storage.hasSession) return; // already ended by another request
    await storage.clear();
    AppLogger.warning('Session ended, sending user to login', tag: 'Auth');
    onSessionExpired();
  }
}
