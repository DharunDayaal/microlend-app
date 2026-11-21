import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';
import 'package:micro_lending_app/features/loans/presentation/controllers/loan_details_controller.dart';
import 'package:micro_lending_app/features/loans/presentation/controllers/loan_with_borrower_controller.dart';
import 'package:micro_lending_app/features/loans/presentation/controllers/loans_list_controller.dart';

import 'fakes.dart';

void main() {
  late FakeLoanRepository repo;
  late FakeBorrowerLookup borrowers;
  late ProviderContainer c;

  setUp(() {
    repo = FakeLoanRepository();
    borrowers = FakeBorrowerLookup();
    c = ProviderContainer.test(
      overrides: [
        loanRepositoryProvider.overrideWithValue(repo),
        borrowerLookupProvider.overrideWithValue(borrowers),
      ],
    );
  });

  group('LoansListController', () {
    test(
      'loads the first page on first read, then appends without duplicates',
      () async {
        repo.loanPages[''] = [
          PagedResult(
            items: [loan('a'), loan('b')],
            page: 1,
            hasNextPage: true,
          ),
          PagedResult(
            items: [loan('b'), loan('c')],
            page: 2,
            hasNextPage: false,
          ),
        ];
        c.listen(loansListProvider, (_, _) {});
        await settle();

        var s = c.read(loansListProvider);
        expect(s.isLoading, false);
        expect(s.items.map((l) => l.id), ['a', 'b']);
        expect(s.generation, 1);

        await c.read(loansListProvider.notifier).loadMore();
        s = c.read(loansListProvider);
        expect(s.items.map((l) => l.id), ['a', 'b', 'c']);
        expect(s.hasNext, false);
      },
    );

    test('a next-page failure keeps the list and can be retried', () async {
      repo.loanPages[''] = [
        PagedResult(items: [loan('a')], page: 1, hasNextPage: true),
        PagedResult(items: [loan('b')], page: 2, hasNextPage: false),
      ];
      c.listen(loansListProvider, (_, _) {});
      await settle();

      repo.failListPage = const ApiException(message: 'offline');
      await c.read(loansListProvider.notifier).loadMore();
      expect(c.read(loansListProvider).loadMoreError, 'offline');
      expect(c.read(loansListProvider).items.length, 1);

      repo.failListPage = null;
      c.read(loansListProvider.notifier).retryLoadMore();
      await settle();
      expect(c.read(loansListProvider).items.map((l) => l.id), ['a', 'b']);
      expect(c.read(loansListProvider).loadMoreError, isNull);
    });

    test(
      'a new search replaces the list and passes the filters through',
      () async {
        repo.loanPages[''] = [
          PagedResult(items: [loan('a')], page: 1, hasNextPage: false),
        ];
        repo.loanPages['kav'] = [
          PagedResult(items: [loan('k')], page: 1, hasNextPage: false),
        ];
        c.listen(loansListProvider, (_, _) {});
        await settle();

        await c
            .read(loansListProvider.notifier)
            .load(search: 'kav', status: 'OVERDUE');
        expect(c.read(loansListProvider).items.map((l) => l.id), ['k']);
        expect(repo.listCalls.last, 'kav|OVERDUE|1');
      },
    );
  });

  group('LoanDetailsController', () {
    test(
      'loads loan, borrower, payments, cycle and issue eligibility',
      () async {
        repo.loans['l2'] = loan('l2', status: 'PAID_OFF');
        repo.payments = [payment('p1')];
        borrowers.loans = [
          loanItem('l1', 'CLOSED', DateTime(2025, 1, 1)),
          loanItem('l2', 'PAID_OFF', DateTime(2026, 1, 1)),
        ];
        c.listen(loanDetailsProvider('l2'), (_, _) {});
        await settle();

        final s = c.read(loanDetailsProvider('l2'));
        expect(s.loan?.id, 'l2');
        expect(s.customer?.customerName, 'Kavya');
        expect(s.payments.single.id, 'p1');
        expect(s.cycle, 2);
        expect(s.canIssueNew, true);
        expect(
          [s.loanLoading, s.customerLoading, s.paymentsLoading],
          [false, false, false],
        );
      },
    );

    test('a borrower with an open loan cannot get a new one', () async {
      repo.loans['l2'] = loan('l2', status: 'CLOSED');
      borrowers.loans = [
        loanItem('l2', 'CLOSED', DateTime(2025, 1, 1)),
        loanItem('l3', 'OVERDUE', DateTime(2026, 1, 1)),
      ];
      c.listen(loanDetailsProvider('l2'), (_, _) {});
      await settle();
      expect(c.read(loanDetailsProvider('l2')).canIssueNew, false);
    });

    test(
      'first-load failure shows an error; refresh failure keeps the loan',
      () async {
        repo.failLoan = const ApiException(message: 'boom');
        c.listen(loanDetailsProvider('l1'), (_, _) {});
        await settle();
        expect(c.read(loanDetailsProvider('l1')).loanError, 'boom');

        repo
          ..failLoan = null
          ..loans['l1'] = loan('l1');
        await c.read(loanDetailsProvider('l1').notifier).load();
        expect(c.read(loanDetailsProvider('l1')).loan?.id, 'l1');

        repo.failLoan = const ApiException(message: 'offline');
        String? shown;
        await c
            .read(loanDetailsProvider('l1').notifier)
            .load(silent: true, onRefreshError: (m) => shown = m);
        expect(shown, 'offline');
        expect(c.read(loanDetailsProvider('l1')).loan?.id, 'l1');
        expect(c.read(loanDetailsProvider('l1')).loanError, isNull);
      },
    );
  });

  group('LoanWithBorrowerController', () {
    test('a borrower failure surfaces as the screen error', () async {
      repo.loans['l1'] = loan('l1');
      borrowers.failDetails = const ApiException(message: 'no borrower');
      c.listen(loanWithBorrowerProvider('l1'), (_, _) {});
      await settle();
      final s = c.read(loanWithBorrowerProvider('l1'));
      expect(s.error, 'no borrower');
      expect(s.isLoading, false);
    });

    test(
      'applyPayment merges the new week, then takes the server copy',
      () async {
        repo.loans['l1'] = loan('l1', tracks: [track(1)]);
        c.listen(loanWithBorrowerProvider('l1'), (_, _) {});
        await settle();

        repo.loans['l1'] = loan(
          'l1',
          outstanding: 900,
          tracks: [track(1), track(2)],
        );
        final pending = c
            .read(loanWithBorrowerProvider('l1').notifier)
            .applyPayment(
              PaymentResultModel(
                track: track(2),
                loanStatus: 'ACTIVE',
                loanOutstandingAfter: 900,
              ),
            );

        // merged values are visible before the refetch completes
        final merged = c.read(loanWithBorrowerProvider('l1')).loan!;
        expect(merged.tracks.map((t) => t.weekNumber), [1, 2]);
        expect(merged.outstandingAmount, 900);
        expect(merged.totalCollected, 300);

        await pending;
        expect(c.read(loanWithBorrowerProvider('l1')).loan!.tracks.length, 2);
      },
    );
  });
}
