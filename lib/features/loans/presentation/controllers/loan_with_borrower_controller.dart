import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';

/// One loan plus its borrower, loaded together. Used by the repayment
/// tracker and the payments screen header.
@immutable
class LoanWithBorrowerState {
  final LoanModel? loan;
  final CustomerDetails? borrower;
  final bool isLoading;
  final String? error;

  const LoanWithBorrowerState({
    this.loan,
    this.borrower,
    this.isLoading = true,
    this.error,
  });
}

final loanWithBorrowerProvider = NotifierProvider.autoDispose
    .family<LoanWithBorrowerController, LoanWithBorrowerState, String>(
      LoanWithBorrowerController.new,
    );

class LoanWithBorrowerController extends Notifier<LoanWithBorrowerState> {
  final String loanId;
  LoanWithBorrowerController(this.loanId);

  int _requestId = 0;

  @override
  LoanWithBorrowerState build() {
    Future.microtask(load);
    return const LoanWithBorrowerState();
  }

  /// Fetches the loan, then its borrower. [showSkeleton] is false for
  /// pull-to-refresh. Returns true when both arrived.
  Future<bool> load({bool showSkeleton = true}) async {
    final id = ++_requestId;
    state = LoanWithBorrowerState(
      loan: state.loan,
      borrower: state.borrower,
      isLoading: showSkeleton ? true : state.isLoading,
    );

    try {
      final loan = await ref.read(loanRepositoryProvider).getLoan(loanId);
      if (!ref.mounted || id != _requestId) return false;
      final borrower = await ref
          .read(borrowerLookupProvider)
          .details(loan.customerId);
      if (!ref.mounted || id != _requestId) return false;

      state = LoanWithBorrowerState(
        loan: loan,
        borrower: borrower,
        isLoading: false,
      );
      return true;
    } on ApiException catch (e) {
      AppLogger.error(e.message);
      if (!ref.mounted || id != _requestId) return false;
      state = LoanWithBorrowerState(
        loan: state.loan,
        borrower: state.borrower,
        isLoading: false,
        error: e.message,
      );
      return false;
    }
  }

  /// Shows a recorded payment at once, then replaces it with the server's
  /// version. If that refetch fails, the merged values stay.
  Future<void> applyPayment(PaymentResultModel result) async {
    final loan = state.loan;
    if (loan == null) return;

    final tracks = [
      ...loan.tracks.where((t) => t.weekNumber != result.track.weekNumber),
      result.track,
    ]..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
    final outstanding = result.loanOutstandingAfter;

    state = LoanWithBorrowerState(
      loan: loan.copyWith(
        tracks: tracks,
        status: result.loanStatus,
        outstandingAmount: outstanding,
        totalCollected: loan.totalPayableAmount - outstanding,
      ),
      borrower: state.borrower,
      isLoading: state.isLoading,
      error: state.error,
    );

    try {
      final fresh = await ref.read(loanRepositoryProvider).getLoan(loanId);
      if (!ref.mounted) return;
      state = LoanWithBorrowerState(
        loan: fresh,
        borrower: state.borrower,
        isLoading: state.isLoading,
        error: state.error,
      );
    } on ApiException {
      // the merged values stay on screen
    }
  }
}
