import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_endpoints.dart';

/// Raw HTTP calls for the audit log.
class AuditRemoteDataSource {
  final ApiClient _api;
  const AuditRemoteDataSource(this._api);

  Future<dynamic> list(Map<String, dynamic> query) =>
      _api.get(ApiEndpoints.auditLogs, query: query);

  Future<dynamic> get(String id) => _api.get(ApiEndpoints.auditLog(id));

  Future<dynamic> actions(String? module, String? adminId) => _api.get(
    ApiEndpoints.auditActions,
    query: {'module': ?module, 'admin_id': ?adminId},
  );
}
