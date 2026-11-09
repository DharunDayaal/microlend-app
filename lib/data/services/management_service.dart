import 'package:micro_lending_app/data/models/managed_account.dart';
import 'package:micro_lending_app/data/models/profile_model.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/network/api_client.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/network/body_unwrap.dart';

class ManagementService {
  ManagementService._();
  static final ApiClient _api = ApiClient.instance;

  static PageOf<ManagedAccount> _page(dynamic res, String key) {
    final b = unwrapBody(res);
    final list = b[key];
    final meta = b['metadata'];
    return PageOf(
      list is List
          ? [
              for (final e in list)
                if (e is Map)
                  ManagedAccount.fromJson(Map<String, dynamic>.from(e)),
            ]
          : <ManagedAccount>[],
      meta is Map && meta['has_next_page'] == true,
    );
  }

  static ManagedAccount _one(dynamic res, String key) {
    final v = unwrapBody(res)[key];
    if (v is! Map) {
      throw const ApiException(
        message: 'Unexpected response from server',
        code: 'BAD_RESPONSE',
      );
    }
    return ManagedAccount.fromJson(Map<String, dynamic>.from(v));
  }

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

  // ---------- admins (SUPER_ADMIN) ----------

  /// Creates an employee as the signed-in admin. [auth] keeps the admin's own token.
  static Future<ManagedAccount?> createEmployee(
    Map<String, dynamic> body,
  ) async {
    final data = unwrapBody(
      await _api.post(ApiEndpoints.createEmployee, data: body, auth: true),
    );
    final v = data['employee'] ?? data['user'];
    return v is Map
        ? ManagedAccount.fromJson(Map<String, dynamic>.from(v))
        : null;
  }

  static Future<PageOf<ManagedAccount>> admins({
    required String status,
    String search = '',
    int page = 1,
    int limit = 20,
  }) async => _page(
    await _api.get(
      ApiEndpoints.admins,
      query: _list(status, search, page, limit),
    ),
    'admins',
  );

  static Future<ManagedAccount> setAdminVerified(String id, bool value) async =>
      _one(
        await _api.patch(
          ApiEndpoints.adminVerification(id),
          data: {'is_verified': value},
        ),
        'admin',
      );

  static Future<ManagedAccount> setAdminActive(String id, bool value) async =>
      _one(
        await _api.patch(
          ApiEndpoints.adminActive(id),
          data: {'is_active': value},
        ),
        'admin',
      );

  static Future<PageOf<ManagedAccount>> employees({
    required String status,
    String search = '',
    String? adminId, // SUPER_ADMIN only; the server ignores it for an ADMIN
    int page = 1,
    int limit = 20,
  }) async => _page(
    await _api.get(
      ApiEndpoints.employees,
      query: {
        ..._list(status, search, page, limit),
        if (adminId != null) 'admin_id': adminId,
      },
    ),
    'employees',
  );

  static Future<ManagedAccount> employee(String id) async =>
      _one(await _api.get(ApiEndpoints.employee(id)), 'employee');

  static Future<ManagedAccount> setEmployeeVerified(
    String id,
    bool value,
  ) async => _one(
    await _api.patch(
      ApiEndpoints.employeeVerification(id),
      data: {'is_verified': value},
    ),
    'employee',
  );

  static Future<ManagedAccount> setEmployeeActive(
    String id,
    bool value,
  ) async => _one(
    await _api.patch(
      ApiEndpoints.employeeActive(id),
      data: {'is_active': value},
    ),
    'employee',
  );

  /// An ADMIN gets their members. A SUPER_ADMIN gets the overview, or one team with [adminId].
  static Future<TeamSummary> team({String? adminId}) async =>
      TeamSummary.fromJson(
        unwrapBody(
          await _api.get(ApiEndpoints.meTeam, query: {'admin_id': ?adminId}),
        ),
      );
}
