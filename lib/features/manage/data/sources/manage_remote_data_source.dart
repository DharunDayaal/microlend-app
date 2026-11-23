import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_endpoints.dart';

/// Raw HTTP calls for admin and employee management.
class ManageRemoteDataSource {
  final ApiClient _api;
  const ManageRemoteDataSource(this._api);

  static Map<String, dynamic> _list(
    String status,
    String search,
    int page,
    int limit,
  ) => {
    'status': status,
    'page': page,
    'limit': limit,
    if (search.isNotEmpty) 'search': search,
  };

  Future<dynamic> admins(String status, String search, int page, int limit) =>
      _api.get(ApiEndpoints.admins, query: _list(status, search, page, limit));

  Future<dynamic> setAdminVerified(String id, bool value) => _api.patch(
    ApiEndpoints.adminVerification(id),
    data: {'is_verified': value},
  );

  Future<dynamic> setAdminActive(String id, bool value) =>
      _api.patch(ApiEndpoints.adminActive(id), data: {'is_active': value});

  Future<dynamic> employees(
    String status,
    String search,
    String? adminId,
    int page,
    int limit,
  ) => _api.get(
    ApiEndpoints.employees,
    query: {..._list(status, search, page, limit), 'admin_id': ?adminId},
  );

  Future<dynamic> employee(String id) => _api.get(ApiEndpoints.employee(id));

  Future<dynamic> setEmployeeVerified(String id, bool value) => _api.patch(
    ApiEndpoints.employeeVerification(id),
    data: {'is_verified': value},
  );

  Future<dynamic> setEmployeeActive(String id, bool value) =>
      _api.patch(ApiEndpoints.employeeActive(id), data: {'is_active': value});

  /// [auth] keeps the admin's own token on the request.
  Future<dynamic> createEmployee(Map<String, dynamic> body) =>
      _api.post(ApiEndpoints.createEmployee, data: body, auth: true);

  Future<dynamic> team(String? adminId, int page, int limit) => _api.get(
    ApiEndpoints.meTeam,
    query: {'admin_id': ?adminId, 'page': page, 'limit': limit},
  );
}
