import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_progress_bar.dart';
import 'package:micro_lending_app/common/widgets/app_section_cards.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/common/widgets/status_chip.dart';
import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/number_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';

/// Shown for a loan whose status is ACTIVE or OVERDUE.
class ActiveFacilityCard extends StatelessWidget {
  final LoanModel loan;
  final String? preferredDay; // the customer's preferred payment day

  const ActiveFacilityCard({super.key, required this.loan, this.preferredDay});

  bool get _overdue => loan.isOverdue || loan.status.toUpperCase() == 'OVERDUE';

  String _nextLabel(DateTime? date) {
    if (_overdue) return 'Payment overdue';
    if (date == null) return 'All installments paid';
    return 'Due ${DateFormatter.weekdayDate(date)}';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final nextTrack = LoanHelper.nextDueTrack(loan);
    final nextPay = LoanHelper.nextPaymentDate(loan, preferredDay);
    final progress = NumberFormatter.progress(
      loan.totalCollected,
      loan.totalPayableAmount,
    );

    return AppSectionCard(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Active Facility',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_overdue) ...[
            const StatusChip(label: 'OVERDUE', type: ChipType.overdue),
            const SizedBox(width: AppSizes.sm),
          ],
          AppChip(
            label: TextFormatter.dummyId(loan.id, "#LN"),
            backgroundColor: AppColors.darkPrimary,
            foregroundColor: Colors.white,
            radius: AppSizes.radiusSm,
            textStyle: text.labelMedium,
          ),
        ],
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AppInfoTile(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Remaining Balance', style: text.labelMedium),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          CurrencyFormatter.format(loan.outstandingAmount),
                          style: text.headlineMedium,
                        ),
                        Text(
                          'of ${CurrencyFormatter.format(loan.totalPayableAmount)} Total',
                          style: text.labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: AppInfoTile(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Next Installment', style: text.labelMedium),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          CurrencyFormatter.format(
                            nextTrack?.remainingBalance ??
                                loan.weeklyPayableAmount,
                          ),
                          style: text.headlineMedium?.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                        Text(
                          _nextLabel(nextPay),
                          style: text.labelMedium?.copyWith(
                            color: _overdue
                                ? AppColors.danger
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Repaid: ${(progress * 100).round()}%',
                style: text.labelLarge,
              ),
              Text(
                '${CurrencyFormatter.format(loan.totalCollected)} Paid',
                style: text.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          AppProgressBar(value: progress),
          AppGap.h24,
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: "View Tracks",
                  onPressed: () => context.push(AppRoutes.loanTrack(loan.id)),
                  backgroundColor: AppColors.darkRim,
                  prefixIcon: Icons.history,
                  radius: AppSizes.radiusLg,
                ),
              ),
              AppGap.w12,
              Expanded(
                child: AppButton(
                  label: "View payments",
                  onPressed: () => context.push(AppRoutes.loanPayment(loan.id)),
                  prefixIcon: Icons.layers,
                  radius: AppSizes.radiusLg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
