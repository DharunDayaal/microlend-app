import 'package:micro_lending_app/data/models/auth_modal.dart';
import 'package:micro_lending_app/routes/auth_notifier.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/local_storage/token_storage.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';
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

  static bool _isNotVerified(ApiException e) {
    if (e.statusCode != 403) return false;
    if (e.code == 'ACCOUNT_PENDING_APPROVAL') {
      return true;
    }
    return e.message.toLowerCase().contains('pending approval');
  }

  static bool _isNotActive(ApiException e) {
    if (e.statusCode != 403) return false;
    if (e.code == 'ACCOUNT_DEACTIVATED') {
      return true;
    }

    return e.message.toLowerCase().contains('deactivated');
  }

  static Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.loginWithEmail,
        data: {"email": email, "password": password},
        auth: false,
      );
      AppLogger.info(response.toString());
      if (response is Map) {
        if (response["data"]["is_verified"] == false) {
          AuthNotifier.instance.pendingApproval();
          return;
        }
        if (response["data"]["is_active"] == false) {
          AuthNotifier.instance.signedOut();
          return;
        }
      }

      await _saveTokens(response);
      AuthNotifier.instance.signedIn();
    } on ApiException catch (e) {
      if (_isNotVerified(e)) {
        AuthNotifier.instance.pendingApproval();
        return;
      }
      if (_isNotActive(e)) {
        AuthNotifier.instance.signedOut();
        return;
      }
      rethrow;
    }
  }

  static Future<void> loginWithPhone({
    required String phoneNumber,
    required String optCode,
    required String purpose,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.loginWithPhone,
        data: {
          "phone_number": phoneNumber,
          "otp_code": optCode,
          "purpose": purpose,
        },
      );
      AppLogger.info(response.toString());
      if (response is Map) {
        if (response["data"]["is_verified"] == false) {
          AuthNotifier.instance.pendingApproval();
          return;
        }
        if (response["data"]["is_active"] == false) {
          AuthNotifier.instance.signedOut();
          return;
        }
      }
      await _saveTokens(response);
      AuthNotifier.instance.signedIn();
    } on ApiException catch (e) {
      if (_isNotVerified(e)) {
        AuthNotifier.instance.pendingApproval();
        return;
      }
      if (_isNotActive(e)) {
        AuthNotifier.instance.signedOut();
        return;
      }
      rethrow;
    }
  }

  static Future<Otp> sendOtpCode({
    required String phoneNumber,
    required String purpose,
  }) async {
    try {
      final response = await _api.post(
        ApiEndpoints.sendOtp,
        data: {"phone_number": phoneNumber, "purpose": purpose},
      );

      final otpReponse = response as Map<String, dynamic>;
      return Otp.fromjson(otpReponse);
    } on ApiException catch (e) {
      rethrow;
    }
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
