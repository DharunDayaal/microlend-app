import 'package:micro_lending_app/data/models/paged_modal.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';

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

  factory LoanModel.fromJson(Map<String, dynamic> json) {
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
          .map((t) => LoanTrackModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      outstandingAmount: (json['outstanding_amount'] as num? ?? 0).toDouble(),
      preferredPaymentDay: json['preferred_payment_day']?.toString() ?? '',
      isOverdue: json['is_overdue'] as bool? ?? false,
      customerName: json['customer_name']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
    );
  }

  factory LoanModel.fromListJson(Map<String, dynamic> json) {
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
  });

  factory LoanTrackModel.fromJson(Map<String, dynamic> json) {
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

  factory LoanTrackModel.fromPaymentJson(Map<String, dynamic> json) {
    return LoanTrackModel(
      success: json['success'] as bool? ?? false,
      id: json['data']['track']['id']?.toString() ?? '',
      loanId: json['data']['track']['loan_id']?.toString() ?? '',
      weekNumber: (json['data']['track']['week_number'] as num? ?? 0).toInt(),
      totalCollected: (json['data']['track']['total_collected'] as num? ?? 0)
          .toDouble(),
      targetAmount: (json['data']['track']['target_amount'] as num? ?? 0)
          .toDouble(),
      status: json['data']['track']['status']?.toString() ?? 'UNPAID',
      isOverdued: json['data']['track']['is_overdued'] as bool? ?? false,
      remainingBalance:
          (json['data']['track']['remaining_balance'] as num? ?? 0).toDouble(),
    );
  }
}

class Summary {
  final int totalCustomers;
  final int totalActiveLoans;
  final int totalOverdueLoans;
  final int totalReferredCustomers;

  const Summary({
    required this.totalCustomers,
    required this.totalActiveLoans,
    required this.totalOverdueLoans,
    required this.totalReferredCustomers,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    int i(String key) => CurrencyFormatter.toNum(json[key]).toInt();

    return Summary(
      totalCustomers: i("total_customers"),
      totalActiveLoans: i("active_loans"),
      totalOverdueLoans: i("overdue_loans"),
      totalReferredCustomers: i("referred_customers"),
    );
  }

  Summary copyWith({
    int? totalCustomers,
    int? totalActiveLoans,
    int? totalOverdueLoans,
    int? totalReferredCustomers,
  }) {
    return Summary(
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalActiveLoans: totalActiveLoans ?? this.totalActiveLoans,
      totalOverdueLoans: totalOverdueLoans ?? this.totalOverdueLoans,
      totalReferredCustomers:
          totalReferredCustomers ?? this.totalReferredCustomers,
    );
  }
}

class CollectionsLoanDueModel {
  final PagedResult result;
  final Summary summary;

  const CollectionsLoanDueModel({required this.result, required this.summary});
}
