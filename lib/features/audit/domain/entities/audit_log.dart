/// Audit log entities. Plain Dart: parsing lives in
/// `features/audit/data/dtos/audit_dto.dart`.
class AuditActor {
  final String? id;
  final String name;
  final String role; // USER, ADMIN, SUPER_ADMIN, SYSTEM
  const AuditActor({this.id, required this.name, required this.role});

  bool get isSystem => role == 'SYSTEM';
}

class AuditTarget {
  final String? id;
  final String name;
  final String role;
  const AuditTarget({this.id, required this.name, required this.role});
}

class AuditLog {
  final String id;
  final DateTime createdAt; // UTC
  final String action;
  final String module; // never empty: OTHER when unmapped
  final String? entityType;
  final String? entityId;
  final String? owningAdminId;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final Map<String, dynamic> meta;
  final AuditActor? actor;
  final AuditTarget? target;
  final List<String> changedFields;
  final Map<String, dynamic> raw;

  const AuditLog({
    required this.id,
    required this.createdAt,
    required this.action,
    required this.module,
    required this.entityType,
    required this.entityId,
    required this.owningAdminId,
    required this.oldValue,
    required this.newValue,
    required this.meta,
    required this.actor,
    required this.target,
    required this.changedFields,
    required this.raw,
  });
}

class AuditPage {
  final List<AuditLog> logs;
  final bool hasNext;
  final int total;
  const AuditPage(this.logs, this.hasNext, this.total);
}

class AuditActionOption {
  final String action;
  final String module;
  final int count;
  final DateTime? lastAt;
  const AuditActionOption({
    required this.action,
    required this.module,
    required this.count,
    required this.lastAt,
  });
}
