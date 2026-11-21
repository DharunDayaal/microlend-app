import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/auth/data/dtos/auth_dto.dart';
import 'package:micro_lending_app/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:micro_lending_app/features/auth/domain/auth_repository.dart';
import 'package:micro_lending_app/features/auth/domain/entities/auth.dart';
import 'package:micro_lending_app/features/auth/domain/login_result.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  const AuthRepositoryImpl(this._remote);

  static const _badResponse = ApiException(
    message: 'Unexpected response from server',
    code: 'BAD_RESPONSE',
  );

  static bool _isNotVerified(ApiException e) {
    if (e.statusCode != 403) return false;
    if (e.code == 'ACCOUNT_PENDING_APPROVAL') return true;
    return e.message.toLowerCase().contains('pending approval');
  }

  static bool _isNotActive(ApiException e) {
    if (e.statusCode != 403) return false;
    if (e.code == 'ACCOUNT_DEACTIVATED') return true;
    return e.message.toLowerCase().contains('deactivated');
  }

  /// Reads a login answer: the account flags first, then tokens and user.
  static LoginResult _login(dynamic res) {
    if (res is Map) {
      if (res["data"]["is_verified"] == false) {
        return const LoginPendingApproval();
      }
      if (res["data"]["is_active"] == false) return const LoginDeactivated();
    }
    final data = res is Map ? res['data'] : null;
    final tokens = data is Map ? data['tokens'] : null;
    final access = tokens is Map ? tokens['access_token'] : null;
    final refresh = tokens is Map ? tokens['refresh_token'] : null;
    final admin = data is Map ? data['admin'] : null;
    if (access is! String || refresh is! String || admin is! Map) {
      throw _badResponse;
    }
    return LoginSucceeded(
      accessToken: access,
      refreshToken: refresh,
      user: AdminUser.fromJson(Map<String, dynamic>.from(admin)),
    );
  }

  /// 403s that mean "pending" or "deactivated" are results, not errors.
  static Future<LoginResult> _guard(Future<dynamic> Function() call) async {
    try {
      return _login(await call());
    } on ApiException catch (e) {
      if (_isNotVerified(e)) return const LoginPendingApproval();
      if (_isNotActive(e)) return const LoginDeactivated();
      rethrow;
    }
  }

  @override
  Future<LoginResult> loginWithEmail({
    required String email,
    required String password,
  }) => _guard(() => _remote.loginWithEmail(email, password));

  @override
  Future<LoginResult> loginWithPhone({
    required String phoneNumber,
    required String optCode,
    required String purpose,
  }) => _guard(() => _remote.loginWithPhone(phoneNumber, optCode, purpose));

  @override
  Future<Otp> sendOtpCode({
    required String phoneNumber,
    required String purpose,
  }) async => OtpDto.fromJson(
    await _remote.sendOtp(phoneNumber, purpose) as Map<String, dynamic>,
  );

  @override
  Future<Otp> verifyOtpCode({
    required String phoneNumber,
    required String otpCode,
    required String purpose,
  }) async => OtpDto.fromJson(
    await _remote.verifyOtp(phoneNumber, otpCode, purpose)
        as Map<String, dynamic>,
  );

  @override
  Future<ResetPassword> resetPassword(
    String? phoneNumber,
    String? email, {
    required String newPassword,
  }) async {
    final res = await _remote.resetPassword({
      if (email != null && email.isNotEmpty) "email": email,
      if (phoneNumber != null && phoneNumber.isNotEmpty)
        "phone_number": phoneNumber,
      "new_password": newPassword,
    });
    return ResetPasswordDto.fromJson(res as Map<String, dynamic>);
  }

  @override
  Future<Register?> register({
    required String userName,
    required String phoneNumber,
    String? email,
    required String password,
    required double defaultUpfrontFeePercentage,
    required double defaultInterestPercentage,
    required double defaultTotalMonths,
  }) async {
    final Map<String, dynamic> res = await _remote.register({
      "user_name": userName,
      "phone_number": phoneNumber,
      if (email != null && email.isNotEmpty) "email": email,
      "password": password,
      "default_upfront_fee_percentage": defaultUpfrontFeePercentage,
      "default_interest_percentage": defaultInterestPercentage,
      "default_total_months": defaultTotalMonths,
    });
    if (res["success"]) return RegisterDto.fromJson(res["data"]["admin"]);
    return null;
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _remote.logout(refreshToken);
  }
}
