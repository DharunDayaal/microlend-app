import 'dart:math' as math;

import 'package:micro_lending_app/features/audit/domain/entities/audit_log.dart';
import 'package:micro_lending_app/features/audit/presentation/formatting/audit_catalog.dart';
import 'package:micro_lending_app/features/audit/domain/audit_time.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';

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

String labelFor(AppLocalizations l, String key) => switch (key) {
  'status' => l.audFieldStatus,
  'user_name' => l.audFieldName,
  'phone_number' => l.audFieldPhone,
  'email' => l.audFieldEmail,
  'is_verified' => l.audFieldApproval,
  'is_active' => l.audFieldActive,
  'default_upfront_fee_percentage' => l.audFieldDefaultUpfrontFee,
  'default_interest_percentage' => l.audFieldDefaultInterest,
  'default_total_months' => l.audFieldDefaultTerm,
  'default_total_weeks' => l.audFieldDefaultTermWeeks,
  'nominal_amount' => l.audFieldPrincipal,
  'total_payable_amount' => l.audFieldTotalPayable,
  'weekly_payable_amount' => l.audFieldWeeklyInstallment,
  'upfront_fee' => l.audFieldUpfrontFee,
  'min_principal' => l.audFieldMinPrincipal,
  'max_principal' => l.audFieldMaxPrincipal,
  'min_months' => l.audFieldMinTerm,
  'max_months' => l.audFieldMaxTerm,
  'max_fee_percent' => l.audFieldMaxFee,
  'max_interest_percent' => l.audFieldMaxInterest,
  'amount_paid' => l.audFieldAmountPaid,
  'week_number' => l.audEntWeek,
  'customer_name' => l.audFieldCustomerName,
  'preferred_payment_day' => l.audFieldCollectionDay,
  'reason' => l.audFieldReason,
  'source' => l.audFieldSource,
  _ => titleCaseKey(key),
};

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

Fmt formatValue(AppLocalizations l, String key, dynamic v) {
  if (v == null || (v is String && v.trim().isEmpty)) {
    return Fmt(l.audValEmpty, isEmpty: true);
  }
  if (v is bool) {
    return Fmt(switch (key) {
      'is_verified' => v ? l.audValVerified : l.audValNotVerified,
      'is_active' => v ? l.audFieldActive : l.audValInactive,
      _ => v ? l.audValYes : l.audValNo,
    });
  }

  final n = _loose(v);
  if (n != null) {
    if (isPercentKey(key)) return Fmt('${_n(n)}%');
    if (isMoneyKey(key)) return Fmt(CurrencyFormatter.format(n.toDouble()));
    if (key.contains('months')) return Fmt(l.audValMonths(_n(n)));
    if (key.contains('weeks')) return Fmt(l.audValWeeks(_n(n)));
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

List<DiffRow> buildDiff(AppLocalizations l, AuditLog log) {
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
        label: labelFor(l, k),
        before: created ? null : formatValue(l, k, oldV[k]),
        after: formatValue(l, k, newV[k]),
        delta: created ? null : deltaFor(k, oldV[k], newV[k]),
      ),
  ];
}

// ---------- meta details (rows with no field changes) ----------

const _hiddenMeta = {'ip', 'user_agent', 'request_id', 'actor_type'};

List<(String, String)> metaDetails(AppLocalizations l, AuditLog log) {
  final entries = [
    for (final e in log.meta.entries)
      if (!_hiddenMeta.contains(e.key) &&
          e.value != null &&
          '${e.value}'.isNotEmpty)
        e,
  ];
  // the reason goes first
  entries.sort((a, b) => a.key == 'reason' ? -1 : (b.key == 'reason' ? 1 : 0));
  return [for (final e in entries) (labelFor(l, e.key), '${e.value}')];
}

/// One line for the list: up to two changes, then "+N more".
String? summaryLine(AppLocalizations l, AuditLog log) {
  final rows = buildDiff(l, log);
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
    return shown.join('   ') + (more > 0 ? '   ${l.audMoreCount(more)}' : '');
  }
  final meta = metaDetails(l, log);
  if (meta.isEmpty) return null;
  return '${meta.first.$1}: ${meta.first.$2}';
}

// ---------- who and what ----------

String actorText(AppLocalizations l, AuditLog log) {
  final a = log.actor;
  if (a == null) return l.commonUnknown;
  if (a.isSystem) return l.audModSystem;
  final name = a.name.isEmpty ? l.commonUnknown : a.name;
  final role = roleLabel(l, a.role);
  return role.isEmpty ? name : '$name ($role)';
}

String subjectText(AppLocalizations l, AuditLog log) {
  final t = log.target;
  if (t != null && t.name.isNotEmpty) return t.name;
  final type = entityLabel(l, log.entityType);
  final id = log.entityId;
  if (id == null || id.isEmpty) {
    final phone = log.meta['phone'] ?? log.meta['phone_number'];
    return phone == null ? type : '$phone';
  }
  return '$type ${id.substring(0, math.min(8, id.length))}'.trim();
}
