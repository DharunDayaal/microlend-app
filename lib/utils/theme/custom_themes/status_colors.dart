import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';

/// Access via: Theme.of(context).extension&lt;StatusColors&gt;()!
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Color paidBg, paidFg, paidBorder;
  final Color pendingBg, pendingFg, pendingBorder;
  final Color overdueBg, overdueFg, overdueBorder;
  final Color active, syncing, synced, offline;

  const StatusColors({
    required this.paidBg,
    required this.paidFg,
    required this.paidBorder,
    required this.pendingBg,
    required this.pendingFg,
    required this.pendingBorder,
    required this.overdueBg,
    required this.overdueFg,
    required this.overdueBorder,
    required this.active,
    required this.syncing,
    required this.synced,
    required this.offline,
  });

  static const dark = StatusColors(
    paidBg: AppColors.successContainer,
    paidFg: Colors.white,
    paidBorder: AppColors.successContainer,
    pendingBg: AppColors.warningContainer,
    pendingFg: Colors.white,
    pendingBorder: AppColors.warningContainer,
    overdueBg: AppColors.dangerContainer,
    overdueFg: Colors.white,
    overdueBorder: AppColors.dangerContainer,
    active: AppColors.active,
    syncing: AppColors.syncing,
    synced: AppColors.synced,
    offline: AppColors.offline,
  );

  static const light = StatusColors(
    paidBg: Color(0xFFD1FAE5),
    paidFg: Color(0xFF065F46),
    paidBorder: Color(0xFFA7F3D0),
    pendingBg: Color(0xFFFEF3C7),
    pendingFg: Color(0xFF92400E),
    pendingBorder: Color(0xFFFDE68A),
    overdueBg: Color(0xFFFEE2E2),
    overdueFg: Color(0xFF991B1B),
    overdueBorder: Color(0xFFFECACA),
    active: AppColors.active,
    syncing: AppColors.syncing,
    synced: AppColors.synced,
    offline: AppColors.offline,
  );

  @override
  StatusColors copyWith() => this;

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) => this;
}
