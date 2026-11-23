import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/network_providers.dart';
import 'package:micro_lending_app/core/storage/storage_providers.dart';
import 'package:micro_lending_app/features/analytics/presentation/screens/advanced_analytics_screen.dart';
import 'package:micro_lending_app/features/analytics/presentation/widgets/analytics_platform_cards.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/session/session_fakes.dart';

/// Analytics answers never arrive: the role gating must not depend on them.
class _NeverAnswers extends Fake implements ApiClient {
  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) => Completer<dynamic>().future;
}

ProviderContainer _container(String savedRole) => ProviderContainer.test(
  overrides: [
    apiClientProvider.overrideWithValue(_NeverAnswers()),
    tokenStorageProvider.overrideWithValue(FakeTokenStorage(hasTokens: true)),
    sessionStorageProvider.overrideWithValue(
      FakeSessionStorage(adminUser(role: savedRole)),
    ),
  ],
);

void main() {
  group('a saved role is not trusted for super-admin access', () {
    test('saved SUPER_ADMIN acts as ADMIN until /me confirms it', () async {
      final c = _container('SUPER_ADMIN');
      final session = c.read(sessionProvider.notifier);
      await session.restore();

      var s = c.read(sessionProvider);
      expect(s.roleConfirmed, false);
      expect(s.isSuperAdmin, false);
      expect(s.role, UserRole.admin);
      expect(s.hasRole(UserRole.admin), true); // admin screens still open
      expect(s.hasRole(UserRole.superAdmin), false);

      await session.setUser(adminUser(role: 'SUPER_ADMIN')); // /me answered
      s = c.read(sessionProvider);
      expect(s.isSuperAdmin, true);
      expect(s.hasRole(UserRole.superAdmin), true);
    });

    test('when /me cannot be reached the saved role is used', () async {
      final c = _container('SUPER_ADMIN');
      await c.read(sessionProvider.notifier).restore();
      c.read(sessionProvider.notifier).confirmSavedRole();
      expect(c.read(sessionProvider).isSuperAdmin, true);
    });

    test('a saved ADMIN or USER is unaffected', () async {
      for (final (saved, role) in [
        ('ADMIN', UserRole.admin),
        ('USER', UserRole.user),
      ]) {
        final c = _container(saved);
        await c.read(sessionProvider.notifier).restore();
        expect(c.read(sessionProvider).role, role);
      }
    });
  });

  group('advanced analytics shows super-admin parts from the session only', () {
    late ProviderContainer c;

    Future<void> open(WidgetTester tester, String savedRole) async {
      SharedPreferences.setMockInitialValues({});
      c = _container(savedRole);
      await c.read(sessionProvider.notifier).restore();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const AdvancedAnalyticsScreen(),
          ),
        ),
      );
    }

    /// Frame by frame while no analytics answer has come back.
    Future<void> expectNoPlatformFor(WidgetTester tester, int frames) async {
      for (var i = 0; i < frames; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(find.text('Platform'), findsNothing, reason: 'frame $i');
        expect(find.byType(PlatformOverviewCard), findsNothing);
      }
    }

    // the screen warms the calendar after 1.5 s; let that timer run out
    Future<void> finish(WidgetTester tester) =>
        tester.pump(const Duration(seconds: 2));

    testWidgets('an ADMIN never sees the platform segment', (tester) async {
      await open(tester, 'ADMIN');
      await expectNoPlatformFor(tester, 30);
      await finish(tester);
    });

    testWidgets('a stale saved SUPER_ADMIN does not flash platform cards', (
      tester,
    ) async {
      await open(tester, 'SUPER_ADMIN');
      await expectNoPlatformFor(tester, 10);

      // /me answers: the account is an ADMIN now
      await c.read(sessionProvider.notifier).setUser(adminUser());
      await expectNoPlatformFor(tester, 10);
      await finish(tester);
    });

    testWidgets('a confirmed SUPER_ADMIN gets the platform segment', (
      tester,
    ) async {
      await open(tester, 'SUPER_ADMIN');
      await c
          .read(sessionProvider.notifier)
          .setUser(adminUser(role: 'SUPER_ADMIN'));
      await tester.pump();
      expect(find.text('Platform'), findsOneWidget);
      await finish(tester);
    });
  });
}
