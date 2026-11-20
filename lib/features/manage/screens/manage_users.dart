import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/data/models/export_model.dart';
import 'package:micro_lending_app/data/models/managed_account.dart';
import 'package:micro_lending_app/data/models/profile_model.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/data/services/management_service.dart';
import 'package:micro_lending_app/features/exports/widgets/export_sheet.dart';
import 'package:micro_lending_app/features/manage/controller/manage_controller.dart';
import 'package:micro_lending_app/features/manage/widgets/account_sheet.dart';
import 'package:micro_lending_app/features/manage/widgets/manage_widgets.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_widgets.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/helpers/dialog_helper.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  bool get _isSuper => CurrentUser.instance.isSuperAdmin;

  String? _adminFilter; // SUPER_ADMIN only
  String? _adminFilterName;

  late final ManageController _c = ManageController(
    loader: (status, search, page) => ManagementService.employees(
      status: status,
      search: search,
      page: page,
      adminId: _isSuper ? _adminFilter : null,
    ),
  );

  TeamSummary? _overview; // SUPER_ADMIN: every team
  TeamSummary? _scoped; // an ADMIN's team, or the chosen admin's
  bool _headerLoading = true;
  String? _headerError;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _c.load();
    _loadHeader();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _loadHeader() async {
    setState(() {
      _headerLoading = _overview == null && _scoped == null;
      _headerError = null;
    });
    try {
      final overview = _isSuper ? await ManagementService.team() : null;
      final scoped = _isSuper
          ? (_adminFilter == null
                ? null
                : await ManagementService.team(adminId: _adminFilter))
          : await ManagementService.team();
      if (!mounted) return;
      setState(() {
        _overview = overview;
        _scoped = scoped;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _headerError = e.message);
    } finally {
      if (mounted) setState(() => _headerLoading = false);
    }
  }

  Future<void> _refresh() =>
      Future.wait([_c.load(silent: true), _loadHeader()]);

  void _setAdmin(String? id, String? name) {
    setState(() {
      _adminFilter = id;
      _adminFilterName = name;
    });
    _c.load();
    _loadHeader();
  }

  int get _pending {
    final s = _scoped;
    if (s != null) {
      return s.members.where((m) => m.isActive && !m.isVerified).length;
    }
    return _overview?.teams.fold<int>(0, (a, t) => a + t.pendingCount) ?? 0;
  }

  Widget _header() {
    if (_headerLoading) return const StatStripSkeleton();
    final s = _scoped;
    final o = _overview;
    if (s == null && o == null) {
      return CardMessage(
        message: _headerError ?? context.l10n.manCountsFailed,
        onRetry: _loadHeader,
      );
    }

    if (s != null) {
      final m = s.members;
      final active = m.where((x) => x.isActive && x.isVerified).length;
      final inactive = m.where((x) => !x.isActive).length;
      return StatStrip(
        items: [
          (
            context.l10n.manPending,
            '${m.where((x) => x.isActive && !x.isVerified).length}',
            context.l10n.manAwaitingApproval,
            AppColors.warning,
          ),
          (
            context.l10n.manActive,
            '$active',
            context.l10n.manCanSignIn,
            AppColors.success,
          ),
          (
            context.l10n.manInactive,
            '$inactive',
            context.l10n.manDeactivatedLower,
            AppColors.progressDanger,
          ),
        ],
      );
    }

    final teams = o!.teams;
    return StatStrip(
      items: [
        (
          context.l10n.manPending,
          '$_pending',
          context.l10n.manAwaitingApproval,
          AppColors.warning,
        ),
        (
          context.l10n.manTeams,
          '${teams.length}',
          context.l10n.manApprovedAdmins,
          AppColors.success,
        ),
        (
          context.l10n.manEmployees,
          '${teams.fold<int>(0, (a, t) => a + t.membersCount)}',
          context.l10n.manAcrossTeams,
          AppColors.stepCurrentLabel,
        ),
      ],
    );
  }

  // ---------- actions ----------

  Future<bool> _run(
    ManagedAccount a,
    Future<ManagedAccount> Function() call,
    String Function(ManagedAccount updated) message,
  ) async {
    setState(() => _busyId = a.id);
    try {
      final updated = await call();
      if (!mounted) return false;
      _c.replace(updated);
      _loadHeader();
      AppSnackbar.success(context, message(updated));
      return true;
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
      return false;
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<bool> _approve(ManagedAccount a) => _run(
    a,
    () => ManagementService.setEmployeeVerified(a.id, true),
    (u) => context.l10n.manApprovedCanSignIn(a.displayName),
  );

  Future<bool> _reject(ManagedAccount a) async {
    final ok = await DialogHelper.confirm(
      context,
      title: context.l10n.manRejectTitle(a.displayName),
      message: context.l10n.manRejectMessage,
      confirmText: context.l10n.manReject,
    );
    if (!ok || !mounted) return false;
    return _run(
      a,
      () => ManagementService.setEmployeeActive(a.id, false),
      (u) => context.l10n.manRejected(a.displayName),
    );
  }

  Future<bool> _deactivate(ManagedAccount a) async {
    final ok = await DialogHelper.confirm(
      context,
      title: context.l10n.manDeactivateTitle(a.displayName),
      message: context.l10n.manDeactivateUserMsg,
      confirmText: context.l10n.manDeactivate,
    );
    if (!ok || !mounted) return false;
    return _run(
      a,
      () => ManagementService.setEmployeeActive(a.id, false),
      (u) => context.l10n.manDeactivated(a.displayName),
    );
  }

  Future<bool> _reactivate(ManagedAccount a) => _run(
    a,
    () => ManagementService.setEmployeeActive(a.id, true),
    (u) => u.status == AccountStatus.pending
        ? context.l10n.manReactivatedPending(a.displayName)
        : context.l10n.manReactivated(a.displayName),
  );

  Future<void> _create() async {
    final created = await context.push<bool>(AppRoutes.createEmployee);
    if (created == true && mounted) {
      _c.load(); // the new employee appears in its tab
      _loadHeader(); // and the counts update
    }
  }

  late final _actions = AccountActions(
    approve: _approve,
    reject: _reject,
    deactivate: _deactivate,
    reactivate: _reactivate,
  );

  // ---------- build ----------

  Widget _adminFilterPill() {
    final teams = _overview?.teams ?? const <AdminTeam>[];
    if (!_isSuper || teams.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.sm,
        AppSizes.lg,
        0,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: PopupMenuButton<String?>(
          tooltip: context.l10n.manFilterByAdmin,
          onSelected: (id) {
            final name = id == null
                ? null
                : teams.firstWhere((t) => t.adminId == id).userName;
            _setAdmin(id, name);
          },
          itemBuilder: (_) => [
            PopupMenuItem<String?>(
              value: null,
              child: Text(context.l10n.anAllAdmins),
            ),
            for (final t in teams)
              PopupMenuItem<String?>(value: t.adminId, child: Text(t.userName)),
          ],
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            decoration: ShapeDecoration(
              color: AppColors.darkSurface,
              shape: const StadiumBorder(
                side: BorderSide(color: AppColors.darkBorder),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 16,
                  color: AppColors.darkOnSurfaceMuted,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _adminFilterName ?? context.l10n.anAllAdmins,
                    style: text.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!CurrentUser.instance.hasRole(UserRole.admin)) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.menuManageUsers)),
        body: Center(
          child: Text(context.l10n.anNoAccess, textAlign: TextAlign.center),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(context.l10n.menuManageUsers),
        actions: [
          ExportMenuButton(
            types: const [
              ExportType.employeePerformance,
              ExportType.customerList,
            ],
            preset: () => ExportPreset(
              adminId: _adminFilter,
              adminName: _adminFilterName,
            ),
          ),
          IconButton(
            tooltip: context.l10n.empAddEmployee,
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: _create,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.lg,
                AppSizes.sm,
                AppSizes.lg,
                AppSizes.sm,
              ),
              child: ListenableBuilder(
                listenable: _c,
                builder: (_, _) => StatusTabs(
                  value: _c.status,
                  pendingBadge: _pending,
                  onChanged: _c.setStatus,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: ManageSearch(
                hint: context.l10n.manSearchHint,
                onChanged: _c.setSearch,
              ),
            ),
            _adminFilterPill(),
            Expanded(
              child: ManageListView(
                c: _c,
                header: _header(),
                onRefresh: _refresh,
                emptyMessage: (s) => switch (s) {
                  'pending' => context.l10n.manNoEmployeesPending,
                  'active' => context.l10n.manNoActiveEmployees,
                  _ => context.l10n.manNoInactiveEmployees,
                },
                itemBuilder: (context, a) => AccountCard(
                  a: a,
                  isAdminAccount: false,
                  showAdminName: _isSuper,
                  busy: _busyId == a.id,
                  onOpen: () => showAccountSheet(
                    context,
                    account: a,
                    isAdminAccount: false,
                    showAdminName: _isSuper,
                    actions: _actions,
                  ),
                  onApprove: () => _approve(a),
                  onReject: () => _reject(a),
                  onDeactivate: () => _deactivate(a),
                  onReactivate: () => _reactivate(a),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
