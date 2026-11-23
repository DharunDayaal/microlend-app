import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/presentation/screens/loan_tracker.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/payment_sheet.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/repayment_track_list.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';

import 'fakes.dart';

LoanTrackModel unpaid(int week) => LoanTrackModel(
  id: 't$week',
  loanId: 'l1',
  weekNumber: week,
  totalCollected: 0,
  targetAmount: 100,
  status: 'UNPAID',
  isOverdued: true,
  remainingBalance: 100,
);

void main() {
  group('nextNewWeek', () {
    int next(List<LoanTrackModel> t) => RepaymentRows.nextNewWeek(t);

    test('starts at week 1', () => expect(next(const []), 1));

    test('skips past missed weeks instead of back-filling them', () {
      // weeks 1-4 paid, 5 missed, 6 paid
      expect(next([for (var w = 1; w <= 4; w++) track(w), track(6)]), 7);
    });

    test('a partial latest week counts as taken', () {
      expect(next([track(1), track(2, status: 'PARTIAL')]), 3);
    });

    test('unpaid tracks with no money do not move it', () {
      expect(next([track(1), unpaid(2), unpaid(3)]), 2);
    });

    test('can go past the term for an extension week', () {
      expect(next([for (var w = 1; w <= 12; w++) track(w)]), 13);
    });
  });

  testWidgets('Record weekly payment opens the week after the latest payment', (
    tester,
  ) async {
    final repo = FakeLoanRepository()
      ..loans['l1'] = loan(
        'l1',
        tracks: [for (var w = 1; w <= 4; w++) track(w), track(6)],
      );
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

    await tester.tap(find.text('+ Record Weekly Payment'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // the stats card behind says "Week 5 of 12" (5 weeks collected),
    // so look only inside the sheet
    Finder inSheet(String t) => find.descendant(
      of: find.byType(PaymentSheet),
      matching: find.textContaining(t),
    );
    expect(inSheet('Week 7 of 12'), findsOneWidget);
    expect(inSheet('Week 5 '), findsNothing);
  });
}
