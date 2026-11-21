import 'package:micro_lending_app/shared/session/models/user_role.dart';
import 'package:micro_lending_app/shared/session/models/profile_limits.dart';
export 'package:micro_lending_app/shared/session/models/profile_limits.dart';

/// The signed-in user's own profile and the profile screen's data. Plain
/// Dart: parsing lives in `features/profile/data/dtos/profile_dto.dart`.
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
  final Map<String, dynamic> raw; // turned into the session user (toAdminUser)

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

  double get collectedFraction =>
      target <= 0 ? 0 : (collected / target).clamp(0.0, 1.0).toDouble();
}

class SessionInfo {
  final String id;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  const SessionInfo({required this.id, this.createdAt, this.expiresAt});
}

/// `isOverview` is true for a SUPER_ADMIN without admin_id (teams, not members).

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
}
