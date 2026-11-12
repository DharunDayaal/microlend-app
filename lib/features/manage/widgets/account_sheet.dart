import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/call_icon_button.dart';
import 'package:micro_lending_app/data/models/managed_account.dart';
import 'package:micro_lending_app/data/models/profile_model.dart';
import 'package:micro_lending_app/data/services/management_service.dart';
import 'package:micro_lending_app/features/analytics/analytics_filter.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_cards_more.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_common.dart';
import 'package:micro_lending_app/features/manage/widgets/manage_widgets.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_widgets.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';

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

class _AccountSheet extends StatelessWidget {
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

  Future<void> _do(
    BuildContext context,
    Future<bool> Function(ManagedAccount) f,
  ) async {
    final ok = await f(a);
    if (ok && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (label, color) = statusLook(a.status);

    return FractionallySizedBox(
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
                        Pill(a.role.label.toUpperCase(), roleColor(a.role)),
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
                  label: 'Phone',
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
                  label: 'Email',
                  value: a.email.isEmpty ? 'Not added' : a.email,
                ),
                const Divider(height: 1, color: AppColors.darkBorder),
                InfoRow(
                  icon: Icons.event_outlined,
                  label: 'Joined',
                  value: DateFormatter.date(a.createdAt),
                ),
                if (!isAdminAccount &&
                    showAdminName &&
                    (a.adminName ?? '').isNotEmpty) ...[
                  const Divider(height: 1, color: AppColors.darkBorder),
                  InfoRow(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Works under',
                    value: a.adminName!,
                  ),
                ],
                if (a.fee != null) ...[
                  const Divider(height: 1, color: AppColors.darkBorder),
                  InfoRow(
                    icon: Icons.tune_rounded,
                    label: isAdminAccount
                        ? 'Loan defaults'
                        : 'Loan defaults (own)',
                    value:
                        'Fee ${_num(a.fee!)}% • Interest ${_num(a.interest ?? 0)}% • '
                        '${_num(a.months ?? 0)} months',
                  ),
                ],
              ],
            ),
          ),
          AppGap.h16,
          if (isAdminAccount) _TeamSection(a: a) else _EmployeeSection(a: a),
          AppGap.h16,
          AppButton(
            label: 'History',
            outlined: true,
            prefixIcon: Icons.history_rounded,
            radius: AppSizes.md,
            onPressed: () {
              Navigator.of(context).pop();
              context.push(
                AppRoutes.auditFor(targetId: a.id, label: a.displayName),
              );
            },
          ),
          AppGap.h12,
          AccountActionBar(
            status: a.status,
            busy: false,
            onApprove: () => _do(context, actions.approve),
            onReject: () => _do(context, actions.reject),
            onDeactivate: () => _do(context, actions.deactivate),
            onReactivate: () => _do(context, actions.reactivate),
          ),
        ],
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  final ManagedAccount a;
  const _TeamSection({required this.a});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AsyncCard<TeamSummary>(
      cacheKey: 'team|${a.id}',
      title: 'Team',
      skeletonHeight: 120,
      load: () => ManagementService.team(adminId: a.id),
      builder: (context, t) => AnalyticsFrame(
        title: 'Team (${t.members.length})',
        trailing: t.pendingCount > 0
            ? Pill('${t.pendingCount} pending', AppColors.warning)
            : null,
        child: t.members.isEmpty
            ? const EmptyNote('No employees under this admin yet.')
            : Column(
                children: [
                  for (final m in t.members)
                    RankedRow(
                      name: m.userName,
                      primary: '${m.customersCount} customers',
                      secondary: m.phoneNumber.isEmpty
                          ? null
                          : PhoneFormatter.display(m.phoneNumber),
                      pill: !m.isActive
                          ? Pill('INACTIVE', AppColors.progressDanger)
                          : (!m.isVerified
                                ? Pill('PENDING', AppColors.warning)
                                : null),
                    ),
                  Text(
                    'Open Manage users to approve or deactivate employees.',
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

class _EmployeeSection extends StatelessWidget {
  final ManagedAccount a;
  const _EmployeeSection({required this.a});

  @override
  Widget build(BuildContext context) {
    return AsyncCard<ManagedAccount>(
      cacheKey: 'emp|${a.id}',
      title: 'Activity',
      skeletonHeight: 100,
      load: () => ManagementService.employee(a.id),
      builder: (context, d) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatStrip(
            items: [
              (
                'CUSTOMERS',
                '${d.customersCount ?? 0}',
                'created',
                AppColors.stepCurrentLabel,
              ),
              (
                'ACTIVE LOANS',
                '${d.activeLoans ?? 0}',
                'active and overdue',
                AppColors.success,
              ),
              (
                'OVERDUE',
                '${d.overdueLoans ?? 0}',
                'loans right now',
                (d.overdueLoans ?? 0) > 0
                    ? AppColors.progressDanger
                    : AppColors.success,
              ),
            ],
          ),
          AppGap.h12,
          AppButton(
            label: 'View performance',
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
