import 'package:micro_lending_app/features/audit/domain/entities/audit_log.dart';

/// JSON -> entity mapping for the audit APIs. Unchanged from the old
/// `fromJson` factories.

Map<String, dynamic>? _mapOrNull(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

abstract final class AuditActorDto {
  static AuditActor fromJson(Map<String, dynamic> j) => AuditActor(
    id: j['id']?.toString(),
    name: '${j['name'] ?? ''}',
    role: '${j['role'] ?? ''}'.toUpperCase(),
  );
}

abstract final class AuditTargetDto {
  static AuditTarget fromJson(Map<String, dynamic> j) => AuditTarget(
    id: j['id']?.toString(),
    name: '${j['name'] ?? j['user_name'] ?? ''}',
    role: '${j['role'] ?? ''}'.toUpperCase(),
  );
}

abstract final class AuditLogDto {
  static AuditLog fromJson(Map<String, dynamic> j) {
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
      actor: actor == null ? null : AuditActorDto.fromJson(actor),
      target: target == null ? null : AuditTargetDto.fromJson(target),
      changedFields: changed is List
          ? [for (final e in changed) '$e']
          : const [],
      raw: j,
    );
  }
}

abstract final class AuditActionOptionDto {
  static AuditActionOption fromJson(Map<String, dynamic> j) {
    final m = '${j['module'] ?? ''}'.toUpperCase();
    return AuditActionOption(
      action: '${j['action'] ?? ''}',
      module: m.isEmpty ? 'OTHER' : m,
      count: (num.tryParse('${j['count']}') ?? 0).round(),
      lastAt: DateTime.tryParse('${j['last_at']}')?.toUtc(),
    );
  }
}
