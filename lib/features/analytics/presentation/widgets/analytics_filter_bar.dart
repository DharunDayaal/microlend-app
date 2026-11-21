import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/features/manage/domain/entities/team.dart';
import 'package:micro_lending_app/features/manage/data/manage_providers.dart';
import 'package:micro_lending_app/features/analytics/presentation/analytics_filter.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/shared/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Pill({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: label,
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
  }
}

class AnalyticsFilterBar extends StatelessWidget {
  final AnalyticsFilters f;
  final bool showAdmin; // SUPER_ADMIN
  final bool showEmployee; // ADMIN, or SUPER_ADMIN once an admin is chosen

  const AnalyticsFilterBar({
    super.key,
    required this.f,
    required this.showAdmin,
    required this.showEmployee,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget viewing(String label, VoidCallback onClear) => InputChip(
      label: Text(context.l10n.anViewing(label)),
      labelStyle: text.labelMedium,
      onDeleted: onClear,
      deleteButtonTooltipMessage: context.l10n.commonClear,
    );

    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
        children: [
          Center(
            child: _Pill(
              icon: Icons.date_range_outlined,
              label: rangePresetLabel(context, f.preset) ?? f.rangeLabel,
              onTap: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: AppColors.darkSurface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                builder: (_) => _RangeSheet(f: f),
              ),
            ),
          ),
          if (showAdmin) ...[
            AppGap.w8,
            Center(
              child: _Pill(
                icon: Icons.admin_panel_settings_outlined,
                label: f.adminName ?? context.l10n.anAllAdmins,
                onTap: () => _pickPerson(context, admins: true),
              ),
            ),
          ],
          if (showEmployee) ...[
            AppGap.w8,
            Center(
              child: _Pill(
                icon: Icons.person_outline,
                label: f.employeeName ?? context.l10n.anAllEmployees,
                onTap: () => _pickPerson(context, admins: false),
              ),
            ),
          ],
          if (f.adminName != null) ...[
            AppGap.w8,
            Center(child: viewing(f.adminName!, () => f.setAdmin(null, null))),
          ],
          if (f.employeeName != null) ...[
            AppGap.w8,
            Center(
              child: viewing(f.employeeName!, () => f.setEmployee(null, null)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickPerson(BuildContext context, {required bool admins}) async {
    final picked = await showModalBottomSheet<(String?, String?)>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _PersonSheet(admins: admins, adminId: f.adminId),
    );
    if (picked == null) return; // closed without choosing
    if (admins) {
      f.setAdmin(picked.$1, picked.$2);
    } else {
      f.setEmployee(picked.$1, picked.$2);
    }
  }
}

// ---------- date range sheet ----------

class _RangeSheet extends StatefulWidget {
  final AnalyticsFilters f;
  const _RangeSheet({required this.f});

  @override
  State<_RangeSheet> createState() => _RangeSheetState();
}

class _RangeSheetState extends State<_RangeSheet> {
  static const _presets = ['7d', '30d', '90d', 'this', 'last', 'custom'];

  late String _preset = widget.f.preset;
  late DateTime _from = widget.f.from;
  late DateTime _to = widget.f.to;

  Future<void> _choose(String p) async {
    if (p != 'custom') {
      final r = AnalyticsFilters.rangeFor(p);
      setState(() {
        _preset = p;
        _from = r.$1;
        _to = r.$2;
      });
      return;
    }

    final now = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (r == null || !mounted) return;
    if (r.duration.inDays + 1 > AnalyticsFilters.maxDays) {
      AppSnackbar.warning(
        context,
        context.l10n.anMaxRange(AnalyticsFilters.maxDays),
      );
      return;
    }
    setState(() {
      _preset = 'custom';
      _from = r.start;
      _to = r.end;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.anDateRange, style: text.headlineSmall),
            AppGap.h16,
            Wrap(
              spacing: AppSizes.sm,
              runSpacing: AppSizes.sm,
              children: [
                for (final p in _presets)
                  ChoiceChip(
                    label: Text(
                      rangePresetLabel(context, p) ?? context.l10n.rangeCustom,
                    ),
                    selected: _preset == p,
                    onSelected: (_) => _choose(p),
                  ),
              ],
            ),
            AppGap.h16,
            AppButton(
              label: context.l10n.commonApply,
              radius: AppSizes.md,
              onPressed: () {
                widget.f.apply(_preset, _from, _to);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- admin / employee picker (searchable) ----------

class _PersonSheet extends ConsumerStatefulWidget {
  final bool admins;
  final String? adminId;
  const _PersonSheet({required this.admins, required this.adminId});

  @override
  ConsumerState<_PersonSheet> createState() => _PersonSheetState();
}

class _PersonSheetState extends ConsumerState<_PersonSheet> {
  List<(String id, String name)>? _all;
  String? _error;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final TeamSummary t = await ref
          .read(manageRepositoryProvider)
          .team(adminId: widget.adminId);
      if (!mounted) return;
      setState(() {
        _all = widget.admins
            ? [for (final a in t.teams) (a.adminId, a.userName)]
            : [for (final m in t.members) (m.id, m.userName)];
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final list = (_all ?? const [])
        .where((e) => e.$2.toLowerCase().contains(_q.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.admins
                    ? context.l10n.anChooseAdmin
                    : context.l10n.anChooseEmployee,
                style: text.headlineSmall,
              ),
              AppGap.h12,
              TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  hintText: context.l10n.commonSearch,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              AppGap.h8,
              if (_error != null)
                Row(
                  children: [
                    Expanded(child: Text(_error!)),
                    TextButton(
                      onPressed: _load,
                      child: Text(context.l10n.commonRetry),
                    ),
                  ],
                )
              else if (_all == null)
                const Padding(
                  padding: EdgeInsets.all(AppSizes.lg),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.groups_outlined),
                        title: Text(
                          widget.admins
                              ? context.l10n.anAllAdmins
                              : context.l10n.anAllEmployees,
                        ),
                        onTap: () => Navigator.of(context).pop((null, null)),
                      ),
                      for (final e in list)
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(e.$2),
                          onTap: () => Navigator.of(context).pop((e.$1, e.$2)),
                        ),
                      if (list.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppSizes.md),
                          child: Text(context.l10n.anNobodyMatches),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
