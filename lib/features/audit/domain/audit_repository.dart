import 'package:micro_lending_app/features/audit/domain/entities/audit_log.dart';

/// Reading the audit log. Implementations throw `ApiException` on failure;
/// `classifyAudit` turns one into what the screen should show.
abstract interface class AuditRepository {
  /// One page of logs. [query] comes from `AuditFilters.query`.
  Future<AuditPage> list(Map<String, dynamic> query);

  Future<AuditLog> get(String id);

  /// The actions recorded in the caller's scope, for the filter sheet.
  Future<List<AuditActionOption>> actions({String? module, String? adminId});
}
