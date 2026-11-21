import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/features/customers/data/customer_providers.dart';
import 'package:micro_lending_app/features/customers/presentation/screens/customer_detail.dart';
import 'package:micro_lending_app/features/customers/presentation/screens/customer_screen.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';

import '../loans/fakes.dart' as loans;
import 'customer_fakes.dart';

Widget _app(Widget child, FakeCustomerRepository repo) => ProviderScope(
  overrides: [
    customerRepositoryProvider.overrideWithValue(repo),
    loanRepositoryProvider.overrideWithValue(loans.FakeLoanRepository()),
  ],
  child: MaterialApp(
    theme: AppTheme.darkTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

void main() {
  testWidgets('Field tab shows the summary and today\'s customers', (
    tester,
  ) async {
    final repo = FakeCustomerRepository();
    // the chips use API values, so the screen asks for e.g. 'FRIDAY'
    repo.pages[DateFormatter.weekdayFull(DateTime.now()).toUpperCase()] = [
      PagedResult(
        items: [customerRow('c1', name: 'Kavya')],
        page: 1,
        hasNextPage: false,
      ),
    ];
    await tester.pumpWidget(_app(const CustomerScreen(), repo));
    await tester.pumpAndSettle();

    expect(find.text('Kavya'), findsOneWidget);
    expect(find.text('3 Borrowers'), findsOneWidget);
    expect(find.text('No more customers'), findsOneWidget);
  });

  testWidgets('customer detail shows the profile', (tester) async {
    final repo = FakeCustomerRepository();
    await tester.pumpWidget(
      _app(const CustomerDetailScreen(customerId: 'c1'), repo),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Kavya'), findsWidgets);
  });

  testWidgets('customer detail reloads after a payment in the tracker', (
    tester,
  ) async {
    final repo = FakeCustomerRepository()
      ..loanList = customerLoans([
        {'id': 'l2', 'status': 'ACTIVE', 'issued_at': '2026-01-01T00:00:00Z'},
      ]);
    final loanRepo = loans.FakeLoanRepository()..loans['l2'] = loans.loan('l2');
    final router = GoRouter(
      initialLocation: '/customers/c1',
      routes: [
        GoRoute(
          path: '/customers/:id',
          builder: (_, _) => const CustomerDetailScreen(customerId: 'c1'),
        ),
        GoRoute(
          path: '/loans/:id/tracks',
          // stands in for the tracker: reports that a payment was recorded
          builder: (context, _) => Scaffold(
            body: TextButton(
              onPressed: () => context.pop(true),
              child: const Text('paid and closed'),
            ),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          customerRepositoryProvider.overrideWithValue(repo),
          loanRepositoryProvider.overrideWithValue(loanRepo),
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
    expect(repo.detailCalls, 1);

    await tester.scrollUntilVisible(find.text('View Tracks'), 200);
    await tester.tap(find.text('View Tracks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('paid and closed'));
    await tester.pumpAndSettle();

    expect(repo.detailCalls, 2);
  });
}
