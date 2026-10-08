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
