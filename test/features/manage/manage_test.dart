import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/features/manage/data/dtos/managed_account_dto.dart';
import 'package:micro_lending_app/features/manage/data/manage_providers.dart';
import 'package:micro_lending_app/features/manage/presentation/controllers/accounts_list_controller.dart';
import 'package:micro_lending_app/features/manage/presentation/screens/manage_admin.dart';
import 'package:micro_lending_app/features/manage/presentation/screens/manage_users.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';
import 'package:micro_lending_app/shared/session/session_state.dart';

import '../../shared/session/session_fakes.dart';
import '../loans/fakes.dart' show settle;
import 'manage_fakes.dart';

/// A session that starts signed in with [role].
class _SignedIn extends SessionController {
  final String role;
  _SignedIn(this.role);

  @override
  SessionState build() => SessionState(
    status: AuthStatus.signedIn,
    user: adminUser(role: role),
  );
}

void main() {
  late FakeManageRepository repo;
  late ProviderContainer c;

  setUp(() {
    repo = FakeManageRepository();
    c = ProviderContainer.test(
      overrides: [manageRepositoryProvider.overrideWithValue(repo)],
    );
  });

  final admins = accountsListProvider(AccountKind.admins);
  final employees = accountsListProvider(AccountKind.employees);

  test(
    'opens on the pending tab; switching tabs and searching reload',
    () async {
      repo.lists['admins|pending||null'] = [account('1')];
      repo.lists['admins|active||null'] = [account('2', verified: true)];
      repo.lists['admins|active|ra|null'] = [];
      c.listen(admins, (_, _) {});
      await settle();
      expect(c.read(admins).items.map((a) => a.id), ['1']);

      c.read(admins.notifier).setStatus('active');
      expect(c.read(admins).items, isEmpty); // cleared at once
      await settle();
      expect(c.read(admins).items.map((a) => a.id), ['2']);

      c.read(admins.notifier).setSearch('ra');
      await settle();
      expect(repo.calls.last, 'admins|active|ra|null');
      expect(c.read(admins.notifier).search, 'ra');
    },
  );

  test('the team filter narrows the employees list', () async {
    c.listen(employees, (_, _) {});
    await settle();
    c.read(employees.notifier).setAdminFilter('a9');
    await settle();
    expect(repo.calls, ['employees|pending||null', 'employees|pending||a9']);
  });

  test('replace updates a row, and drops it when it leaves the tab', () async {
    repo.lists['admins|pending||null'] = [account('1'), account('2')];
    c.listen(admins, (_, _) {});
    await settle();
    final ctrl = c.read(admins.notifier);

    // still pending: updated in place, missing fields kept from the old row
    ctrl.replace(
      ManagedAccountDto.fromJson({'id': '1', 'user_name': 'Renamed'}),
    );
    expect(c.read(admins).items.first.userName, 'Renamed');
    expect(c.read(admins).items.first.phone, '+91987651');

    // approved: no longer pending, so it leaves this tab
    ctrl.replace(account('2', verified: true));
    expect(c.read(admins).items.map((a) => a.id), ['1']);
  });

  Widget app(Widget screen, String role) => ProviderScope(
    overrides: [
      manageRepositoryProvider.overrideWithValue(repo),
      sessionProvider.overrideWith(() => _SignedIn(role)),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ),
  );

  testWidgets('Manage admins lists pending admins for a super admin', (
    tester,
  ) async {
    repo.lists['admins|pending||null'] = [account('7')];
    await tester.pumpWidget(app(const ManageAdminsScreen(), 'SUPER_ADMIN'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('User 7'), findsOneWidget);
  });

  testWidgets('Manage admins is closed to a plain admin', (tester) async {
    await tester.pumpWidget(app(const ManageAdminsScreen(), 'ADMIN'));
    await tester.pumpAndSettle();
    expect(find.text("You don't have access to this view."), findsOneWidget);
  });

  testWidgets('Manage users lists an admin\'s pending employees', (
    tester,
  ) async {
    repo.lists['employees|pending||null'] = [account('5')];
    await tester.pumpWidget(app(const ManageUsersScreen(), 'ADMIN'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('User 5'), findsOneWidget);
  });
}
