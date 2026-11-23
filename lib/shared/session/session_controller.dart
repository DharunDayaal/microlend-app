import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:micro_lending_app/core/storage/storage_providers.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';
import 'package:micro_lending_app/shared/session/session_state.dart';

/// The single source of truth for the session. The router listens to
/// [SessionState.status]; screens watch it for role checks.
final sessionProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);

class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  /// Call once at startup: loads the saved profile and checks the tokens.
  Future<void> restore() async {
    final user = await ref.read(sessionStorageProvider).read();
    final tokens = ref.read(tokenStorageProvider);
    final hasTokens = await tokens.hasSession;
    state = SessionState(
      status: hasTokens ? AuthStatus.signedIn : AuthStatus.signedOut,
      user: user,
      // the saved role is a guess until GET /api/me answers
      roleConfirmed: user == null,
    );

    // Tokens but no saved profile: an install from before profiles were
    // saved, or cleared storage. Without the profile there is no role and no
    // defaults, so sign in again.
    if (state.isLoggedIn && !state.hasProfile) {
      await tokens.clear();
      signedOut();
    }
  }

  /// Saves the profile, then shows it. A failed save is logged, not fatal.
  Future<void> setUser(AdminUser user) async {
    try {
      await ref.read(sessionStorageProvider).save(user);
    } catch (e, st) {
      AppLogger.error(
        "Saving the profile failed",
        tag: "Session",
        error: e,
        stack: st,
      );
    }
    state = state.withUser(user);
  }

  /// /me could not be reached (offline, server error): keep working with the
  /// saved role rather than hiding features for the whole run.
  void confirmSavedRole() {
    if (!state.roleConfirmed) state = state.withRoleConfirmed();
  }

  Future<void> clearUser() async {
    state = state.withUser(null);
    await ref.read(sessionStorageProvider).clear();
  }

  void signedIn() => _setStatus(AuthStatus.signedIn);

  /// Logged in, but the account is not approved yet.
  void pendingApproval() => _setStatus(AuthStatus.pendingApproval);

  /// Logout, or the refresh token was rejected.
  void signedOut() {
    unawaited(clearUser());
    _setStatus(AuthStatus.signedOut);
  }

  void _setStatus(AuthStatus next) {
    if (state.status == next) return;
    state = state.withStatus(next);
  }
}
