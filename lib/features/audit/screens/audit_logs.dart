import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/state_views.dart';
import 'package:micro_lending_app/data/models/audit_model.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/features/audit/controller/audit_controller.dart';
import 'package:micro_lending_app/features/audit/audit_filters.dart';
import 'package:micro_lending_app/features/audit/domain/audit_time.dart';
import 'package:micro_lending_app/features/audit/widgets/audit_filters_sheet.dart';
import 'package:micro_lending_app/features/audit/widgets/audit_widgets.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

class AuditListScreen extends StatefulWidget {
  final AuditScope? scope;
  const AuditListScreen({super.key, this.scope});

  @override
  State<AuditListScreen> createState() => _AuditListScreenState();
}

class _AuditListScreenState extends State<AuditListScreen> {
  late final AuditFilters _f = AuditFilters(scope: widget.scope);
  late final AuditController _c = AuditController(_f);
  final _scroll = ScrollController();

  bool get _isSuper => CurrentUser.instance.isSuperAdmin;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _f.addListener(_toTop); // a new filter starts at the top
    _c.load();
  }

  @override
  void dispose() {
    _f.removeListener(_toTop);
    _scroll.dispose();
    _c.dispose();
    _f.dispose();
    super.dispose();
  }

  void _toTop() {
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final p = _scroll.position;
    if (p.pixels >= p.maxScrollExtent - 460) {
      _c.loadMore(); // about 5 rows from the end
    }
  }

  List<Object> _flat(List<AuditLog> logs) {
    final out = <Object>[];
    DateTime? day;
    for (final l in logs) {
      final d = istDayOf(l.createdAt);
      if (day != d) {
        out.add(d);
        day = d;
      }
      out.add(l);
    }
    return out;
  }

  Future<void> _pickRange() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _RangeSheet(f: _f),
    );
  }

  Future<void> _pickAdmin() async {
    final r = await showPersonPicker(context, title: 'Team', admins: true);
    if (r != null) _f.setAdmin(r.$1, r.$2);
  }

  void _copy(AuditLog l) {
    Clipboard.setData(ClipboardData(text: l.id));
    AppSnackbar.info(context, 'Log id copied');
  }

  void _open(AuditLog l) => context.push(AppRoutes.auditDetail(l.id), extra: l);

  @override
  Widget build(BuildContext context) {
    if (!CurrentUser.instance.hasRole(UserRole.admin)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Audit log')),
        body: const Center(
          child: Text("You don't have access to the audit log."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(widget.scope != null ? 'History' : 'Audit log'),
        actions: [
          ListenableBuilder(
            listenable: _f,
            builder: (_, _) => Padding(
              padding: const EdgeInsets.only(right: AppSizes.sm),
              child: TextButton.icon(
                onPressed: () => showAuditFilters(context, _f),
                icon: Badge(
                  isLabelVisible: _f.activeCount > 0,
                  label: Text('${_f.activeCount}'),
                  child: const Icon(Icons.tune_rounded),
                ),
                label: const Text('Filters'),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([_f, _c]),
          builder: (context, _) => Column(
            children: [
              _bar(),
              ModuleChipRow(selected: _f.module, onSelected: _f.setModule),
              if (_c.notice != null) _notice(_c.notice!),
              Expanded(child: _body()),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- filter bar ----------

  Widget _bar() {
    final text = Theme.of(context).textTheme;

    Widget pill(IconData icon, String label, VoidCallback onTap) => Center(
      child: Material(
        color: AppColors.darkSurface,
        shape: const StadiumBorder(
          side: BorderSide(color: AppColors.darkBorder),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: AppColors.darkOnSurfaceMuted),
                  const SizedBox(width: 6),
                  Text(label, style: text.labelLarge),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Widget scope(String label, VoidCallback onClear) => Center(
      child: InputChip(
        label: Text(label),
        labelStyle: text.labelMedium,
        onDeleted: onClear,
        deleteButtonTooltipMessage: 'Clear',
      ),
    );

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        children: [
          pill(Icons.date_range_outlined, _f.rangeLabel, _pickRange),
          if (_isSuper) ...[
            AppGap.w8,
            pill(
              Icons.admin_panel_settings_outlined,
              _f.adminName ?? 'All teams',
              _pickAdmin,
            ),
          ],
          if (_f.entityId != null) ...[
            AppGap.w8,
            scope(
              'Viewing: ${_f.entityChipLabel}',
              () => _f.setEntity(null, null),
            ),
          ],
          if (_f.targetId != null) ...[
            AppGap.w8,
            scope(
              'About: ${_f.targetName ?? widget.scope?.label ?? 'this user'}',
              () => _f.setTarget(null, null),
            ),
          ],
          if (_f.actorId != null) ...[
            AppGap.w8,
            scope(
              'By: ${_f.actorName ?? widget.scope?.label ?? 'this person'}',
              () => _f.setActor(null, null),
            ),
          ],
          if (_f.hasFilters) ...[
            AppGap.w8,
            Center(
              child: TextButton(
                onPressed: _f.clearAll,
                child: const Text('Clear all'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _notice(String message) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        0,
        AppSizes.lg,
        AppSizes.sm,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(28),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.warning.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: AppColors.warning),
          AppGap.w8,
          Expanded(
            child: Text(
              message,
              style: text.labelMedium?.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- the list ----------

  Widget _body() {
    final text = Theme.of(context).textTheme;
    final pad = EdgeInsets.fromLTRB(
      AppSizes.lg,
      AppSizes.sm,
      AppSizes.lg,
      AppSizes.bottomClearance,
    );
    const physics = AlwaysScrollableScrollPhysics();

    if (_c.forbidden) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.lg),
          child: Text(
            "You don't have access to the audit log.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_c.loading && !_c.silent) {
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: pad,
        itemCount: 6,
        separatorBuilder: (_, _) => AppGap.h12,
        itemBuilder: (_, _) => const AuditRowSkeleton(),
      );
    }

    if (_c.error != null && _c.items.isEmpty) {
      return ListView(
        physics: physics,
        padding: pad,
        children: [ErrorView(message: _c.error!, onRetry: _c.load)],
      );
    }

    if (_c.items.isEmpty) {
      final filtered = _f.hasFilters;
      return RefreshIndicator(
        onRefresh: () => _c.load(pull: true),
        child: ListView(
          physics: physics,
          padding: pad,
          children: [
            const SizedBox(height: AppSizes.xl),
            const Icon(
              Icons.history_rounded,
              size: 48,
              color: AppColors.darkOnSurfaceMuted,
            ),
            AppGap.h12,
            Text(
              filtered ? 'Nothing matches these filters' : 'No activity yet',
              textAlign: TextAlign.center,
              style: text.headlineSmall,
            ),
            AppGap.h8,
            Text(
              filtered
                  ? 'Try a wider date range or fewer filters.'
                  : 'Changes made in the app will appear here.',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: AppColors.darkOnSurfaceMuted,
              ),
            ),
            if (filtered) ...[
              AppGap.h16,
              Center(
                child: AppButton(
                  label: 'Clear filters',
                  outlined: true,
                  fitContent: true,
                  radius: AppSizes.md,
                  onPressed: _f.clearAll,
                ),
              ),
            ],
          ],
        ),
      );
    }

    final flat = _flat(_c.items);
    return RefreshIndicator(
      onRefresh: () => _c.load(pull: true),
      child: ListView.separated(
        controller: _scroll,
        physics: physics,
        padding: pad,
        itemCount: flat.length + 1, // the last item is the footer
        separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm),
        itemBuilder: (context, i) {
          if (i == flat.length) return _footer(text);
          final item = flat[i];
          if (item is DateTime) return DayHeader(item);

          final log = item as AuditLog;
          final target = log.target;
          return AuditRow(
            log: log,
            onTap: () => _open(log),
            onCopy: () => _copy(log),
            onActorTap: log.actor?.id == null
                ? null
                : () => _f.setActor(log.actor!.id, log.actor!.name),
            onSubjectTap: target?.id != null
                ? () => _f.setTarget(target!.id, target.name)
                : (log.entityId != null && log.entityType != null
                      ? () => _f.setEntity(log.entityType, log.entityId)
                      : null),
          );
        },
      ),
    );
  }

  Widget _footer(TextTheme text) {
    if (_c.loadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.md),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }
    if (_c.moreError != null) {
      return Column(
        children: [
          Text(_c.moreError!, textAlign: TextAlign.center),
          TextButton(
            onPressed: _c.retryMore,
            child: const Text('Tap to retry'),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
      child: Center(
        child: Text(
          _c.hasNext ? '' : '${_c.items.length} of ${_c.total} entries',
          style: text.bodySmall?.copyWith(color: AppColors.darkOnSurfaceMuted),
        ),
      ),
    );
  }
}

// ---------- date range sheet ----------

class _RangeSheet extends StatefulWidget {
  final AuditFilters f;
  const _RangeSheet({required this.f});

  @override
  State<_RangeSheet> createState() => _RangeSheetState();
}

class _RangeSheetState extends State<_RangeSheet> {
  static const _presets = [
    ('today', 'Today'),
    ('7d', 'Last 7 days'),
    ('30d', 'Last 30 days'),
    ('custom', 'Custom'),
  ];

  late String _preset = widget.f.preset;
  late DateTime _from = widget.f.from;
  late DateTime _to = widget.f.to;

  Future<void> _choose(String p) async {
    if (p != 'custom') {
      final r = AuditFilters.rangeFor(p);
      setState(() {
        _preset = p;
        _from = r.$1;
        _to = r.$2;
      });
      return;
    }

    final today = istToday();
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(today.year - 3),
      lastDate: DateTime(today.year, today.month, today.day),
      initialDateRange: DateTimeRange(
        start: DateTime(_from.year, _from.month, _from.day),
        end: DateTime(_to.year, _to.month, _to.day),
      ),
    );
    if (r == null || !mounted) return;
    if (r.duration.inDays + 1 > AuditFilters.maxDays) {
      AppSnackbar.warning(
        context,
        'Pick a range of at most ${AuditFilters.maxDays} days.',
      );
      return;
    }
    setState(() {
      _preset = 'custom';
      _from = DateTime.utc(r.start.year, r.start.month, r.start.day);
      _to = DateTime.utc(r.end.year, r.end.month, r.end.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date range',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            AppGap.h16,
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                for (final p in _presets)
                  ChoiceChip(
                    label: Text(p.$2),
                    selected: _preset == p.$1,
                    onSelected: (_) => _choose(p.$1),
                  ),
              ],
            ),
            AppGap.h16,
            AppButton(
              label: 'Apply',
              radius: AppSizes.md,
              onPressed: () {
                widget.f.setRange(_preset, _from, _to);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
