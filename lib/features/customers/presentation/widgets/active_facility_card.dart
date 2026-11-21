import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_progress_bar.dart';
import 'package:micro_lending_app/shared/widgets/app_section_cards.dart';
import 'package:micro_lending_app/shared/widgets/app_status_chip.dart';
import 'package:micro_lending_app/shared/widgets/status_chip.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/number_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/features/loans/domain/loan_helper.dart';

/// Shown for a loan whose status is ACTIVE or OVERDUE.
class ActiveFacilityCard extends StatelessWidget {
  final LoanModel loan;
  final String? preferredDay; // the customer's preferred payment day

  /// Called when a screen opened from here changed the loan (a payment).
  final VoidCallback? onLoanChanged;

  const ActiveFacilityCard({
    super.key,
    required this.loan,
    this.preferredDay,
    this.onLoanChanged,
  });

  Future<void> _open(BuildContext context, String route) async {
    final changed = await context.push<bool>(route);
    if (changed == true) onLoanChanged?.call();
  }

  bool get _overdue => loan.isOverdue || loan.status.toUpperCase() == 'OVERDUE';

  String _nextLabel(BuildContext context, DateTime? date) {
    final l = context.l10n;
    if (_overdue) return l.facilityPaymentOverdue;
    if (date == null) return l.facilityAllPaid;
    return l.trackDueOn(DateFormatter.weekdayDate(date));
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
      title: context.l10n.facilityTitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_overdue) ...[
            StatusChip(
              label: context.l10n.statusOverdue,
              type: ChipType.overdue,
            ),
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
                        Text(
                          context.l10n.facilityRemaining,
                          style: text.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          CurrencyFormatter.format(loan.outstandingAmount),
                          style: text.headlineMedium,
                        ),
                        Text(
                          context.l10n.facilityOfTotal(
                            CurrencyFormatter.format(loan.totalPayableAmount),
                          ),
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
                        Text(
                          context.l10n.facilityNextInstallment,
                          style: text.labelMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
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
                          _nextLabel(context, nextPay),
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
              Flexible(
                child: Text(
                  context.l10n.facilityRepaidPercent((progress * 100).round()),
                  style: text.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppGap.w8,
              Flexible(
                child: Text(
                  context.l10n.facilityPaidAmount(
                    CurrencyFormatter.format(loan.totalCollected),
                  ),
                  style: text.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
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
                  label: context.l10n.facilityViewTracks,
                  onPressed: () => _open(context, AppRoutes.loanTrack(loan.id)),
                  backgroundColor: AppColors.darkRim,
                  prefixIcon: Icons.history,
                  radius: AppSizes.radiusLg,
                ),
              ),
              AppGap.w12,
              Expanded(
                child: AppButton(
                  label: context.l10n.facilityViewPayments,
                  onPressed: () =>
                      _open(context, AppRoutes.loanPayment(loan.id)),
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
