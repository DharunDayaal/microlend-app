import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_progress_bar.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/device/device_utils.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/number_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';

class PaymentTile extends StatelessWidget {
  final PaymentModel payment;
  final double weekTarget;
  final double weekCollected;
  final bool isExtension;

  const PaymentTile({
    super.key,
    required this.payment,
    required this.weekTarget,
    required this.weekCollected,
    this.isExtension = false,
  });

  factory PaymentTile.fromLoan({
    Key? key,
    required PaymentModel payment,
    required LoanModel loan,
  }) {
    final track = loan.tracks
        .where((t) => t.weekNumber == payment.weekNumber)
        .firstOrNull;

    return PaymentTile(
      key: key,
      payment: payment,
      weekTarget: track?.targetAmount ?? loan.weeklyPayableAmount,
      weekCollected: track?.totalCollected ?? payment.amountPaid,
      isExtension: payment.weekNumber > loan.totalWeeks,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const muted = AppColors.darkOnSurfaceMuted;

    final cleared = weekTarget > 0 && weekCollected >= weekTarget;
    final left = math.max(0.0, weekTarget - weekCollected);
    final progress = NumberFormatter.progress(weekCollected, weekTarget);

    final accent = isExtension
        ? AppColors.dangerContainer
        : cleared
        ? AppColors.success
        : AppColors.warning;

    final paidAt = payment.paidAt;
    final when = paidAt != null
        ? '${DateFormatter.date(paidAt)} • ${DateFormatter.time(paidAt)}'
        : '--';

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Container(
        color: AppColors.darkSurface.withAlpha(AppAlphas.badgeFill),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppChip(
                            label: 'Week ${payment.weekNumber}',
                            backgroundColor: AppColors.darkPrimary.withAlpha(
                              AppAlphas.borderTint,
                            ),
                            foregroundColor: AppColors.stepCurrentLabel,
                            borderColor: Colors.transparent,
                            radius: AppSizes.radiusSm,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm + 2,
                              vertical: 3,
                            ),
                            textStyle: text.labelMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (isExtension) ...[
                            AppGap.w8,
                            AppChip(
                              label: 'PAST TERM',
                              backgroundColor: AppColors.dangerContainer,
                              foregroundColor: Colors.white,
                              borderColor: Colors.transparent,
                              radius: AppSizes.radiusSm,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: 3,
                              ),
                              textStyle: text.labelSmall,
                            ),
                          ],
                          AppGap.w8,
                          Expanded(
                            child: Text(
                              when,
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.labelLarge?.copyWith(color: muted),
                            ),
                          ),
                        ],
                      ),
                      AppGap.h12,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('AMOUNT PAID', style: text.labelMedium),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    CurrencyFormatter.format(
                                      payment.amountPaid,
                                    ),
                                    style: text.headlineMedium?.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppGap.w8,
                          AppChip(
                            label: cleared ? 'WEEK CLEARED' : 'PARTIAL',
                            backgroundColor: cleared
                                ? AppColors.successContainer
                                : AppColors.approvalGlowWarm,
                            foregroundColor: cleared
                                ? Colors.white
                                : AppColors.progressWarning,
                            borderColor: Colors.transparent,
                            radius: AppSizes.radiusSm,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm + 2,
                              vertical: 4,
                            ),
                            textStyle: text.labelSmall,
                            leading: Icon(
                              cleared ? Icons.check_circle : Icons.timelapse,
                              size: 12,
                              color: cleared
                                  ? Colors.white
                                  : AppColors.progressWarning,
                            ),
                          ),
                        ],
                      ),
                      AppGap.h12,
                      AppProgressBar(
                        value: progress,
                        height: 6,
                        color: accent,
                        semanticsLabel: 'Week ${payment.weekNumber} progress',
                      ),
                      const SizedBox(height: AppSizes.xs + 2),
                      Text(
                        cleared
                            ? 'Week ${payment.weekNumber} fully collected '
                                  '(${CurrencyFormatter.format(weekTarget)})'
                            : '${CurrencyFormatter.format(weekCollected)} of '
                                  '${CurrencyFormatter.format(weekTarget)} collected '
                                  '• ${CurrencyFormatter.format(left)} left',
                        style: text.labelMedium?.copyWith(color: muted),
                      ),
                      AppGap.h12,
                      InkWell(
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        onTap: () {
                          DeviceUtils.copy(payment.id);
                          AppSnackbar.success(context, 'Payment ID copied');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                            vertical: AppSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkBackground.withAlpha(
                              AppAlphas.scrim,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSm,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  TextFormatter.dummyId(payment.id, 'PAY'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.labelMedium?.copyWith(
                                    fontFamily: 'monospace',
                                    color: muted,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.copy_rounded,
                                size: 14,
                                color: muted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
