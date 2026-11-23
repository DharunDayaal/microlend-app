import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';

/// JSON -> entity mapping for the customers API. Field names and fallbacks
/// are unchanged from the old `fromJson` factories.

abstract final class CustomerDto {
  static Customer fromJson(Map<String, dynamic> j) {
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

abstract final class DashboardSummaryDto {
  static DashboardSummary fromJson(Map<String, dynamic> json) {
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

abstract final class CreateCustomerDto {
  static CreateCustomer fromJson(Map<String, dynamic> json) {
    String s(String key) => '${json[key] ?? ''}';

    return CreateCustomer(
      success: json['success'] as bool? ?? false,
      id: s('id'),
      customerName: s('customer_name'),
      customerPhoneNumber: s('phone_number'),
    );
  }
}

abstract final class CustomerDetailsDto {
  static CustomerDetails fromJson(Map<String, dynamic> json) {
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
      creditHistory: CreditHistoryDto.fromJson(data['credit_history'] ?? {}),
      referralStats: ReferralStatsDto.fromJson(data['referral_stats'] ?? {}),
    );
  }
}

abstract final class CreditHistoryDto {
  static CreditHistory fromJson(Map<String, dynamic> json) {
    return CreditHistory(
      onTimeCount: json['on_time_count'] ?? 0,
      delayedCount: json['delayed_count'] ?? 0,
      defaultCount: json['default_count'] ?? 0,
      totalLoans: json['total_loans'] ?? 0,
      onTimeRatio: json['on_time_ratio'] ?? 0,
    );
  }
}

abstract final class ReferralStatsDto {
  static ReferralStats fromJson(Map<String, dynamic> json) {
    return ReferralStats(
      totalReferred: json['total_referred'] ?? 0,
      activeReferred: json['active_referred'] ?? 0,
      pairedReferred: json['paired_referred'] ?? 0,
      pairedPercentage: json['paired_percentage'] ?? 0,
    );
  }
}

abstract final class ReferralItemDto {
  static ReferralItem fromJson(Map<String, dynamic> json) {
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

abstract final class LoanItemDto {
  static LoanItem fromJson(Map<String, dynamic> json) {
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
