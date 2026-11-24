import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/data/payment_outbox.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan_stage.dart';

/// The loan details screen. Each section (loan, borrower, recent payments)
/// loads and fails on its own, so one failure never blanks the page.
@immutable
class LoanDetailsState {
  final LoanModel? loan;
  final CustomerDetails? customer;

  /// Which loan this is for the borrower (1 = first). Null when unknown.
  final int? cycle;

  /// Null = unknown, so the "issue new loan" action stays hidden.
  final bool? canIssueNew;
  final List<PaymentModel> payments;

  final bool loanLoading;
  final bool customerLoading;
  final bool paymentsLoading;
  final String? loanError;
  final String? customerError;
  final String? paymentsError;

  const LoanDetailsState({
    this.loan,
    this.customer,
    this.cycle,
    this.canIssueNew,
    this.payments = const [],
    this.loanLoading = true,
    this.customerLoading = true,
    this.paymentsLoading = true,
    this.loanError,
    this.customerError,
    this.paymentsError,
  });

  static const _keep = Object();

  LoanDetailsState copyWith({
    Object? loan = _keep,
    Object? customer = _keep,
    Object? cycle = _keep,
    Object? canIssueNew = _keep,
    List<PaymentModel>? payments,
    bool? loanLoading,
    bool? customerLoading,
    bool? paymentsLoading,
    Object? loanError = _keep,
    Object? customerError = _keep,
    Object? paymentsError = _keep,
  }) {
    T pick<T>(Object? v, T current) => identical(v, _keep) ? current : v as T;
    return LoanDetailsState(
      loan: pick(loan, this.loan),
      customer: pick(customer, this.customer),
      cycle: pick(cycle, this.cycle),
      canIssueNew: pick(canIssueNew, this.canIssueNew),
      payments: payments ?? this.payments,
      loanLoading: loanLoading ?? this.loanLoading,
      customerLoading: customerLoading ?? this.customerLoading,
      paymentsLoading: paymentsLoading ?? this.paymentsLoading,
      loanError: pick(loanError, this.loanError),
      customerError: pick(customerError, this.customerError),
      paymentsError: pick(paymentsError, this.paymentsError),
    );
  }
}

final loanDetailsProvider = NotifierProvider.autoDispose
    .family<LoanDetailsController, LoanDetailsState, String>(
      LoanDetailsController.new,
    );

class LoanDetailsController extends Notifier<LoanDetailsState> {
  final String loanId;
  LoanDetailsController(this.loanId);

  /// A response from an older request (before a refresh) is ignored.
  int _requestId = 0;

  @override
  LoanDetailsState build() {
    ref.listen(paymentOutboxProvider.select((s) => s.settledVersion), (_, _) {
      if (ref.read(paymentOutboxProvider).settledLoanIds.contains(loanId)) {
        unawaited(load(silent: true));
      }
    });
    Future.microtask(load);
    return const LoanDetailsState();
  }

  bool _stale(int id) => !ref.mounted || id != _requestId;

  /// Loads every section. With [silent] the current content stays visible.
  /// If the loan fails while one is already shown, [onRefreshError] gets the
  /// message (the screen shows it as a snackbar) and the old loan stays.
  Future<void> load({
    bool silent = false,
    void Function(String message)? onRefreshError,
  }) async {
    final id = ++_requestId;
    state = state.copyWith(
      loanLoading: silent ? null : true,
      customerLoading: silent ? null : true,
      paymentsLoading: silent ? null : true,
      loanError: null,
    );

    // payments only need the loan id, so they start right away
    final payments = _loadPayments(id);
    Future<void> borrower = Future.value();

    try {
      final loan = await ref.read(loanRepositoryProvider).getLoan(loanId);
      if (_stale(id)) return;
      state = state.copyWith(loan: loan);
      borrower = _loadBorrower(loan.customerId, id);
    } on ApiException catch (e) {
      if (_stale(id)) return;
      if (state.loan == null) {
        state = state.copyWith(loanError: e.message);
      } else {
        onRefreshError?.call(e.message); // keep what is on screen
      }
    } finally {
      if (!_stale(id)) state = state.copyWith(loanLoading: false);
    }

    await Future.wait([payments, borrower]);
  }

  void retryPayments() {
    state = state.copyWith(paymentsLoading: true);
    unawaited(_loadPayments(_requestId));
  }

  void retryBorrower() {
    final loan = state.loan;
    if (loan == null) return;
    state = state.copyWith(customerLoading: true);
    unawaited(_loadBorrower(loan.customerId, _requestId));
  }

  Future<void> _loadPayments(int id) async {
    try {
      final res = await ref
          .read(loanRepositoryProvider)
          .listPayments(loanId: loanId, page: 1, limit: 3);
      if (_stale(id)) return;
      state = state.copyWith(
        payments: List.unmodifiable(res.items),
        paymentsError: null,
      );
    } on ApiException catch (e) {
      if (!_stale(id)) state = state.copyWith(paymentsError: e.message);
    } finally {
      if (!_stale(id)) state = state.copyWith(paymentsLoading: false);
    }
  }

  Future<void> _loadBorrower(String customerId, int id) =>
      Future.wait([_loadCustomer(customerId, id), _loadCycle(customerId, id)]);

  Future<void> _loadCustomer(String customerId, int id) async {
    try {
      final c = await ref.read(borrowerLookupProvider).details(customerId);
      if (_stale(id)) return;
      state = state.copyWith(customer: c, customerError: null);
    } on ApiException catch (e) {
      if (!_stale(id)) state = state.copyWith(customerError: e.message);
    } finally {
      if (!_stale(id)) state = state.copyWith(customerLoading: false);
    }
  }

  /// Optional extras: the cycle number and whether a new loan can be issued.
  /// A failure here only hides them. It never breaks the page.
  Future<void> _loadCycle(String customerId, int id) async {
    try {
      final all = await ref.read(borrowerLookupProvider).loansOf(customerId);
      if (_stale(id)) return;

      final loans = [...all]..sort((a, b) => a.issuedAt.compareTo(b.issuedAt));
      final index = loans.indexWhere((l) => l.id == loanId);
      final hasOpen = loans.any((l) {
        final stage = loanStageOf(l.status);
        return stage == LoanStage.active || stage == LoanStage.overdue;
      });

      state = state.copyWith(
        cycle: index < 0 ? null : index + 1,
        canIssueNew: !hasOpen,
      );
    } on ApiException catch (e) {
      AppLogger.warning(
        'Could not load the borrower loans: ${e.message}',
        tag: 'LoanDetails',
      );
    }
  }
}
