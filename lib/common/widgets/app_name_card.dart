import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';

class AppNameCard extends StatelessWidget {
  final String name;
  final double width;
  final double height;
  final Color textColor;
  final Color backgroundColor;
  final double radius;

  const AppNameCard({
    super.key,
    required this.name,
    this.width = 48,
    this.height = 48,
    this.textColor = AppColors.darkOnSurface,
    this.backgroundColor = AppColors.darkRim,
    this.radius = AppSizes.radiusLg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            TextFormatter.initials(name),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
