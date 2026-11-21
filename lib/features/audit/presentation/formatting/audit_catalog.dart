import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:micro_lending_app/features/audit/domain/audit_time.dart';
import 'package:micro_lending_app/features/audit/domain/entities/audit_log.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';

class ModuleStyle {
  final String key;
  final IconData icon;
  final Color dark;
  final Color light;
  const ModuleStyle(this.key, this.icon, this.dark, this.light);

  String label(AppLocalizations l) => switch (key) {
    'AUTH' => l.audModAuth,
    'PROFILE' => l.audModProfile,
    'ADMIN' => l.audModAdmin,
    'EMPLOYEE' => l.audModEmployee,
    'CUSTOMER' => l.audModCustomer,
    'LOAN' => l.audModLoan,
    'PAYMENT' => l.audModPayment,
    'SETTINGS' => l.audModSettings,
    'SYSTEM' => l.audModSystem,
    _ => l.audModOther,
  };

  Color color(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}

const _modules = <String, ModuleStyle>{
  'AUTH': ModuleStyle(
    'AUTH',
    Icons.lock_outline,
    Color(0xFFFBBF24),
    Color(0xFFB45309),
  ),
  'PROFILE': ModuleStyle(
    'PROFILE',
    Icons.person_outline,
    Color(0xFF2DD4BF),
    Color(0xFF0F766E),
  ),
  'ADMIN': ModuleStyle(
    'ADMIN',
    Icons.admin_panel_settings_outlined,
    Color(0xFFC084FC),
    Color(0xFF7E22CE),
  ),
  'EMPLOYEE': ModuleStyle(
    'EMPLOYEE',
    Icons.badge_outlined,
    Color(0xFFA5B4FC),
    Color(0xFF4338CA),
  ),
  'CUSTOMER': ModuleStyle(
    'CUSTOMER',
    Icons.people_alt_outlined,
    Color(0xFF93C5FD),
    Color(0xFF1D4ED8),
  ),
  'LOAN': ModuleStyle(
    'LOAN',
    Icons.account_balance_outlined,
    Color(0xFF86EFAC),
    Color(0xFF15803D),
  ),
  'PAYMENT': ModuleStyle(
    'PAYMENT',
    Icons.payments_outlined,
    Color(0xFFF9A8D4),
    Color(0xFFBE185D),
  ),
  'SETTINGS': ModuleStyle(
    'SETTINGS',
    Icons.tune_rounded,
    Color(0xFFCBD5E1),
    Color(0xFF475569),
  ),
  'SYSTEM': ModuleStyle(
    'SYSTEM',
    Icons.settings_suggest_outlined,
    Color(0xFF67E8F9),
    Color(0xFF0E7490),
  ),
  'OTHER': ModuleStyle(
    'OTHER',
    Icons.label_outline,
    Color(0xFFD1D5DB),
    Color(0xFF6B7280),
  ),
};

const moduleOrder = [
  'AUTH',
  'PROFILE',
  'ADMIN',
  'EMPLOYEE',
  'CUSTOMER',
  'LOAN',
  'PAYMENT',
  'SETTINGS',
  'SYSTEM',
  'OTHER',
];

ModuleStyle moduleStyle(String? module) =>
    _modules[(module ?? '').toUpperCase()] ?? _modules['OTHER']!;

// ---------- actions ----------

enum _Attn { no, yes, onDeactivate }

const Map<String, _Attn> _attention = {
  'ADMIN_REGISTERED': _Attn.no,
  'LOGIN_FAILED': _Attn.yes,
  'LOGIN_BLOCKED': _Attn.yes,
  'PASSWORD_RESET': _Attn.yes,
  'SESSIONS_REVOKED': _Attn.yes,
  'PROFILE_UPDATED': _Attn.no,
  'PHONE_CHANGED': _Attn.yes,
  'PASSWORD_CHANGED': _Attn.no,
  'LOAN_DEFAULTS_UPDATED': _Attn.no,
  'ADMIN_VERIFICATION_CHANGED': _Attn.no,
  'ADMIN_ACTIVE_CHANGED': _Attn.onDeactivate,
  'ADMIN_DEFAULTS_CHANGED': _Attn.no,
  'EMPLOYEE_CREATED': _Attn.no,
  'EMPLOYEE_VERIFICATION_CHANGED': _Attn.no,
  'EMPLOYEE_ACTIVE_CHANGED': _Attn.onDeactivate,
  'EMPLOYEE_REASSIGNED': _Attn.yes,
  'EMPLOYEE_DEFAULTS_UPDATED': _Attn.no,
  'EMPLOYEE_PROFILE_EDITED': _Attn.no,
  'CUSTOMER_CREATED': _Attn.no,
  'CUSTOMER_UPDATED': _Attn.no,
  'CUSTOMER_DELETED': _Attn.yes,
  'CUSTOMER_REASSIGNED': _Attn.yes,
  'REFERRER_CHANGED': _Attn.no,
  'LOAN_CREATED': _Attn.no,
  'LOAN_STATUS_CHANGED': _Attn.no,
  'LOAN_TERMS_EDITED': _Attn.yes,
  'LOAN_CLOSED': _Attn.no,
  'LOAN_WRITTEN_OFF': _Attn.yes,
  'LOAN_DELETED': _Attn.yes,
  'PAYMENT_RECORDED': _Attn.no,
  'PAYMENT_EDITED': _Attn.yes,
  'PAYMENT_REVERSED': _Attn.yes,
  'WEEK_STATUS_CHANGED': _Attn.no,
  'BACKDATED_PAYMENT': _Attn.yes,
  'LOAN_LIMITS_UPDATED': _Attn.yes,
  'SETTINGS_CHANGED': _Attn.yes,
  'DATA_EXPORTED': _Attn.yes,
  'BULK_IMPORT': _Attn.yes,
};

String? _actionText(AppLocalizations l, String action) => switch (action) {
  'ADMIN_REGISTERED' => l.audActAdminRegistered,
  'LOGIN_FAILED' => l.audActLoginFailed,
  'LOGIN_BLOCKED' => l.audActLoginBlocked,
  'PASSWORD_RESET' => l.audActPasswordReset,
  'SESSIONS_REVOKED' => l.audActSessionsRevoked,
  'PROFILE_UPDATED' => l.audActProfileUpdated,
  'PHONE_CHANGED' => l.audActPhoneChanged,
  'PASSWORD_CHANGED' => l.audActPasswordChanged,
  'LOAN_DEFAULTS_UPDATED' => l.audActLoanDefaultsUpdated,
  'ADMIN_VERIFICATION_CHANGED' => l.audActAdminVerificationChanged,
  'ADMIN_ACTIVE_CHANGED' => l.audActAdminActiveChanged,
  'ADMIN_DEFAULTS_CHANGED' => l.audActAdminDefaultsChanged,
  'EMPLOYEE_CREATED' => l.audActEmployeeCreated,
  'EMPLOYEE_VERIFICATION_CHANGED' => l.audActEmployeeVerificationChanged,
  'EMPLOYEE_ACTIVE_CHANGED' => l.audActEmployeeActiveChanged,
  'EMPLOYEE_REASSIGNED' => l.audActEmployeeReassigned,
  'EMPLOYEE_DEFAULTS_UPDATED' => l.audActEmployeeDefaultsUpdated,
  'EMPLOYEE_PROFILE_EDITED' => l.audActEmployeeProfileEdited,
  'CUSTOMER_CREATED' => l.audActCustomerCreated,
  'CUSTOMER_UPDATED' => l.audActCustomerUpdated,
  'CUSTOMER_DELETED' => l.audActCustomerDeleted,
  'CUSTOMER_REASSIGNED' => l.audActCustomerReassigned,
  'REFERRER_CHANGED' => l.audActReferrerChanged,
  'LOAN_CREATED' => l.audActLoanCreated,
  'LOAN_STATUS_CHANGED' => l.audActLoanStatusChanged,
  'LOAN_TERMS_EDITED' => l.audActLoanTermsEdited,
  'LOAN_CLOSED' => l.audActLoanClosed,
  'LOAN_WRITTEN_OFF' => l.audActLoanWrittenOff,
  'LOAN_DELETED' => l.audActLoanDeleted,
  'PAYMENT_RECORDED' => l.audActPaymentRecorded,
  'PAYMENT_EDITED' => l.audActPaymentEdited,
  'PAYMENT_REVERSED' => l.audActPaymentReversed,
  'WEEK_STATUS_CHANGED' => l.audActWeekStatusChanged,
  'BACKDATED_PAYMENT' => l.audActBackdatedPayment,
  'LOAN_LIMITS_UPDATED' => l.audActLoanLimitsUpdated,
  'SETTINGS_CHANGED' => l.audActSettingsChanged,
  'DATA_EXPORTED' => l.audActDataExported,
  'BULK_IMPORT' => l.audActBulkImport,
  _ => null,
};

String titleCaseKey(String key) => key
    .split('_')
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
    .join(' ');

String actionLabel(AppLocalizations l, String action) =>
    _actionText(l, action) ?? titleCaseKey(action);

/// Decided by the app from the action name. Unknown actions never flag.
bool needsAttention(AuditLog l) {
  final e = _attention[l.action];
  if (e == null) return false;
  return switch (e) {
    _Attn.yes => true,
    _Attn.no => false,
    _Attn.onDeactivate => l.newValue?['is_active'] == false,
  };
}

String roleLabel(AppLocalizations l, String role) => switch (role) {
  'USER' => l.audModEmployee,
  'ADMIN' => l.roleAdmin,
  'SUPER_ADMIN' => l.roleSuperAdmin,
  'SYSTEM' => l.audModSystem,
  _ => '',
};

String entityLabel(AppLocalizations l, String? type) =>
    switch ((type ?? '').toUpperCase()) {
      'USER' => l.audEntUser,
      'CUSTOMER' => l.audModCustomer,
      'LOAN' => l.audModLoan,
      'PAYMENT' => l.audModPayment,
      'REPAYMENT_TRACK' => l.audEntWeek,
      'SETTING' => l.audEntSetting,
      _ => '',
    };

/// "Today", "Yesterday" or the date, for list headers and custom ranges.
String dayHeader(AppLocalizations l, DateTime day) {
  final diff = istToday().difference(day).inDays;
  if (diff == 0) return l.rangeToday;
  if (diff == 1) return l.audYesterday;
  final sameYear = day.year == istToday().year;
  return DateFormat(sameYear ? 'EEE d MMM' : 'EEE d MMM yyyy').format(day);
}
