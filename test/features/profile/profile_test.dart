import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/storage/storage_providers.dart';
import 'package:micro_lending_app/features/manage/data/manage_providers.dart';
import 'package:micro_lending_app/features/profile/data/dtos/profile_dto.dart';
import 'package:micro_lending_app/features/profile/data/profile_providers.dart';
import 'package:micro_lending_app/features/profile/domain/entities/profile.dart';
import 'package:micro_lending_app/features/profile/domain/profile_repository.dart';
import 'package:micro_lending_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:micro_lending_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';
import 'package:micro_lending_app/shared/session/session_state.dart';

import '../../shared/session/session_fakes.dart';
import '../loans/fakes.dart' show settle;
import '../manage/manage_fakes.dart';

UserProfile profileOf(String role, {String name = 'Dharun'}) =>
    UserProfileDto.fromJson({
      'id': 'u1',
      'user_name': name,
      'phone_number': '+919876543210',
      'role': role,
      'is_verified': true,
    });

class FakeProfileRepository implements ProfileRepository {
  UserProfile me = profileOf('USER');
  ApiException? failSave;
  final List<String> calls = [];

  @override
  Future<UserProfile> getProfile() async {
    calls.add('profile');
    return me;
  }

  @override
  Future<UserProfile> updateProfile({String? userName, String? email}) async {
    if (failSave != null) throw failSave!;
    return me = profileOf(me.role.apiValue, name: userName ?? me.userName);
  }

  @override
  Future<ProfileStats> getStats({
    required String range,
    required String scope,
    String? adminId,
  }) async {
    calls.add('stats|$range|$scope|$adminId');
    return ProfileStatsDto.fromJson({'range': range, 'collected': 1500});
  }

  @override
  Future<List<SessionInfo>> getSessions() async {
    calls.add('sessions');
    return [
      SessionInfoDto.fromJson({'id': 's1'}),
    ];
  }

  @override
  Future<List<AdminAccount>> getAdmins({
    String status = 'pending',
    int page = 1,
    int limit = 5,
  }) async {
    calls.add('admins');
    return [
      AdminAccountDto.fromJson({'id': 'a1', 'user_name': 'New admin'}),
    ];
  }

  @override
  Future<void> changePassword({
    required String current,
    required String next,
    String? refreshToken,
  }) async => calls.add('password|$refreshToken');

  @override
  Future<UserProfile> changePhone(String phone) => throw UnimplementedError();
  @override
  Future<UserProfile> updateDefaults({
    double? fee,
    double? interest,
    double? months,
  }) => throw UnimplementedError();
  @override
  Future<void> deleteSession(String id) => throw UnimplementedError();
  @override
  Future<void> deleteAllSessions() => throw UnimplementedError();
  @override
  Future<void> updateLimits(Map<String, double> changes) =>
      throw UnimplementedError();
}

void main() {
  late FakeProfileRepository repo;
  late FakeManageRepository manage;
  late FakeTokenStorage tokens;
  late ProviderContainer c;

  setUp(() {
    repo = FakeProfileRepository();
    manage = FakeManageRepository();
    tokens = FakeTokenStorage(hasTokens: true, refresh: 'r1');
    c = ProviderContainer.test(
      overrides: [
        profileRepositoryProvider.overrideWithValue(repo),
        manageRepositoryProvider.overrideWithValue(manage),
        tokenStorageProvider.overrideWithValue(tokens),
        sessionStorageProvider.overrideWithValue(FakeSessionStorage()),
      ],
    );
  });

  ProfileController ctrl() => c.read(profileControllerProvider.notifier);
  Future<void> start() async {
    c.listen(profileControllerProvider, (_, _) {});
    await settle();
  }

  test('an employee loads profile, stats and sessions only', () async {
    await start();
    expect(repo.calls, ['profile', 'stats|week|me|null', 'sessions']);
    expect(ctrl().profile.data?.userName, 'Dharun');
    expect(ctrl().stats.data?.collected, 1500);
    expect(ctrl().team.data, isNull);
    // the fresh profile becomes the session user
    expect(c.read(sessionProvider).user?.userName, 'Dharun');
  });

  test('a super admin also loads team and pending admins, and picks the '
      'first team for team stats', () async {
    repo.me = profileOf('SUPER_ADMIN');
    manage.teams = [
      {'admin_id': 'a7', 'user_name': 'Team A'},
    ];
    await start();
    expect(ctrl().pendingAdmins.data?.single.userName, 'New admin');
    expect(ctrl().teamAdminId, 'a7');

    await ctrl().setScope('team');
    expect(repo.calls.last, 'stats|week|team|a7');
  });

  test(
    'team stats with no approved team explain why, in the app language',
    () async {
      repo.me = profileOf('SUPER_ADMIN');
      await start();
      await ctrl().setScope('team');
      expect(ctrl().stats.error, 'There is no approved team to show yet.');
    },
  );

  test('saving contact updates the profile and the session', () async {
    await start();
    expect(await ctrl().saveContact(name: 'Kavya'), isNull);
    expect(ctrl().profile.data?.userName, 'Kavya');
    await settle(); // the session save is fire-and-forget
    expect(c.read(sessionProvider).user?.userName, 'Kavya');
  });

  test('a save with no server answer reloads and says so', () async {
    await start();
    repo.failSave = const ApiException(message: 'timeout');
    final err = await ctrl().saveContact(name: 'Kavya');
    await settle();
    expect(err, startsWith('No answer from the server.'));
    expect(repo.calls.where((x) => x == 'profile').length, 2);
  });

  test(
    'password change without a stored token signs this device out',
    () async {
      await start();
      c.read(sessionProvider.notifier).signedIn();
      tokens.refresh = null;
      expect(await ctrl().changePassword(current: 'a', next: 'b'), isNull);
      expect(tokens.cleared, true);
      expect(c.read(sessionProvider).status, AuthStatus.signedOut);
    },
  );

  test('admin decisions go through the manage repository', () async {
    repo.me = profileOf('SUPER_ADMIN');
    await start();
    final admin = ctrl().pendingAdmins.data!.single;
    await ctrl().decideAdmin(admin, approve: true);
    await ctrl().decideAdmin(admin, approve: false);
    expect(manage.decisions, ['verified|a1|true', 'active|a1|false']);
  });

  testWidgets('profile screen shows the signed-in user', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repo),
          manageRepositoryProvider.overrideWithValue(manage),
          tokenStorageProvider.overrideWithValue(tokens),
          sessionStorageProvider.overrideWithValue(FakeSessionStorage()),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Dharun'), findsWidgets);
  });
}
