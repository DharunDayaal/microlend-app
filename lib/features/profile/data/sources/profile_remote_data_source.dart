import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_endpoints.dart';

/// Raw HTTP calls for the signed-in user's own account.
class ProfileRemoteDataSource {
  final ApiClient _api;
  const ProfileRemoteDataSource(this._api);

  Future<dynamic> getProfile() => _api.get(ApiEndpoints.me);

  Future<dynamic> updateProfile(String? userName, String? email) => _api.patch(
    ApiEndpoints.me,
    data: {'user_name': ?userName, 'email': ?email},
  );

  Future<dynamic> changePhone(String phone) =>
      _api.post(ApiEndpoints.mePhone, data: {'phone_number': phone});

  Future<dynamic> updateDefaults(
    double? fee,
    double? interest,
    double? months,
  ) => _api.patch(
    ApiEndpoints.meDefaults,
    data: {
      'default_upfront_fee_percentage': ?fee,
      'default_interest_percentage': ?interest,
      'default_total_months': ?months,
    },
  );

  Future<dynamic> changePassword(
    String current,
    String next,
    String? refreshToken,
  ) => _api.post(
    ApiEndpoints.mePassword,
    data: {
      'current_password': current,
      'new_password': next,
      if (refreshToken != null && refreshToken.isNotEmpty)
        'refresh_token': refreshToken,
    },
  );

  Future<dynamic> getSessions(int page, int limit) =>
      _api.get(ApiEndpoints.meSessions, query: {'page': page, 'limit': limit});
  Future<dynamic> deleteSession(String id) =>
      _api.delete(ApiEndpoints.meSession(id));
  Future<dynamic> deleteAllSessions() => _api.delete(ApiEndpoints.meSessions);

  Future<dynamic> getStats(String range, String scope, String? adminId) =>
      _api.get(
        ApiEndpoints.meStats,
        query: {'range': range, 'scope': scope, 'admin_id': ?adminId},
      );

  Future<dynamic> getAdmins(String status, int page, int limit) => _api.get(
    ApiEndpoints.admins,
    query: {'status': status, 'page': page, 'limit': limit},
  );

  Future<dynamic> updateLimits(Map<String, double> changes) =>
      _api.patch(ApiEndpoints.settingsLimits, data: changes);
}
