import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/status_colors.dart';

enum ChipType { paid, pending, overdue, active, neutral }

class StatusChip extends StatelessWidget {
  final String label;
  final ChipType type;

  // Optional overrides, all passed through to AppChip
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final TextStyle? textStyle;
  final double radius;
  final EdgeInsetsGeometry? padding;

  const StatusChip({
    super.key,
    required this.label,
    required this.type,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.textStyle,
    this.radius = AppSizes.radiusFull,
    this.padding,
  });

  /// ACTIVE -> blue, PAID_OFF -> green, OVERDUE -> red, anything else -> grey
  factory StatusChip.fromLoanStatus(String status) {
    final type = switch (status) {
      'ACTIVE' => ChipType.active,
      'PAID_OFF' || 'PAID' => ChipType.paid,
      'PARTIAL' => ChipType.pending,
      'OVERDUE' => ChipType.overdue,
      _ => ChipType.neutral,
    };
    return StatusChip(
      label: TextFormatter.enumLabel(status).toUpperCase(),
      type: type,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.extension<StatusColors>()!;
    final scheme = theme.colorScheme;

    final (bg, fg, border) = switch (type) {
      ChipType.paid => (s.paidBg, s.paidFg, s.paidBorder),
      ChipType.pending => (s.pendingBg, s.pendingFg, s.pendingBorder),
      ChipType.overdue => (s.overdueBg, s.overdueFg, s.overdueBorder),
      ChipType.active => (s.active, Colors.white, s.active),
      ChipType.neutral => (
        scheme.outlineVariant.withAlpha(60),
        scheme.onSurfaceVariant,
        scheme.outlineVariant,
      ),
    };

    return AppChip(
      label: label,
      backgroundColor: backgroundColor ?? bg,
      foregroundColor: foregroundColor ?? fg,
      borderColor: borderColor ?? border,
      textStyle: textStyle,
      radius: radius,
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSizes.md - 2,
            vertical: AppSizes.xs,
          ),
    );
  }
}
