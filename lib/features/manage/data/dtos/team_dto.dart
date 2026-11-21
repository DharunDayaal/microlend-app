import 'package:micro_lending_app/core/utils/json_fields.dart';
import 'package:micro_lending_app/features/manage/domain/entities/team.dart';

/// JSON -> entity mapping for the team endpoint (GET /api/me/team).

abstract final class TeamMemberDto {
  static TeamMember fromJson(Map<String, dynamic> j) => TeamMember(
    id: jStr(j['id']),
    userName: jStr(j['user_name']),
    phoneNumber: jStr(j['phone_number']),
    isActive: j['is_active'] != false,
    isVerified: j['is_verified'] == true,
    customersCount: jInt(j['customers_count']),
  );
}

abstract final class AdminTeamDto {
  static AdminTeam fromJson(Map<String, dynamic> j) => AdminTeam(
    adminId: jStr(j['admin_id']),
    userName: jStr(j['user_name']),
    isActive: j['is_active'] != false,
    isVerified: j['is_verified'] == true,
    membersCount: jInt(j['members_count']),
    pendingCount: jInt(j['pending_count']),
  );
}

abstract final class TeamSummaryDto {
  static TeamSummary fromJson(Map<String, dynamic> j) => TeamSummary(
    isOverview: j.containsKey('teams'),
    members: jMaps(j['members']).map(TeamMemberDto.fromJson).toList(),
    pendingCount: jInt(j['pending_count']),
    teams: jMaps(j['teams']).map(AdminTeamDto.fromJson).toList(),
    pendingAdminApprovals: jInt(j['pending_admin_approvals']),
  );
}
