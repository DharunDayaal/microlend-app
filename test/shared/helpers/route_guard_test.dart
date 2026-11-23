import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/features/profile/presentation/widgets/profile_sheets.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';
import 'package:micro_lending_app/shared/helpers/route_guard.dart';

/// A pushed screen that returns a bool (like the app's go_router screens),
/// with a button that opens [sheet]. Records both results.
class _Harness {
  Object? sheetResult = 'not closed';
  bool? pageResult;
  bool pagePopped = false;

  Widget app(WidgetBuilder sheet) => MaterialApp(
    theme: AppTheme.darkTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => TextButton(
        onPressed: () async {
          pageResult = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    sheetResult = await showProfileSheet<Object>(
                      context,
                      sheet,
                    );
                  },
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
  );

  Future<void> open(WidgetTester tester, WidgetBuilder sheet) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(sheet));
    await tester.tap(find.text('screen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('sheet'));
    await tester.pumpAndSettle();
  }
}

/// Pops after [gate], like a sheet saving something.
class _AsyncPopper extends StatelessWidget {
  final Completer<void> gate;
  const _AsyncPopper(this.gate);

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () async {
      await gate.future;
      if (context.mounted) context.popIfTop('done');
    },
    child: const Text('save'),
  );
}

void main() {
  group('popIfTop', () {
    testWidgets('pops the sheet when it is still on top', (tester) async {
      final h = _Harness();
      final gate = Completer<void>()..complete();
      await h.open(tester, (_) => _AsyncPopper(gate));
      await tester.tap(find.text('save'));
      await tester.pumpAndSettle();
      expect(h.sheetResult, 'done');
      expect(h.pagePopped, false);
    });

    testWidgets('does nothing once the sheet was closed: the screen below '
        'stays', (tester) async {
      final h = _Harness();
      final gate = Completer<void>();
      await h.open(tester, (_) => _AsyncPopper(gate));
      await tester.tap(find.text('save'));
      await tester.pump();
      await tester.tapAt(const Offset(20, 20)); // dismiss via the barrier
      await tester.pumpAndSettle();
      expect(find.text('save'), findsNothing);

      gate.complete();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(h.pagePopped, false); // a plain pop would have closed it
      expect(find.text('sheet'), findsOneWidget);
    });
  });

  testWidgets('change password sheet stays open while saving, then returns '
      'its result to the screen', (tester) async {
    final h = _Harness();
    final gate = Completer<String?>();
    await h.open(
      tester,
      (_) => ChangePasswordSheet(onSubmit: (_, _) => gate.future),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'oldpass1');
    await tester.enterText(fields.at(1), 'Newpass1!');
    await tester.enterText(fields.at(2), 'Newpass1!');
    await tester.tap(find.text('Update password'));
    await tester.pump();

    // every way out while the request is pending
    await tester.tapAt(const Offset(20, 20));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.drag(find.byType(ChangePasswordSheet), const Offset(0, 800));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(ChangePasswordSheet), findsOneWidget);

    gate.complete(null); // saved
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(ChangePasswordSheet), findsNothing);
    expect(h.sheetResult, true);
    expect(h.pagePopped, false);
  });
}
