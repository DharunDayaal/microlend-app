import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

/// Card with an icon + title header and an optional trailing widget.
class AppSectionCard extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets? margin;

  const AppSectionCard({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    this.trailing,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      margin: margin,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor ?? AppColors.stepCurrentLabel),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSizes.sm),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppSizes.lg),
          child,
        ],
      ),
    );
  }
}

/// The darker rounded box used for values inside a section card.
class AppInfoTile extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppInfoTile({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.md),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: child,
    );
  }
}
