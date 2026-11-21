import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';
import 'package:micro_lending_app/features/manage/domain/entities/managed_account.dart';

/// JSON -> entity mapping for the admin/employee APIs. Unchanged from the
/// old `fromJson` factory.

double? _n(dynamic v) => v == null ? null : num.tryParse('$v')?.toDouble();
int? _ni(dynamic v) => _n(v)?.round();
String _s(dynamic v) => v == null ? '' : '$v';

abstract final class ManagedAccountDto {
  static ManagedAccount fromJson(Map<String, dynamic> j) {
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
          ManagedAccount.computeStatus(verified, active),
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
}
