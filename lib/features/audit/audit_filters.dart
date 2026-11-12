import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/features/audit/domain/audit_catalog.dart';
import 'package:micro_lending_app/features/audit/domain/audit_time.dart';

/// What a History button opens the list with.
class AuditScope {
  final String? entityType;
  final String? entityId;
  final String? targetId;
  final String? actorId;
  final String? label;
  const AuditScope({
    this.entityType,
    this.entityId,
    this.targetId,
    this.actorId,
    this.label,
  });
}

class AuditFilters extends ChangeNotifier {
  static const maxDays = 366;

  AuditFilters({AuditScope? scope}) {
    final r = rangeFor('7d');
    from = r.$1;
    to = r.$2;
    if (scope != null) {
      entityType = scope.entityType;
      entityId = scope.entityId;
      targetId = scope.targetId;
      actorId = scope.actorId;
      scopeLabel = scope.label;
    }
  }

  String preset = '7d'; // today, 7d, 30d, custom
  late DateTime from; // IST days, as UTC midnight
  late DateTime to;

  String? module;
  Set<String> actions = {};
  String? actorId;
  String? actorName;
  String? targetId;
  String? targetName;
  String? entityType;
  String? entityId;
  String? scopeLabel; // the name shown on the scope chip
  String? adminId;
  String? adminName;

  static (DateTime, DateTime) rangeFor(String preset) {
    final t = istToday();
    return switch (preset) {
      'today' => (t, t),
      '30d' => (t.subtract(const Duration(days: 29)), t),
      _ => (t.subtract(const Duration(days: 6)), t),
    };
  }

  String get rangeLabel => switch (preset) {
    'today' => 'Today',
    '7d' => 'Last 7 days',
    '30d' => 'Last 30 days',
    _ => '${dayHeader(from)} - ${dayHeader(to)}',
  };

  bool get hasFilters =>
      module != null ||
      actions.isNotEmpty ||
      actorId != null ||
      targetId != null ||
      entityId != null ||
      adminId != null;

  /// For the badge on the Filters button.
  int get activeCount =>
      (module != null ? 1 : 0) +
      (actions.isNotEmpty ? 1 : 0) +
      (actorId != null ? 1 : 0) +
      (targetId != null ? 1 : 0) +
      (entityId != null ? 1 : 0) +
      (adminId != null ? 1 : 0);

  String get entityChipLabel =>
      scopeLabel ??
      '${entityLabel(entityType)} ${(entityId ?? '').substring(0, (entityId ?? '').length.clamp(0, 8))}'
          .trim();

  /// Empty values are left out, not sent blank.
  Map<String, dynamic> query(
    int page, {
    required bool isSuper,
    int limit = 20,
  }) => {
    if (actions.isNotEmpty) 'action': actions.join(','),
    if (module != null) 'module': module,
    if (actorId != null) 'actor_id': actorId,
    if (targetId != null) 'target_id': targetId,
    if (entityType != null) 'entity_type': entityType,
    if (entityId != null) 'entity_id': entityId,
    if (isSuper && adminId != null) 'admin_id': adminId,
    'from': ymd(from),
    'to': ymd(to),
    'page': page,
    'limit': limit,
  };

  // ---------- changes ----------

  void setRange(String preset, DateTime from, DateTime to) {
    this.preset = preset;
    this.from = from;
    this.to = to;
    notifyListeners();
  }

  void setModule(String? m) {
    if (m == module) return;
    module = m;
    notifyListeners();
  }

  void setActor(String? id, String? name) {
    actorId = id;
    actorName = name;
    notifyListeners();
  }

  void setTarget(String? id, String? name) {
    targetId = id;
    targetName = name;
    notifyListeners();
  }

  void setEntity(String? type, String? id, {String? label}) {
    entityType = type;
    entityId = id;
    scopeLabel = label;
    notifyListeners();
  }

  void setAdmin(String? id, String? name) {
    adminId = id;
    adminName = name;
    notifyListeners();
  }

  /// The sheet applies everything at once, so the list loads once.
  void applySheet({
    required String? module,
    required Set<String> actions,
    required String? actorId,
    required String? actorName,
    required String? targetId,
    required String? targetName,
    required String? adminId,
    required String? adminName,
  }) {
    this.module = module;
    this.actions = actions;
    this.actorId = actorId;
    this.actorName = actorName;
    this.targetId = targetId;
    this.targetName = targetName;
    this.adminId = adminId;
    this.adminName = adminName;
    notifyListeners();
  }

  void clearAll() {
    module = null;
    actions = {};
    actorId = actorName = null;
    targetId = targetName = null;
    entityType = entityId = scopeLabel = null;
    adminId = adminName = null;
    notifyListeners();
  }
}
