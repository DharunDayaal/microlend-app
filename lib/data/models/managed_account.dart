import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';

enum AccountStatus { pending, active, inactive }

double? _n(dynamic v) => v == null ? null : num.tryParse('$v')?.toDouble();
int? _ni(dynamic v) => _n(v)?.round();
String _s(dynamic v) => v == null ? '' : '$v';

class PageOf<T> {
  final List<T> items;
  final bool hasNext;
  const PageOf(this.items, this.hasNext);
}

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

  factory ManagedAccount.fromJson(Map<String, dynamic> j) {
    final verified = j['is_verified'] == true;
    final active = j['is_active'] != false;
    final raw = _s(j['status']);

    return ManagedAccount(
      id: _s(j['id']),
      userName: _s(j['user_name']),
      phone: _s(j['phone_number']),
      email: _s(j['email']),
      role: UserRole.parse(j['role']?.toString()),
      isVerified: verified,
      isActive: active,
      status:
          AccountStatus.values.where((s) => s.name == raw).firstOrNull ??
          computeStatus(verified, active),
      adminId: j['admin_id']?.toString(),
      adminName: j['admin_name']?.toString(),
      createdAt: DateFormatter.parse(j['created_at']),
      membersCount: _ni(j['members_count']),
      customersCount: _ni(j['customers_count']),
      activeLoans: _ni(j['active_loans']),
      overdueLoans: _ni(j['overdue_loans']),
      hasOwnDefaults: j['has_own_defaults'] is bool
          ? j['has_own_defaults'] as bool
          : null,
      fee: _n(j['default_upfront_fee_percentage']),
      interest: _n(j['default_interest_percentage']),
      months: _n(j['default_total_months']),
    );
  }

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
