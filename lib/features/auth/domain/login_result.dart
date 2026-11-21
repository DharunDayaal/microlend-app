import 'package:micro_lending_app/shared/session/models/user_role.dart';

/// What a login attempt ended in. The caller decides what it means for the
/// session; the repository only reports it.
sealed class LoginResult {
  const LoginResult();
}

final class LoginSucceeded extends LoginResult {
  final String accessToken;
  final String refreshToken;
  final AdminUser user;
  const LoginSucceeded({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}

/// Correct credentials, but an admin has not approved the account yet.
final class LoginPendingApproval extends LoginResult {
  const LoginPendingApproval();
}

/// The account was deactivated.
final class LoginDeactivated extends LoginResult {
  const LoginDeactivated();
}
