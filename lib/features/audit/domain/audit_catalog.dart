import 'package:flutter/material.dart';
import 'package:micro_lending_app/data/models/audit_model.dart';


class ModuleStyle {
  final String key;
  final String label;
  final IconData icon;
  final Color dark;
  final Color light;
  const ModuleStyle(this.key, this.label, this.icon, this.dark, this.light);

  Color color(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}

const _modules = <String, ModuleStyle>{
  'AUTH': ModuleStyle('AUTH', 'Auth', Icons.lock_outline, Color(0xFFFBBF24), Color(0xFFB45309)),
  'PROFILE': ModuleStyle('PROFILE', 'Profile', Icons.person_outline, Color(0xFF2DD4BF), Color(0xFF0F766E)),
  'ADMIN': ModuleStyle('ADMIN', 'Admin', Icons.admin_panel_settings_outlined, Color(0xFFC084FC), Color(0xFF7E22CE)),
  'EMPLOYEE': ModuleStyle('EMPLOYEE', 'Employee', Icons.badge_outlined, Color(0xFFA5B4FC), Color(0xFF4338CA)),
  'CUSTOMER': ModuleStyle('CUSTOMER', 'Customer', Icons.people_alt_outlined, Color(0xFF93C5FD), Color(0xFF1D4ED8)),
  'LOAN': ModuleStyle('LOAN', 'Loan', Icons.account_balance_outlined, Color(0xFF86EFAC), Color(0xFF15803D)),
  'PAYMENT': ModuleStyle('PAYMENT', 'Payment', Icons.payments_outlined, Color(0xFFF9A8D4), Color(0xFFBE185D)),
  'SETTINGS': ModuleStyle('SETTINGS', 'Settings', Icons.tune_rounded, Color(0xFFCBD5E1), Color(0xFF475569)),
  'SYSTEM': ModuleStyle('SYSTEM', 'System', Icons.settings_suggest_outlined, Color(0xFF67E8F9), Color(0xFF0E7490)),
  'OTHER': ModuleStyle('OTHER', 'Other', Icons.label_outline, Color(0xFFD1D5DB), Color(0xFF6B7280)),
};

const moduleOrder = [
  'AUTH', 'PROFILE', 'ADMIN', 'EMPLOYEE', 'CUSTOMER',
  'LOAN', 'PAYMENT', 'SETTINGS', 'SYSTEM', 'OTHER',
];

ModuleStyle moduleStyle(String? module) =>
    _modules[(module ?? '').toUpperCase()] ?? _modules['OTHER']!;

// ---------- actions ----------

enum _Attn { no, yes, onDeactivate }

const Map<String, (String, _Attn)> _catalog = {
  'ADMIN_REGISTERED': ('Admin registered', _Attn.no),
  'LOGIN_FAILED': ('Login failed', _Attn.yes),
  'LOGIN_BLOCKED': ('Login blocked', _Attn.yes),
  'PASSWORD_RESET': ('Password reset', _Attn.yes),
  'SESSIONS_REVOKED': ('Sessions signed out', _Attn.yes),
  'PROFILE_UPDATED': ('Profile updated', _Attn.no),
  'PHONE_CHANGED': ('Phone number changed', _Attn.yes),
  'PASSWORD_CHANGED': ('Password changed', _Attn.no),
  'LOAN_DEFAULTS_UPDATED': ('Loan defaults updated', _Attn.no),
  'ADMIN_VERIFICATION_CHANGED': ('Admin approval changed', _Attn.no),
  'ADMIN_ACTIVE_CHANGED': ('Admin activated or deactivated', _Attn.onDeactivate),
  'ADMIN_DEFAULTS_CHANGED': ('Admin defaults changed', _Attn.no),
  'EMPLOYEE_CREATED': ('Employee created', _Attn.no),
  'EMPLOYEE_VERIFICATION_CHANGED': ('Employee approval changed', _Attn.no),
  'EMPLOYEE_ACTIVE_CHANGED': ('Employee activated or deactivated', _Attn.onDeactivate),
  'EMPLOYEE_REASSIGNED': ('Employee moved to another admin', _Attn.yes),
  'EMPLOYEE_DEFAULTS_UPDATED': ('Employee defaults updated', _Attn.no),
  'EMPLOYEE_PROFILE_EDITED': ('Employee profile edited', _Attn.no),
  'CUSTOMER_CREATED': ('Customer created', _Attn.no),
  'CUSTOMER_UPDATED': ('Customer updated', _Attn.no),
  'CUSTOMER_DELETED': ('Customer deleted', _Attn.yes),
  'CUSTOMER_REASSIGNED': ('Customer reassigned', _Attn.yes),
  'REFERRER_CHANGED': ('Referrer changed', _Attn.no),
  'LOAN_CREATED': ('Loan created', _Attn.no),
  'LOAN_STATUS_CHANGED': ('Loan status changed', _Attn.no),
  'LOAN_TERMS_EDITED': ('Loan terms edited', _Attn.yes),
  'LOAN_CLOSED': ('Loan closed', _Attn.no),
  'LOAN_WRITTEN_OFF': ('Loan written off', _Attn.yes),
  'LOAN_DELETED': ('Loan deleted', _Attn.yes),
  'PAYMENT_RECORDED': ('Payment recorded', _Attn.no),
  'PAYMENT_EDITED': ('Payment edited', _Attn.yes),
  'PAYMENT_REVERSED': ('Payment reversed', _Attn.yes),
  'WEEK_STATUS_CHANGED': ('Week status changed', _Attn.no),
  'BACKDATED_PAYMENT': ('Backdated payment', _Attn.yes),
  'LOAN_LIMITS_UPDATED': ('Loan limits updated', _Attn.yes),
  'SETTINGS_CHANGED': ('Settings changed', _Attn.yes),
  'DATA_EXPORTED': ('Data exported', _Attn.yes),
  'BULK_IMPORT': ('Bulk import', _Attn.yes),
};

String titleCaseKey(String key) => key
    .split('_')
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
    .join(' ');

String actionLabel(String action) => _catalog[action]?.$1 ?? titleCaseKey(action);

/// Decided by the app from the action name. Unknown actions never flag.
bool needsAttention(AuditLog l) {
  final e = _catalog[l.action];
  if (e == null) return false;
  return switch (e.$2) {
    _Attn.yes => true,
    _Attn.no => false,
    _Attn.onDeactivate => l.newValue?['is_active'] == false,
  };
}

String roleLabel(String role) => switch (role) {
      'USER' => 'Employee',
      'ADMIN' => 'Admin',
      'SUPER_ADMIN' => 'Super Admin',
      'SYSTEM' => 'System',
      _ => '',
    };

String entityLabel(String? type) => switch ((type ?? '').toUpperCase()) {
      'USER' => 'User',
      'CUSTOMER' => 'Customer',
      'LOAN' => 'Loan',
      'PAYMENT' => 'Payment',
      'REPAYMENT_TRACK' => 'Week',
      'SETTING' => 'Setting',
      _ => '',
    };