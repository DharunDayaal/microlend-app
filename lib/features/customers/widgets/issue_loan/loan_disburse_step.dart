import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/data/models/customer_model.dart';
import 'package:micro_lending_app/data/models/loan_terms_model.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';

enum PayoutMode { cash, bank }

String _pct(double v) => '${v == v.truncateToDouble() ? v.toInt() : v}%';

/// Step 3: review the numbers and choose how the money is handed over.
class LoanDisburseStep extends StatelessWidget {
  final CustomerDetails customer;
  final LoanTerms terms;
  final PayoutMode mode;
  final ValueChanged<PayoutMode> onModeChanged;

  /// Bank transfer needs a verified account on file. Nothing in the
  /// customer data says there is one, so it stays off until you have it.
  final bool bankAvailable;

  const LoanDisburseStep({
    super.key,
    required this.customer,
    required this.terms,
    required this.mode,
    required this.onModeChanged,
    this.bankAvailable = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = terms;
    final weeks = t.totalWeeks;
    final firstDue = LoanHelper.scheduledDueDate(
      week: 1,
      preferredDay: customer.preferredPaymentDay,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ----- summary -----
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppNameCard(
                    name: customer.customerName,
                    width: 44,
                    height: 44,
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.customerName,
                          style: text.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: AppSizes.sm,
                          runSpacing: 4,
                          children: [
                            AppChip(
                              label: TextFormatter.dummyId(customer.id, '#USR'),
                              radius: AppSizes.radiusSm,
                              textStyle: text.labelSmall?.copyWith(
                                color: AppColors.darkOnSurfaceMuted,
                              ),
                            ),
                            AppChip(
                              label: t.isValid
                                  ? 'READY FOR DISBURSAL'
                                  : 'CHECK TERMS',
                              radius: AppSizes.radiusSm,
                              backgroundColor:
                                  (t.isValid
                                          ? AppColors.successContainer
                                          : AppColors.dangerContainer)
                                      .withAlpha(AppAlphas.badgeFill),
                              textStyle: text.labelSmall?.copyWith(
                                color: t.isValid
                                    ? AppColors.progressSuccess
                                    : AppColors.progressDanger,
                              ),
                              leading: Icon(
                                t.isValid
                                    ? Icons.verified_outlined
                                    : Icons.error_outline,
                                size: 12,
                                color: t.isValid
                                    ? AppColors.progressSuccess
                                    : AppColors.progressDanger,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppGap.h16,
              _Line(
                label: 'Sanctioned Principal',
                value: CurrencyFormatter.format(t.principal),
              ),
              _Line(
                label: 'Upfront Fee (${_pct(t.feePercent)})',
                value: '-${CurrencyFormatter.format(t.upfrontFee)}',
                valueColor: AppColors.progressDanger,
              ),
              AppGap.h8,
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.successContainer.withAlpha(
                    AppAlphas.badgeFill,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: AppColors.successContainer.withAlpha(
                      AppAlphas.borderTint,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      color: AppColors.success,
                    ),
                    AppGap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NET CASH HANDOVER',
                            style: text.labelSmall?.copyWith(
                              color: AppColors.progressSuccess,
                            ),
                          ),
                          Text(
                            'Immediate physical disbursal',
                            style: text.labelMedium?.copyWith(
                              color: AppColors.darkOnSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppGap.w8,
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormatter.format(t.netDisbursed),
                        style: text.headlineMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h12,
              Row(
                spacing: AppSizes.sm,
                children: [
                  Expanded(
                    child: _StatTile(
                      label: 'TOTAL REPAYABLE',
                      value: CurrencyFormatter.format(t.totalPayable),
                      caption: '$weeks wks',
                    ),
                  ),
                  Expanded(
                    child: _StatTile(
                      label: 'WEEKLY CADENCE',
                      value: CurrencyFormatter.format(t.weeklyInstallment),
                      caption: DateFormatter.weekdayDate(firstDue),
                      captionColor: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        AppGap.h16,

        // ----- payout mode -----
        Row(
          children: [
            Expanded(
              child: Text(
                'Payout Mode',
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              'Select 1 channel',
              style: text.labelMedium?.copyWith(
                color: AppColors.darkOnSurfaceMuted,
              ),
            ),
          ],
        ),
        AppGap.h8,
        _PayoutTile(
          icon: Icons.payments_outlined,
          title: 'Cash in hand',
          subtitle:
              'Agent hands over ${CurrencyFormatter.format(t.netDisbursed)} '
              'in currency notes from the collection pouch.',
          badge: 'FIELD STANDARD',
          selected: mode == PayoutMode.cash,
          enabled: true,
          onTap: () => onModeChanged(PayoutMode.cash),
        ),
        AppGap.h8,
        _PayoutTile(
          icon: Icons.account_balance_outlined,
          title: 'Instant UPI / IMPS Bank Transfer',
          subtitle: bankAvailable
              ? 'Disburse to the verified account on file.'
              : 'No verified bank account on file for this borrower.',
          selected: mode == PayoutMode.bank,
          enabled: bankAvailable,
          onTap: () => onModeChanged(PayoutMode.bank),
        ),
      ],
    );
  }
}

// ---------- bottom bar ----------

class DisburseBar extends StatelessWidget {
  final double netAmount;
  final PayoutMode mode;
  final bool isLoading;
  final VoidCallback? onPressed; // null disables the button

  const DisburseBar({
    super.key,
    required this.netAmount,
    required this.mode,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final amount = CurrencyFormatter.format(netAmount);
    final modeLabel = mode == PayoutMode.cash ? 'Cash' : 'Bank transfer';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'NET PHYSICAL HANDOVER',
                      style: text.labelMedium?.copyWith(
                        color: AppColors.darkOnSurfaceMuted,
                      ),
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: amount,
                      style: text.headlineSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w800,
                      ),
                      children: [
                        TextSpan(
                          text: ' ($modeLabel)',
                          style: text.labelMedium?.copyWith(
                            color: AppColors.darkOnSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppGap.h8,
              AppButton(
                label: 'ISSUE LOAN & DISBURSE $amount',
                prefixIcon: Icons.check_circle_outline,
                radius: AppSizes.md,
                isLoading: isLoading,
                onPressed: onPressed,
              ),
              AppGap.h8,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 14,
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                  const SizedBox(width: AppSizes.xs + 2),
                  Flexible(
                    child: Text(
                      'Disbursal is recorded to the field ledger',
                      style: text.labelSmall?.copyWith(
                        color: AppColors.darkOnSurfaceMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- small building blocks ----------

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: child,
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Line({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: text.bodyMedium)),
          Text(
            value,
            style: text.bodyLarge?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final Color? captionColor;
  const _StatTile({
    required this.label,
    required this.value,
    required this.caption,
    this.captionColor,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.labelSmall?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            caption,
            style: text.labelMedium?.copyWith(
              color: captionColor ?? AppColors.darkOnSurfaceMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PayoutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _PayoutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppSizes.radiusLg);

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: title,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Material(
          color: selected
              ? AppColors.successContainer.withAlpha(AppAlphas.watermark)
              : AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: enabled ? onTap : null,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: selected
                      ? AppColors.successContainer
                      : AppColors.darkBorder,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? AppColors.success
                        : AppColors.darkOnSurfaceMuted,
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(icon, size: AppSizes.iconSm),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Text(
                                title,
                                style: text.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (badge != null) ...[
                              AppGap.w8,
                              AppChip(
                                label: badge!,
                                radius: AppSizes.radiusSm,
                                backgroundColor: AppColors.successContainer,
                                foregroundColor: Colors.white,
                                borderColor: Colors.transparent,
                                textStyle: text.labelSmall,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: text.labelMedium?.copyWith(
                            color: AppColors.darkOnSurfaceMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
