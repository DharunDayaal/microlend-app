import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_progress_bar.dart';
import 'package:micro_lending_app/shared/widgets/app_status_chip.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/shared/design_system/constants/alphas.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/device/device_utils.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/number_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/shared/helpers/snackbar_helper.dart';

/// One payment with the state of the week it was paid against.
class PaymentEntry {
  final PaymentModel payment;
  final double weekTarget;
  final double weekCollected;
  final bool isExtension; // week past the loan's term

  const PaymentEntry({
    required this.payment,
    required this.weekTarget,
    required this.weekCollected,
    this.isExtension = false,
  });

  factory PaymentEntry.fromLoan(PaymentModel payment, LoanModel loan) {
    final track = loan.tracks
        .where((t) => t.weekNumber == payment.weekNumber)
        .firstOrNull;
    return PaymentEntry(
      payment: payment,
      weekTarget: track?.targetAmount ?? loan.weeklyPayableAmount,
      weekCollected: track?.totalCollected ?? payment.amountPaid,
      isExtension: payment.weekNumber > loan.totalWeeks,
    );
  }

  bool get cleared => weekTarget > 0 && weekCollected >= weekTarget;
  double get left => math.max(0.0, weekTarget - weekCollected);
  double get progress => NumberFormatter.progress(weekCollected, weekTarget);

  Color get accent => isExtension
      ? AppColors.progressDanger
      : cleared
      ? AppColors.success
      : AppColors.warning;

  IconData get icon => isExtension
      ? Icons.error_outline_rounded
      : cleared
      ? Icons.check_rounded
      : Icons.timelapse_rounded;

  /// "Week cleared" or "₹100 left for this week".
  String weekLine(BuildContext context) => cleared
      ? context.l10n.payWeekClearedShort
      : context.l10n.payLeftForWeek(CurrencyFormatter.format(left));
}

/// A compact timeline row: status icon, week, time and amount. Tapping it
/// opens [PaymentDetailsSheet].
class PaymentRow extends StatelessWidget {
  final PaymentEntry entry;
  const PaymentRow({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = entry.payment;
    const muted = AppColors.darkOnSurfaceMuted;
    final time = DateFormatter.time(p.paidAt, fallback: '--');

    return Semantics(
      button: true,
      label: context.l10n.payOpenDetails,
      child: InkWell(
        onTap: () => PaymentDetailsSheet.show(context, entry),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm + 4,
          ),
          child: Row(
            children: [
              _StatusDot(entry: entry),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            context.l10n.commonWeekN(p.weekNumber),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (entry.isExtension) ...[
                          AppGap.w8,
                          const Flexible(child: _PastTermChip()),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$time • ${entry.weekLine(context)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.labelMedium?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              AppGap.w8,
              Flexible(
                flex: 0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '+${CurrencyFormatter.format(p.amountPaid)}',
                      style: text.titleMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, size: 20, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final PaymentEntry entry;
  final double size;
  const _StatusDot({required this.entry, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: entry.accent.withAlpha(AppAlphas.borderTint),
      ),
      child: Icon(entry.icon, size: size * 0.5, color: entry.accent),
    );
  }
}

class _PastTermChip extends StatelessWidget {
  const _PastTermChip();

  @override
  Widget build(BuildContext context) {
    return AppChip(
      label: context.l10n.payPastTerm,
      backgroundColor: AppColors.dangerContainer,
      foregroundColor: Colors.white,
      borderColor: Colors.transparent,
      radius: AppSizes.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
      textStyle: Theme.of(context).textTheme.labelSmall,
    );
  }
}

/// Everything about one payment: amount, when, the week's progress, who
/// collected it and the references (copyable).
class PaymentDetailsSheet extends StatelessWidget {
  final PaymentEntry entry;
  const PaymentDetailsSheet({super.key, required this.entry});

  static Future<void> show(BuildContext context, PaymentEntry entry) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: AppColors.darkSurface,
        builder: (_) => PaymentDetailsSheet(entry: entry),
      );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l = context.l10n;
    final p = entry.payment;
    const muted = AppColors.darkOnSurfaceMuted;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.lg,
          0,
          AppSizes.lg,
          AppSizes.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.payDetails,
              textAlign: TextAlign.center,
              style: text.labelLarge?.copyWith(color: muted),
            ),
            AppGap.h16,
            Center(child: _StatusDot(entry: entry, size: 56)),
            AppGap.h12,
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                CurrencyFormatter.format(p.amountPaid),
                style: text.displaySmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            AppGap.h4,
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSizes.sm,
              runSpacing: AppSizes.xs,
              children: [
                Text(l.commonWeekN(p.weekNumber), style: text.bodyLarge),
                if (entry.isExtension) const _PastTermChip(),
              ],
            ),
            AppGap.h16,

            // the week this payment went to
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.weekLine(context),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(
                            color: entry.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AppGap.w8,
                      Text(
                        '${(entry.progress * 100).floor()}%',
                        style: text.labelLarge?.copyWith(color: entry.accent),
                      ),
                    ],
                  ),
                  AppGap.h8,
                  AppProgressBar(
                    value: entry.progress,
                    height: 6,
                    color: entry.accent,
                    semanticsLabel: l.payWeekProgress(p.weekNumber),
                  ),
                  AppGap.h8,
                  Text(
                    l.payCollectedOfLeft(
                      CurrencyFormatter.format(entry.weekCollected),
                      CurrencyFormatter.format(entry.weekTarget),
                      CurrencyFormatter.format(entry.left),
                    ),
                    style: text.labelMedium?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            AppGap.h12,

            _Panel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _DetailRow(
                    label: l.payPaidOn,
                    value: p.paidAt == null
                        ? '--'
                        : '${DateFormatter.date(p.paidAt)} • ${DateFormatter.time(p.paidAt)}',
                  ),
                  const _RowDivider(),
                  _DetailRow(
                    label: l.payCollectedBy,
                    value: TextFormatter.dummyId(p.collectedByAdminId, 'ADM'),
                    mono: true,
                  ),
                  const _RowDivider(),
                  _DetailRow(
                    label: l.payReference,
                    value: TextFormatter.dummyId(p.id, 'PAY'),
                    mono: true,
                    copyValue: p.id,
                  ),
                  const _RowDivider(),
                  _DetailRow(
                    label: l.payWeekRecord,
                    value: TextFormatter.dummyId(p.trackId, 'TRK'),
                    mono: true,
                    copyValue: p.trackId,
                  ),
                ],
              ),
            ),
            AppGap.h16,
            AppButton(
              label: l.commonClose,
              outlined: true,
              radius: AppSizes.md,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Panel({
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.md),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: child,
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    indent: AppSizes.md,
    endIndent: AppSizes.md,
    color: AppColors.darkBorder.withAlpha(AppAlphas.borderTint),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  /// Set to show a copy button that copies this (the full id).
  final String? copyValue;

  const _DetailRow({
    required this.label,
    required this.value,
    this.mono = false,
    this.copyValue,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const muted = AppColors.darkOnSurfaceMuted;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.md,
        copyValue == null ? AppSizes.sm + 4 : AppSizes.xs,
        copyValue == null ? AppSizes.md : AppSizes.xs,
        copyValue == null ? AppSizes.sm + 4 : AppSizes.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(color: muted),
            ),
          ),
          AppGap.w8,
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
          if (copyValue != null)
            IconButton(
              tooltip: context.l10n.commonCopy,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.copy_rounded, size: 16, color: muted),
              onPressed: () {
                DeviceUtils.copy(copyValue!);
                AppSnackbar.success(context, context.l10n.payIdCopied);
              },
            ),
        ],
      ),
    );
  }
}
