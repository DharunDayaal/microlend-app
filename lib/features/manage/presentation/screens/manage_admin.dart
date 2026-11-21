import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/widgets/app_icon_button.dart';
import 'package:micro_lending_app/features/exports/domain/entities/export.dart';
import 'package:micro_lending_app/features/manage/domain/entities/managed_account.dart';
import 'package:micro_lending_app/features/manage/domain/entities/team.dart';
import 'package:micro_lending_app/features/manage/data/manage_providers.dart';
import 'package:micro_lending_app/features/exports/presentation/widgets/export_sheet.dart';
import 'package:micro_lending_app/features/manage/presentation/controllers/accounts_list_controller.dart';
import 'package:micro_lending_app/features/manage/presentation/widgets/account_sheet.dart';
import 'package:micro_lending_app/features/manage/presentation/widgets/manage_widgets.dart';
import 'package:micro_lending_app/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/shared/helpers/dialog_helper.dart';
import 'package:micro_lending_app/shared/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

class ManageAdminsScreen extends ConsumerStatefulWidget {
  const ManageAdminsScreen({super.key});

  @override
  ConsumerState<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends ConsumerState<ManageAdminsScreen> {
  AccountsListController get _list =>
      ref.read(accountsListProvider(AccountKind.admins).notifier);

  TeamSummary? _team;
  bool _headerLoading = true;
  String? _headerError;
  String? _busyId;

  @override
  void initState() {
    super.initState();
    _loadHeader(); // the list loads itself
  }

  Future<void> _loadHeader() async {
    setState(() {
      _headerLoading = _team == null;
      _headerError = null;
    });
    try {
      final t = await ref.read(manageRepositoryProvider).team();
      if (mounted) setState(() => _team = t);
    } on ApiException catch (e) {
      if (mounted) setState(() => _headerError = e.message);
    } finally {
      if (mounted) setState(() => _headerLoading = false);
    }
  }

  Future<void> _refresh() =>
      Future.wait([_list.refresh(showSkeleton: false), _loadHeader()]);

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
      _list.replace(updated);
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
    () => ref.read(manageRepositoryProvider).setAdminVerified(a.id, true),
    (u) => context.l10n.manApproved(a.displayName),
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
      () => ref.read(manageRepositoryProvider).setAdminActive(a.id, false),
      (u) => context.l10n.manRejected(a.displayName),
    );
  }

  Future<bool> _deactivate(ManagedAccount a) async {
    final ok = await DialogHelper.confirm(
      context,
      title: context.l10n.manDeactivateTitle(a.displayName),
      message: context.l10n.manDeactivateAdminMsg,
      confirmText: context.l10n.manDeactivate,
    );
    if (!ok || !mounted) return false;
    return _run(
      a,
      () => ref.read(manageRepositoryProvider).setAdminActive(a.id, false),
      (u) => context.l10n.manDeactivated(a.displayName),
    );
  }

  Future<bool> _reactivate(ManagedAccount a) => _run(
    a,
    () => ref.read(manageRepositoryProvider).setAdminActive(a.id, true),
    (u) => u.status == AccountStatus.pending
        ? context.l10n.manReactivatedPending(a.displayName)
        : context.l10n.manReactivated(a.displayName),
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
        message: _headerError ?? context.l10n.manCountsFailed,
        onRetry: _loadHeader,
      );
    }
    final employees = t.teams.fold<int>(0, (s, e) => s + e.membersCount);
    return StatStrip(
      items: [
        (
          context.l10n.manPending,
          '${t.pendingAdminApprovals}',
          context.l10n.manAwaitingApproval,
          AppColors.warning,
        ),
        (
          context.l10n.manTeams,
          '${t.teams.length}',
          context.l10n.manApprovedAdmins,
          AppColors.success,
        ),
        (
          context.l10n.manEmployees,
          '$employees',
          context.l10n.manAcrossAllTeams,
          AppColors.stepCurrentLabel,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(accountsListProvider(AccountKind.admins));
    if (!ref.watch(sessionProvider).isSuperAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.manManageAdmins)),
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
        title: Text(context.l10n.manManageAdmins),
        actions: const [
          ExportMenuButton(types: [ExportType.teamSummary]),
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
              child: StatusTabs(
                value: _list.status,
                pendingBadge: _team?.pendingAdminApprovals ?? 0,
                onChanged: _list.setStatus,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
              child: ManageSearch(
                hint: context.l10n.manSearchHint,
                onChanged: _list.setSearch,
              ),
            ),
            Expanded(
              child: ManageListView(
                kind: AccountKind.admins,
                header: _header(),
                onRefresh: _refresh,
                emptyMessage: (s) => switch (s) {
                  'pending' => context.l10n.manNoAdminsPending,
                  'active' => context.l10n.manNoActiveAdmins,
                  _ => context.l10n.manNoInactiveAdmins,
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
