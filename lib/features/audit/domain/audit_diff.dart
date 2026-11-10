import 'dart:math' as math;

import 'package:micro_lending_app/data/models/audit_model.dart';
import 'package:micro_lending_app/features/audit/domain/audit_catalog.dart';
import 'package:micro_lending_app/features/audit/domain/audit_time.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';

class Fmt {
  final String text;
  final bool isLong; // collapsed with "View"
  final bool isEmpty;
  final dynamic raw;
  const Fmt(this.text, {this.isLong = false, this.isEmpty = false, this.raw});
}

class DiffRow {
  final String key;
  final String label;
  final Fmt? before; // null for a created row
  final Fmt after;
  final String? delta;
  const DiffRow({
    required this.key,
    required this.label,
    required this.before,
    required this.after,
    required this.delta,
  });
}

// ---------- labels ----------

const _labels = <String, String>{
  'status': 'Status',
  'user_name': 'Name',
  'phone_number': 'Phone',
  'email': 'Email',
  'is_verified': 'Approval',
  'is_active': 'Active',
  'default_upfront_fee_percentage': 'Default upfront fee',
  'default_interest_percentage': 'Default interest',
  'default_total_months': 'Default term',
  'default_total_weeks': 'Default term (weeks)',
  'nominal_amount': 'Principal',
  'total_payable_amount': 'Total payable',
  'weekly_payable_amount': 'Weekly installment',
  'upfront_fee': 'Upfront fee',
  'min_principal': 'Minimum principal',
  'max_principal': 'Maximum principal',
  'min_months': 'Minimum term',
  'max_months': 'Maximum term',
  'max_fee_percent': 'Maximum fee',
  'max_interest_percent': 'Maximum interest',
  'amount_paid': 'Amount paid',
  'week_number': 'Week',
  'customer_name': 'Customer name',
  'preferred_payment_day': 'Collection day',
  'reason': 'Reason',
  'source': 'Source',
};

String labelFor(String key) => _labels[key] ?? titleCaseKey(key);

// ---------- value formatting ----------

num? _loose(dynamic v) => v is num ? v : (v is String ? num.tryParse(v) : null);

bool isPercentKey(String k) =>
    k.contains('percent') || k == 'fee' || k == 'interest';

bool isMoneyKey(String k) =>
    !isPercentKey(k) &&
    RegExp(
      r'principal|amount|collected|outstanding|balance|disbursed|payable|nominal',
    ).hasMatch(k);

bool _isDateKey(String k) => k.endsWith('_at') || k.endsWith('_date');

String _n(num v) => v == v.truncate() ? v.truncate().toString() : v.toString();

Fmt formatValue(String key, dynamic v) {
  if (v == null || (v is String && v.trim().isEmpty)) {
    return const Fmt('empty', isEmpty: true);
  }
  if (v is bool) {
    return Fmt(switch (key) {
      'is_verified' => v ? 'Verified' : 'Not verified',
      'is_active' => v ? 'Active' : 'Inactive',
      _ => v ? 'Yes' : 'No',
    });
  }

  final n = _loose(v);
  if (n != null) {
    if (isPercentKey(key)) return Fmt('${_n(n)}%');
    if (isMoneyKey(key)) return Fmt(CurrencyFormatter.format(n.toDouble()));
    if (key.contains('months')) return Fmt('${_n(n)} months');
    if (key.contains('weeks')) return Fmt('${_n(n)} weeks');
  }
  if (_isDateKey(key) && v is String) {
    final d = DateTime.tryParse(v);
    if (d != null) return Fmt(istShort(d));
  }
  if (v is Map || v is List) {
    final s = '$v';
    return Fmt(
      s.length > 60 ? '${s.substring(0, 57)}...' : s,
      isLong: true,
      raw: v,
    );
  }
  final s = '$v';
  if (s.length > 80) {
    return Fmt('${s.substring(0, 77)}...', isLong: true, raw: s);
  }
  return Fmt(s, raw: v);
}

/// "+5%" or "-₹1,000" for numeric changes. Null when it is not a number.
String? deltaFor(String key, dynamic before, dynamic after) {
  final a = _loose(before);
  final b = _loose(after);
  if (a == null || b == null || a == b) return null;
  final numeric =
      (before is num && after is num) ||
      isPercentKey(key) ||
      isMoneyKey(key) ||
      key.contains('months') ||
      key.contains('weeks');
  if (!numeric) return null;

  final d = b - a;
  final abs = d.abs();
  final txt = isPercentKey(key)
      ? '${_n(abs)}%'
      : isMoneyKey(key)
      ? CurrencyFormatter.format(abs.toDouble())
      : _n(abs);
  return '${d > 0 ? '+' : '-'}$txt';
}

// ---------- the diff ----------

bool isCreated(AuditLog l) => l.oldValue == null && l.newValue != null;

List<DiffRow> buildDiff(AuditLog log) {
  final created = isCreated(log);
  final newV = log.newValue ?? const <String, dynamic>{};
  final oldV = log.oldValue ?? const <String, dynamic>{};

  final List<String> keys = created
      ? newV.keys.toList()
      : log.changedFields.isNotEmpty
      ? log.changedFields
      : {
          ...newV.keys,
          ...oldV.keys,
        }.where((k) => '${newV[k]}' != '${oldV[k]}').toList();

  return [
    for (final k in keys)
      DiffRow(
        key: k,
        label: labelFor(k),
        before: created ? null : formatValue(k, oldV[k]),
        after: formatValue(k, newV[k]),
        delta: created ? null : deltaFor(k, oldV[k], newV[k]),
      ),
  ];
}

// ---------- meta details (rows with no field changes) ----------

const _hiddenMeta = {'ip', 'user_agent', 'request_id', 'actor_type'};

List<(String, String)> metaDetails(AuditLog l) {
  final out = <(String, String)>[
    for (final e in l.meta.entries)
      if (!_hiddenMeta.contains(e.key) &&
          e.value != null &&
          '${e.value}'.isNotEmpty)
        (labelFor(e.key), '${e.value}'),
  ];
  out.sort((a, b) => a.$1 == 'Reason' ? -1 : (b.$1 == 'Reason' ? 1 : 0));
  return out;
}

/// One line for the list: up to two changes, then "+N more".
String? summaryLine(AuditLog log) {
  final rows = buildDiff(log);
  if (rows.isNotEmpty) {
    final created = isCreated(log);
    final shown = rows
        .take(2)
        .map(
          (r) => created
              ? '${r.label}: ${r.after.text}'
              : '${r.label}: ${r.before!.text} → ${r.after.text}',
        );
    final more = rows.length - 2;
    return shown.join('   ') + (more > 0 ? '   +$more more' : '');
  }
  final meta = metaDetails(log);
  if (meta.isEmpty) return null;
  return '${meta.first.$1}: ${meta.first.$2}';
}

// ---------- who and what ----------

String actorText(AuditLog l) {
  final a = l.actor;
  if (a == null) return 'Unknown';
  if (a.isSystem) return 'System';
  final name = a.name.isEmpty ? 'Unknown' : a.name;
  final role = roleLabel(a.role);
  return role.isEmpty ? name : '$name ($role)';
}

String subjectText(AuditLog l) {
  final t = l.target;
  if (t != null && t.name.isNotEmpty) return t.name;
  final type = entityLabel(l.entityType);
  final id = l.entityId;
  if (id == null || id.isEmpty) {
    final phone = l.meta['phone'] ?? l.meta['phone_number'];
    return phone == null ? type : '$phone';
  }
  return '$type ${id.substring(0, math.min(8, id.length))}'.trim();
}
