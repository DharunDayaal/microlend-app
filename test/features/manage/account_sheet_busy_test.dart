import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/features/manage/data/manage_providers.dart';
import 'package:micro_lending_app/features/manage/domain/entities/managed_account.dart';
import 'package:micro_lending_app/features/manage/presentation/widgets/account_sheet.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';

import 'manage_fakes.dart';

void main() {
  late Completer<bool> gate;
  var calls = 0;
  bool pagePopped = false;

  Future<bool> approve(ManagedAccount _) {
    calls++;
    return gate.future;
  }

  final actions = AccountActions(
    approve: approve,
    reject: approve,
    deactivate: approve,
    reactivate: approve,
  );

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    gate = Completer<bool>();
    calls = 0;
    pagePopped = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          manageRepositoryProvider.overrideWithValue(FakeManageRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              // the Manage screen: a pushed route under the sheet
              onPressed: () async {
                await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      body: TextButton(
                        onPressed: () => showAccountSheet(
                          context,
                          account: account('7'), // pending: shows Approve
                          isAdminAccount: true,
                          showAdminName: false,
                          actions: actions,
                        ),
                        child: const Text('sheet'),
                      ),
                    ),
                  ),
                );
                pagePopped = true;
              },
              child: const Text('screen'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('screen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('sheet'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Approve'), 300);
    await tester.tap(find.text('Approve'));
    await tester.pump();
  }

  final sheet = find.text('User 7');

  Future<void> tryEveryWayOut(WidgetTester tester) async {
    await tester.tapAt(const Offset(20, 20)); // barrier
    await tester.pump(const Duration(milliseconds: 600));
    await tester.drag(sheet, const Offset(0, 800));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.binding.handlePopRoute(); // Android back
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('stays open while the action runs, then closes on success', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Approve'), findsNothing); // spinner instead
    await tryEveryWayOut(tester);
    expect(sheet, findsOneWidget);

    gate.complete(true);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(sheet, findsNothing);
    expect(pagePopped, false); // the screen below stays
    expect(calls, 1);
  });

  testWidgets('a failed or cancelled action unlocks the sheet', (tester) async {
    await open(tester);
    gate.complete(false);
    await tester.pumpAndSettle();

    expect(sheet, findsOneWidget); // still open, buttons back
    expect(find.text('Approve'), findsOneWidget);
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(sheet, findsNothing); // can be closed again
    expect(pagePopped, false);
  });
}
