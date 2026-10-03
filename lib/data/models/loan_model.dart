class LoanModel {
  final String id;
  final String customerId;
  final int nominalAmount;
  final int upfrontFee;
  final int disbursedAmount;
  final int totalPayableAmount;
  final int weeklyPayableAmount;
  final double totalMonths;
  final int totalWeeks;
  final String status;
  final DateTime issuedAt;
  final String issuedByAdminId;
  final DateTime updatedAt;
  final String owningAdminId;
  final String customerName;
  final String phoneNumber;
  final int totalCollected;
  final bool isOverdue;

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
    required this.customerName,
    required this.phoneNumber,
    required this.totalCollected,
    required this.isOverdue,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      nominalAmount: (json['nominal_amount'] as num).toInt(),
      upfrontFee: (json['upfront_fee'] as num).toInt(),
      disbursedAmount: (json['disbursed_amount'] as num).toInt(),
      totalPayableAmount: (json['total_payable_amount'] as num).toInt(),
      weeklyPayableAmount: (json['weekly_payable_amount'] as num).toInt(),
      totalMonths: (json['total_months'] as num).toDouble(),
      totalWeeks: (json['total_weeks'] as num).toInt(),
      status: json['status'] as String,
      issuedAt: DateTime.parse(json['issued_at'] as String),
      issuedByAdminId: json['issued_by_admin_id'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      owningAdminId: json['owning_admin_id'] as String,
      customerName: json['customer_name'] as String,
      phoneNumber: json['phone_number'] as String,
      totalCollected: (json['total_collected'] as num).toInt(),
      isOverdue: json['is_overdue'] as bool,
    );
  }
}
