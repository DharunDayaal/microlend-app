import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/storage/storage_providers.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';
import 'package:micro_lending_app/features/manage/data/manage_providers.dart';
import 'package:micro_lending_app/features/manage/domain/entities/team.dart';
import 'package:micro_lending_app/features/profile/data/profile_providers.dart';
import 'package:micro_lending_app/features/profile/domain/entities/profile.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/l10n/locale_controller.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

/// One independently loading part of the profile screen.
@immutable
class Section<T> {
  final T? data;
  final bool loading;
  final String? error;
  const Section({this.data, this.loading = false, this.error});
}

@immutable
class ProfileState {
  final Section<UserProfile> profile;
  final Section<ProfileStats> stats;
  final Section<List<SessionInfo>> sessions;
  final Section<TeamSummary> team;
  final Section<List<AdminAccount>> pendingAdmins;

  /// Stats controls: 'week' | 'month', 'me' | 'team' | 'all'.
  final String range;
  final String scope;

  /// SUPER_ADMIN, team scope: which team the stats show.
  final String? teamAdminId;

  const ProfileState({
    this.profile = const Section(),
    this.stats = const Section(),
    this.sessions = const Section(),
    this.team = const Section(),
    this.pendingAdmins = const Section(),
    this.range = 'week',
    this.scope = 'me',
    this.teamAdminId,
  });

  static const _keep = Object();

  ProfileState copyWith({
    Section<UserProfile>? profile,
    Section<ProfileStats>? stats,
    Section<List<SessionInfo>>? sessions,
    Section<TeamSummary>? team,
    Section<List<AdminAccount>>? pendingAdmins,
    String? range,
    String? scope,
    Object? teamAdminId = _keep,
  }) => ProfileState(
    profile: profile ?? this.profile,
    stats: stats ?? this.stats,
    sessions: sessions ?? this.sessions,
    team: team ?? this.team,
    pendingAdmins: pendingAdmins ?? this.pendingAdmins,
    range: range ?? this.range,
    scope: scope ?? this.scope,
    teamAdminId: identical(teamAdminId, _keep)
        ? this.teamAdminId
        : teamAdminId as String?,
  );
}

/// The profile screen. Lives as long as the screen.
final profileControllerProvider =
    NotifierProvider.autoDispose<ProfileController, ProfileState>(
      ProfileController.new,
    );

class ProfileController extends Notifier<ProfileState> {
  int _statsRequest = 0;

  @override
  ProfileState build() {
    Future.microtask(load);
    return const ProfileState();
  }

  // ---------- read access for the cards ----------

  Section<UserProfile> get profile => state.profile;
  Section<ProfileStats> get stats => state.stats;
  Section<List<SessionInfo>> get sessions => state.sessions;
  Section<TeamSummary> get team => state.team;
  Section<List<AdminAccount>> get pendingAdmins => state.pendingAdmins;
  String get range => state.range;
  String get scope => state.scope;
  String? get teamAdminId => state.teamAdminId;

  // The role comes from the latest GET /api/me, not from stored login data.
  UserRole get role =>
      state.profile.data?.role ?? ref.read(sessionProvider).role;
  bool get isAdmin => role.index >= UserRole.admin.index;
  bool get isSuper => role == UserRole.superAdmin;

  AppLocalizations get _l => lookupAppLocalizations(ref.read(localeProvider));

  // ---------- one section load ----------

  Future<void> _run<T>(
    Section<T> Function(ProfileState) read,
    ProfileState Function(ProfileState, Section<T>) write,
    Future<T> Function() fn, {
    bool silent = false,
    bool Function()? isCurrent,
  }) async {
    bool current() => ref.mounted && (isCurrent == null || isCurrent());
    final before = read(state);
    state = write(
      state,
      Section(
        data: before.data,
        loading: !silent || before.data == null ? true : before.loading,
      ),
    );
    try {
      final result = await fn();
      if (!current()) return;
      state = write(state, Section(data: result));
    } on ApiException catch (e) {
      if (!current()) return;
      state = write(state, Section(data: read(state).data, error: e.message));
    } catch (e, st) {
      AppLogger.error(
        'Profile load failed',
        tag: 'Profile',
        error: e,
        stack: st,
      );
      if (!current()) return;
      state = write(
        state,
        Section(data: read(state).data, error: _l.commonSomethingWrong),
      );
    }
  }

  // ---------- loading ----------

  Future<void> load({bool silent = false}) async {
    await loadProfile(silent: silent);
    if (!ref.mounted || state.profile.data == null) return;
    await Future.wait([
      loadStats(silent: silent),
      loadSessions(silent: silent),
      if (isAdmin) loadTeam(silent: silent),
      if (isSuper) loadPendingAdmins(silent: silent),
    ]);
  }

  Future<void> loadProfile({bool silent = false}) =>
      _run((s) => s.profile, (s, v) => s.copyWith(profile: v), () async {
        final p = await ref.read(profileRepositoryProvider).getProfile();
        unawaited(ref.read(sessionProvider.notifier).setUser(p.toAdminUser()));
        return p;
      }, silent: silent);

  Future<void> loadStats({bool silent = false}) {
    final id = ++_statsRequest;
    final s = state;
    return _run(
      (s) => s.stats,
      (s, v) => s.copyWith(stats: v),
      () => ref
          .read(profileRepositoryProvider)
          .getStats(
            range: s.range,
            scope: s.scope,
            adminId: s.scope == 'team' && isSuper ? s.teamAdminId : null,
          ),
      silent: silent,
      isCurrent: () => id == _statsRequest,
    );
  }

  Future<void> loadSessions({bool silent = false}) => _run(
    (s) => s.sessions,
    (s, v) => s.copyWith(sessions: v),
    ref.read(profileRepositoryProvider).getSessions,
    silent: silent,
  );

  Future<void> loadTeam({bool silent = false}) =>
      _run((s) => s.team, (s, v) => s.copyWith(team: v), () async {
        final t = await ref.read(manageRepositoryProvider).team();
        if (isSuper && ref.mounted && state.teamAdminId == null) {
          state = state.copyWith(teamAdminId: t.teams.firstOrNull?.adminId);
        }
        return t;
      }, silent: silent);

  Future<void> loadPendingAdmins({bool silent = false}) => _run(
    (s) => s.pendingAdmins,
    (s, v) => s.copyWith(pendingAdmins: v),
    () => ref
        .read(profileRepositoryProvider)
        .getAdmins(status: 'pending', limit: 5),
    silent: silent,
  );

  // ---------- stats controls ----------

  Future<void> setRange(String value) {
    state = state.copyWith(range: value);
    return loadStats();
  }

  Future<void> setScope(String value) async {
    state = state.copyWith(scope: value);
    if (value == 'team' && isSuper) {
      final id =
          state.teamAdminId ?? state.team.data?.teams.firstOrNull?.adminId;
      state = state.copyWith(teamAdminId: id);
      if (id == null) {
        state = state.copyWith(stats: Section(error: _l.profNoApprovedTeam));
        return;
      }
    }
    await loadStats();
  }

  Future<void> setTeam(String adminId) {
    state = state.copyWith(teamAdminId: adminId);
    return loadStats();
  }

  // ---------- writes: each returns an error message, or null on success ----------

  void _applyProfile(UserProfile p) {
    state = state.copyWith(profile: Section(data: p));
    unawaited(ref.read(sessionProvider.notifier).setUser(p.toAdminUser()));
  }

  Future<String?> _save(Future<UserProfile> Function() call) async {
    try {
      final p = await call();
      if (ref.mounted) _applyProfile(p);
      return null;
    } on ApiException catch (e) {
      if (e.isNetworkError) {
        // The change may already be saved: reload before the user tries again.
        unawaited(loadProfile(silent: true));
        return _l.profNoAnswerReloaded;
      }
      return e.message;
    } catch (e, st) {
      AppLogger.error(
        'Profile save failed',
        tag: 'Profile',
        error: e,
        stack: st,
      );
      return _l.commonSomethingWrong;
    }
  }

  Future<String?> saveContact({String? name, String? email}) => _save(
    () => ref
        .read(profileRepositoryProvider)
        .updateProfile(userName: name, email: email),
  );

  Future<String?> saveDefaults({
    double? fee,
    double? interest,
    double? months,
  }) => _save(
    () => ref
        .read(profileRepositoryProvider)
        .updateDefaults(fee: fee, interest: interest, months: months),
  );

  Future<String?> changePhone(String phone) =>
      _save(() => ref.read(profileRepositoryProvider).changePhone(phone));

  Future<String?> changePassword({
    required String current,
    required String next,
  }) async {
    try {
      final refresh = await ref.read(tokenStorageProvider).refreshToken;
      await ref
          .read(profileRepositoryProvider)
          .changePassword(current: current, next: next, refreshToken: refresh);
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
      AppLogger.error(
        'Password change failed',
        tag: 'Profile',
        error: e,
        stack: st,
      );
      return _l.commonSomethingWrong;
    }
  }

  Future<String?> revokeSession(String id) async {
    try {
      await ref.read(profileRepositoryProvider).deleteSession(id);
      unawaited(loadSessions(silent: true));
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> revokeAllSessions() async {
    try {
      await ref.read(profileRepositoryProvider).deleteAllSessions();
      await _signOutLocal(); // this device is signed out too
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  /// approve: PATCH verification true. reject: PATCH active false.
  Future<String?> decideAdmin(
    AdminAccount admin, {
    required bool approve,
  }) async {
    try {
      final manage = ref.read(manageRepositoryProvider);
      if (approve) {
        await manage.setAdminVerified(admin.id, true);
      } else {
        await manage.setAdminActive(admin.id, false);
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
      await ref.read(profileRepositoryProvider).updateLimits(changes);
      unawaited(loadProfile(silent: true)); // limits live inside the profile
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> _signOutLocal() async {
    // read both before the await: signing out disposes this screen
    final tokens = ref.read(tokenStorageProvider);
    final session = ref.read(sessionProvider.notifier);
    await tokens.clear();
    session.signedOut(); // the router moves to login
  }
}
