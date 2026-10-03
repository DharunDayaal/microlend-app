import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/utils/local_storage/token_storage.dart';

enum AuthStatus { signedOut, signedIn, pendingApproval }

/// Single source of truth for "is the user logged in". GoRouter listens to
/// it, so changing it moves the user public routes and protected routes.
class AuthNotifier extends ChangeNotifier {
  AuthNotifier._();
  static final AuthNotifier instance = AuthNotifier._();

  AuthStatus _status = AuthStatus.signedOut;
  AuthStatus get status => _status;

  bool get isLoggedIn => _status == AuthStatus.signedIn;
  bool get isPendingApproval => _status == AuthStatus.pendingApproval;

  /// Call once in main() before runApp().
  Future<void> init() async {
    _status = await TokenStorage.instance.hasSession
        ? AuthStatus.signedIn
        : AuthStatus.signedOut;
  }

  void signedIn() => _set(AuthStatus.signedIn);

  /// Login but account is not verified.
  void pendingApproval() => _set(AuthStatus.pendingApproval);

  /// Logout or the refresh token was rejected.
  void signedOut() => _set(AuthStatus.signedOut);

  void _set(AuthStatus next) {
    if (_status == next) return;
    _status = next;
    notifyListeners();
  }
}
