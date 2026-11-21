import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/app/app_overrides.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/customers/data/customer_borrower_lookup.dart';
import 'package:micro_lending_app/features/customers/data/customer_providers.dart';
import 'package:micro_lending_app/features/customers/presentation/controllers/customer_detail_controller.dart';
import 'package:micro_lending_app/features/customers/presentation/controllers/customers_list_controller.dart';
import 'package:micro_lending_app/features/customers/presentation/controllers/dashboard_summary_controller.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';

import '../loans/fakes.dart' as loans;
import 'customer_fakes.dart';

void main() {
  late FakeCustomerRepository repo;
  late loans.FakeLoanRepository loanRepo;
  late ProviderContainer c;

  setUp(() {
    repo = FakeCustomerRepository();
    loanRepo = loans.FakeLoanRepository();
    c = ProviderContainer.test(
      overrides: [
        customerRepositoryProvider.overrideWithValue(repo),
        loanRepositoryProvider.overrideWithValue(loanRepo),
      ],
    );
  });

  group('CustomersListController', () {
    test('waits for the screen, then loads the chosen weekday', () async {
      repo.pages['MONDAY'] = [
        PagedResult(
          items: [customerRow('c1'), customerRow('c2')],
          page: 1,
          hasNextPage: true,
        ),
        PagedResult(items: [customerRow('c3')], page: 2, hasNextPage: false),
      ];
      c.listen(customersListProvider, (_, _) {});
      await loans.settle();
      expect(repo.listCalls, isEmpty); // no weekday yet, so no request

      final ctrl = c.read(customersListProvider.notifier);
      await ctrl.load(weekday: 'MONDAY', search: 'ka');
      await ctrl.loadMore();

      expect(c.read(customersListProvider).items.map((x) => x.id), [
        'c1',
        'c2',
        'c3',
      ]);
      expect(repo.listCalls, ['MONDAY|ka|1', 'MONDAY|ka|2']);
    });
  });

  group('DashboardSummaryController', () {
    test(
      'loads the summary; a failure is reported and keeps the old one',
      () async {
        final ctrl = c.read(dashboardSummaryProvider.notifier);
        c.listen(dashboardSummaryProvider, (_, _) {});
        await ctrl.load();
        expect(c.read(dashboardSummaryProvider).summary?.totalTarget, 5000);
        expect(c.read(dashboardSummaryProvider).isLoading, false);

        repo.failSummary = const ApiException(message: 'offline');
        String? shown;
        await ctrl.load(showSkeleton: false, onError: (m) => shown = m);
        expect(shown, 'offline');
        expect(c.read(dashboardSummaryProvider).summary?.totalTarget, 5000);
        expect(c.read(dashboardSummaryProvider).isLoading, false);
      },
    );
  });

  group('CustomerDetailController', () {
    test('loads profile, loans and the full open loan', () async {
      repo.loanList = customerLoans([
        {'id': 'l1', 'status': 'PAID_OFF', 'issued_at': '2025-01-01T00:00:00Z'},
        {'id': 'l2', 'status': 'ACTIVE', 'issued_at': '2026-01-01T00:00:00Z'},
      ]);
      loanRepo.loans['l2'] = loans.loan('l2');
      c.listen(customerDetailProvider('c1'), (_, _) {});
      await c.read(customerDetailProvider('c1').notifier).load();

      final s = c.read(customerDetailProvider('c1'));
      expect(s.details?.id, 'c1');
      expect(s.loans.length, 2);
      expect(s.openLoan?.id, 'l2');
      expect(s.hasOpenLoan, true);
      expect(s.isLoading, false);
    });

    test('each failing section is reported; the others still load', () async {
      repo
        ..failDetails = const ApiException(message: 'no profile')
        ..failReferrals = const ApiException(message: 'no referrals');
      final errors = <String>[];
      c.listen(customerDetailProvider('c1'), (_, _) {});
      await c
          .read(customerDetailProvider('c1').notifier)
          .load(onError: errors.add);

      final s = c.read(customerDetailProvider('c1'));
      expect(errors, unorderedEquals(['no profile', 'no referrals']));
      expect(s.details, isNull);
      expect(s.hasOpenLoan, false);
      expect(s.isLoading, false);
    });
  });

  test(
    'the app wires the loans borrower lookup to the customers repository',
    () {
      final app = ProviderContainer.test(
        overrides: [
          ...appOverrides,
          customerRepositoryProvider.overrideWithValue(repo),
        ],
      );
      expect(app.read(borrowerLookupProvider), isA<CustomerBorrowerLookup>());
    },
  );
}
