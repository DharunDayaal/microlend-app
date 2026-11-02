import 'package:micro_lending_app/utils/formatters/date_formatter.dart';

/// Declared lowest to highest. The order is used for "at least this role".
enum UserRole {
  user('USER'),
  admin('ADMIN'),
  superAdmin('SUPER_ADMIN');

  final String apiValue;
  const UserRole(this.apiValue);

  /// A missing or unknown role becomes USER, the lowest privilege.
  static UserRole parse(String? value) {
    final v = (value ?? '').trim().toUpperCase();
    return UserRole.values.firstWhere(
      (r) => r.apiValue == v,
      orElse: () => UserRole.user,
    );
  }

  String get label => switch (this) {
        UserRole.user => 'User',
        UserRole.admin => 'Admin',
        UserRole.superAdmin => 'Super Admin',
      };
}

/// The logged-in account (`data.admin` in the login response).
/// Tokens are NOT part of this: they stay in secure storage.
class AdminUser {
  final String id;
  final String userName;
  final String phoneNumber;
  final String email;
  final UserRole role;
  final bool isVerified;
  final bool isActive;
  final double? defaultUpfrontFeePercentage;
  final double? defaultInterestPercentage;
  final double? defaultTotalMonths;
  final int? defaultTotalWeeks;
  final String? adminId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminUser({
    required this.id,
    required this.userName,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isActive,
    this.defaultUpfrontFeePercentage,
    this.defaultInterestPercentage,
    this.defaultTotalMonths,
    this.defaultTotalWeeks,
    this.adminId,
    this.createdAt,
    this.updatedAt,
  });

  /// The admin this account works under (itself when it has none).
  String get teamId => adminId ?? id;

  static double? _num(dynamic v) =>
      v == null ? null : num.tryParse('$v')?.toDouble();

  factory AdminUser.fromJson(Map<String, dynamic> j) {
    return AdminUser(
      id: '${j['id'] ?? ''}',
      userName: '${j['user_name'] ?? ''}',
      phoneNumber: '${j['phone_number'] ?? ''}',
      email: '${j['email'] ?? ''}',
      role: UserRole.parse(j['role']?.toString()),
      isVerified: j['is_verified'] == true,
      isActive: j['is_active'] != false,
      defaultUpfrontFeePercentage: _num(j['default_upfront_fee_percentage']),
      defaultInterestPercentage: _num(j['default_interest_percentage']),
      defaultTotalMonths: _num(j['default_total_months']),
      defaultTotalWeeks: _num(j['default_total_weeks'])?.round(),
      adminId: j['admin_id']?.toString(),
      createdAt: DateFormatter.parse(j['created_at']),
      updatedAt: DateFormatter.parse(j['updated_at']),
    );
  }

  /// Same keys as the API, so fromJson reads it back.
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_name': userName,
        'phone_number': phoneNumber,
        'email': email,
        'role': role.apiValue,
        'is_verified': isVerified,
        'is_active': isActive,
        'default_upfront_fee_percentage': defaultUpfrontFeePercentage,
        'default_interest_percentage': defaultInterestPercentage,
        'default_total_months': defaultTotalMonths,
        'default_total_weeks': defaultTotalWeeks,
        'admin_id': adminId,
        'created_at': createdAt?.toUtc().toIso8601String(),
        'updated_at': updatedAt?.toUtc().toIso8601String(),
      };
}