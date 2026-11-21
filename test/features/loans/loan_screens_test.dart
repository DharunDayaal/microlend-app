import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/presentation/screens/loan_details.dart';
import 'package:micro_lending_app/features/loans/presentation/screens/loan_payments.dart';
import 'package:micro_lending_app/features/loans/presentation/screens/loan_tracker.dart';
import 'package:micro_lending_app/features/loans/presentation/screens/loans.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';

import 'fakes.dart';

Widget _app(Widget child, FakeLoanRepository repo, FakeBorrowerLookup b) =>
    ProviderScope(
      overrides: [
        loanRepositoryProvider.overrideWithValue(repo),
        borrowerLookupProvider.overrideWithValue(b),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );

void main() {
  late FakeLoanRepository repo;
  late FakeBorrowerLookup borrowers;

  setUp(() {
    repo = FakeLoanRepository()
      ..loans['l1'] = loan('l1', tracks: [track(1)])
      ..payments = [payment('p1')];
    borrowers = FakeBorrowerLookup();
  });

  testWidgets('loans list shows rows from the repository', (tester) async {
    repo.loanPages[''] = [
      PagedResult(items: [loan('l1'), loan('l2')], page: 1, hasNextPage: false),
    ];
    await tester.pumpWidget(_app(const LoansScreen(), repo, borrowers));
    await tester.pumpAndSettle();
    expect(find.text('View Ledger'), findsNWidgets(2));
    expect(find.text('No more loans'), findsOneWidget);
  });

  testWidgets('payments, tracker and details screens build with data', (
    tester,
  ) async {
    for (final screen in const [
      LoanPaymentsScreen(loanId: 'l1'),
      LoanTrackerScreen(loanId: 'l1'),
      LoanDetailsScreen(loanId: 'l1'),
    ]) {
      await tester.pumpWidget(_app(screen, repo, borrowers));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$screen');
      expect(find.text('Kavya'), findsWidgets, reason: '$screen');
    }
  });

  testWidgets('loans list reloads when a loan changed on its detail screen', (
    tester,
  ) async {
    repo.loanPages[''] = [
      PagedResult(items: [loan('l1')], page: 1, hasNextPage: false),
    ];
    final router = GoRouter(
      initialLocation: '/loans',
      routes: [
        GoRoute(
          path: '/loans',
          builder: (_, _) => const LoansScreen(),
          routes: [
            GoRoute(
              path: ':id',
              // stands in for loan details: reports a change on close
              builder: (context, _) => Scaffold(
                body: TextButton(
                  onPressed: () => context.pop(true),
                  child: const Text('close changed'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loanRepositoryProvider.overrideWithValue(repo),
          borrowerLookupProvider.overrideWithValue(borrowers),
        ],
        child: MaterialApp.router(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(repo.listCalls, hasLength(1));

    await tester.tap(find.text('View Ledger'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('close changed'));
    await tester.pumpAndSettle();

    expect(repo.listCalls, hasLength(2));
    expect(find.text('View Ledger'), findsOneWidget);
  });
}
