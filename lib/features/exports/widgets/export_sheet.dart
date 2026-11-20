import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/data/models/export_model.dart';
import 'package:micro_lending_app/features/audit/domain/audit_time.dart';
import 'package:micro_lending_app/features/audit/widgets/audit_filters_sheet.dart';
import 'package:micro_lending_app/features/exports/exports_tracker.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_widgets.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

const _days = [
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];
DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _today() => _dayOnly(istToday());

/// Starting values for the sheet. Anything left out gets a sensible default.
class ExportPreset {
  final DateTime? from;
  final DateTime? to;
  final String? weekday;
  final String? paymentDay;
  final String? status;
  final DateTime? issuedFrom;
  final DateTime? issuedTo;
  final String? employeeId;
  final String? employeeName;
  final String? adminId;
  final String? adminName;

  /// audit_log only: module, action, actor_id, entity_type, entity_id.
  final Map<String, dynamic> audit;
  final String? auditNote;

  const ExportPreset({
    this.from,
    this.to,
    this.weekday,
    this.paymentDay,
    this.status,
    this.issuedFrom,
    this.issuedTo,
    this.employeeId,
    this.employeeName,
    this.adminId,
    this.adminName,
    this.audit = const {},
    this.auditNote,
  });
}

Future<void> showExportSheet(
  BuildContext context,
  ExportType type, {
  ExportPreset preset = const ExportPreset(),
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => ExportSheet(type: type, preset: preset),
  );
}

// =============== the menu button ===============

/// An app bar button: a menu of the reports this user may export.
class ExportMenuButton extends StatelessWidget {
  final List<ExportType> types;
  final ExportPreset Function()? preset;

  const ExportMenuButton({super.key, required this.types, this.preset});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ExportsTracker.instance,
        CurrentUser.instance,
      ]),
      builder: (context, _) {
        final allowed = [
          for (final t in types)
            if (CurrentUser.instance.hasRole(t.spec.minimum)) t,
        ];
        if (allowed.isEmpty) return const SizedBox.shrink();

        final active = ExportsTracker.instance.activeCount;
        return PopupMenuButton<Object>(
          tooltip: context.l10n.expExport,
          icon: Badge(
            isLabelVisible: active > 0,
            label: Text('$active'),
            child: const Icon(Icons.file_download_outlined),
          ),
          onSelected: (v) {
            if (v is ExportType) {
              showExportSheet(
                context,
                v,
                preset: preset?.call() ?? const ExportPreset(),
              );
            } else {
              context.push(AppRoutes.downloads);
            }
          },
          itemBuilder: (_) => [
            for (final t in allowed)
              PopupMenuItem<Object>(
                value: t,
                child: Row(
                  children: [
                    Icon(t.spec.icon, size: 20),
                    const SizedBox(width: AppSizes.md),
                    Expanded(child: Text(t.l10nLabel(context))),
                  ],
                ),
              ),
            const PopupMenuDivider(),
            PopupMenuItem<Object>(
              value: 'downloads',
              child: Row(
                children: [
                  const Icon(Icons.download_done_rounded, size: 20),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(
                      active > 0
                          ? context.l10n.expDownloadsBuilding(active)
                          : context.l10n.menuDownloads,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============== the sheet ===============

class ExportSheet extends StatefulWidget {
  final ExportType type;
  final ExportPreset preset;
  const ExportSheet({super.key, required this.type, required this.preset});

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  ExportSpec get spec => widget.type.spec;
  ExportsTracker get _t => ExportsTracker.instance;
  bool get _isSuper => CurrentUser.instance.isSuperAdmin;

  late ExportFormat _format = spec.defaultFormat;
  DateTime? _from;
  DateTime? _to;
  String _rangeKey = 'all';
  late String _weekday =
      widget.preset.weekday?.toUpperCase() ?? _days[_today().weekday - 1];
  String? _paymentDay;
  String? _status;
  DateTime? _issuedFrom;
  DateTime? _issuedTo;
  String? _employeeId;
  String? _employeeName;
  String? _adminId;
  String? _adminName;

  bool _creating = false;
  String? _error;
  String? _jobId;
  bool _already = false;

  @override
  void initState() {
    super.initState();
    final p = widget.preset;
    _paymentDay = p.paymentDay?.toUpperCase();
    _status = p.status;
    _issuedFrom = p.issuedFrom == null ? null : _dayOnly(p.issuedFrom!);
    _issuedTo = p.issuedTo == null ? null : _dayOnly(p.issuedTo!);
    _employeeId = p.employeeId;
    _employeeName = p.employeeName;
    _adminId = p.adminId;
    _adminName = p.adminName;
    _initRange();
  }

  // ---------- date range ----------

  List<(String, String, (DateTime, DateTime))> get _options {
    final t = _today();
    final monday = t.subtract(Duration(days: t.weekday - 1));
    final all = <(String, String, (DateTime, DateTime))>[
      ('today', context.l10n.rangeToday, (t, t)),
      (
        'week',
        context.l10n.expThisWeek,
        spec.futureOk
            ? (monday, monday.add(const Duration(days: 6)))
            : (monday, t),
      ),
      if (spec.futureOk)
        ('next7', context.l10n.expNext7, (t, t.add(const Duration(days: 6)))),
      ('7d', context.l10n.rangeLast7, (t.subtract(const Duration(days: 6)), t)),
      (
        '30d',
        context.l10n.rangeLast30,
        (t.subtract(const Duration(days: 29)), t),
      ),
      ('month', context.l10n.rangeThisMonth, (DateTime(t.year, t.month, 1), t)),
    ];
    return [
      for (final o in all)
        if (spec.maxDays == 0 ||
            o.$3.$2.difference(o.$3.$1).inDays + 1 <= spec.maxDays)
          o,
    ];
  }

  void _applyKey(String key) {
    _rangeKey = key;
    if (key == 'all') {
      _from = _to = null;
      return;
    }
    final o = _options.where((o) => o.$1 == key).firstOrNull;
    if (o != null) {
      _from = o.$3.$1;
      _to = o.$3.$2;
    }
  }

  void _initRange() {
    if (!spec.range) return;
    final p = widget.preset;

    if (p.from != null && p.to != null) {
      final f = _dayOnly(p.from!), t = _dayOnly(p.to!);
      final fits =
          spec.maxDays == 0 || t.difference(f).inDays + 1 <= spec.maxDays;
      if (fits) {
        _from = f;
        _to = t;
        _rangeKey = 'custom';
        for (final o in _options) {
          if (o.$3.$1 == f && o.$3.$2 == t) _rangeKey = o.$1;
        }
        return;
      }
    }
    if (!spec.rangeRequired) {
      _applyKey('all');
    } else {
      _applyKey(widget.type == ExportType.dueThisWeek ? 'week' : '30d');
    }
  }

  Future<void> _pickCustom() async {
    final t = _today();
    final last = spec.futureOk
        ? t.add(Duration(days: math.max(spec.maxDays, 366)))
        : t;
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(t.year - 3),
      lastDate: last,
      initialDateRange: _from != null && _to != null
          ? DateTimeRange(start: _from!, end: _to!)
          : null,
    );
    if (r == null || !mounted) return;
    if (spec.maxDays > 0 &&
        r.end.difference(r.start).inDays + 1 > spec.maxDays) {
      AppSnackbar.warning(context, context.l10n.expPickAtMost(spec.maxDays));
      return;
    }
    setState(() {
      _rangeKey = 'custom';
      _from = _dayOnly(r.start);
      _to = _dayOnly(r.end);
      _error = null;
    });
  }

  Future<void> _pickIssued() async {
    final t = _today();
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(t.year - 5),
      lastDate: t,
      initialDateRange: _issuedFrom != null && _issuedTo != null
          ? DateTimeRange(start: _issuedFrom!, end: _issuedTo!)
          : null,
    );
    if (r == null || !mounted) return;
    setState(() {
      _issuedFrom = _dayOnly(r.start);
      _issuedTo = _dayOnly(r.end);
      _error = null;
    });
  }

  // ---------- people ----------

  Future<void> _pickEmployee() async {
    final r = await showPersonPicker(
      context,
      title: context.l10n.expCustomersAddedBy,
      admins: false,
      adminId: _isSuper ? _adminId : null,
    );
    if (r != null) {
      final employeeId = r.$1;
      final employeeName = r.$2;
      setState(() {
        _employeeId = employeeId;
        _employeeName = employeeName;
      });
    }
  }

  Future<void> _pickAdmin() async {
    final r = await showPersonPicker(
      context,
      title: context.l10n.auditTeam,
      admins: true,
    );
    if (r == null) return;
    final adminId = r.$1;
    final adminName = r.$2;
    setState(() {
      _adminId = adminId;
      _adminName = adminName;
      _employeeId = _employeeName =
          null; // the old employee belongs to another team
    });
  }

  // ---------- request ----------

  String? _validate() {
    if (spec.weekday && _weekday.isEmpty) return context.l10n.expChooseWeekday;
    if (spec.range && spec.rangeRequired && (_from == null || _to == null)) {
      return context.l10n.expChooseRange;
    }
    if (spec.range && _from != null && _to != null) {
      if (_from!.isAfter(_to!)) {
        return context.l10n.expStartBeforeEnd;
      }
      if (spec.maxDays > 0 &&
          _to!.difference(_from!).inDays + 1 > spec.maxDays) {
        return context.l10n.expPickAtMost(spec.maxDays);
      }
    }
    return null;
  }

  Map<String, dynamic> _filters() => {
    if (spec.range && _from != null && _to != null) ...{
      'from': ymd(_from!),
      'to': ymd(_to!),
    },
    if (spec.weekday) 'weekday': _weekday,
    if (spec.paymentDay && _paymentDay != null) 'payment_day': _paymentDay,
    if (spec.statuses.isNotEmpty && _status != null) 'status': _status,
    if (spec.issuedRange && _issuedFrom != null)
      'issued_from': ymd(_issuedFrom!),
    if (spec.issuedRange && _issuedTo != null) 'issued_to': ymd(_issuedTo!),
    if (spec.employee && _employeeId != null) 'employee_id': _employeeId,
    if (spec.admin && _isSuper && _adminId != null) 'admin_id': _adminId,
    if (spec.auditFilters) ...widget.preset.audit,
  };

  Future<void> _create() async {
    if (_creating) return;
    final problem = _validate();
    if (problem != null) {
      setState(() => _error = problem);
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final c = await _t.start(
        type: widget.type,
        format: _format,
        filters: _filters(),
      );
      if (!mounted) return;
      setState(() {
        _jobId = c.job.id;
        _already = c.alreadyRunning;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.isNetworkError ? context.l10n.expNoServerAnswer : e.message; // 400 row limits, 403, 429 all carry a readable message
      });
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _use(ExportJob j, {required bool share}) async {
    try {
      await _t.use(j, share: share);
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, context.l10n.expCouldNotOpen);
    }
  }

  // ---------- build ----------

  String get _scopeNote {
    final u = CurrentUser.instance;
    if (u.isSuperAdmin) return context.l10n.expScopeSuper;
    if (u.isAdmin) return context.l10n.expScopeAdmin;
    return context.l10n.expScopeUser;
  }

  String get _formatHint => switch (_format) {
    ExportFormat.xlsx => context.l10n.expHintXlsx,
    ExportFormat.csv => context.l10n.expHintCsv,
    ExportFormat.pdf =>
      widget.type == ExportType.weekdaySheet
          ? context.l10n.expHintPdfWeekday
          : widget.type == ExportType.auditLog
          ? context.l10n.expHintPdfAudit
          : context.l10n.expHintPdf,
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: _jobId == null
            ? _config(context)
            : ListenableBuilder(
                listenable: _t,
                builder: (context, _) {
                  final j = _t.job(_jobId!);
                  return j == null
                      ? _gone(context)
                      : _Progress(
                          job: j,
                          already: _already,
                          downloading: _t.downloading.containsKey(j.id),
                          downloadProgress: _t.downloading[j.id],
                          onOpen: () => _use(j, share: false),
                          onShare: () => _use(j, share: true),
                          onAgain: () => setState(() {
                            _jobId = null;
                            _error = null;
                          }),
                          onDownloads: () {
                            Navigator.of(context).pop();
                            context.push(AppRoutes.downloads);
                          },
                        );
                },
              ),
      ),
    );
  }

  Widget _gone(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(context.l10n.expGone, textAlign: TextAlign.center),
      AppGap.h12,
      AppButton(
        label: context.l10n.expStartAgain,
        outlined: true,
        fitContent: true,
        radius: AppSizes.md,
        onPressed: () => setState(() => _jobId = null),
      ),
    ],
  );

  Widget _label(String s, {String? trailing}) => Padding(
    padding: const EdgeInsets.only(top: AppSizes.md, bottom: AppSizes.sm),
    child: Row(
      children: [
        Expanded(
          child: Text(
            s.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: AppColors.darkOnSurfaceMuted),
          ),
      ],
    ),
  );

  Widget _config(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.labelMedium?.copyWith(
      color: AppColors.darkOnSurfaceMuted,
    );
    final p = widget.preset;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----- header -----
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.stepCurrentLabel.withAlpha(36),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(spec.icon, color: AppColors.stepCurrentLabel),
            ),
            AppGap.w12,
            Expanded(
              child: Text(
                widget.type.l10nLabel(context),
                style: text.headlineSmall,
              ),
            ),
            IconButton(
              tooltip: context.l10n.commonClose,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        AppGap.h8,
        Text(widget.type.l10nBlurb(context), style: muted),

        // ----- format -----
        _label(context.l10n.expFormat),
        SegmentedButton<ExportFormat>(
          showSelectedIcon: false,
          segments: [
            for (final f in ExportFormat.values)
              ButtonSegment(
                value: f,
                label: Text(f.label),
                icon: Icon(f.icon, size: 18),
              ),
          ],
          selected: {_format},
          onSelectionChanged: (v) => setState(() {
            _format = v.first;
            _error = null;
          }),
        ),
        const SizedBox(height: 6),
        Text(_formatHint, style: muted),

        // ----- weekday -----
        if (spec.weekday) ...[
          _label(context.l10n.expWeekday),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              for (final d in _days)
                ChoiceChip(
                  label: Text(weekdayAbbr(context, d)),
                  selected: _weekday == d,
                  onSelected: (_) => setState(() {
                    _weekday = d;
                    _error = null;
                  }),
                ),
            ],
          ),
        ],

        // ----- payment day -----
        if (spec.paymentDay) ...[
          _label(
            context.l10n.expPaymentDay,
            trailing: context.l10n.expOptional,
          ),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              ChoiceChip(
                label: Text(context.l10n.expAny),
                selected: _paymentDay == null,
                onSelected: (_) => setState(() => _paymentDay = null),
              ),
              for (final d in _days)
                ChoiceChip(
                  label: Text(weekdayAbbr(context, d)),
                  selected: _paymentDay == d,
                  onSelected: (_) => setState(() => _paymentDay = d),
                ),
            ],
          ),
        ],

        // ----- date range -----
        if (spec.range) ...[
          _label(
            context.l10n.anDateRange,
            trailing: !spec.rangeRequired
                ? context.l10n.expOptional
                : (spec.maxDays > 0
                      ? context.l10n.expUpToDays(spec.maxDays)
                      : null),
          ),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              if (!spec.rangeRequired)
                ChoiceChip(
                  label: Text(context.l10n.expAllTime),
                  selected: _rangeKey == 'all',
                  onSelected: (_) => setState(() => _applyKey('all')),
                ),
              for (final o in _options)
                ChoiceChip(
                  label: Text(o.$2),
                  selected: _rangeKey == o.$1,
                  onSelected: (_) => setState(() {
                    _applyKey(o.$1);
                    _error = null;
                  }),
                ),
              ChoiceChip(
                avatar: const Icon(Icons.date_range_outlined, size: 16),
                label: Text(
                  _rangeKey == 'custom' && _from != null && _to != null
                      ? '${DateFormatter.dayMonth(_from)} - ${DateFormatter.dayMonth(_to)}'
                      : context.l10n.rangeCustom,
                ),
                selected: _rangeKey == 'custom',
                onSelected: (_) => _pickCustom(),
              ),
            ],
          ),
        ],

        // ----- loans register: issue dates -----
        if (spec.issuedRange) ...[
          _label(
            context.l10n.expIssuedBetween,
            trailing: context.l10n.expOptional,
          ),
          Wrap(
            spacing: AppSizes.sm,
            children: [
              ChoiceChip(
                label: Text(context.l10n.expAnyDate),
                selected: _issuedFrom == null,
                onSelected: (_) =>
                    setState(() => _issuedFrom = _issuedTo = null),
              ),
              ChoiceChip(
                avatar: const Icon(Icons.date_range_outlined, size: 16),
                label: Text(
                  _issuedFrom != null && _issuedTo != null
                      ? '${DateFormatter.dayMonth(_issuedFrom)} - ${DateFormatter.dayMonth(_issuedTo)}'
                      : context.l10n.expPickDates,
                ),
                selected: _issuedFrom != null,
                onSelected: (_) => _pickIssued(),
              ),
            ],
          ),
        ],

        // ----- status -----
        if (spec.statuses.isNotEmpty) ...[
          _label(context.l10n.commonStatus, trailing: context.l10n.expOptional),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              ChoiceChip(
                label: Text(context.l10n.loansFilterAll),
                selected: _status == null,
                onSelected: (_) => setState(() => _status = null),
              ),
              for (final s in spec.statuses)
                ChoiceChip(
                  label: Text(
                    switch (s) {
                          'ACTIVE' => context.l10n.loansFilterActive,
                          'OVERDUE' => context.l10n.loansFilterOverdue,
                          'PAID_OFF' => context.l10n.loansFilterPaidOff,
                          'DEFAULTED' => context.l10n.loansFilterDefaulted,
                          'CLOSED' => context.l10n.loansFilterClosed,
                          _ => null,
                        } ??
                        s
                            .replaceAll('_', ' ')
                            .toLowerCase()
                            .replaceFirstMapped(
                              RegExp(r'^.'),
                              (m) => m[0]!.toUpperCase(),
                            ),
                  ),
                  selected: _status == s,
                  onSelected: (_) => setState(() => _status = s),
                ),
            ],
          ),
        ],

        // ----- who -----
        if ((spec.admin && _isSuper) ||
            (spec.employee && CurrentUser.instance.isAdmin)) ...[
          _label(context.l10n.expScope),
          if (spec.admin && _isSuper)
            InfoRow(
              icon: Icons.admin_panel_settings_outlined,
              label: context.l10n.auditTeam,
              value: _adminName ?? context.l10n.auditAllTeams,
              trailing: _adminId == null
                  ? IconButton(
                      onPressed: _pickAdmin,
                      icon: const Icon(Icons.chevron_right_rounded),
                    )
                  : IconButton(
                      tooltip: context.l10n.commonClear,
                      onPressed: () =>
                          setState(() => _adminId = _adminName = null),
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          if (spec.employee && CurrentUser.instance.isAdmin)
            InfoRow(
              icon: Icons.person_outline,
              label: context.l10n.expCustomersAddedBy,
              value: _employeeName ?? context.l10n.anAllEmployees,
              trailing: _employeeId == null
                  ? IconButton(
                      onPressed: _pickEmployee,
                      icon: const Icon(Icons.chevron_right_rounded),
                    )
                  : IconButton(
                      tooltip: context.l10n.commonClear,
                      onPressed: () =>
                          setState(() => _employeeId = _employeeName = null),
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
        ],

        if (spec.auditFilters && p.auditNote != null) ...[
          AppGap.h8,
          Text(context.l10n.expAuditNote(p.auditNote!), style: muted),
        ],

        AppGap.h12,
        Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 14,
              color: AppColors.darkOnSurfaceMuted,
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(_scopeNote, style: muted)),
          ],
        ),

        if (_error != null) ...[
          AppGap.h12,
          Text(
            _error!,
            style: text.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          Wrap(
            spacing: AppSizes.sm,
            children: [
              // the server's row-limit messages say which format to use instead
              if (_error!.contains('CSV') && _format != ExportFormat.csv)
                TextButton(
                  onPressed: () => setState(() {
                    _format = ExportFormat.csv;
                    _error = null;
                  }),
                  child: Text(context.l10n.expSwitchCsv),
                ),
              if (_error!.contains('Excel') && _format == ExportFormat.pdf)
                TextButton(
                  onPressed: () => setState(() {
                    _format = ExportFormat.xlsx;
                    _error = null;
                  }),
                  child: Text(context.l10n.expSwitchExcel),
                ),
            ],
          ),
        ],
        AppGap.h16,
        AppButton(
          label: context.l10n.expCreateFormat(_format.label),
          prefixIcon: Icons.file_download_outlined,
          radius: AppSizes.md,
          isLoading: _creating,
          onPressed: _create,
        ),
      ],
    );
  }
}

// =============== the progress view ===============

class _Progress extends StatelessWidget {
  final ExportJob job;
  final bool already;
  final bool downloading;
  final double? downloadProgress;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onAgain;
  final VoidCallback onDownloads;

  const _Progress({
    required this.job,
    required this.already,
    required this.downloading,
    required this.downloadProgress,
    required this.onOpen,
    required this.onShare,
    required this.onAgain,
    required this.onDownloads,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.labelMedium?.copyWith(
      color: AppColors.darkOnSurfaceMuted,
    );
    final spec = job.kind?.spec;

    Widget body;
    if (job.isActive) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            job.status == ExportStatus.queued
                ? context.l10n.expWaiting
                : context.l10n.expBuildingFile,
            style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          AppGap.h8,
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: job.status == ExportStatus.queued ? null : job.progress,
              minHeight: 8,
              backgroundColor: AppColors.darkBorder,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            job.totalRows == null
                ? (already
                      ? context.l10n.expAlreadyInProgress
                      : context.l10n.expCountingRows)
                : '${context.l10n.expRowsProgress(job.processedRows, job.totalRows!)}'
                      '${job.progress == null ? '' : ' • ${(job.progress! * 100).round()}%'}'
                      '${already ? context.l10n.expAlreadyInProgressSuffix : ''}',
            style: muted,
          ),
        ],
      );
    } else if (job.isReady) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success),
              AppGap.w8,
              Expanded(
                child: Text(
                  '${context.l10n.expReadyLabel}${job.fileSize == null ? '' : ' • ${fmtBytes(job.fileSize)}'}',
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (job.fileName != null) ...[
            const SizedBox(height: 4),
            Text(
              job.fileName!,
              style: muted,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          AppGap.h12,
          if (downloading) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: downloadProgress,
                minHeight: 8,
                backgroundColor: AppColors.darkBorder,
              ),
            ),
            const SizedBox(height: 6),
            Text(context.l10n.expDownloading, style: muted),
          ] else
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: context.l10n.expOpen,
                    prefixIcon: Icons.open_in_new_rounded,
                    radius: AppSizes.md,
                    onPressed: onOpen,
                  ),
                ),
                AppGap.w12,
                Expanded(
                  child: AppButton(
                    label: context.l10n.expShare,
                    outlined: true,
                    prefixIcon: Icons.ios_share_rounded,
                    radius: AppSizes.md,
                    onPressed: onShare,
                  ),
                ),
              ],
            ),
        ],
      );
    } else if (job.status == ExportStatus.failed) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.progressDanger),
              AppGap.w8,
              Expanded(
                child: Text(
                  context.l10n.expBuildFailed,
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (job.error != null) ...[
            const SizedBox(height: 4),
            Text(job.error!, style: muted),
          ],
          AppGap.h12,
          AppButton(
            label: context.l10n.expTryAgain,
            outlined: true,
            radius: AppSizes.md,
            onPressed: onAgain,
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.expFileExpired,
            style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(context.l10n.expKeptExpired, style: muted),
          AppGap.h12,
          AppButton(
            label: context.l10n.expCreateAgain,
            outlined: true,
            radius: AppSizes.md,
            onPressed: onAgain,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.stepCurrentLabel.withAlpha(36),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                spec?.icon ?? job.format.icon,
                color: AppColors.stepCurrentLabel,
              ),
            ),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job.l10nTitle(context), style: text.headlineSmall),
                  Text(
                    '${job.format.label} • ${job.filterSummary}',
                    style: muted,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: context.l10n.commonClose,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        AppGap.h16,
        body,
        AppGap.h16,
        Row(
          children: [
            Expanded(
              child: Text(
                job.isActive
                    ? context.l10n.expCanClose
                    : context.l10n.expKept24,
                style: muted,
              ),
            ),
            TextButton(
              onPressed: onDownloads,
              child: Text(context.l10n.menuDownloads),
            ),
          ],
        ),
      ],
    );
  }
}
