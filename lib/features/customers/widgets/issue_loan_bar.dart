import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';

class IssueLoanBar extends StatelessWidget {
  final String customerName;
  final int cycleNo;
  final bool canIssue;
  final String? blockedMessage; // shown under a disabled button
  final VoidCallback onPressed;

  const IssueLoanBar({
    super.key,
    required this.customerName,
    required this.cycleNo,
    required this.canIssue,
    required this.onPressed,
    this.blockedMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final name = customerName.trim().isEmpty
        ? ''
        : ' TO ${TextFormatter.firstName(customerName).toUpperCase()}';

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
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.md,
            AppSizes.lg,
            AppSizes.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: AppSizes.iconSm,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        'One active loan per borrower',
                        style: text.labelMedium,
                      ),
                    ],
                  ),
                  Text(
                    'Cycle $cycleNo',
                    style: text.labelMedium?.copyWith(color: AppColors.warning),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              AppButton(
                label: 'ISSUE LOAN$name',
                prefixIcon: Icons.add_circle_outline,
                onPressed: canIssue ? onPressed : null,
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                canIssue
                    ? 'Check credit limits & calculate custom repayment schedule'
                    : (blockedMessage ?? ''),
                textAlign: TextAlign.center,
                style: text.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
