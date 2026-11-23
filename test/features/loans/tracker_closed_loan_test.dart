import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/presentation/screens/loan_tracker.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';

import 'fakes.dart';

LoanTrackModel partial(int week) => LoanTrackModel(
  id: 't$week',
  loanId: 'l1',
  weekNumber: week,
  totalCollected: 40,
  targetAmount: 100,
  status: 'PARTIAL',
  isOverdued: false,
  remainingBalance: 60,
);

void main() {
  Future<void> pump(WidgetTester tester, LoanModel l) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repo = FakeLoanRepository()..loans['l1'] = l;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loanRepositoryProvider.overrideWithValue(repo),
          borrowerLookupProvider.overrideWithValue(FakeBorrowerLookup()),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const LoanTrackerScreen(loanId: 'l1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2)); // calendar prefetch timer
    expect(tester.takeException(), isNull);
  }

  final recordButton = find.text('+ Record Weekly Payment');
  final collectButton = find.textContaining('Collect ₹');

  testWidgets('a paid-off loan shows its state instead of the button', (
    tester,
  ) async {
    await pump(
      tester,
      loan(
        'l1',
        status: 'PAID_OFF',
        outstanding: 0,
        tracks: [for (var w = 1; w <= 12; w++) track(w)],
      ),
    );
    expect(recordButton, findsNothing);
    expect(find.text('Loan paid off'), findsOneWidget);
    expect(
      find.text('No more payments can be recorded on this loan.'),
      findsOneWidget,
    );
    expect(collectButton, findsNothing);
  });

  testWidgets('an active loan with nothing left owed is shown as paid off', (
    tester,
  ) async {
    await pump(tester, loan('l1', outstanding: 0));
    expect(recordButton, findsNothing);
    expect(find.text('Loan paid off'), findsOneWidget);
  });

  testWidgets('a defaulted loan hides the button and the Collect buttons', (
    tester,
  ) async {
    await pump(
      tester,
      loan('l1', status: 'DEFAULTED', outstanding: 600, tracks: [partial(1)]),
    );
    expect(recordButton, findsNothing);
    expect(find.textContaining('Loan status:'), findsOneWidget);
    expect(collectButton, findsNothing);
  });

  testWidgets('an open loan keeps the button and the Collect buttons', (
    tester,
  ) async {
    await pump(tester, loan('l1', outstanding: 600, tracks: [partial(1)]));
    expect(recordButton, findsOneWidget);
    expect(find.text('Loan paid off'), findsNothing);
    await tester.scrollUntilVisible(collectButton.first, 300);
    expect(collectButton, findsWidgets);
  });
}
