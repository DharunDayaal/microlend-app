import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_section_cards.dart';
import 'package:micro_lending_app/data/models/customer_model.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';

/// Shows this customer's guarantor and the borrowers they referred.
class SocialNetworkCard extends StatelessWidget {
  final CustomerDetails? customerDetails;
  final List<ReferralItem> referrals;

  const SocialNetworkCard({
    super.key,
    required this.customerDetails,
    required this.referrals,
  });

  @override
  Widget build(BuildContext context) {
    final referrerName = customerDetails?.referredByName;
    final hasReferrer = referrerName != null && referrerName.trim().isNotEmpty;
    if (!hasReferrer && referrals.isEmpty) return const SizedBox.shrink();

    final text = Theme.of(context).textTheme;

    return AppSectionCard(
      icon: Icons.groups_outlined,
      iconColor: AppColors.success,
      title: 'Social Network & Guarantees',
      margin: EdgeInsets.only(top: AppSizes.xl),
      child: Column(
        children: [
          if (hasReferrer)
            AppInfoTile(
              child: Row(
                children: [
                  AppNameCard(name: referrerName, width: 40, height: 40),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Referred By Guarantor', style: text.labelMedium),
                        Text(
                          TextFormatter.titleCase(referrerName),
                          style: text.bodyLarge,
                        ),
                        if (customerDetails?.referredById?.isNotEmpty ?? false)
                          Text(
                            TextFormatter.dummyId(
                              customerDetails!.referredById!,
                              'USR',
                            ),
                            style: text.labelMedium,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (hasReferrer && referrals.isNotEmpty)
            const SizedBox(height: AppSizes.sm),
          if (referrals.isNotEmpty)
            AppInfoTile(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Borrowers Referred', style: text.labelMedium),
                  const SizedBox(height: AppSizes.sm),
                  ...referrals.indexed.map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(
                        bottom: entry.$1 == referrals.length - 1
                            ? 0
                            : AppSizes.sm,
                      ),
                      child: _ReferralRow(referral: entry.$2),
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

class _ReferralRow extends StatelessWidget {
  final ReferralItem referral;

  const _ReferralRow({required this.referral});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        AppNameCard(name: referral.customerName, width: 40, height: 40),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TextFormatter.titleCase(referral.customerName),
                style: text.bodyLarge,
              ),
              Text(
                TextFormatter.dummyId(referral.id, 'USR'),
                style: text.labelMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
