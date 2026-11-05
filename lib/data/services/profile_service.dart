import 'package:micro_lending_app/data/models/profile_model.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/network/api_client.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

class ProfileService {
  ProfileService._();
  static final ApiClient _api = ApiClient.instance;

  static Map<String, dynamic> _data(dynamic res) {
    final d = res is Map ? res['data'] : null;
    return d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{};
  }

  static UserProfile _profile(dynamic res) {
    final p = _data(res)['profile'];
    if (p is! Map) {
      throw const ApiException(
        message: 'Unexpected response from server',
        code: 'BAD_RESPONSE',
      );
    }
    return UserProfile.fromJson(Map<String, dynamic>.from(p));
  }

  // ----- profile -----
  static Future<UserProfile> getProfile() async =>
      _profile(await _api.get(ApiEndpoints.me));

  /// Called on app start: keeps the stored role and defaults current.
  static Future<void> refreshCurrentUser() async {
    try {
      final p = await getProfile();
      await CurrentUser.instance.setUser(p.toAdminUser());
    } catch (_) {
      // offline or signed out: the stored profile stays
    }
  }

  static Future<UserProfile> updateProfile({
    String? userName,
    String? email,
  }) async => _profile(
    await _api.patch(
      ApiEndpoints.me,
      data: {'user_name': ?userName, 'email': ?email},
    ),
  );

  static Future<UserProfile> changePhone(String phone) async => _profile(
    await _api.post(ApiEndpoints.mePhone, data: {'phone_number': phone}),
  );

  static Future<UserProfile> updateDefaults({
    double? fee,
    double? interest,
    double? months,
  }) async => _profile(
    await _api.patch(
      ApiEndpoints.meDefaults,
      data: {
        'default_upfront_fee_percentage': ?fee,
        'default_interest_percentage': ?interest,
        'default_total_months': ?months,
      },
    ),
  );

  // ----- security -----
  static Future<void> changePassword({
    required String current,
    required String next,
    String? refreshToken,
  }) async {
    await _api.post(
      ApiEndpoints.mePassword,
      data: {
        'current_password': current,
        'new_password': next,
        if (refreshToken != null && refreshToken.isNotEmpty)
          'refresh_token': refreshToken,
      },
    );
  }

  static Future<List<SessionInfo>> getSessions() async {
    final list = _data(await _api.get(ApiEndpoints.meSessions))['sessions'];
    return list is List
        ? [
            for (final e in list)
              if (e is Map) SessionInfo.fromJson(Map<String, dynamic>.from(e)),
          ]
        : <SessionInfo>[];
  }

  static Future<void> deleteSession(String id) async {
    await _api.delete(ApiEndpoints.meSession(id));
  }

  static Future<void> deleteAllSessions() async {
    await _api.delete(ApiEndpoints.meSessions);
  }

  // ----- numbers and team -----
  static Future<ProfileStats> getStats({
    required String range,
    required String scope,
    String? adminId,
  }) async {
    final s = _data(
      await _api.get(
        ApiEndpoints.meStats,
        query: {'range': range, 'scope': scope, 'admin_id': ?adminId},
      ),
    )['stats'];
    return ProfileStats.fromJson(s is Map ? Map<String, dynamic>.from(s) : {});
  }

  static Future<TeamSummary> getTeam({String? adminId}) async =>
      TeamSummary.fromJson(
        _data(
          await _api.get(ApiEndpoints.meTeam, query: {'admin_id': ?adminId}),
        ),
      );

  // ----- admins (SUPER_ADMIN) -----
  static Future<List<AdminAccount>> getAdmins({
    String status = 'pending',
    int page = 1,
    int limit = 5,
  }) async {
    final list = _data(
      await _api.get(
        ApiEndpoints.admins,
        query: {'status': status, 'page': page, 'limit': limit},
      ),
    )['admins'];
    return list is List
        ? [
            for (final e in list)
              if (e is Map) AdminAccount.fromJson(Map<String, dynamic>.from(e)),
          ]
        : <AdminAccount>[];
  }

  static Future<void> setAdminVerified(String id, bool value) async {
    await _api.patch(
      ApiEndpoints.adminVerification(id),
      data: {'is_verified': value},
    );
  }

  static Future<void> setAdminActive(String id, bool value) async {
    await _api.patch(ApiEndpoints.adminActive(id), data: {'is_active': value});
  }

  static Future<void> updateLimits(Map<String, double> changes) async {
    await _api.patch(ApiEndpoints.settingsLimits, data: changes);
  }
}
