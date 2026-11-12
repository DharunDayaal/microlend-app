import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/data/models/managed_account.dart';
import 'package:micro_lending_app/data/models/profile_model.dart';
import 'package:micro_lending_app/data/services/management_service.dart';
import 'package:micro_lending_app/features/manage/controller/manage_controller.dart';
import 'package:micro_lending_app/features/manage/widgets/account_sheet.dart';
import 'package:micro_lending_app/features/manage/widgets/manage_widgets.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_widgets.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/helpers/dialog_helper.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

class ManageAdminsScreen extends StatefulWidget {
  const ManageAdminsScreen({super.key});

  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  late final ManageController _c = ManageController(
    loader: (status, search, page) =>
        ManagementService.admins(status: status, search: search, page: page),
  );

  TeamSummary? _team;
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
      _headerLoading = _team == null;
      _headerError = null;
    });
    try {
      final t = await ManagementService.team();
      if (mounted) setState(() => _team = t);
    } on ApiException catch (e) {
      if (mounted) setState(() => _headerError = e.message);
    } finally {
      if (mounted) setState(() => _headerLoading = false);
    }
  }

  Future<void> _refresh() =>
      Future.wait([_c.load(silent: true), _loadHeader()]);

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
      _loadHeader(); // the pending badge
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
    () => ManagementService.setAdminVerified(a.id, true),
    (u) => '${a.displayName} approved.',
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
      () => ManagementService.setAdminActive(a.id, false),
      (u) => '${a.displayName} rejected.',
    );
  }

  Future<bool> _deactivate(ManagedAccount a) async {
    final ok = await DialogHelper.confirm(
      context,
      title: 'Deactivate ${a.displayName}?',
      message:
          'They are signed out once their access token expires. '
          'Their employees are not changed.',
      confirmText: 'Deactivate',
    );
    if (!ok || !mounted) return false;
    return _run(
      a,
      () => ManagementService.setAdminActive(a.id, false),
      (u) => '${a.displayName} deactivated.',
    );
  }

  Future<bool> _reactivate(ManagedAccount a) => _run(
    a,
    () => ManagementService.setAdminActive(a.id, true),
    (u) => u.status == AccountStatus.pending
        ? '${a.displayName} reactivated. They are waiting for approval again.'
        : '${a.displayName} reactivated.',
  );

  late final _actions = AccountActions(
    approve: _approve,
    reject: _reject,
    deactivate: _deactivate,
    reactivate: _reactivate,
  );

  // ---------- build ----------

  Widget _header() {
    if (_headerLoading) return const StatStripSkeleton();
    final t = _team;
    if (t == null) {
      return CardMessage(
        message: _headerError ?? 'Could not load the counts.',
        onRetry: _loadHeader,
      );
    }
    final employees = t.teams.fold<int>(0, (s, e) => s + e.membersCount);
    return StatStrip(
      items: [
        (
          'PENDING',
          '${t.pendingAdminApprovals}',
          'awaiting approval',
          AppColors.warning,
        ),
        ('TEAMS', '${t.teams.length}', 'approved admins', AppColors.success),
        (
          'EMPLOYEES',
          '$employees',
          'across all teams',
          AppColors.stepCurrentLabel,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!CurrentUser.instance.isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage admins')),
        body: const Center(child: Text("You don't have access to this view.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Manage admins'),
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
                  pendingBadge: _team?.pendingAdminApprovals ?? 0,
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
            Expanded(
              child: ManageListView(
                c: _c,
                header: _header(),
                onRefresh: _refresh,
                emptyMessage: (s) => switch (s) {
                  'pending' => 'No admins are waiting for approval.',
                  'active' => 'No active admins yet.',
                  _ => 'No inactive admins.',
                },
                itemBuilder: (context, a) => AccountCard(
                  a: a,
                  isAdminAccount: true,
                  showAdminName: false,
                  busy: _busyId == a.id,
                  onOpen: () => showAccountSheet(
                    context,
                    account: a,
                    isAdminAccount: true,
                    showAdminName: false,
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
