import 'package:micro_lending_app/data/models/loan_model.dart';

class PaymentResultModel {
  final LoanTrackModel track;
  final String loanStatus;
  final double loanOutstandingAfter;

  const PaymentResultModel({
    required this.track,
    required this.loanStatus,
    required this.loanOutstandingAfter,
  });

  /// True once the loan has reached a terminal state — this is what the
  /// backend's collectPayment auto-flips to PAID_OFF for, the moment the
  /// loan-wide total reaches total_payable_amount.
  bool get isLoanClosed =>
      loanStatus == 'PAID_OFF' ||
      loanStatus == 'CLOSED' ||
      loanStatus == 'DEFAULTED';

  factory PaymentResultModel.fromJson(Map<String, dynamic> json) {
    final loan = json['loan'] as Map<String, dynamic>;

    return PaymentResultModel(
      track: LoanTrackModel.fromJson(json['track'] as Map<String, dynamic>),
      loanStatus: loan['status'] as String,
      loanOutstandingAfter:
          ((loan['total_payable_amount'] as num) -
                  (loan['total_collected'] as num? ?? 0))
              .toDouble(),
    );
  }
}
