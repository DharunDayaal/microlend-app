import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';

class PaymentResultModel {
  final LoanTrackModel track;
  final String loanStatus;
  final double loanOutstandingAfter;

  /// The server already had this payment (a retry with the same key).
  final bool replayed;

  /// Review flags from the server, e.g. `WEEK_ALREADY_PAID`,
  /// `OTHER_COLLECTOR_THIS_WEEK`. The payment is still accepted.
  final List<String> flags;

  const PaymentResultModel({
    required this.track,
    required this.loanStatus,
    required this.loanOutstandingAfter,
    this.replayed = false,
    this.flags = const [],
  });

  /// True once the loan has reached a terminal state — this is what the
  /// backend's collectPayment auto-flips to PAID_OFF for, the moment the
  /// loan-wide total reaches total_payable_amount.
  bool get isLoanClosed =>
      loanStatus == 'PAID_OFF' ||
      loanStatus == 'CLOSED' ||
      loanStatus == 'DEFAULTED';
}
