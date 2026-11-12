Map<String, dynamic>? _mapOrNull(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

class AuditActor {
  final String? id;
  final String name;
  final String role; // USER, ADMIN, SUPER_ADMIN, SYSTEM
  const AuditActor({this.id, required this.name, required this.role});

  factory AuditActor.fromJson(Map<String, dynamic> j) => AuditActor(
    id: j['id']?.toString(),
    name: '${j['name'] ?? ''}',
    role: '${j['role'] ?? ''}'.toUpperCase(),
  );

  bool get isSystem => role == 'SYSTEM';
}

class AuditTarget {
  final String? id;
  final String name;
  final String role;
  const AuditTarget({this.id, required this.name, required this.role});

  factory AuditTarget.fromJson(Map<String, dynamic> j) => AuditTarget(
    id: j['id']?.toString(),
    name: '${j['name'] ?? j['user_name'] ?? ''}',
    role: '${j['role'] ?? ''}'.toUpperCase(),
  );
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

  factory AuditLog.fromJson(Map<String, dynamic> j) {
    final actor = _mapOrNull(j['actor']);
    final target = _mapOrNull(j['target']);
    final module = '${j['module'] ?? ''}'.toUpperCase();
    final changed = j['changed_fields'];

    return AuditLog(
      id: '${j['id'] ?? ''}',
      createdAt:
          DateTime.tryParse('${j['created_at']}')?.toUtc() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      action: '${j['action'] ?? ''}',
      module: module.isEmpty ? 'OTHER' : module,
      entityType: j['entity_type']?.toString(),
      entityId: j['entity_id']?.toString(),
      owningAdminId: j['owning_admin_id']?.toString(),
      oldValue: _mapOrNull(j['old_value']),
      newValue: _mapOrNull(j['new_value']),
      meta: _mapOrNull(j['meta']) ?? <String, dynamic>{},
      actor: actor == null ? null : AuditActor.fromJson(actor),
      target: target == null ? null : AuditTarget.fromJson(target),
      changedFields: changed is List
          ? [for (final e in changed) '$e']
          : const [],
      raw: j,
    );
  }
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

  factory AuditActionOption.fromJson(Map<String, dynamic> j) {
    final m = '${j['module'] ?? ''}'.toUpperCase();
    return AuditActionOption(
      action: '${j['action'] ?? ''}',
      module: m.isEmpty ? 'OTHER' : m,
      count: (num.tryParse('${j['count']}') ?? 0).round(),
      lastAt: DateTime.tryParse('${j['last_at']}')?.toUtc(),
    );
  }
}
