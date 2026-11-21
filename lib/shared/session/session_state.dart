import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';

enum AuthStatus { signedOut, signedIn, pendingApproval }

/// Who is using the app. [status] comes from the saved tokens and drives the
/// router; [user] is the saved profile and drives role checks.
@immutable
class SessionState {
  final AuthStatus status;
  final AdminUser? user;

  const SessionState({this.status = AuthStatus.signedOut, this.user});

  bool get isLoggedIn => status == AuthStatus.signedIn;
  bool get isPendingApproval => status == AuthStatus.pendingApproval;

  /// A profile is loaded (the role is known).
  bool get hasProfile => user != null;

  UserRole get role => user?.role ?? UserRole.user;
  bool get isSuperAdmin => user?.role == UserRole.superAdmin;
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
      SessionState(status: status, user: user);

  SessionState withUser(AdminUser? user) =>
      SessionState(status: status, user: user);
}
