/// Customer entities used across the app. Plain Dart: no JSON here.
/// Parsing lives in `features/customers/data/dtos/customer_dto.dart`.
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
}
