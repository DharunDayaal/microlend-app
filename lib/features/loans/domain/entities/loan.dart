import 'package:micro_lending_app/features/loans/domain/loan_helper.dart';

/// Loan entities used across the app. Plain Dart: no JSON here.
/// Parsing lives in `features/loans/data/dtos/loan_dto.dart`.
class LoanModel {
  final String id;
  final String customerId;
  final int nominalAmount;
  final double upfrontFee;
  final double disbursedAmount;
  final double totalPayableAmount;
  final double weeklyPayableAmount;
  final double totalMonths;
  final int totalWeeks;
  final String status;
  final DateTime issuedAt;
  final String issuedByAdminId;
  final DateTime updatedAt;
  final String owningAdminId;
  final DateTime? closedAt;
  final double totalCollected;
  final int paidWeeks;
  final int partialWeeks;
  final List<LoanTrackModel> tracks;
  final double outstandingAmount;
  final String preferredPaymentDay;
  final bool isOverdue;
  final String? customerName;
  final String? phoneNumber;

  /// Overdue as the server says, or because the term has run out with money
  /// still owed (the server flag can lag until the loan is re-read).
  bool get isOverdueNow =>
      isOverdue ||
      status.toUpperCase() == 'OVERDUE' ||
      LoanHelper.isOverdue(
        issuedAt: issuedAt,
        totalWeeks: totalWeeks,
        isActive: status.toUpperCase() == 'ACTIVE',
        balance: outstandingAmount,
      );

  const LoanModel({
    required this.id,
    required this.customerId,
    required this.nominalAmount,
    required this.upfrontFee,
    required this.disbursedAmount,
    required this.totalPayableAmount,
    required this.weeklyPayableAmount,
    required this.totalMonths,
    required this.totalWeeks,
    required this.status,
    required this.issuedAt,
    required this.issuedByAdminId,
    required this.updatedAt,
    required this.owningAdminId,
    this.closedAt,
    required this.totalCollected,
    required this.paidWeeks,
    required this.partialWeeks,
    required this.tracks,
    required this.outstandingAmount,
    required this.preferredPaymentDay,
    required this.isOverdue,
    this.customerName,
    this.phoneNumber,
  });

  LoanModel copyWith({
    List<LoanTrackModel>? tracks,
    double? totalCollected,
    double? outstandingAmount,
    String? status,
    bool? isOverdue,
  }) {
    return LoanModel(
      id: id,
      customerId: customerId,
      nominalAmount: nominalAmount,
      upfrontFee: upfrontFee,
      disbursedAmount: disbursedAmount,
      totalPayableAmount: totalPayableAmount,
      weeklyPayableAmount: weeklyPayableAmount,
      totalMonths: totalMonths,
      totalWeeks: totalWeeks,
      status: status ?? this.status,
      issuedAt: issuedAt,
      issuedByAdminId: issuedByAdminId,
      updatedAt: updatedAt,
      owningAdminId: owningAdminId,
      closedAt: closedAt,
      totalCollected: totalCollected ?? this.totalCollected,
      paidWeeks: paidWeeks,
      partialWeeks: partialWeeks,
      tracks: tracks ?? this.tracks,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      preferredPaymentDay: preferredPaymentDay,
      isOverdue: isOverdue ?? this.isOverdue,
      customerName: customerName,
      phoneNumber: phoneNumber,
    );
  }
}

class LoanTrackModel {
  final String id;
  final String loanId;
  final int weekNumber;
  final double totalCollected;
  final double targetAmount;
  final String status;
  final bool isOverdued;
  final double remainingBalance;
  final bool? success;

  /// Includes a payment saved on this phone that hasn't synced yet.
  final bool pendingSync;

  const LoanTrackModel({
    required this.id,
    required this.loanId,
    required this.weekNumber,
    required this.totalCollected,
    required this.targetAmount,
    required this.status,
    required this.isOverdued,
    required this.remainingBalance,
    this.success,
    this.pendingSync = false,
  });
}

class PaymentModel {
  final String id;
  final String trackId;
  final String loanId;
  final double amountPaid;
  final DateTime? paidAt;
  final String collectedByAdminId;
  final int weekNumber;

  const PaymentModel({
    required this.id,
    required this.trackId,
    required this.loanId,
    required this.amountPaid,
    required this.paidAt,
    required this.collectedByAdminId,
    required this.weekNumber,
  });
}
