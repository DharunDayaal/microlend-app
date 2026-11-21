import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_endpoints.dart';

/// Raw HTTP calls for auth.
class AuthRemoteDataSource {
  final ApiClient _api;
  const AuthRemoteDataSource(this._api);

  Future<dynamic> loginWithEmail(String email, String password) => _api.post(
    ApiEndpoints.loginWithEmail,
    data: {"email": email, "password": password},
    auth: false,
  );

  Future<dynamic> loginWithPhone(String phone, String otp, String purpose) =>
      _api.post(
        ApiEndpoints.loginWithPhone,
        data: {"phone_number": phone, "otp_code": otp, "purpose": purpose},
      );

  Future<dynamic> sendOtp(String phone, String purpose) => _api.post(
    ApiEndpoints.sendOtp,
    data: {"phone_number": phone, "purpose": purpose},
  );

  Future<dynamic> verifyOtp(String phone, String otp, String purpose) =>
      _api.post(
        ApiEndpoints.verifyOtp,
        data: {"phone_number": phone, "otp_code": otp, "purpose": purpose},
      );

  Future<dynamic> resetPassword(Map<String, dynamic> body) =>
      _api.post(ApiEndpoints.resetPassword, data: body);

  Future<dynamic> register(Map<String, dynamic> body) =>
      _api.post(ApiEndpoints.register, data: body);

  Future<dynamic> logout(String refreshToken) =>
      _api.post(ApiEndpoints.logout, data: {"refresh_token": refreshToken});
}
