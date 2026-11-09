import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/data/models/managed_account.dart';
import 'package:micro_lending_app/data/models/profile_model.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/data/services/management_service.dart';
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
        message: _headerError ?? 'Could not load the counts.',
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
            'PENDING',
            '${m.where((x) => x.isActive && !x.isVerified).length}',
            'awaiting approval',
            AppColors.warning,
          ),
          ('ACTIVE', '$active', 'can sign in', AppColors.success),
          ('INACTIVE', '$inactive', 'deactivated', AppColors.progressDanger),
        ],
      );
    }

    final teams = o!.teams;
    return StatStrip(
      items: [
        ('PENDING', '$_pending', 'awaiting approval', AppColors.warning),
        ('TEAMS', '${teams.length}', 'approved admins', AppColors.success),
        (
          'EMPLOYEES',
          '${teams.fold<int>(0, (a, t) => a + t.membersCount)}',
          'across teams',
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
    (u) => '${a.displayName} approved. They can sign in now.',
  );

  Future<bool> _reject(ManagedAccount a) async {
    final ok = await DialogHelper.confirm(
      context,
      title: 'Reject ${a.displayName}?',
      message:
          'The account is deactivated and cannot sign in. It is never deleted.',
      confirmText: 'Reject',
    );
    if (!ok || !mounted) return false;
    return _run(
      a,
      () => ManagementService.setEmployeeActive(a.id, false),
      (u) => '${a.displayName} rejected.',
    );
  }

  Future<bool> _deactivate(ManagedAccount a) async {
    final ok = await DialogHelper.confirm(
      context,
      title: 'Deactivate ${a.displayName}?',
      message:
          'They are signed out once their access token expires. '
          'Their customers and loans stay as they are.',
      confirmText: 'Deactivate',
    );
    if (!ok || !mounted) return false;
    return _run(
      a,
      () => ManagementService.setEmployeeActive(a.id, false),
      (u) => '${a.displayName} deactivated.',
    );
  }

  Future<bool> _reactivate(ManagedAccount a) => _run(
    a,
    () => ManagementService.setEmployeeActive(a.id, true),
    (u) => u.status == AccountStatus.pending
        ? '${a.displayName} reactivated. They are waiting for approval again.'
        : '${a.displayName} reactivated.',
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
          tooltip: 'Filter by admin',
          onSelected: (id) {
            final name = id == null
                ? null
                : teams.firstWhere((t) => t.adminId == id).userName;
            _setAdmin(id, name);
          },
          itemBuilder: (_) => [
            const PopupMenuItem<String?>(
              value: null,
              child: Text('All admins'),
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
                Text(_adminFilterName ?? 'All admins', style: text.labelLarge),
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
        appBar: AppBar(title: const Text('Manage users')),
        body: const Center(child: Text("You don't have access to this view.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Manage users'),
        actions: [
          IconButton(
            tooltip: 'Add employee',
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
                hint: 'Search by name, phone or email',
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
                  'pending' => 'No employees are waiting for approval.',
                  'active' => 'No active employees yet.',
                  _ => 'No inactive employees.',
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
