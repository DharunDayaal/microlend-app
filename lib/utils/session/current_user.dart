import 'package:flutter/material.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/utils/local_storage/session_storage.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';

class CurrentUser extends ChangeNotifier {
  CurrentUser._();

  static final CurrentUser instance = CurrentUser._();

  AdminUser? _user;
  AdminUser? get user => _user;
  bool get isSignedIn => _user != null;

  UserRole get role => _user?.role ?? UserRole.user;
  bool get isSuperAdmin => _user?.role == UserRole.superAdmin;
  bool get isAdmin => hasRole(UserRole.admin);

  /// True when the role is [minimum] or higher. SUPER_ADMIN passes everything.
  bool hasRole(UserRole minimum) {
    if (_user == null) {
      return false;
    }

    return isSuperAdmin || role.index >= minimum.index;
  }

  /// True when the role is in [allowed]. SUPER_ADMIN passes everything.
  bool hasAnyRole(Iterable<UserRole> allowed) {
    if (_user == null) return false;

    return isSuperAdmin || allowed.contains(role);
  }

  /// Call once in main() before runApp.
  Future<void> init() async {
    _user = await SessionStorage.read();
    notifyListeners();
  }

  Future<void> setUser(AdminUser user) async {
    try {
      await SessionStorage.save(user);
    } catch (e, st) {
      AppLogger.error(
        "Saving the profile failed",
        tag: "Session",
        error: e,
        stack: st,
      );
    }
    _user = user;
    notifyListeners();
  }

  Future<void> clear() async {
    final had = _user != null;
    _user = null;
    if (had) notifyListeners();
    await SessionStorage.clear();
  }
}
