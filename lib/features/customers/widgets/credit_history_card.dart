import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_section_cards.dart';
import 'package:micro_lending_app/common/widgets/status_chip.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';

enum CycleOutcome { paid, delayed, defaulted, closed }

class CycleSummary {
  final int cycleNo;
  final String loanId;
  final double amount;
  final DateTime? closedAt;
  final CycleOutcome outcome;

  const CycleSummary({
    required this.cycleNo,
    required this.loanId,
    required this.amount,
    required this.closedAt,
    required this.outcome,
  });
}

/// Past loans (anything that isn't ACTIVE or OVERDUE). [cycles] is newest first.
class CreditHistoryCard extends StatelessWidget {
  final List<CycleSummary> cycles;
  const CreditHistoryCard({super.key, required this.cycles});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    final onTime = cycles.where((c) => c.outcome == CycleOutcome.paid).length;
    final delayed = cycles
        .where((c) => c.outcome == CycleOutcome.delayed)
        .length;
    final defaulted = cycles
        .where((c) => c.outcome == CycleOutcome.defaulted)
        .length;
    final ratio = cycles.isEmpty ? 0 : (onTime / cycles.length * 100).round();

    final (standing, standingColor) = cycles.isEmpty
        ? ('NEW BORROWER', theme.colorScheme.onSurfaceVariant)
        : defaulted > 0
        ? ('AT RISK', AppColors.danger)
        : ratio >= 70
        ? ('GOOD STANDING', AppColors.success)
        : ('FAIR', AppColors.warning);

    return AppSectionCard(
      icon: Icons.credit_score_outlined,
      iconColor: AppColors.success,
      title: 'Field Credit History',
      trailing: Text(
        standing,
        style: text.labelMedium?.copyWith(color: standingColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'ON-TIME',
                  value: onTime,
                  caption: '$ratio% Ratio',
                  labelColor: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _StatBox(
                  label: 'DELAYED',
                  value: delayed,
                  caption: 'Repaid late',
                  labelColor: AppColors.warning,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _StatBox(
                  label: 'DEFAULT',
                  value: defaulted,
                  caption: defaulted == 0 ? 'Clean Sheet' : 'Needs review',
                  labelColor: AppColors.danger,
                  captionColor: defaulted == 0
                      ? AppColors.success
                      : AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          Text('COMPLETED CYCLES', style: text.labelMedium),
          const SizedBox(height: AppSizes.sm),
          if (cycles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Text('No completed cycles yet', style: text.bodyMedium),
            )
          else
            for (final c in cycles) ...[
              _CycleRow(cycle: c),
              const SizedBox(height: AppSizes.sm),
            ],
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final int value;
  final String caption;
  final Color labelColor;
  final Color? captionColor;

  const _StatBox({
    required this.label,
    required this.value,
    required this.caption,
    required this.labelColor,
    this.captionColor,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppInfoTile(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: text.labelMedium?.copyWith(color: labelColor)),
          Text('$value', style: text.headlineLarge),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: text.labelMedium?.copyWith(color: captionColor),
          ),
        ],
      ),
    );
  }
}

class _CycleRow extends StatelessWidget {
  final CycleSummary cycle;
  const _CycleRow({required this.cycle});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final (icon, color, chipLabel, chipType) = switch (cycle.outcome) {
      CycleOutcome.paid => (
        Icons.check_circle_outline,
        AppColors.success,
        'PAID',
        ChipType.paid,
      ),
      CycleOutcome.delayed => (
        Icons.schedule,
        AppColors.warning,
        'DELAY REPAID',
        ChipType.pending,
      ),
      CycleOutcome.defaulted => (
        Icons.cancel_outlined,
        AppColors.danger,
        'DEFAULT',
        ChipType.overdue,
      ),
      CycleOutcome.closed => (
        Icons.lock_outline,
        AppColors.darkHint,
        'CLOSED',
        ChipType.neutral,
      ),
    };

    return AppInfoTile(
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cycle #${cycle.cycleNo} • ${TextFormatter.dummyId(cycle.loanId, "#LN")}',
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Closed ${DateFormatter.date(cycle.closedAt)} • '
                  '${CurrencyFormatter.format(cycle.amount)}',
                  style: text.labelMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          StatusChip(label: chipLabel, type: chipType),
        ],
      ),
    );
  }
}
