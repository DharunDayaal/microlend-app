import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/loans/domain/entities/collections_due.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan_terms.dart';
import 'package:micro_lending_app/features/loans/domain/entities/manual_loan_status.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';
import 'package:micro_lending_app/features/loans/domain/entities/pending_payment.dart';
import 'package:micro_lending_app/features/loans/domain/loan_repository.dart';
import 'package:micro_lending_app/features/loans/domain/pending_overlay.dart';

/// Wraps the server repository so every loan it returns already includes
/// the payments waiting on this phone ([PendingOverlay]). Screens don't
/// need to know about the queue to show the right balance.
class PendingAwareLoanRepository implements LoanRepository {
  final LoanRepository _inner;
  final Iterable<PendingPayment> Function() _pending;

  const PendingAwareLoanRepository(this._inner, this._pending);

  LoanModel _overlay(LoanModel l, {bool withTracks = true}) =>
      PendingOverlay.apply(l, _pending(), withTracks: withTracks);

  @override
  Future<LoanModel> getLoan(String loanId) async =>
      _overlay(await _inner.getLoan(loanId));

  @override
  Future<PagedResult<LoanModel>> listLoans({
    int page = 1,
    int limit = 20,
    String search = '',
    String status = '',
  }) async {
    final res = await _inner.listLoans(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );
    return PagedResult(
      items: [for (final l in res.items) _overlay(l, withTracks: false)],
      page: res.page,
      hasNextPage: res.hasNextPage,
    );
  }

  @override
  Future<CollectionsLoanDueModel> collectionsDue({
    required String weekday,
    int page = 1,
    int limit = 20,
    String search = '',
    String issuedAdmin = '',
  }) async {
    final due = await _inner.collectionsDue(
      weekday: weekday,
      page: page,
      limit: limit,
      search: search,
      issuedAdmin: issuedAdmin,
    );
    return CollectionsLoanDueModel(
      summary: due.summary,
      result: PagedResult(
        items: [for (final l in due.result.items) _overlay(l)],
        page: due.result.page,
        hasNextPage: due.result.hasNextPage,
      ),
    );
  }

  @override
  Future<PagedResult<PaymentModel>> listPayments({
    required String loanId,
    int page = 1,
    int limit = 20,
  }) => _inner.listPayments(loanId: loanId, page: page, limit: limit);

  @override
  Future<PaymentResultModel> collectPayment({
    required String loanId,
    required int weekNumber,
    required double amount,
    required String idempotencyKey,
    required DateTime collectedAt,
  }) => _inner.collectPayment(
    loanId: loanId,
    weekNumber: weekNumber,
    amount: amount,
    idempotencyKey: idempotencyKey,
    collectedAt: collectedAt,
  );

  @override
  Future<LoanModel> issueLoan({
    required String customerId,
    required LoanTerms terms,
    DateTime? issuedAt,
  }) => _inner.issueLoan(
    customerId: customerId,
    terms: terms,
    issuedAt: issuedAt,
  );

  @override
  Future<void> changeStatus({
    required String loanId,
    required ManualLoanStatus status,
  }) => _inner.changeStatus(loanId: loanId, status: status);
}
