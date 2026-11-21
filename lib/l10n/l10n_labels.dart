import 'package:flutter/widgets.dart';
import 'package:micro_lending_app/features/exports/domain/entities/export.dart';
import 'package:micro_lending_app/features/loans/domain/entities/manual_loan_status.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';
import 'package:micro_lending_app/features/loans/presentation/models/loan_snapshot.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';

/// Translated display text for model enums. The models keep their English
/// `label` getters untouched; screens call these instead.

extension UserRoleL10n on UserRole {
  String l10nLabel(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      UserRole.user => l.roleUser,
      UserRole.admin => l.roleAdmin,
      UserRole.superAdmin => l.roleSuperAdmin,
    };
  }
}

extension ManualLoanStatusL10n on ManualLoanStatus {
  String l10nLabel(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      ManualLoanStatus.closed => l.manualStatusClosed,
      ManualLoanStatus.defaulted => l.manualStatusDefaulted,
      ManualLoanStatus.active => l.manualStatusReopen,
    };
  }

  String l10nDescription(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      ManualLoanStatus.closed => l.manualStatusClosedDesc,
      ManualLoanStatus.defaulted => l.manualStatusDefaultedDesc,
      ManualLoanStatus.active => l.manualStatusReopenDesc,
    };
  }
}

extension ExportTypeL10n on ExportType {
  String l10nLabel(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      ExportType.weekdaySheet => l.exportWeekdaySheet,
      ExportType.dueThisWeek => l.exportDueThisWeek,
      ExportType.customerList => l.exportCustomerList,
      ExportType.overdue => l.exportOverdue,
      ExportType.collections => l.exportCollections,
      ExportType.loansRegister => l.exportLoansRegister,
      ExportType.closedLoans => l.exportClosedLoans,
      ExportType.newCustomers => l.exportNewCustomers,
      ExportType.auditLog => l.exportAuditLog,
      ExportType.employeePerformance => l.exportEmployeePerformance,
      ExportType.teamSummary => l.exportTeamSummary,
    };
  }

  String l10nBlurb(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      ExportType.weekdaySheet => l.exportWeekdaySheetBlurb,
      ExportType.dueThisWeek => l.exportDueThisWeekBlurb,
      ExportType.customerList => l.exportCustomerListBlurb,
      ExportType.overdue => l.exportOverdueBlurb,
      ExportType.collections => l.exportCollectionsBlurb,
      ExportType.loansRegister => l.exportLoansRegisterBlurb,
      ExportType.closedLoans => l.exportClosedLoansBlurb,
      ExportType.newCustomers => l.exportNewCustomersBlurb,
      ExportType.auditLog => l.exportAuditLogBlurb,
      ExportType.employeePerformance => l.exportEmployeePerformanceBlurb,
      ExportType.teamSummary => l.exportTeamSummaryBlurb,
    };
  }
}

extension ExportJobL10n on ExportJob {
  /// Translated report name; falls back to the model's own title.
  String l10nTitle(BuildContext context) => kind?.l10nLabel(context) ?? title;
}

/// Weekday name for an API value such as `MONDAY`. Unknown values are
/// returned unchanged.
String weekdayLabel(BuildContext context, String apiDay, {bool short = false}) {
  final l = context.l10n;
  return switch (apiDay.trim().toUpperCase()) {
    'MONDAY' => short ? l.dayMonShort : l.dayMonday,
    'TUESDAY' => short ? l.dayTueShort : l.dayTuesday,
    'WEDNESDAY' => short ? l.dayWedShort : l.dayWednesday,
    'THURSDAY' => short ? l.dayThuShort : l.dayThursday,
    'FRIDAY' => short ? l.dayFriShort : l.dayFriday,
    'SATURDAY' => short ? l.daySatShort : l.daySaturday,
    'SUNDAY' => short ? l.daySunShort : l.daySunday,
    _ => apiDay,
  };
}

extension LoanStageL10n on LoanStage {
  /// Upper-case status label shown on chips and headers.
  String l10nLabel(BuildContext context) {
    final l = context.l10n;
    return switch (this) {
      LoanStage.active => l.loanStageActive,
      LoanStage.overdue => l.statusOverdue,
      LoanStage.paidOff => l.loanStagePaidOff,
      LoanStage.closed => l.statusClosed,
      LoanStage.defaulted => l.loanStageDefaulted,
      LoanStage.unknown => l.loanStageUnknown,
    };
  }
}

/// Name of a date-range preset ('today', '7d', '30d', '90d', 'this', 'last').
/// Returns null for a custom range so the caller can show the dates instead.
String? rangePresetLabel(BuildContext context, String preset) {
  final l = context.l10n;
  return switch (preset) {
    'today' => l.rangeToday,
    '7d' => l.rangeLast7,
    '30d' => l.rangeLast30,
    '90d' => l.rangeLast90,
    'this' => l.rangeThisMonth,
    'last' => l.rangeLastMonth,
    _ => null,
  };
}

/// "just now", "5 min ago", "3 h ago", "2 d ago".
String agoText(BuildContext context, DateTime t) {
  final l = context.l10n;
  final m = DateTime.now().difference(t).inMinutes;
  if (m < 1) return l.agoJustNow;
  if (m < 60) return l.agoMinutes(m);
  final h = m ~/ 60;
  return h < 24 ? l.agoHours(h) : l.agoDays(h ~/ 24);
}

/// Three-letter weekday ("Mon") for an API value such as `MONDAY`.
String weekdayAbbr(BuildContext context, String apiDay) {
  final l = context.l10n;
  return switch (apiDay.trim().toUpperCase()) {
    'MONDAY' => l.dayMonAbbr,
    'TUESDAY' => l.dayTueAbbr,
    'WEDNESDAY' => l.dayWedAbbr,
    'THURSDAY' => l.dayThuAbbr,
    'FRIDAY' => l.dayFriAbbr,
    'SATURDAY' => l.daySatAbbr,
    'SUNDAY' => l.daySunAbbr,
    _ => apiDay,
  };
}
