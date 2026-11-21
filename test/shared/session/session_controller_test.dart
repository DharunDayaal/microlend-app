import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/storage/storage_providers.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';
import 'package:micro_lending_app/shared/session/session_state.dart';

import 'session_fakes.dart';

void main() {
  late FakeTokenStorage tokens;
  late FakeSessionStorage profile;
  late ProviderContainer c;

  ProviderContainer make() => ProviderContainer.test(
    overrides: [
      tokenStorageProvider.overrideWithValue(tokens),
      sessionStorageProvider.overrideWithValue(profile),
    ],
  );

  setUp(() {
    tokens = FakeTokenStorage();
    profile = FakeSessionStorage();
    c = make();
  });

  group('restore', () {
    test('tokens and a saved profile: signed in with that profile', () async {
      tokens.hasTokens = true;
      profile.saved = adminUser();
      await c.read(sessionProvider.notifier).restore();

      final s = c.read(sessionProvider);
      expect(s.status, AuthStatus.signedIn);
      expect(s.user?.userName, 'Dharun');
      expect(s.hasRole(UserRole.admin), true);
      expect(s.hasRole(UserRole.superAdmin), false);
    });

    test(
      'tokens but no profile: tokens are cleared and the user signs in again',
      () async {
        tokens.hasTokens = true;
        await c.read(sessionProvider.notifier).restore();

        expect(tokens.cleared, true);
        expect(c.read(sessionProvider).status, AuthStatus.signedOut);
      },
    );

    test('no tokens: signed out', () async {
      await c.read(sessionProvider.notifier).restore();
      expect(c.read(sessionProvider).isLoggedIn, false);
    });
  });

  test('setUser saves the profile; a failed save still shows it', () async {
    final ctrl = c.read(sessionProvider.notifier);
    await ctrl.setUser(adminUser());
    expect(profile.saved?.id, 'u1');

    profile.failSave = true;
    await ctrl.setUser(adminUser(role: 'SUPER_ADMIN'));
    expect(c.read(sessionProvider).isSuperAdmin, true);
  });

  test('signedOut clears the profile and the status', () async {
    final ctrl = c.read(sessionProvider.notifier);
    await ctrl.setUser(adminUser());
    ctrl.signedIn();

    ctrl.signedOut();
    await Future<void>.delayed(Duration.zero);

    final s = c.read(sessionProvider);
    expect(s.status, AuthStatus.signedOut);
    expect(s.user, isNull);
    expect(profile.saved, isNull);
  });
}
