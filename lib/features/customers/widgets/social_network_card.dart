import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_section_cards.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';

/// Who referred this customer, and how many borrowers they referred.
/// Draws nothing when both are empty.
class SocialNetworkCard extends StatelessWidget {
  final String? referrerName;
  final String customerName;
  final int referredCount;

  const SocialNetworkCard({
    super.key,
    required this.referrerName,
    required this.customerName,
    required this.referredCount,
  });

  @override
  Widget build(BuildContext context) {
    final hasReferrer = referrerName != null && referrerName!.trim().isNotEmpty;
    if (!hasReferrer && referredCount == 0) return const SizedBox.shrink();

    final text = Theme.of(context).textTheme;

    return AppSectionCard(
      icon: Icons.groups_outlined,
      iconColor: AppColors.success,
      title: 'Social Network & Guarantees',
      child: Column(
        children: [
          if (hasReferrer)
            AppInfoTile(
              child: Row(
                children: [
                  AppNameCard(name: referrerName!, width: 40, height: 40),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Referred By Guarantor', style: text.labelMedium),
                        Text(
                          TextFormatter.titleCase(referrerName!),
                          style: text.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (hasReferrer && referredCount > 0)
            const SizedBox(height: AppSizes.sm),
          if (referredCount > 0)
            AppInfoTile(
              child: Row(
                children: [
                  const Icon(Icons.group_add_outlined),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Borrowers Referred by ${TextFormatter.firstName(customerName)}',
                          style: text.labelMedium,
                        ),
                        Text('$referredCount Field Members', style: text.bodyLarge),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}