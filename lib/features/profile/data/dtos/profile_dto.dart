import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/core/utils/json_fields.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';
import 'package:micro_lending_app/features/profile/domain/entities/profile.dart';

/// JSON -> entity mapping for the profile APIs. Unchanged from the old
/// `fromJson` factories.

abstract final class UserProfileDto {
  static UserProfile fromJson(Map<String, dynamic> j) => UserProfile(
    id: jStr(j['id']),
    userName: jStr(j['user_name']),
    phoneNumber: jStr(j['phone_number']),
    email: jStr(j['email']),
    role: UserRole.parse(j['role']?.toString()),
    isVerified: j['is_verified'] == true,
    isActive: j['is_active'] != false,
    defaultFee: jDbl(j['default_upfront_fee_percentage']),
    defaultInterest: jDbl(j['default_interest_percentage']),
    defaultMonths: jDbl(j['default_total_months']),
    defaultWeeks: jInt(j['default_total_weeks']),
    defaultsInherited: j['defaults_inherited'] == true,
    defaultsSourceAdminId: j['defaults_source_admin_id']?.toString(),
    canEditDefaults: j['can_edit_defaults'] == true,
    adminId: j['admin_id']?.toString(),
    createdAt: DateFormatter.parse(j['created_at']),
    limits: ProfileLimits.fromJson(jMap(j['limits'])),
    raw: j,
  );
}

abstract final class ProfileStatsDto {
  static ProfileStats fromJson(Map<String, dynamic> j) => ProfileStats(
    range: jStr(j['range']),
    scope: jStr(j['scope']),
    from: jStr(j['from']),
    to: jStr(j['to']),
    collected: jDbl(j['collected']),
    target: jDbl(j['target']),
    customersPaid: jInt(j['customers_paid']),
    overdueCount: jInt(j['overdue_count']),
    onTimeRatio: jNum(j['on_time_ratio']),
  );
}

abstract final class SessionInfoDto {
  static SessionInfo fromJson(Map<String, dynamic> j) => SessionInfo(
    id: jStr(j['id']),
    createdAt: DateFormatter.parse(j['created_at']),
    expiresAt: DateFormatter.parse(j['expires_at']),
  );
}

abstract final class AdminAccountDto {
  static AdminAccount fromJson(Map<String, dynamic> j) => AdminAccount(
    id: jStr(j['id']),
    userName: jStr(j['user_name']),
    phoneNumber: jStr(j['phone_number']),
    email: jStr(j['email']),
    isVerified: j['is_verified'] == true,
    isActive: j['is_active'] != false,
    membersCount: jInt(j['members_count']),
  );
}
