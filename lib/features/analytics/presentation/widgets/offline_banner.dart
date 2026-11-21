import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/features/analytics/domain/entities/analytics_status.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/features/analytics/data/analytics_providers.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';

String agoLabel(BuildContext context, DateTime t) => agoText(context, t);

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<AnalyticsStatus>(
      // if your notifier is still called `status`, use that name here
      valueListenable: ref.read(analyticsRepositoryProvider).connection,
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
                      ? context.l10n.offlineNoData
                      : context.l10n.offlineShowingFrom(
                          agoLabel(context, s.updatedAt!),
                        ),
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
