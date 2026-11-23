import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';

enum AuthStatus { signedOut, signedIn, pendingApproval }

/// Who is using the app. [status] comes from the saved tokens and drives the
/// router; [user] is the saved profile and drives role checks.
@immutable
class SessionState {
  final AuthStatus status;
  final AdminUser? user;

  /// False while [user] is only the profile saved on the device: its role
  /// may be out of date (changed on the server since). Becomes true once
  /// this run's login or GET /api/me answered. Until then a saved
  /// SUPER_ADMIN counts as ADMIN, so super-admin-only screens and cards
  /// never show on a stale role.
  final bool roleConfirmed;

  const SessionState({
    this.status = AuthStatus.signedOut,
    this.user,
    this.roleConfirmed = true,
  });

  bool get isLoggedIn => status == AuthStatus.signedIn;
  bool get isPendingApproval => status == AuthStatus.pendingApproval;

  /// A profile is loaded (the role is known).
  bool get hasProfile => user != null;

  /// The role to act on. An unconfirmed SUPER_ADMIN is treated as ADMIN.
  UserRole get role {
    final r = user?.role ?? UserRole.user;
    return r == UserRole.superAdmin && !roleConfirmed ? UserRole.admin : r;
  }

  bool get isSuperAdmin => role == UserRole.superAdmin;
  bool get isAdmin => hasRole(UserRole.admin);

  /// True when the role is [minimum] or higher. SUPER_ADMIN passes everything.
  bool hasRole(UserRole minimum) {
    if (user == null) return false;
    return isSuperAdmin || role.index >= minimum.index;
  }

  /// True when the role is in [allowed]. SUPER_ADMIN passes everything.
  bool hasAnyRole(Iterable<UserRole> allowed) {
    if (user == null) return false;
    return isSuperAdmin || allowed.contains(role);
  }

  SessionState withStatus(AuthStatus status) =>
      SessionState(status: status, user: user, roleConfirmed: roleConfirmed);

  /// [user] fresh from the server (login, /me, a profile update).
  SessionState withUser(AdminUser? user) =>
      SessionState(status: status, user: user);

  SessionState withRoleConfirmed() => SessionState(status: status, user: user);
}
