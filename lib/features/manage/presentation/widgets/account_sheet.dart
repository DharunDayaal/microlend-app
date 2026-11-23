import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/shared/helpers/route_guard.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_name_card.dart';
import 'package:micro_lending_app/shared/widgets/call_icon_button.dart';
import 'package:micro_lending_app/features/manage/domain/entities/managed_account.dart';
import 'package:micro_lending_app/features/manage/domain/entities/team.dart';
import 'package:micro_lending_app/features/manage/data/manage_providers.dart';
import 'package:micro_lending_app/features/analytics/presentation/analytics_filter.dart';
import 'package:micro_lending_app/features/analytics/presentation/widgets/analytics_cards_more.dart';
import 'package:micro_lending_app/features/analytics/presentation/widgets/analytics_common.dart';
import 'package:micro_lending_app/features/manage/presentation/widgets/manage_widgets.dart';
import 'package:micro_lending_app/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/phone_formatter.dart';

/// Each returns true when the change was made (the sheet then closes).
class AccountActions {
  final Future<bool> Function(ManagedAccount) approve;
  final Future<bool> Function(ManagedAccount) reject;
  final Future<bool> Function(ManagedAccount) deactivate;
  final Future<bool> Function(ManagedAccount) reactivate;

  const AccountActions({
    required this.approve,
    required this.reject,
    required this.deactivate,
    required this.reactivate,
  });
}

Future<void> showAccountSheet(
  BuildContext context, {
  required ManagedAccount account,
  required bool isAdminAccount,
  required bool showAdminName,
  required AccountActions actions,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _AccountSheet(
      a: account,
      isAdminAccount: isAdminAccount,
      showAdminName: showAdminName,
      actions: actions,
    ),
  );
}

String _num(double v) =>
    v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

class _AccountSheet extends StatefulWidget {
  final ManagedAccount a;
  final bool isAdminAccount;
  final bool showAdminName;
  final AccountActions actions;

  const _AccountSheet({
    required this.a,
    required this.isAdminAccount,
    required this.showAdminName,
    required this.actions,
  });

  @override
  State<_AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends State<_AccountSheet> {
  /// An action (its confirm dialog and request) is running: the sheet
  /// can't be closed and the buttons wait.
  bool _busy = false;

  Future<void> _do(Future<bool> Function(ManagedAccount) f) async {
    if (_busy) return;
    setState(() => _busy = true);
    bool ok = false;
    try {
      ok = await f(widget.a);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (ok && mounted) context.popIfTop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final a = widget.a;
    final isAdminAccount = widget.isAdminAccount;
    final showAdminName = widget.showAdminName;
    final actions = widget.actions;
    final (label, color) = statusLook(context, a.status);

    return BusySheetGuard(
      busy: _busy,
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.lg),
          children: [
            Row(
              children: [
                AppNameCard(name: a.displayName, width: 56, height: 56),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.displayName,
                        style: text.headlineSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: AppSizes.sm,
                        children: [
                          Pill(label, color),
                          Pill(
                            a.role.l10nLabel(context).toUpperCase(),
                            roleColor(a.role),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppGap.h16,
            AnalyticsFrame(
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.phone_outlined,
                    label: context.l10n.accPhone,
                    value: a.phone.isEmpty
                        ? '--'
                        : PhoneFormatter.display(a.phone),
                    trailing: a.phone.isEmpty
                        ? null
                        : CallIconButton(phone: a.phone),
                  ),
                  const Divider(height: 1, color: AppColors.darkBorder),
                  InfoRow(
                    icon: Icons.mail_outline,
                    label: context.l10n.accEmail,
                    value: a.email.isEmpty ? context.l10n.accNotAdded : a.email,
                  ),
                  const Divider(height: 1, color: AppColors.darkBorder),
                  InfoRow(
                    icon: Icons.event_outlined,
                    label: context.l10n.accJoined,
                    value: DateFormatter.date(a.createdAt),
                  ),
                  if (!isAdminAccount &&
                      showAdminName &&
                      (a.adminName ?? '').isNotEmpty) ...[
                    const Divider(height: 1, color: AppColors.darkBorder),
                    InfoRow(
                      icon: Icons.admin_panel_settings_outlined,
                      label: context.l10n.empWorksUnder,
                      value: a.adminName!,
                    ),
                  ],
                  if (a.fee != null) ...[
                    const Divider(height: 1, color: AppColors.darkBorder),
                    InfoRow(
                      icon: Icons.tune_rounded,
                      label: isAdminAccount
                          ? context.l10n.empLoanDefaults
                          : context.l10n.accLoanDefaultsOwn,
                      value: context.l10n.accDefaultsLine(
                        _num(a.fee!),
                        _num(a.interest ?? 0),
                        _num(a.months ?? 0),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppGap.h16,
            if (isAdminAccount) _TeamSection(a: a) else _EmployeeSection(a: a),
            AppGap.h16,
            AppButton(
              label: context.l10n.commonHistory,
              outlined: true,
              prefixIcon: Icons.history_rounded,
              radius: AppSizes.md,
              onPressed: _busy
                  ? null
                  : () {
                      Navigator.of(context).pop();
                      context.push(
                        AppRoutes.auditFor(
                          targetId: a.id,
                          label: a.displayName,
                        ),
                      );
                    },
            ),
            AppGap.h12,
            AccountActionBar(
              status: a.status,
              busy: _busy,
              onApprove: () => _do(actions.approve),
              onReject: () => _do(actions.reject),
              onDeactivate: () => _do(actions.deactivate),
              onReactivate: () => _do(actions.reactivate),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamSection extends ConsumerWidget {
  final ManagedAccount a;
  const _TeamSection({required this.a});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    return AsyncCard<TeamSummary>(
      cacheKey: 'team|${a.id}',
      title: context.l10n.auditTeam,
      skeletonHeight: 120,
      load: (ref) => ref.read(manageRepositoryProvider).team(adminId: a.id),
      builder: (context, t) => AnalyticsFrame(
        title: context.l10n.accTeamCount(t.members.length),
        trailing: t.pendingCount > 0
            ? Pill(
                context.l10n.accPendingCount(t.pendingCount),
                AppColors.warning,
              )
            : null,
        child: t.members.isEmpty
            ? EmptyNote(context.l10n.accNoEmployees)
            : Column(
                children: [
                  for (final m in t.members)
                    RankedRow(
                      name: m.userName,
                      primary: context.l10n.accCustomersCount(m.customersCount),
                      secondary: m.phoneNumber.isEmpty
                          ? null
                          : PhoneFormatter.display(m.phoneNumber),
                      pill: !m.isActive
                          ? Pill(
                              context.l10n.manInactive,
                              AppColors.progressDanger,
                            )
                          : (!m.isVerified
                                ? Pill(
                                    context.l10n.manPending,
                                    AppColors.warning,
                                  )
                                : null),
                    ),
                  Text(
                    context.l10n.accOpenManageUsers,
                    style: text.labelSmall?.copyWith(
                      color: AppColors.darkOnSurfaceMuted,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _EmployeeSection extends ConsumerWidget {
  final ManagedAccount a;
  const _EmployeeSection({required this.a});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncCard<ManagedAccount>(
      cacheKey: 'emp|${a.id}',
      title: context.l10n.accActivity,
      skeletonHeight: 100,
      load: (ref) => ref.read(manageRepositoryProvider).employee(a.id),
      builder: (context, d) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatStrip(
            items: [
              (
                context.l10n.accCustomers,
                '${d.customersCount ?? 0}',
                context.l10n.accCreated,
                AppColors.stepCurrentLabel,
              ),
              (
                context.l10n.accActiveLoans,
                '${d.activeLoans ?? 0}',
                context.l10n.accActiveAndOverdue,
                AppColors.success,
              ),
              (
                context.l10n.statusOverdue,
                '${d.overdueLoans ?? 0}',
                context.l10n.anLoansRightNow,
                (d.overdueLoans ?? 0) > 0
                    ? AppColors.progressDanger
                    : AppColors.success,
              ),
            ],
          ),
          AppGap.h12,
          AppButton(
            label: context.l10n.accViewPerformance,
            outlined: true,
            prefixIcon: Icons.insights_outlined,
            radius: AppSizes.md,
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              backgroundColor: AppColors.darkSurface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              builder: (_) => EmployeeSheet(
                id: a.id,
                name: a.displayName,
                f: AnalyticsFilters(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
