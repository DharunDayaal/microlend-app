import 'package:flutter/material.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';

/// Segmented rating bar. `level` filled segments out of `segments`.
/// The fill color follows the level: weak = red, fair = amber, good/strong = green.
class AppSecurityRating extends StatelessWidget {
  final int level;
  final int segments;
  final String? title;
  final bool showLevelLabel;
  final List<String>? levelLabels;
  final bool showCard;

  final double barHeight;
  final double gap;
  final EdgeInsetsGeometry padding;
  final double radius;

  final Color? backgroundColor;
  final Color? emptyColor;
  final List<Color>? levelColors;

  const AppSecurityRating({
    super.key,
    required this.level,
    this.segments = 4,
    this.title,
    this.showLevelLabel = false,
    this.levelLabels,
    this.showCard = true,
    this.barHeight = 8,
    this.gap = AppSizes.sm,
    this.padding = const EdgeInsets.all(AppSizes.lg),
    this.radius = AppSizes.radiusMd,
    this.backgroundColor,
    this.emptyColor,
    this.levelColors,
  }) : assert(segments > 0),
       assert(levelColors == null || levelColors.length == segments),
       assert(levelLabels == null || levelLabels.length == segments);

  Color _colorFor(int lvl) {
    if (levelColors != null) return levelColors![lvl - 1];
    final ratio = lvl / segments;
    if (ratio <= 0.25) return AppColors.progressDanger;
    if (ratio <= 0.5) return AppColors.progressWarning;
    return AppColors.progressSuccess;
  }

  String? _labelFor(BuildContext context, int lvl) {
    if (lvl <= 0) return null;
    final l = context.l10n;
    final defaults = [
      l.securityWeak,
      l.securityFair,
      l.securityGood,
      l.securityStrong,
    ];
    final labels = levelLabels ?? (segments == 4 ? defaults : null);
    return labels?[lvl - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final lvl = level.clamp(0, segments);
    final active = lvl == 0 ? scheme.outlineVariant : _colorFor(lvl);
    final empty = emptyColor ?? scheme.outlineVariant;
    final label = showLevelLabel ? _labelFor(context, lvl) : null;
    final title = this.title ?? context.l10n.securityRating;
    final levelOf = context.l10n.securityLevelOf(lvl, segments);

    final bars = Row(
      children: [
        for (var i = 0; i < segments; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: barHeight,
              decoration: BoxDecoration(
                color: i < lvl ? active : empty,
                borderRadius: BorderRadius.circular(barHeight / 2),
              ),
            ),
          ),
        ],
      ],
    );

    if (!showCard) {
      return Semantics(label: title, value: levelOf, child: bars);
    }

    return Semantics(
      label: title,
      value: label ?? levelOf,
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? scheme.surface,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    TextFormatter.titleCase(title),
                    style: theme.textTheme.labelLarge!.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                if (label != null)
                  Text(
                    label.toUpperCase(),
                    style: theme.textTheme.labelMedium!.copyWith(color: active),
                  ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            bars,
          ],
        ),
      ),
    );
  }
}
