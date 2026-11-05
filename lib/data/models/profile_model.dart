import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/data/models/profile_limits.dart';
export 'package:micro_lending_app/data/models/profile_limits.dart';

double? _num(dynamic v) => v == null ? null : num.tryParse('$v')?.toDouble();
double _dbl(dynamic v, [double fallback = 0]) => _num(v) ?? fallback;
int _int(dynamic v) => (_num(v) ?? 0).round();
String _str(dynamic v) => v == null ? '' : '$v';
Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
List<Map<String, dynamic>> _maps(dynamic v) => v is List
    ? [
        for (final e in v)
          if (e is Map) Map<String, dynamic>.from(e),
      ]
    : const [];

class UserProfile {
  final String id;
  final String userName;
  final String phoneNumber;
  final String email;
  final UserRole role;
  final bool isVerified;
  final bool isActive;
  final double defaultFee;
  final double defaultInterest;
  final double defaultMonths;
  final int defaultWeeks;
  final bool defaultsInherited;
  final String? defaultsSourceAdminId;
  final bool canEditDefaults;
  final String? adminId;
  final DateTime? createdAt;
  final ProfileLimits limits;
  final Map<String, dynamic> raw; // lets CurrentUser rebuild itself

  const UserProfile({
    required this.id,
    required this.userName,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.defaultFee,
    required this.defaultInterest,
    required this.defaultMonths,
    required this.defaultWeeks,
    required this.defaultsInherited,
    required this.defaultsSourceAdminId,
    required this.canEditDefaults,
    required this.adminId,
    required this.createdAt,
    required this.limits,
    required this.raw,
  });

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
    id: _str(j['id']),
    userName: _str(j['user_name']),
    phoneNumber: _str(j['phone_number']),
    email: _str(j['email']),
    role: UserRole.parse(j['role']?.toString()),
    isVerified: j['is_verified'] == true,
    isActive: j['is_active'] != false,
    defaultFee: _dbl(j['default_upfront_fee_percentage']),
    defaultInterest: _dbl(j['default_interest_percentage']),
    defaultMonths: _dbl(j['default_total_months']),
    defaultWeeks: _int(j['default_total_weeks']),
    defaultsInherited: j['defaults_inherited'] == true,
    defaultsSourceAdminId: j['defaults_source_admin_id']?.toString(),
    canEditDefaults: j['can_edit_defaults'] == true,
    adminId: j['admin_id']?.toString(),
    createdAt: DateFormatter.parse(j['created_at']),
    limits: ProfileLimits.fromJson(_map(j['limits'])),
    raw: j,
  );

  AdminUser toAdminUser() => AdminUser.fromJson(raw);
}

class ProfileStats {
  final String range;
  final String scope;
  final String from;
  final String to;
  final double collected;
  final double target;
  final int customersPaid;
  final int overdueCount;
  final double? onTimeRatio; // null = no payments yet

  const ProfileStats({
    required this.range,
    required this.scope,
    required this.from,
    required this.to,
    required this.collected,
    required this.target,
    required this.customersPaid,
    required this.overdueCount,
    required this.onTimeRatio,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> j) => ProfileStats(
    range: _str(j['range']),
    scope: _str(j['scope']),
    from: _str(j['from']),
    to: _str(j['to']),
    collected: _dbl(j['collected']),
    target: _dbl(j['target']),
    customersPaid: _int(j['customers_paid']),
    overdueCount: _int(j['overdue_count']),
    onTimeRatio: _num(j['on_time_ratio']),
  );

  double get collectedFraction =>
      target <= 0 ? 0 : (collected / target).clamp(0.0, 1.0).toDouble();
}

class SessionInfo {
  final String id;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  const SessionInfo({required this.id, this.createdAt, this.expiresAt});

  factory SessionInfo.fromJson(Map<String, dynamic> j) => SessionInfo(
    id: _str(j['id']),
    createdAt: DateFormatter.parse(j['created_at']),
    expiresAt: DateFormatter.parse(j['expires_at']),
  );
}

class TeamMember {
  final String id;
  final String userName;
  final String phoneNumber;
  final bool isActive;
  final bool isVerified;
  final int customersCount;

  const TeamMember({
    required this.id,
    required this.userName,
    required this.phoneNumber,
    required this.isActive,
    required this.isVerified,
    required this.customersCount,
  });

  factory TeamMember.fromJson(Map<String, dynamic> j) => TeamMember(
    id: _str(j['id']),
    userName: _str(j['user_name']),
    phoneNumber: _str(j['phone_number']),
    isActive: j['is_active'] != false,
    isVerified: j['is_verified'] == true,
    customersCount: _int(j['customers_count']),
  );
}

class AdminTeam {
  final String adminId;
  final String userName;
  final bool isActive;
  final bool isVerified;
  final int membersCount;
  final int pendingCount;

  const AdminTeam({
    required this.adminId,
    required this.userName,
    required this.isActive,
    required this.isVerified,
    required this.membersCount,
    required this.pendingCount,
  });

  factory AdminTeam.fromJson(Map<String, dynamic> j) => AdminTeam(
    adminId: _str(j['admin_id']),
    userName: _str(j['user_name']),
    isActive: j['is_active'] != false,
    isVerified: j['is_verified'] == true,
    membersCount: _int(j['members_count']),
    pendingCount: _int(j['pending_count']),
  );
}

/// `isOverview` is true for a SUPER_ADMIN without admin_id (teams, not members).
class TeamSummary {
  final bool isOverview;
  final List<TeamMember> members;
  final int pendingCount;
  final List<AdminTeam> teams;
  final int pendingAdminApprovals;

  const TeamSummary({
    required this.isOverview,
    required this.members,
    required this.pendingCount,
    required this.teams,
    required this.pendingAdminApprovals,
  });

  factory TeamSummary.fromJson(Map<String, dynamic> j) => TeamSummary(
    isOverview: j.containsKey('teams'),
    members: _maps(j['members']).map(TeamMember.fromJson).toList(),
    pendingCount: _int(j['pending_count']),
    teams: _maps(j['teams']).map(AdminTeam.fromJson).toList(),
    pendingAdminApprovals: _int(j['pending_admin_approvals']),
  );
}

class AdminAccount {
  final String id;
  final String userName;
  final String phoneNumber;
  final String email;
  final bool isVerified;
  final bool isActive;
  final int membersCount;

  const AdminAccount({
    required this.id,
    required this.userName,
    required this.phoneNumber,
    required this.email,
    required this.isVerified,
    required this.isActive,
    required this.membersCount,
  });

  factory AdminAccount.fromJson(Map<String, dynamic> j) => AdminAccount(
    id: _str(j['id']),
    userName: _str(j['user_name']),
    phoneNumber: _str(j['phone_number']),
    email: _str(j['email']),
    isVerified: j['is_verified'] == true,
    isActive: j['is_active'] != false,
    membersCount: _int(j['members_count']),
  );
}
