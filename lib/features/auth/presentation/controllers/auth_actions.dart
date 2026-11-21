import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/storage/storage_providers.dart';
import 'package:micro_lending_app/features/auth/data/auth_providers.dart';
import 'package:micro_lending_app/features/auth/domain/entities/auth.dart';
import 'package:micro_lending_app/features/auth/domain/login_result.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

/// Sign-in, registration and logout, applied to the session: tokens are
/// stored, the user is set and the router moves on (it follows the status).
final authActionsProvider = Provider<AuthActions>(AuthActions.new);

class AuthActions {
  AuthActions(this._ref);
  final Ref _ref;

  SessionController get _session => _ref.read(sessionProvider.notifier);

  Future<void> _apply(LoginResult r) async {
    switch (r) {
      case LoginPendingApproval():
        _session.pendingApproval();
      case LoginDeactivated():
        _session.signedOut();
      case LoginSucceeded():
        await _ref
            .read(tokenStorageProvider)
            .saveTokens(
              accessToken: r.accessToken,
              refreshToken: r.refreshToken,
            );
        await _session.setUser(r.user);
        _session.signedIn();
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async => _apply(
    await _ref
        .read(authRepositoryProvider)
        .loginWithEmail(email: email, password: password),
  );

  Future<void> loginWithPhone({
    required String phoneNumber,
    required String optCode,
    required String purpose,
  }) async => _apply(
    await _ref
        .read(authRepositoryProvider)
        .loginWithPhone(
          phoneNumber: phoneNumber,
          optCode: optCode,
          purpose: purpose,
        ),
  );

  /// A new account always waits for an admin's approval.
  Future<Register?> register({
    required String userName,
    required String phoneNumber,
    String? email,
    required String password,
    required double defaultUpfrontFeePercentage,
    required double defaultInterestPercentage,
    required double defaultTotalMonths,
  }) async {
    final r = await _ref
        .read(authRepositoryProvider)
        .register(
          userName: userName,
          phoneNumber: phoneNumber,
          email: email,
          password: password,
          defaultUpfrontFeePercentage: defaultUpfrontFeePercentage,
          defaultInterestPercentage: defaultInterestPercentage,
          defaultTotalMonths: defaultTotalMonths,
        );
    if (r != null) _session.pendingApproval();
    return r;
  }

  /// Revokes the token on the server when it can; signs out locally always.
  Future<void> logout() async {
    final tokens = _ref.read(tokenStorageProvider);
    final session = _session;
    try {
      final refresh = await tokens.refreshToken;
      if (refresh != null) {
        await _ref.read(authRepositoryProvider).logout(refresh);
      }
    } on ApiException {
      // Even when logout fails, log out locally.
    } finally {
      await tokens.clear();
      session.signedOut();
    }
  }
}
