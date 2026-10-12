import 'package:micro_lending_app/utils/formatters/date_formatter.dart';

class Customer {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String? referredById;
  final String preferredPaymentDay;
  final DateTime? createdAt;
  final String owningAdminId;
  final String createdBy;
  final String? streetName;
  final String city;
  final String district;

  const Customer({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    this.referredById,
    required this.preferredPaymentDay,
    this.createdAt,
    required this.owningAdminId,
    required this.createdBy,
    this.streetName,
    required this.city,
    required this.district,
  });

  factory Customer.fromJson(Map<String, dynamic> j) {
    String s(String key) => '${j[key] ?? ''}';

    return Customer(
      id: s('id'),
      customerName: s('customer_name'),
      phoneNumber: s('phone_number'),
      referredById: j['referred_by_id'] as String?,
      preferredPaymentDay: s('preferred_payment_day'),
      createdAt: DateFormatter.parse(j['created_at']),
      owningAdminId: s('owning_admin_id'),
      createdBy: s('created_by'),
      streetName: j['street_name'] as String?,
      city: s('city'),
      district: s('district'),
    );
  }
}

class DashboardSummary {
  final String date;
  final String weekday;
  final int totalTarget;
  final int totalCollected;
  final int remainingAmount;
  final int totalBorrowers;
  final int borrowersPending;

  const DashboardSummary({
    required this.date,
    required this.weekday,
    required this.totalTarget,
    required this.totalCollected,
    required this.remainingAmount,
    required this.totalBorrowers,
    required this.borrowersPending,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      date: json['date'] ?? '',
      weekday: json['weekday'] ?? '',
      totalTarget: json['totalTarget'] ?? 0,
      totalCollected: json['totalCollected'] ?? 0,
      remainingAmount: json['remainingAmount'] ?? 0,
      totalBorrowers: json['totalBorrowers'] ?? 0,
      borrowersPending: json['borrowersPending'] ?? 0,
    );
  }
}

class CreateCustomer {
  final bool success;
  final String id;
  final String customerName;
  final String customerPhoneNumber;

  const CreateCustomer({
    required this.success,
    required this.id,
    required this.customerName,
    required this.customerPhoneNumber,
  });

  factory CreateCustomer.fromJson(Map<String, dynamic> json) {
    String s(String key) => '${json[key] ?? ''}';

    return CreateCustomer(
      success: json['success'] as bool? ?? false,
      id: s('id'),
      customerName: s('customer_name'),
      customerPhoneNumber: s('phone_number'),
    );
  }
}

class CustomerDetails {
  final bool success;
  final String message;
  final String id;
  final String customerName;
  final String phoneNumber;
  final String? referredById;
  final String preferredPaymentDay;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? streetName;
  final String city;
  final String district;
  final String preferredPaymentTime;
  final String? referredByName;
  final String? referredByStanding;
  final CreditHistory creditHistory;
  final ReferralStats referralStats;

  CustomerDetails({
    required this.success,
    required this.message,
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    this.referredById,
    required this.preferredPaymentDay,
    required this.createdAt,
    required this.updatedAt,
    this.streetName,
    required this.city,
    required this.district,
    required this.preferredPaymentTime,
    this.referredByName,
    this.referredByStanding,
    required this.creditHistory,
    required this.referralStats,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    final data = json['data']?['user'] ?? {};

    return CustomerDetails(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      id: data['id'] ?? '',
      customerName: data['customer_name'] ?? '',
      phoneNumber: data['phone_number'] ?? '',
      referredById: data['referred_by_id'],
      preferredPaymentDay: data['preferred_payment_day'] ?? '',
      createdAt: DateTime.parse(
        data['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        data['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      streetName: data['street_name'],
      city: data['city'] ?? '',
      district: data['district'] ?? '',
      preferredPaymentTime: data['preferred_payment_time'] ?? '',
      referredByName: data['referred_by_name'],
      referredByStanding: data['referred_by_standing'],
      creditHistory: CreditHistory.fromJson(data['credit_history'] ?? {}),
      referralStats: ReferralStats.fromJson(data['referral_stats'] ?? {}),
    );
  }
}

class CreditHistory {
  final int onTimeCount;
  final int delayedCount;
  final int defaultCount;
  final int totalLoans;
  final num onTimeRatio;

  CreditHistory({
    required this.onTimeCount,
    required this.delayedCount,
    required this.defaultCount,
    required this.totalLoans,
    required this.onTimeRatio,
  });

  factory CreditHistory.fromJson(Map<String, dynamic> json) {
    return CreditHistory(
      onTimeCount: json['on_time_count'] ?? 0,
      delayedCount: json['delayed_count'] ?? 0,
      defaultCount: json['default_count'] ?? 0,
      totalLoans: json['total_loans'] ?? 0,
      onTimeRatio: json['on_time_ratio'] ?? 0,
    );
  }
}

class ReferralStats {
  final int totalReferred;
  final int activeReferred;
  final int pairedReferred;
  final num pairedPercentage;

  Map<String, dynamic> toMap() => {
    'total_referred': totalReferred,
    'active_referred': activeReferred,
  };

  ReferralStats({
    required this.totalReferred,
    required this.activeReferred,
    required this.pairedReferred,
    required this.pairedPercentage,
  });

  factory ReferralStats.fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      totalReferred: json['total_referred'] ?? 0,
      activeReferred: json['active_referred'] ?? 0,
      pairedReferred: json['paired_referred'] ?? 0,
      pairedPercentage: json['paired_percentage'] ?? 0,
    );
  }
}

class CustomerReferrals {
  final bool success;
  final String message;
  final List<ReferralItem> referrals;

  CustomerReferrals({
    required this.success,
    required this.message,
    required this.referrals,
  });

  factory CustomerReferrals.fromJson(Map<String, dynamic> json) {
    final list = json['data']?['referrals'] as List? ?? [];
    return CustomerReferrals(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      referrals: list.map((item) => ReferralItem.fromJson(item)).toList(),
    );
  }
}

class ReferralItem {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String referredById;
  final String preferredPaymentDay;
  final DateTime createdAt;

  ReferralItem({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    required this.referredById,
    required this.preferredPaymentDay,
    required this.createdAt,
  });

  factory ReferralItem.fromJson(Map<String, dynamic> json) {
    return ReferralItem(
      id: json['id'] ?? '',
      customerName: json['customer_name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      referredById: json['referred_by_id'] ?? '',
      preferredPaymentDay: json['preferred_payment_day'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

class CustomerLoans {
  final bool success;
  final String message;
  final List<LoanItem> loans;

  CustomerLoans({
    required this.success,
    required this.message,
    required this.loans,
  });

  factory CustomerLoans.fromJson(Map<String, dynamic> json) {
    final list = json['data']?['loans'] as List? ?? [];
    return CustomerLoans(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      loans: list.map((item) => LoanItem.fromJson(item)).toList(),
    );
  }
}

class LoanItem {
  final String id;
  final String customerId;
  final num nominalAmount;
  final num upfrontFee;
  final num disbursedAmount;
  final num totalPayableAmount;
  final num weeklyPayableAmount;
  final double totalMonths;
  final int totalWeeks;
  final String status;
  final DateTime issuedAt;
  final DateTime? closedAt;

  LoanItem({
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
    this.closedAt,
  });

  factory LoanItem.fromJson(Map<String, dynamic> json) {
    return LoanItem(
      id: json['id'] ?? '',
      customerId: json['customer_id'] ?? '',
      nominalAmount: json['nominal_amount'] ?? 0,
      upfrontFee: json['upfront_fee'] ?? 0,
      disbursedAmount: json['disbursed_amount'] ?? 0,
      totalPayableAmount: json['total_payable_amount'] ?? 0,
      weeklyPayableAmount: json['weekly_payable_amount'] ?? 0,
      totalMonths: (json['total_months'] as num? ?? 0).toDouble(),
      totalWeeks: (json['total_weeks'] as int? ?? 0).toInt(),
      status: json['status'] ?? 'UNKNOWN',
      issuedAt: DateTime.parse(
        json['issued_at'] ?? DateTime.now().toIso8601String(),
      ),
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'])
          : null,
    );
  }
}
