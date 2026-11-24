import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/data/payment_outbox.dart';
import 'package:micro_lending_app/features/loans/domain/entities/collections_due.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';
import 'package:micro_lending_app/shared/pagination/paged_notifier.dart';
import 'package:micro_lending_app/shared/pagination/paged_state.dart';

/// Totals above the Borrowers list. Updated with every page and adjusted
/// when a loan closes from this screen.
final borrowersSummaryProvider =
    NotifierProvider.autoDispose<BorrowersSummaryController, Summary?>(
      BorrowersSummaryController.new,
    );

class BorrowersSummaryController extends Notifier<Summary?> {
  @override
  Summary? build() => null;

  void set(Summary summary) => state = summary;

  /// A loan just closed: it leaves today's active list.
  void loanClosed() {
    final s = state;
    if (s == null) return;
    state = s.copyWith(
      totalActiveLoans: s.totalActiveLoans - 1,
      totalCustomers: s.totalCustomers - 1,
    );
  }
}

/// Loans due today (the Borrowers tab), with their repayment tracks.
final borrowersProvider =
    NotifierProvider.autoDispose<BorrowersController, PagedState<LoanModel>>(
      BorrowersController.new,
    );

class BorrowersController extends PagedNotifier<LoanModel> {
  /// Today's collection day, in the API's form ('MONDAY').
  final String weekday = DateFormatter.weekdayFull(DateTime.now());

  @override
  PagedState<LoanModel> build() {
    // a queued payment for a loan on this list synced (or was rejected)
    // in the background: reload so the rows show the server's numbers
    ref.listen(paymentOutboxProvider.select((s) => s.settledVersion), (_, _) {
      final settled = ref.read(paymentOutboxProvider).settledLoanIds;
      if (state.items.any((l) => settled.contains(l.id))) {
        unawaited(refresh(showSkeleton: false));
      }
    });
    return super.build();
  }

  @override
  Future<PagedResult<LoanModel>> fetchPage(int page, int limit) async {
    final due = await ref
        .read(loanRepositoryProvider)
        .collectionsDue(weekday: weekday, page: page, limit: limit);
    return _DuePage(due);
  }

  @override
  void onPageAccepted(PagedResult<LoanModel> page) {
    if (page is _DuePage) {
      ref.read(borrowersSummaryProvider.notifier).set(page.summary);
    }
  }

  @override
  Object idOf(LoanModel item) => item.id;

  /// Shows a payment collected from a row: updates its week, or drops the
  /// loan from today's list when the payment closed it.
  void applyPayment(PaymentResultModel payment) {
    final loanId = payment.track.loanId;
    if (payment.isLoanClosed) {
      AppLogger.info("The loan closed on complete payment", tag: "CLOSED");
      editItems((items) => items.where((l) => l.id != loanId).toList());
      ref.read(borrowersSummaryProvider.notifier).loanClosed();
      return;
    }
    editItems(
      (items) => [
        for (final l in items)
          if (l.id != loanId)
            l
          else
            l.copyWith(
              tracks: [
                ...l.tracks.where((t) => t.id != payment.track.id),
                payment.track,
              ]..sort((a, b) => a.weekNumber.compareTo(b.weekNumber)),
            ),
      ],
    );
  }
}

/// A page of due loans that also carries the summary counts.
class _DuePage extends PagedResult<LoanModel> {
  final Summary summary;
  _DuePage(CollectionsLoanDueModel due)
    : summary = due.summary,
      super(
        items: due.result.items,
        page: due.result.page,
        hasNextPage: due.result.hasNextPage,
      );
}
