import 'package:micro_lending_app/shared/session/models/user_role.dart';

/// An admin or employee account as the manage screens see it. Plain Dart:
/// parsing lives in `features/manage/data/dtos/managed_account_dto.dart`.

enum AccountStatus { pending, active, inactive }

/// One account row: an admin or an employee. Fields a list or a PATCH response
/// does not carry are null, and [withFallback] fills them from the old row.
class ManagedAccount {
  final String id;
  final String userName;
  final String phone;
  final String email;
  final UserRole role;
  final bool isVerified;
  final bool isActive;
  final AccountStatus status;
  final String? adminId;
  final String? adminName;
  final DateTime? createdAt;
  final int? membersCount; // admins
  final int? customersCount; // employees
  final int? activeLoans; // employee detail only
  final int? overdueLoans; // employee detail only
  final bool? hasOwnDefaults; // employees
  final double? fee;
  final double? interest;
  final double? months;

  const ManagedAccount({
    required this.id,
    required this.userName,
    required this.phone,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.status,
    this.adminId,
    this.adminName,
    this.createdAt,
    this.membersCount,
    this.customersCount,
    this.activeLoans,
    this.overdueLoans,
    this.hasOwnDefaults,
    this.fee,
    this.interest,
    this.months,
  });

  static AccountStatus computeStatus(bool verified, bool active) => !active
      ? AccountStatus.inactive
      : (verified ? AccountStatus.active : AccountStatus.pending);

  /// A name that is never empty.
  String get displayName =>
      userName.isNotEmpty ? userName : (email.isNotEmpty ? email : phone);

  String get subtitle => email.isNotEmpty ? email : phone;

  ManagedAccount withFallback(ManagedAccount o) => ManagedAccount(
    id: id,
    userName: userName.isNotEmpty ? userName : o.userName,
    phone: phone.isNotEmpty ? phone : o.phone,
    email: email.isNotEmpty ? email : o.email,
    role: role,
    isVerified: isVerified,
    isActive: isActive,
    status: status,
    adminId: adminId ?? o.adminId,
    adminName: adminName ?? o.adminName,
    createdAt: createdAt ?? o.createdAt,
    membersCount: membersCount ?? o.membersCount,
    customersCount: customersCount ?? o.customersCount,
    activeLoans: activeLoans ?? o.activeLoans,
    overdueLoans: overdueLoans ?? o.overdueLoans,
    hasOwnDefaults: hasOwnDefaults ?? o.hasOwnDefaults,
    fee: fee ?? o.fee,
    interest: interest ?? o.interest,
    months: months ?? o.months,
  );
}
