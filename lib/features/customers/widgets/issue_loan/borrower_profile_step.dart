import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_progress_bar.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/common/widgets/call_icon_button.dart';
import 'package:micro_lending_app/data/models/customer_model.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';

// Sizes shared by the real cards and their skeletons, so nothing jumps on load.
const double _headerH = 28;
const double _rowH = 48;
const double _statH = 72;

// ---------- shared frame ----------

class _ProfileCard extends StatelessWidget {
  final Widget? header;
  final Widget child;
  const _ProfileCard({this.header, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[header!, AppGap.h12],
          child,
        ],
      ),
    );
  }
}

Widget _cardHeader(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String title,
  Widget? trailing,
}) {
  final text = Theme.of(context).textTheme;
  return SizedBox(
    height: _headerH,
    child: Row(
      children: [
        Icon(icon, size: AppSizes.iconMd, color: color),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            title,
            style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

// ---------- the step ----------

class BorrowerProfileStep extends StatelessWidget {
  final CustomerDetails customer;

  /// Shows a "Switch borrower" chip when set.
  final VoidCallback? onSwitch;

  const BorrowerProfileStep({super.key, required this.customer, this.onSwitch});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _IdentityCard(customer: customer, onSwitch: onSwitch),
        AppGap.h16,
        _RouteCard(customer: customer),
        AppGap.h16,
        _CreditCard(history: customer.creditHistory),
        AppGap.h16,
        _ReferralCard(customer: customer),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final CustomerDetails customer;
  final VoidCallback? onSwitch;
  const _IdentityCard({required this.customer, this.onSwitch});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return _ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppNameCard(name: customer.customerName, width: 56, height: 56),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.customerName,
                      style: text.headlineSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      PhoneFormatter.display(customer.phoneNumber),
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
              CallIconButton(phone: customer.phoneNumber),
            ],
          ),
          AppGap.h12,
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              AppChip(
                label: TextFormatter.dummyId(customer.id, '#USR'),
                radius: AppSizes.radiusSm,
                textStyle: text.labelSmall?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                ),
              ),
              AppChip(
                label: 'Cycle ${customer.creditHistory.totalLoans + 1}',
                radius: AppSizes.radiusSm,
                backgroundColor:
                    AppColors.successContainer.withAlpha(AppAlphas.badgeFill),
                textStyle: text.labelSmall?.copyWith(
                  color: AppColors.progressSuccess,
                ),
              ),
              AppChip(
                label: 'Since ${DateFormatter.date(customer.createdAt)}',
                radius: AppSizes.radiusSm,
                textStyle: text.labelSmall?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                ),
              ),
              if (onSwitch != null)
                AppChip(
                  label: 'Switch borrower',
                  radius: AppSizes.radiusSm,
                  onTap: onSwitch,
                  leading: const Icon(
                    Icons.swap_horiz_rounded,
                    size: AppSizes.iconSm,
                    color: AppColors.stepCurrentLabel,
                  ),
                  textStyle: text.labelSmall?.copyWith(
                    color: AppColors.stepCurrentLabel,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final CustomerDetails customer;
  const _RouteCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final c = customer;
    final time = DateFormatter.formatTimeString(
      c.preferredPaymentTime,
      fallback: '',
    );
    final day = c.preferredPaymentDay.isEmpty
        ? 'Not set'
        : 'Every ${TextFormatter.enumLabel(c.preferredPaymentDay)}';
    final street = (c.streetName == null || c.streetName!.trim().isEmpty)
        ? 'No street on file'
        : c.streetName!.trim();
    final area = [c.city, c.district]
        .where((s) => s.trim().isNotEmpty)
        .toSet() // "Puducherry, Puducherry" shows once
        .join(', ');

    return _ProfileCard(
      header: _cardHeader(
        context,
        icon: Icons.route_outlined,
        color: AppColors.stepCurrentLabel,
        title: 'Collection route',
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.event_repeat_outlined,
            label: 'Collection day',
            value: time.isEmpty ? day : '$day • $time',
          ),
          const _RowDivider(),
          _InfoRow(
            icon: Icons.home_outlined,
            label: 'Street',
            value: street,
          ),
          const _RowDivider(),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Town & district',
            value: area.isEmpty ? '--' : area,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SizedBox(
      height: _rowH,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, size: AppSizes.iconMd - 4, color: AppColors.darkOnSurface),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                ),
                Text(
                  value,
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: AppColors.darkBorder);
}

// ---------- credit history ----------

class _CreditCard extends StatelessWidget {
  final CreditHistory history;
  const _CreditCard({required this.history});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final h = history;
    final total = h.totalLoans;
    final onTimePct = total == 0 ? 0 : (h.onTimeCount / total * 100).round();

    final (standing, standingColor) = total == 0
        ? ('NEW BORROWER', AppColors.darkOnSurfaceMuted)
        : h.defaultCount > 0
            ? ('AT RISK', AppColors.progressDanger)
            : onTimePct >= 70
                ? ('GOOD STANDING', AppColors.success)
                : ('FAIR', AppColors.warning);

    return _ProfileCard(
      header: _cardHeader(
        context,
        icon: Icons.credit_score_outlined,
        color: AppColors.success,
        title: 'Credit history',
        trailing: Text(
          standing,
          style: text.labelMedium?.copyWith(color: standingColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: AppSizes.sm,
            children: [
              Expanded(
                child: _StatBox(
                  label: 'ON-TIME',
                  value: '${h.onTimeCount}',
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _StatBox(
                  label: 'DELAYED',
                  value: '${h.delayedCount}',
                  color: AppColors.warning,
                ),
              ),
              Expanded(
                child: _StatBox(
                  label: 'DEFAULT',
                  value: '${h.defaultCount}',
                  color: AppColors.progressDanger,
                ),
              ),
            ],
          ),
          AppGap.h12,
          if (total == 0)
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: AppSizes.iconSm,
                  color: AppColors.darkOnSurfaceMuted,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'First loan for this borrower. There is no repayment history yet.',
                    style: text.labelMedium?.copyWith(
                      color: AppColors.darkOnSurfaceMuted,
                    ),
                  ),
                ),
              ],
            )
          else ...[
            AppProgressBar.segmented(
              segments: [
                ProgressSegment(value: h.onTimeCount / total),
                ProgressSegment(
                  value: h.delayedCount / total,
                  color: AppColors.progressWarning,
                ),
                ProgressSegment(
                  value: h.defaultCount / total,
                  color: AppColors.progressDanger,
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              '$onTimePct% repaid on time across $total ${total == 1 ? 'loan' : 'loans'}',
              style: text.labelMedium?.copyWith(
                color: AppColors.darkOnSurfaceMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      height: _statH,
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: text.labelMedium?.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(
            value,
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ---------- referral network ----------

class _ReferralCard extends StatelessWidget {
  final CustomerDetails customer;
  const _ReferralCard({required this.customer});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = customer;
    final stats = c.referralStats;
    final hasReferrer =
        c.referredByName != null && c.referredByName!.trim().isNotEmpty;

    return _ProfileCard(
      header: _cardHeader(
        context,
        icon: Icons.hub_outlined,
        color: AppColors.warning,
        title: 'Referral network',
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // who referred this borrower
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                if (hasReferrer)
                  AppNameCard(name: c.referredByName!, width: 40, height: 40)
                else
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Icon(Icons.storefront_outlined),
                  ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasReferrer ? 'Referred by' : 'Source',
                        style: text.labelMedium?.copyWith(
                          color: AppColors.darkOnSurfaceMuted,
                        ),
                      ),
                      Text(
                        hasReferrer
                            ? TextFormatter.titleCase(c.referredByName!)
                            : 'Direct walk-in',
                        style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (hasReferrer &&
                    c.referredByStanding != null &&
                    c.referredByStanding!.trim().isNotEmpty) ...[
                  const SizedBox(width: AppSizes.sm),
                  AppChip(
                    label: TextFormatter.enumLabel(c.referredByStanding!),
                    radius: AppSizes.radiusSm,
                    backgroundColor:
                        AppColors.successContainer.withAlpha(AppAlphas.badgeFill),
                    textStyle: text.labelSmall?.copyWith(
                      color: AppColors.progressSuccess,
                    ),
                  ),
                ],
              ],
            ),
          ),
          AppGap.h12,
          // who this borrower has referred
          Row(
            spacing: AppSizes.sm,
            children: [
              Expanded(
                child: _StatBox(
                  label: 'REFERRED',
                  value: '${stats.totalReferred}',
                  color: AppColors.stepCurrentLabel,
                ),
              ),
              Expanded(
                child: _StatBox(
                  label: 'ACTIVE',
                  value: '${stats.activeReferred}',
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _StatBox(
                  label: 'PAIRED',
                  value: '${stats.pairedPercentage.round()}%',
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------- skeleton ----------
// The shimmer repaints everything inside it, so only SkeletonBox and layout
// widgets go inside AppShimmer. Frames and boxes are drawn outside it.

class BorrowerProfileStepSkeleton extends StatelessWidget {
  const BorrowerProfileStepSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileCard(
          child: AppShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SkeletonBox(width: 56, height: 56, radius: AppSizes.radiusLg),
                    AppGap.w12,
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 150, height: 18, radius: 4),
                          SizedBox(height: 8),
                          SkeletonBox(width: 110, height: 12, radius: 4),
                        ],
                      ),
                    ),
                    const SkeletonBox(width: 40, height: 40, radius: AppSizes.radiusMd),
                  ],
                ),
                AppGap.h12,
                const Row(
                  children: [
                    SkeletonBox(width: 76, height: 24, radius: AppSizes.radiusSm),
                    SizedBox(width: AppSizes.sm),
                    SkeletonBox(width: 64, height: 24, radius: AppSizes.radiusSm),
                    SizedBox(width: AppSizes.sm),
                    SkeletonBox(width: 110, height: 24, radius: AppSizes.radiusSm),
                  ],
                ),
              ],
            ),
          ),
        ),
        AppGap.h16,
        _ProfileCard(
          header: const _HeaderSkeleton(),
          child: Column(
            children: const [
              _InfoRowSkeleton(),
              _RowDivider(),
              _InfoRowSkeleton(),
              _RowDivider(),
              _InfoRowSkeleton(),
            ],
          ),
        ),
        AppGap.h16,
        _ProfileCard(
          header: const _HeaderSkeleton(),
          child: Column(
            children: [
              const _StatRowSkeleton(),
              AppGap.h12,
              const AppShimmer(
                child: SkeletonBox(width: double.infinity, height: 8, radius: 4),
              ),
              AppGap.h8,
              const AppShimmer(child: SkeletonBox(width: 180, height: 10, radius: 4)),
            ],
          ),
        ),
        AppGap.h16,
        _ProfileCard(
          header: const _HeaderSkeleton(),
          child: Column(
            children: [
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: const AppShimmer(
                  child: Row(
                    children: [
                      SkeletonBox(width: 40, height: 40, radius: AppSizes.radiusMd),
                      SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 70, height: 10, radius: 4),
                            SizedBox(height: 8),
                            SkeletonBox(width: 120, height: 14, radius: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppGap.h12,
              const _StatRowSkeleton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderSkeleton extends StatelessWidget {
  const _HeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: _headerH,
      child: AppShimmer(
        child: Row(
          children: [
            SkeletonBox(width: 22, height: 22, circle: true),
            SizedBox(width: AppSizes.sm),
            SkeletonBox(width: 130, height: 14, radius: 4),
          ],
        ),
      ),
    );
  }
}

class _InfoRowSkeleton extends StatelessWidget {
  const _InfoRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: _rowH,
      child: AppShimmer(
        child: Row(
          children: [
            SkeletonBox(width: 36, height: 36, radius: AppSizes.radiusMd),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 90, height: 10, radius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: 170, height: 14, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRowSkeleton extends StatelessWidget {
  const _StatRowSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget box() => Expanded(
          child: Container(
            height: _statH,
            decoration: BoxDecoration(
              color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: const AppShimmer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonBox(width: 52, height: 10, radius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: 28, height: 20, radius: 4),
                ],
              ),
            ),
          ),
        );

    return Row(
      spacing: AppSizes.sm,
      children: [box(), box(), box()],
    );
  }
}