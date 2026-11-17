import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';

enum ExportStatus { queued, running, done, failed, expired }

enum ExportFormat {
  xlsx('Excel', 'xlsx', Icons.table_chart_outlined),
  csv('CSV', 'csv', Icons.description_outlined),
  pdf('PDF', 'pdf', Icons.picture_as_pdf_outlined);

  final String label;
  final String ext;
  final IconData icon;
  const ExportFormat(this.label, this.ext, this.icon);
}

/// What a report is, who may ask for it and which filters it takes.
class ExportSpec {
  final String api;
  final String label;
  final String blurb;
  final IconData icon;
  final UserRole minimum;
  final ExportFormat defaultFormat;

  final bool range; // from / to
  final bool rangeRequired;
  final int maxDays; // 0 = no limit
  final bool futureOk; // dates after today make sense (route sheet)

  final bool weekday; // required
  final bool paymentDay; // optional
  final List<String> statuses; // optional status filter
  final bool issuedRange; // optional issued_from / issued_to
  final bool employee; // employee_id
  final bool admin; // admin_id (SUPER_ADMIN only)
  final bool
  auditFilters; // module, action, actor, entity: passed in by the audit screen

  const ExportSpec({
    required this.api,
    required this.label,
    required this.blurb,
    required this.icon,
    required this.minimum,
    this.defaultFormat = ExportFormat.xlsx,
    this.range = false,
    this.rangeRequired = false,
    this.maxDays = 0,
    this.futureOk = false,
    this.weekday = false,
    this.paymentDay = false,
    this.statuses = const [],
    this.issuedRange = false,
    this.employee = false,
    this.admin = false,
    this.auditFilters = false,
  });
}

/// Declared in menu order: the collection sheet comes first.
enum ExportType {
  weekdaySheet(
    ExportSpec(
      api: 'weekday_sheet',
      label: 'Collection sheet',
      blurb:
          'One block per customer for a weekday: loan details and what was '
          'paid each week (W1 - 300, W2 - 400).',
      icon: Icons.fact_check_outlined,
      minimum: UserRole.user,
      defaultFormat: ExportFormat.pdf,
      weekday: true,
      employee: true,
      admin: true,
    ),
  ),
  dueThisWeek(
    ExportSpec(
      api: 'due_this_week',
      label: 'Route sheet',
      blurb: 'Weekly instalments falling due, by day, with amount due, paid and balance.',
      icon: Icons.route_outlined,
      minimum: UserRole.user,
      range: true,
      rangeRequired: true,
      maxDays: 366,
      futureOk: true,
      employee: true,
      admin: true,
    ),
  ),
  customerList(
    ExportSpec(
      api: 'customer_list',
      label: 'Customer list',
      blurb: 'Customers with phone, area, payment day, active loans and outstanding.',
      icon: Icons.people_alt_outlined,
      minimum: UserRole.user,
      paymentDay: true,
      employee: true,
      admin: true,
    ),
  ),
  overdue(
    ExportSpec(
      api: 'overdue',
      label: 'Overdue loans',
      blurb:
          'Overdue and defaulted loans with days late and the overdue amount.',
      icon: Icons.warning_amber_rounded,
      minimum: UserRole.user,
      employee: true,
      admin: true,
    ),
  ),
  collections(
    ExportSpec(
      api: 'collections',
      label: 'Collections',
      blurb: 'Every payment taken in a date range.',
      icon: Icons.payments_outlined,
      minimum: UserRole.admin,
      range: true,
      rangeRequired: true,
      maxDays: 366,
      employee: true,
      admin: true,
    ),
  ),
  loansRegister(
    ExportSpec(
      api: 'loans_register',
      label: 'Loans register',
      blurb:
          'Every loan with its money columns. Filter by status and issue date.',
      icon: Icons.account_balance_outlined,
      minimum: UserRole.admin,
      statuses: ['ACTIVE', 'OVERDUE', 'DEFAULTED', 'PAID_OFF', 'CLOSED'],
      issuedRange: true,
      employee: true,
      admin: true,
    ),
  ),
  closedLoans(
    ExportSpec(
      api: 'closed_loans',
      label: 'Closed loans',
      blurb: 'Loans closed, paid off or defaulted in a range, with collected and shortfall.',
      icon: Icons.lock_outline,
      minimum: UserRole.admin,
      range: true,
      rangeRequired: true,
      maxDays: 366,
      statuses: ['PAID_OFF', 'CLOSED', 'DEFAULTED'],
      employee: true,
      admin: true,
    ),
  ),
  newCustomers(
    ExportSpec(
      api: 'new_customers',
      label: 'New customers',
      blurb: 'Customers added in a range, with referrer and who added them.',
      icon: Icons.person_add_alt_1_outlined,
      minimum: UserRole.admin,
      range: true,
      rangeRequired: true,
      maxDays: 366,
      employee: true,
      admin: true,
    ),
  ),
  auditLog(
    ExportSpec(
      api: 'audit_log',
      label: 'Audit log',
      blurb: 'Who changed what, with old and new values.',
      icon: Icons.history_rounded,
      minimum: UserRole.admin,
      range: true,
      maxDays: 366,
      admin: true,
      auditFilters: true,
    ),
  ),
  employeePerformance(
    ExportSpec(
      api: 'employee_performance',
      label: 'Employee performance',
      blurb: 'Per employee: collected, target, rates, overdue, new customers and loans.',
      icon: Icons.leaderboard_outlined,
      minimum: UserRole.admin,
      range: true,
      rangeRequired: true,
      maxDays: 366,
      admin: true,
    ),
  ),
  teamSummary(
    ExportSpec(
      api: 'team_summary',
      label: 'Team summary',
      blurb: 'One row per admin.',
      icon: Icons.groups_outlined,
      minimum: UserRole.superAdmin,
      range: true,
      rangeRequired: true,
      maxDays: 366,
    ),
  );

  final ExportSpec spec;
  const ExportType(this.spec);

  static ExportType? parse(String api) =>
      ExportType.values.where((t) => t.spec.api == api).firstOrNull;
}

num? _n(dynamic v) => v == null ? null : num.tryParse('$v');
DateTime? _t(dynamic v) => DateTime.tryParse('${v ?? ''}')?.toUtc();

class ExportJob {
  final String id;
  final String type;
  final ExportFormat format;
  final ExportStatus status;
  final Map<String, dynamic> filters;
  final int? totalRows;
  final int processedRows;
  final double? progress; // 0..1, null when the total is unknown
  final String? fileName;
  final int? fileSize;
  final String? error;
  final DateTime? createdAt;
  final DateTime? finishedAt;
  final DateTime? expiresAt;
  final String? downloadUrl; // only on GET /exports/:id, valid for 5 minutes

  const ExportJob({
    required this.id,
    required this.type,
    required this.format,
    required this.status,
    required this.filters,
    required this.totalRows,
    required this.processedRows,
    required this.progress,
    required this.fileName,
    required this.fileSize,
    required this.error,
    required this.createdAt,
    required this.finishedAt,
    required this.expiresAt,
    required this.downloadUrl,
  });

  factory ExportJob.fromJson(Map<String, dynamic> j) {
    final f = j['filters'];
    final status = '${j['status'] ?? ''}'.toLowerCase();
    final format = '${j['format'] ?? ''}'.toLowerCase();

    return ExportJob(
      id: '${j['id'] ?? ''}',
      type: '${j['type'] ?? ''}',
      format:
          ExportFormat.values.where((e) => e.name == format).firstOrNull ??
          ExportFormat.xlsx,
      status:
          ExportStatus.values.where((e) => e.name == status).firstOrNull ??
          ExportStatus.queued,
      filters: f is Map ? Map<String, dynamic>.from(f) : <String, dynamic>{},
      totalRows: _n(j['total_rows'])?.round(),
      processedRows: _n(j['processed_rows'])?.round() ?? 0,
      progress: _n(j['progress'])?.toDouble().clamp(0.0, 1.0).toDouble(),
      fileName: j['file_name']?.toString(),
      fileSize: _n(j['file_size'])?.round(),
      error: j['error']?.toString(),
      createdAt: _t(j['created_at']),
      finishedAt: _t(j['finished_at']),
      expiresAt: _t(j['expires_at']),
      downloadUrl: j['download_url']?.toString(),
    );
  }

  ExportType? get kind => ExportType.parse(type);

  String get title =>
      kind?.spec.label ??
      type
          .split('_')
          .where((w) => w.isNotEmpty)
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');

  bool get isActive =>
      status == ExportStatus.queued || status == ExportStatus.running;

  /// DONE, but the 24 hours are over (the status can lag behind the clock).
  bool get isExpired =>
      status == ExportStatus.expired ||
      (status == ExportStatus.done &&
          expiresAt != null &&
          expiresAt!.isBefore(DateTime.now()));

  bool get isReady => status == ExportStatus.done && !isExpired;

  String get filterSummary {
    String d(dynamic v) {
      final t = DateTime.tryParse('${v ?? ''}');
      return t == null ? '$v' : DateFormat('d MMM').format(t);
    }

    String word(dynamic v) {
      final s = '$v'.toLowerCase();
      return s.isEmpty
          ? ''
          : s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');
    }

    final parts = <String>[
      if (filters['weekday'] != null) word(filters['weekday']),
      if (filters['payment_day'] != null)
        '${word(filters['payment_day'])} customers',
      if (filters['from'] != null && filters['to'] != null)
        '${d(filters['from'])} - ${d(filters['to'])}',
      if (filters['issued_from'] != null || filters['issued_to'] != null)
        'Issued ${filters['issued_from'] != null ? d(filters['issued_from']) : '...'} - '
            '${filters['issued_to'] != null ? d(filters['issued_to']) : '...'}',
      if (filters['status'] != null) word(filters['status']),
      if (filters['employee_id'] != null) 'One employee',
      if (filters['admin_id'] != null) 'One team',
    ];
    return parts.isEmpty ? 'All records' : parts.join(' • ');
  }
}

class ExportCreated {
  final ExportJob job;
  final bool alreadyRunning;
  const ExportCreated(this.job, this.alreadyRunning);
}

String fmtBytes(int? b) {
  if (b == null) return '';
  if (b < 1024) return '$b B';
  if (b < 1024 * 1024) return '${(b / 1024).round()} KB';
  return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
}
