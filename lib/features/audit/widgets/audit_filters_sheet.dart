import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/data/models/audit_model.dart';
import 'package:micro_lending_app/data/services/audit_service.dart';
import 'package:micro_lending_app/data/services/management_service.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_common.dart';
import 'package:micro_lending_app/features/audit/audit_filters.dart';
import 'package:micro_lending_app/features/audit/domain/audit_catalog.dart';
import 'package:micro_lending_app/features/audit/widgets/audit_widgets.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_widgets.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

Future<void> showAuditFilters(BuildContext context, AuditFilters f) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _FiltersSheet(f: f),
  );
}

/// Pick an admin or an employee. Returns (id, name); (null, null) means "anyone".
Future<(String?, String?)?> showPersonPicker(
  BuildContext context, {
  required String title,
  required bool admins,
  String? adminId,
}) {
  return showModalBottomSheet<(String?, String?)>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) =>
        _PersonSheet(title: title, admins: admins, adminId: adminId),
  );
}

class _FiltersSheet extends StatefulWidget {
  final AuditFilters f;
  const _FiltersSheet({required this.f});

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late String? _module = widget.f.module;
  late final Set<String> _actions = {...widget.f.actions};
  late String? _actorId = widget.f.actorId;
  late String? _actorName = widget.f.actorName;
  late String? _targetId = widget.f.targetId;
  late String? _targetName = widget.f.targetName;
  late String? _adminId = widget.f.adminId;
  late String? _adminName = widget.f.adminName;

  List<AuditActionOption>? _options;
  String? _optionsError;
  int _req = 0;

  bool get _isSuper => CurrentUser.instance.isSuperAdmin;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    final id = ++_req;
    setState(() {
      _optionsError = null;
      _options = null;
    });
    try {
      final o = await AuditService.actions(
        module: _module,
        adminId: _isSuper ? _adminId : null,
      );
      if (mounted && id == _req) setState(() => _options = o);
    } on ApiException catch (e) {
      if (mounted && id == _req) setState(() => _optionsError = e.message);
    }
  }

  Future<void> _pickActor() async {
    final r = await showPersonPicker(
      context,
      title: 'Who did it',
      admins: false,
      adminId: _isSuper ? _adminId : null,
    );
    if (r != null) {
      final (id, name) = r;
      setState(() {
        _actorId = id;
        _actorName = name;
      });
    }
  }

  Future<void> _pickTarget() async {
    final r = await showPersonPicker(
      context,
      title: 'Who it affected',
      admins: false,
      adminId: _isSuper ? _adminId : null,
    );
    if (r != null) {
      final (id, name) = r;
      setState(() {
        _targetId = id;
        _targetName = name;
      });
    }
  }

  Future<void> _pickAdmin() async {
    final r = await showPersonPicker(context, title: 'Team', admins: true);
    if (r == null) return;
    final (id, name) = r;
    setState(() {
      _adminId = id;
      _adminName = name;
    });
    _loadOptions();
  }

  void _reset() {
    setState(() {
      _module = null;
      _actions.clear();
      _actorId = null;
      _actorName = null;
      _targetId = null;
      _targetName = null;
      _adminId = null;
      _adminName = null;
    });
    _loadOptions();
  }

  void _apply() {
    widget.f.applySheet(
      module: _module,
      actions: _actions,
      actorId: _actorId,
      actorName: _actorName,
      targetId: _targetId,
      targetName: _targetName,
      adminId: _adminId,
      adminName: _adminName,
    );
    Navigator.of(context).pop();
  }

  Widget _personTile(
    IconData icon,
    String label,
    String? value,
    VoidCallback onTap,
    VoidCallback onClear,
  ) {
    return InfoRow(
      icon: icon,
      label: label,
      value: value ?? 'Anyone',
      trailing: value == null
          ? IconButton(
              onPressed: onTap,
              icon: const Icon(Icons.chevron_right_rounded),
            )
          : IconButton(
              tooltip: 'Clear',
              onPressed: onClear,
              icon: const Icon(Icons.close_rounded),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final options = _options;

    // group by module, in the same order as the chips
    final groups = <String, List<AuditActionOption>>{};
    for (final o in options ?? const <AuditActionOption>[]) {
      groups.putIfAbsent(o.module, () => []).add(o);
    }

    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.lg),
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Filters', style: text.headlineSmall)),
                    TextButton(onPressed: _reset, child: const Text('Reset')),
                  ],
                ),
                AppGap.h8,
                Text(
                  'MODULE',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                    letterSpacing: 0.6,
                  ),
                ),
                ModuleChipRow(
                  selected: _module,
                  padding: EdgeInsets.zero,
                  onSelected: (m) {
                    setState(() => _module = m);
                    _loadOptions();
                  },
                ),
                AppGap.h12,
                Text(
                  'ACTIONS',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                    letterSpacing: 0.6,
                  ),
                ),
                AppGap.h8,
                if (_optionsError != null)
                  CardMessage(message: _optionsError!, onRetry: _loadOptions)
                else if (options == null)
                  const Padding(
                    padding: EdgeInsets.all(AppSizes.md),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  )
                else if (options.isEmpty)
                  const EmptyNote(
                    'No actions have been recorded in your scope yet.',
                  )
                else
                  for (final key in [
                    ...moduleOrder.where(groups.containsKey),
                  ]) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppSizes.sm,
                        bottom: 6,
                      ),
                      child: Text(
                        moduleStyle(key).label,
                        style: text.labelLarge?.copyWith(
                          color: moduleStyle(key).color(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: AppSizes.sm,
                      runSpacing: AppSizes.sm,
                      children: [
                        for (final o in groups[key]!)
                          FilterChip(
                            label: Text(
                              '${actionLabel(o.action)} (${o.count})',
                            ),
                            selected: _actions.contains(o.action),
                            onSelected: (v) => setState(() {
                              if (v) {
                                _actions.add(o.action);
                              } else {
                                _actions.remove(o.action);
                              }
                            }),
                          ),
                      ],
                    ),
                  ],
                AppGap.h16,
                _personTile(
                  Icons.person_outline,
                  'Who did it',
                  _actorName ?? (_actorId == null ? null : 'Selected'),
                  _pickActor,
                  () => setState(() {
                    _actorId = null;
                    _actorName = null;
                  }),
                ),
                const Divider(height: 1, color: AppColors.darkBorder),
                _personTile(
                  Icons.person_pin_outlined,
                  'Who it affected',
                  _targetName ?? (_targetId == null ? null : 'Selected'),
                  _pickTarget,
                  () => setState(() {
                    _targetId = null;
                    _targetName = null;
                  }),
                ),
                if (_isSuper) ...[
                  const Divider(height: 1, color: AppColors.darkBorder),
                  _personTile(
                    Icons.admin_panel_settings_outlined,
                    'Team',
                    _adminName,
                    _pickAdmin,
                    () {
                      setState(() {
                        _adminId = null;
                        _adminName = null;
                      });
                      _loadOptions();
                    },
                  ),
                ],
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.darkBorder)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: AppButton(
                  label: 'Apply filters',
                  radius: AppSizes.md,
                  onPressed: _apply,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonSheet extends StatefulWidget {
  final String title;
  final bool admins;
  final String? adminId;
  const _PersonSheet({
    required this.title,
    required this.admins,
    required this.adminId,
  });

  @override
  State<_PersonSheet> createState() => _PersonSheetState();
}

class _PersonSheetState extends State<_PersonSheet> {
  List<(String, String)>? _all;
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
      final isSuper = CurrentUser.instance.isSuperAdmin;
      // a SUPER_ADMIN with no team chosen lists admins; otherwise the team's members
      final t = await ManagementService.team(
        adminId: isSuper ? widget.adminId : null,
      );
      final list =
          (widget.admins || (isSuper && widget.adminId == null && t.isOverview))
          ? [for (final a in t.teams) (a.adminId, a.userName)]
          : [for (final m in t.members) (m.id, m.userName)];

      final me = CurrentUser.instance.user;
      if (!widget.admins && me != null) {
        list.insert(0, (me.id, '${me.userName} (me)'));
      }
      if (mounted) setState(() => _all = list);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final list = (_all ?? const <(String, String)>[])
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
              Text(widget.title, style: text.headlineSmall),
              AppGap.h12,
              TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: const InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              AppGap.h8,
              if (_error != null)
                CardMessage(message: _error!, onRetry: _load)
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
                        title: const Text('Anyone'),
                        onTap: () => Navigator.of(context).pop((null, null)),
                      ),
                      for (final e in list)
                        ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(e.$2),
                          onTap: () => Navigator.of(context).pop((e.$1, e.$2)),
                        ),
                      if (list.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(AppSizes.md),
                          child: Text('Nobody matches.'),
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
