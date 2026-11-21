/// A team: an admin and the employees under them. Plain Dart: parsing lives
/// in `features/manage/data/dtos/team_dto.dart`.
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
}

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
}
