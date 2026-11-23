import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/features/loans/domain/entities/collections_due.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan_terms.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';

/// JSON <-> entity mapping for the loans API. Field names and fallbacks are
/// unchanged from the old `fromJson` factories.
abstract final class LoanDto {
  static LoanModel fromJson(Map<String, dynamic> json) {
    final trackList = json['tracks'] as List? ?? [];

    return LoanModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      nominalAmount: (json['nominal_amount'] as num? ?? 0).toInt(),
      upfrontFee: (json['upfront_fee'] as num? ?? 0).toDouble(),
      disbursedAmount: (json['disbursed_amount'] as num? ?? 0).toDouble(),
      totalPayableAmount: (json['total_payable_amount'] as num? ?? 0)
          .toDouble(),
      weeklyPayableAmount: (json['weekly_payable_amount'] as num? ?? 0)
          .toDouble(),
      totalMonths: (json['total_months'] as num? ?? 0).toDouble(),
      totalWeeks: (json['total_weeks'] as num? ?? 0).toInt(),
      status: json['status']?.toString() ?? 'UNKNOWN',
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'].toString())
          : DateTime.now(),
      issuedByAdminId: json['issued_by_admin_id']?.toString() ?? '',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      owningAdminId: json['owning_admin_id']?.toString() ?? '',
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'].toString())
          : null,

      totalCollected: (json['total_collected'] as num? ?? 0).toDouble(),
      paidWeeks: (json['paid_weeks'] as num? ?? 0).toInt(),
      partialWeeks: (json['partial_weeks'] as num? ?? 0).toInt(),
      tracks: trackList
          .map((t) => LoanTrackDto.fromJson(t as Map<String, dynamic>))
          .toList(),
      outstandingAmount: (json['outstanding_amount'] as num? ?? 0).toDouble(),
      preferredPaymentDay: json['preferred_payment_day']?.toString() ?? '',
      isOverdue: json['is_overdue'] as bool? ?? false,
      customerName: json['customer_name']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
    );
  }

  /// The list endpoint sends no tracks and no outstanding amount.
  static LoanModel fromListJson(Map<String, dynamic> json) {
    final double totalPayable = (json['total_payable_amount'] as num? ?? 0)
        .toDouble();
    final double collected = (json['total_collected'] as num? ?? 0).toDouble();

    return LoanModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customer_id']?.toString() ?? '',
      nominalAmount: (json['nominal_amount'] as num? ?? 0).toInt(),
      upfrontFee: (json['upfront_fee'] as num? ?? 0).toDouble(),
      disbursedAmount: (json['disbursed_amount'] as num? ?? 0).toDouble(),
      totalPayableAmount: totalPayable,
      weeklyPayableAmount: (json['weekly_payable_amount'] as num? ?? 0)
          .toDouble(),
      totalMonths: (json['total_months'] as num? ?? 0).toDouble(),
      totalWeeks: (json['total_weeks'] as num? ?? 0).toInt(),
      status: json['status']?.toString() ?? 'UNKNOWN',
      issuedAt: json['issued_at'] != null
          ? DateTime.parse(json['issued_at'].toString())
          : DateTime.now(),
      issuedByAdminId: json['issued_by_admin_id']?.toString() ?? '',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      owningAdminId: json['owning_admin_id']?.toString() ?? '',
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'].toString())
          : null,
      totalCollected: collected,
      preferredPaymentDay: json['preferred_payment_day']?.toString() ?? '',
      isOverdue: json['is_overdue'] as bool? ?? false,
      paidWeeks: 0,
      partialWeeks: 0,
      tracks: const [],
      outstandingAmount: totalPayable - collected,
      customerName: json['customer_name']?.toString() ?? 'N/A',
      phoneNumber: json['phone_number']?.toString() ?? '',
    );
  }
}

abstract final class LoanTrackDto {
  static LoanTrackModel fromJson(Map<String, dynamic> json) {
    return LoanTrackModel(
      id: json['id']?.toString() ?? '',
      loanId: json['loan_id']?.toString() ?? '',
      weekNumber: (json['week_number'] as num? ?? 0).toInt(),
      totalCollected: (json['total_collected'] as num? ?? 0).toDouble(),
      targetAmount: (json['target_amount'] as num? ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'UNPAID',
      isOverdued: json['is_overdued'] as bool? ?? false,
      remainingBalance: (json['remaining_balance'] as num? ?? 0).toDouble(),
    );
  }
}

abstract final class PaymentDto {
  static PaymentModel fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id']?.toString() ?? '',
      trackId: json['track_id']?.toString() ?? '',
      loanId: json['loan_id']?.toString() ?? '',
      amountPaid: CurrencyFormatter.toNum(json['amount_paid']).toDouble(),
      paidAt: DateFormatter.parse(json['paid_at']),
      collectedByAdminId: json['collected_by_admin_id']?.toString() ?? '',
      weekNumber: CurrencyFormatter.toNum(json['week_number']).toInt(),
    );
  }
}

abstract final class PaymentResultDto {
  static PaymentResultModel fromJson(Map<String, dynamic> json) {
    final loan = json['loan'] as Map<String, dynamic>;

    return PaymentResultModel(
      track: LoanTrackDto.fromJson(json['track'] as Map<String, dynamic>),
      loanStatus: loan['status'] as String,
      loanOutstandingAfter:
          ((loan['total_payable_amount'] as num) -
                  (loan['total_collected'] as num? ?? 0))
              .toDouble(),
      replayed: json['replayed'] as bool? ?? false,
      flags: [for (final f in json['flags'] as List? ?? const []) f.toString()],
    );
  }
}

abstract final class CollectionsSummaryDto {
  static Summary fromJson(Map<String, dynamic> json) {
    int i(String key) => CurrencyFormatter.toNum(json[key]).toInt();

    return Summary(
      totalCustomers: i("total_customers"),
      totalActiveLoans: i("active_loans"),
      totalOverdueLoans: i("overdue_loans"),
      totalReferredCustomers: i("referred_customers"),
    );
  }
}

abstract final class LoanTermsDto {
  /// Body for the issue-loan call. Optional fields are omitted when null.
  static Map<String, dynamic> issuePayload(
    LoanTerms terms, {
    required String customerId,
    DateTime? issuedAt,
  }) => {
    'customer_id': customerId,
    'nominal_amount': terms.principal,
    'total_months': terms.months,
    'upfront_fee_percentage': terms.feePercent,
    'interest_percentage': terms.interestPercent,
    if (issuedAt != null) 'issued_at': issuedAt.toUtc().toIso8601String(),
  };
}
