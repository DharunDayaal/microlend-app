import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_section_cards.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

class AddressCard extends StatelessWidget {
  final String? street;
  final String? city;
  final String? district;

  const AddressCard({super.key, this.street, this.city, this.district});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final line1 = (street == null || street!.trim().isEmpty)
        ? 'No street on file'
        : street!.trim();
    final line2 = [city, district]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .join(', ');

    return AppSectionCard(
      icon: Icons.location_on_outlined,
      iconColor: AppColors.success,
      title: 'Address & Location',
      child: AppInfoTile(
        child: Row(
          children: [
            const Icon(Icons.home_outlined),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line1, style: text.bodyLarge),
                  if (line2.isNotEmpty) Text(line2, style: text.labelMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
