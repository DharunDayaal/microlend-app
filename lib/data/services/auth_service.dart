import 'package:micro_lending_app/routes/auth_notifier.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/local_storage/token_storage.dart';
import 'package:micro_lending_app/utils/network/api_client.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class AuthService {
  AuthService._();

  static final _api = ApiClient.instance;

  static Future<void> _saveTokens(dynamic res) async {
    final data = res is Map ? res['data'] : null;
    final tokens = data is Map ? data['tokens'] : null;
    final accessToken = tokens is Map ? tokens['access_token'] : null;
    final refreshToken = tokens is Map ? tokens['refresh_token'] : null;

    if (accessToken is! String || refreshToken is! String) {
      throw const ApiException(
        message: "Unexpected response from server",
        code: "BAD_RESPONSE",
      );
    }

    await TokenStorage.instance.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  static Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      ApiEndpoints.loginWithEmail,
      data: {"email": email, "password": password},
      auth: false,
    );
    await _saveTokens(response);
    AuthNotifier.instance.signedIn();
  }

  static Future<void> loginWithPhone({
    required String phoneNumber,
    required String optCode,
    required String purpose,
  }) async {
    final response = await _api.post(
      ApiEndpoints.loginWithPhone,
      data: {
        "phone_number": phoneNumber,
        "otp_code": optCode,
        "purpose": purpose,
      },
    );

    await _saveTokens(response);
    AuthNotifier.instance.signedIn();
  }

  static Future<void> logout() async {
    try {
      final refreshToken = await TokenStorage.instance.refreshToken;
      if (refreshToken != null) {
        await _api.post(
          ApiEndpoints.logout,
          data: {"refresh_token": refreshToken},
        );
      }
    } on ApiException {
      // Even logout fails log out locally.
    } finally {
      await TokenStorage.instance.clear();
      AuthNotifier.instance.signedOut();
    }
  }
}
