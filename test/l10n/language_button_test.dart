import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/l10n/language_sheet.dart';
import 'package:micro_lending_app/l10n/locale_controller.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            theme: AppTheme.darkTheme,
            locale: ref.watch(localeProvider),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              appBar: AppBar(actions: const [LanguageButton()]),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('header button shows the language and switches it', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('EN'), findsOneWidget);

    await tester.tap(find.byType(LanguageButton));
    await tester.pumpAndSettle();
    expect(find.text('தமிழ்'), findsOneWidget); // the language sheet

    await tester.tap(find.text('தமிழ்'));
    await tester.pumpAndSettle();
    expect(find.text('த'), findsOneWidget);
    expect(find.text('EN'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
