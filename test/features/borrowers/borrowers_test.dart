import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/features/borrowers/presentation/controllers/borrowers_controller.dart';
import 'package:micro_lending_app/features/borrowers/presentation/screens/borrowers_screen.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';

import '../loans/fakes.dart';

void main() {
  late FakeLoanRepository repo;
  late ProviderContainer c;

  setUp(() {
    repo = FakeLoanRepository();
    c = ProviderContainer.test(
      overrides: [loanRepositoryProvider.overrideWithValue(repo)],
    );
    c.listen(borrowersSummaryProvider, (_, _) {});
  });

  Future<void> start() async {
    c.listen(borrowersProvider, (_, _) {});
    await settle();
  }

  test('loads today\'s loans and the summary; next page updates it', () async {
    repo.duePages = [
      duePage([loan('l1')], hasNext: true, active: 5),
      duePage([loan('l2')], page: 2, active: 6),
    ];
    await start();
    expect(c.read(borrowersSummaryProvider)?.totalActiveLoans, 5);

    await c.read(borrowersProvider.notifier).loadMore();
    expect(c.read(borrowersProvider).items.map((l) => l.id), ['l1', 'l2']);
    expect(c.read(borrowersSummaryProvider)?.totalActiveLoans, 6);
  });

  test('a payment updates that row\'s week in place', () async {
    repo.duePages = [
      duePage([
        loan('l1', tracks: [track(1, status: 'PARTIAL')]),
        loan('l2'),
      ]),
    ];
    await start();

    c
        .read(borrowersProvider.notifier)
        .applyPayment(
          PaymentResultModel(
            track: track(1), // loanId 'l1', now PAID
            loanStatus: 'ACTIVE',
            loanOutstandingAfter: 900,
          ),
        );
    final l1 = c.read(borrowersProvider).items.first;
    expect(l1.tracks.single.status, 'PAID');
    expect(c.read(borrowersProvider).items.length, 2);
  });

  test(
    'a payment that closes the loan removes it and adjusts totals',
    () async {
      repo.duePages = [
        duePage([loan('l1'), loan('l2')], active: 5),
      ];
      await start();

      c
          .read(borrowersProvider.notifier)
          .applyPayment(
            PaymentResultModel(
              track: track(12),
              loanStatus: 'PAID_OFF',
              loanOutstandingAfter: 0,
            ),
          );
      expect(c.read(borrowersProvider).items.map((l) => l.id), ['l2']);
      expect(c.read(borrowersSummaryProvider)?.totalActiveLoans, 4);
      expect(c.read(borrowersSummaryProvider)?.totalCustomers, 8);
    },
  );

  test(
    'an unexpected failure shows a translated message, not a stuck skeleton',
    () async {
      repo.failDue = StateError('bad data');
      await start();
      final s = c.read(borrowersProvider);
      expect(s.isLoading, false);
      expect(s.error, 'Something went wrong. Please try again.');
    },
  );

  test('no next page is fetched while a silent refresh is running', () async {
    repo.duePages = [
      duePage([loan('l1')], hasNext: true),
      duePage([loan('l2')], page: 2),
    ];
    await start();
    final calls = repo.dueCalls;

    final gate = Completer<void>();
    repo.dueGate = gate.future;
    final refreshing = c
        .read(borrowersProvider.notifier)
        .refresh(showSkeleton: false);
    await c.read(borrowersProvider.notifier).loadMore();
    expect(repo.dueCalls, calls + 1); // only the refresh

    gate.complete();
    await refreshing;
  });

  testWidgets('Borrowers tab shows the totals and the due loans', (
    tester,
  ) async {
    repo.duePages = [
      duePage([loan('l1')], active: 5),
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [loanRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const BorrowerScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('9'), findsOneWidget); // total customers
    expect(find.text('Collect payment'), findsOneWidget);
  });
}
