import 'package:micro_lending_app/features/auth/domain/entities/auth.dart';
import 'package:micro_lending_app/features/auth/domain/login_result.dart';

/// Sign-in, registration, OTP and password reset. Pure API: nothing here
/// touches tokens or the session. Implementations throw `ApiException`.
abstract interface class AuthRepository {
  Future<LoginResult> loginWithEmail({
    required String email,
    required String password,
  });

  Future<LoginResult> loginWithPhone({
    required String phoneNumber,
    required String optCode,
    required String purpose,
  });

  Future<Otp> sendOtpCode({
    required String phoneNumber,
    required String purpose,
  });

  Future<Otp> verifyOtpCode({
    required String phoneNumber,
    required String otpCode,
    required String purpose,
  });

  Future<ResetPassword> resetPassword(
    String? phoneNumber,
    String? email, {
    required String newPassword,
  });

  /// The new account, or null when the server did not accept it.
  Future<Register?> register({
    required String userName,
    required String phoneNumber,
    String? email,
    required String password,
    required double defaultUpfrontFeePercentage,
    required double defaultInterestPercentage,
    required double defaultTotalMonths,
  });

  /// Revokes [refreshToken] on the server.
  Future<void> logout(String refreshToken);
}
