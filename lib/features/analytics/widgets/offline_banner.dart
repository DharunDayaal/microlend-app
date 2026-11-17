import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/data/services/analytics_service.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

String agoLabel(DateTime t) {
  final m = DateTime.now().difference(t).inMinutes;
  if (m < 1) return 'just now';
  if (m < 60) return '$m min ago';
  final h = m ~/ 60;
  return h < 24 ? '$h h ago' : '${h ~/ 24} d ago';
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AnalyticsStatus>(
      // if your notifier is still called `status`, use that name here
      valueListenable: AnalyticsService.connection,
      builder: (context, s, _) {
        if (!s.offline) return const SizedBox.shrink();
        final text = Theme.of(context).textTheme;
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.xs,
            AppSizes.lg,
            AppSizes.xs,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.warning.withAlpha(28),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.warning.withAlpha(80)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 18,
                color: AppColors.warning,
              ),
              AppGap.w8,
              Expanded(
                child: Text(
                  s.updatedAt == null
                      ? 'You are offline.'
                      : 'You are offline. Showing numbers from ${agoLabel(s.updatedAt!)}.',
                  style: text.labelMedium?.copyWith(color: AppColors.warning),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
