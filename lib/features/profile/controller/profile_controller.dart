import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/data/models/profile_model.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/data/services/profile_service.dart';
import 'package:micro_lending_app/routes/auth_notifier.dart';
import 'package:micro_lending_app/utils/local_storage/token_storage.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

class Section<T> {
  T? data;
  bool loading = false;
  String? error;
}

class ProfileController extends ChangeNotifier {
  final profile = Section<UserProfile>();
  final stats = Section<ProfileStats>();
  final sessions = Section<List<SessionInfo>>();
  final team = Section<TeamSummary>();
  final pendingAdmins = Section<List<AdminAccount>>();

  String range = 'week';
  String scope = 'me';
  String? teamAdminId; // SUPER_ADMIN, team scope
  int _statsRequest = 0;
  bool _disposed = false;

  // The role comes from the latest GET /api/me, not from stored login data.
  UserRole get role => profile.data?.role ?? CurrentUser.instance.role;
  bool get isAdmin => role.index >= UserRole.admin.index;
  bool get isSuper => role == UserRole.superAdmin;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _emit() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _run<T>(
    Section<T> s,
    Future<T> Function() fn, {
    bool silent = false,
    bool Function()? isCurrent,
  }) async {
    if (!silent || s.data == null) s.loading = true;
    s.error = null;
    _emit();
    try {
      final result = await fn();
      if (isCurrent != null && !isCurrent()) return; // an older request
      s.data = result;
    } on ApiException catch (e) {
      if (isCurrent == null || isCurrent()) s.error = e.message;
    } catch (e, st) {
      AppLogger.error('Profile load failed', tag: 'Profile', error: e, stack: st);
      if (isCurrent == null || isCurrent()) {
        s.error = 'Something went wrong. Please try again.';
      }
    } finally {
      if (isCurrent == null || isCurrent()) s.loading = false;
      _emit();
    }
  }

  // ---------- loading ----------

  Future<void> load({bool silent = false}) async {
    await loadProfile(silent: silent);
    if (profile.data == null) return;
    await Future.wait([
      loadStats(silent: silent),
      loadSessions(silent: silent),
      if (isAdmin) loadTeam(silent: silent),
      if (isSuper) loadPendingAdmins(silent: silent),
    ]);
  }

  Future<void> loadProfile({bool silent = false}) => _run(
        profile,
        () async {
          final p = await ProfileService.getProfile();
          unawaited(CurrentUser.instance.setUser(p.toAdminUser()));
          return p;
        },
        silent: silent,
      );

  Future<void> loadStats({bool silent = false}) {
    final id = ++_statsRequest;
    return _run(
      stats,
      () => ProfileService.getStats(
        range: range,
        scope: scope,
        adminId: scope == 'team' && isSuper ? teamAdminId : null,
      ),
      silent: silent,
      isCurrent: () => id == _statsRequest,
    );
  }

  Future<void> loadSessions({bool silent = false}) =>
      _run(sessions, ProfileService.getSessions, silent: silent);

  Future<void> loadTeam({bool silent = false}) => _run(
        team,
        () async {
          final t = await ProfileService.getTeam();
          if (isSuper) teamAdminId ??= t.teams.firstOrNull?.adminId;
          return t;
        },
        silent: silent,
      );

  Future<void> loadPendingAdmins({bool silent = false}) => _run(
        pendingAdmins,
        () => ProfileService.getAdmins(status: 'pending', limit: 5),
        silent: silent,
      );

  // ---------- stats controls ----------

  Future<void> setRange(String value) {
    range = value;
    return loadStats();
  }

  Future<void> setScope(String value) async {
    scope = value;
    if (value == 'team' && isSuper) {
      teamAdminId ??= team.data?.teams.firstOrNull?.adminId;
      if (teamAdminId == null) {
        stats.data = null;
        stats.error = 'There is no approved team to show yet.';
        _emit();
        return;
      }
    }
    await loadStats();
  }

  Future<void> setTeam(String adminId) {
    teamAdminId = adminId;
    return loadStats();
  }

  // ---------- writes: each returns an error message, or null on success ----------

  void _applyProfile(UserProfile p) {
    profile.data = p;
    profile.error = null;
    unawaited(CurrentUser.instance.setUser(p.toAdminUser()));
    _emit();
  }

  Future<String?> _save(Future<UserProfile> Function() call) async {
    try {
      _applyProfile(await call());
      return null;
    } on ApiException catch (e) {
      if (e.isNetworkError) {
        // The change may already be saved: reload before the user tries again.
        unawaited(loadProfile(silent: true));
        return 'No answer from the server. Your profile was reloaded; '
            'check it and save again if needed.';
      }
      return e.message;
    } catch (e, st) {
      AppLogger.error('Profile save failed', tag: 'Profile', error: e, stack: st);
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> saveContact({String? name, String? email}) =>
      _save(() => ProfileService.updateProfile(userName: name, email: email));

  Future<String?> saveDefaults({double? fee, double? interest, double? months}) =>
      _save(() => ProfileService.updateDefaults(
            fee: fee,
            interest: interest,
            months: months,
          ));

  Future<String?> changePhone(String phone) =>
      _save(() => ProfileService.changePhone(phone));

  Future<String?> changePassword({
    required String current,
    required String next,
  }) async {
    try {
      final refresh = await TokenStorage.instance.refreshToken;
      await ProfileService.changePassword(
        current: current,
        next: next,
        refreshToken: refresh,
      );
      if (refresh == null || refresh.isEmpty) {
        // Without our token every session, this one too, is signed out.
        await _signOutLocal();
      } else {
        unawaited(loadSessions(silent: true));
      }
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e, st) {
      AppLogger.error('Password change failed', tag: 'Profile', error: e, stack: st);
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> revokeSession(String id) async {
    try {
      await ProfileService.deleteSession(id);
      unawaited(loadSessions(silent: true));
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> revokeAllSessions() async {
    try {
      await ProfileService.deleteAllSessions();
      await _signOutLocal(); // this device is signed out too
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  /// approve: PATCH verification true. reject: PATCH active false.
  Future<String?> decideAdmin(AdminAccount admin, {required bool approve}) async {
    try {
      if (approve) {
        await ProfileService.setAdminVerified(admin.id, true);
      } else {
        await ProfileService.setAdminActive(admin.id, false);
      }
      unawaited(loadPendingAdmins(silent: true));
      unawaited(loadTeam(silent: true));
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> updateLimits(Map<String, double> changes) async {
    try {
      await ProfileService.updateLimits(changes);
      unawaited(loadProfile(silent: true)); // limits live inside the profile
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> _signOutLocal() async {
    await TokenStorage.instance.clear();
    AuthNotifier.instance.signedOut(); // the router moves to login
  }
}