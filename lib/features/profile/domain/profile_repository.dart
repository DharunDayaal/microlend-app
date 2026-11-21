import 'package:micro_lending_app/features/profile/domain/entities/profile.dart';

/// The signed-in user's own account: profile, defaults, security, numbers.
/// Team and admin-approval calls live in `ManageRepository`. Implementations
/// throw `ApiException` on failure.
abstract interface class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile({String? userName, String? email});
  Future<UserProfile> changePhone(String phone);
  Future<UserProfile> updateDefaults({
    double? fee,
    double? interest,
    double? months,
  });

  /// Sending [refreshToken] keeps this device signed in.
  Future<void> changePassword({
    required String current,
    required String next,
    String? refreshToken,
  });

  Future<List<SessionInfo>> getSessions();
  Future<void> deleteSession(String id);
  Future<void> deleteAllSessions();

  Future<ProfileStats> getStats({
    required String range,
    required String scope,
    String? adminId,
  });

  /// A short preview of admins waiting for approval (SUPER_ADMIN).
  Future<List<AdminAccount>> getAdmins({
    String status = 'pending',
    int page = 1,
    int limit = 5,
  });

  /// Platform loan limits (SUPER_ADMIN).
  Future<void> updateLimits(Map<String, double> changes);
}
