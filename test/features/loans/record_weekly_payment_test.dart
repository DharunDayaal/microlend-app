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

List<LoanTrackModel> paidUpTo(int last) => [
  for (var w = 1; w <= last; w++) track(w),
];

final _now = DateTime.now();
final today = DateTime(_now.year, _now.month, _now.day);

/// Issued so that [week] falls due [inDays] from today (week N is due
/// issuedAt + 7N days).
DateTime issuedFor(int week, {required int inDays}) =>
    today.add(Duration(days: inDays - 7 * week));

void main() {
  group('nextNewWeek: the next scheduled week', () {
    int next(List<LoanTrackModel> t, DateTime issued) =>
        RepaymentRows.nextNewWeek(t, issuedAt: issued, now: today);

    test('a missed week stays missed: week 5 passed, week 6 in 2 days', () {
      expect(next(paidUpTo(4), issuedFor(6, inDays: 2)), 6);
    });

    test('a week due today is the one opened', () {
      expect(next(paidUpTo(4), issuedFor(5, inDays: 0)), 5);
    });

    test('nothing paid yet: still the scheduled week, not week 1', () {
      expect(next(const [], issuedFor(3, inDays: 4)), 3);
    });

    test('ahead of schedule: the week after the latest payment', () {
      expect(next(paidUpTo(6), issuedFor(6, inDays: 2)), 7);
      expect(next([track(1), track(2, status: 'PARTIAL')], today), 3);
    });

    test('empty unpaid tracks do not count as payments', () {
      expect(
        next([track(1), unpaid(2), unpaid(3)], issuedFor(2, inDays: 1)),
        2,
      );
    });

    test('past a 12-week term it keeps counting', () {
      // week 15 is due in 3 days: 13 and 14 are past and missed
      expect(next(paidUpTo(12), issuedFor(15, inDays: 3)), 15);
    });
  });

  group('overdue past the term', () {
    test('an ACTIVE loan past its term with money owed is overdue', () {
      final past = issuedFor(12, inDays: -1); // term ended yesterday
      expect(loan('l1', issuedAt: past).isOverdueNow, true);
      expect(loan('l1', issuedAt: past, outstanding: 0).isOverdueNow, false);
      expect(
        loan('l1', issuedAt: issuedFor(12, inDays: 0)).isOverdueNow,
        false, // the last week is due today: not yet
      );
      expect(loan('l1', issuedAt: today, isOverdue: true).isOverdueNow, true);
    });

    test('weeks past the term are overdue rows, paid or not', () {
      final rows = RepaymentRows.build(
        tracks: [...paidUpTo(12), track(13)],
        totalWeeks: 12,
        issuedAt: issuedFor(14, inDays: 0),
        isOverdueLoan: false, // even before the server flags the loan
      );
      expect(rows[11].isExtension, false);
      expect(rows[12].isExtension, true);
      expect(rows[12].state, RepaymentRowState.paid);
    });
  });

  Future<void> openRecordSheet(WidgetTester tester, LoanModel l) async {
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
    await tester.tap(find.text('+ Record Weekly Payment'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  // the stats card behind the sheet also says "Week N of M", so look only
  // inside the sheet
  Finder inSheet(String t) => find.descendant(
    of: find.byType(PaymentSheet),
    matching: find.textContaining(t),
  );

  testWidgets('the button opens the next scheduled week, not the missed one', (
    tester,
  ) async {
    await openRecordSheet(
      tester,
      loan('l1', tracks: paidUpTo(4), issuedAt: issuedFor(6, inDays: 2)),
    );
    expect(inSheet('Week 6 of 12'), findsOneWidget);
    expect(inSheet('Week 5 '), findsNothing);
  });

  testWidgets('past the term the new week is shown as overdue', (tester) async {
    await openRecordSheet(
      tester,
      loan('l1', tracks: paidUpTo(12), issuedAt: issuedFor(15, inDays: 3)),
    );
    expect(inSheet('Week 15 of 12'), findsOneWidget);
    expect(inSheet('Overdue — past the 12-week term'), findsOneWidget);
  });
}
