import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_progress_bar.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';

// Shared by the card and its skeleton, so they are exactly the same size.
const double _titleRowHeight = 20;
const double _barHeight = 8;

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: child,
    );
  }
}

class RecoveryProgressCard extends StatelessWidget {
  final RecoveryProgress progress;
  const RecoveryProgressCard({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final hasOverdue = progress.overdue > 0;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _titleRowHeight,
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  size: AppSizes.iconMd - 4,
                  color: AppColors.darkOnSurface,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'Overall Recovery Target',
                    style: text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  '${progress.completedPercent}% Completed',
                  style: text.labelLarge?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          AppProgressBar.segmented(
            height: _barHeight,
            semanticsLabel: 'Overall recovery',
            segments: [
              ProgressSegment(value: progress.collectedFraction),
              if (hasOverdue)
                ProgressSegment(
                  value: progress.overdueFraction,
                  color: AppColors.progressWarning,
                ),
            ],
          ),
          if (hasOverdue) ...[
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.progressWarning,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                Text(
                  '${progress.overduePercent}% overdue • '
                  '${CurrencyFormatter.format(progress.overdue)}',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.progressWarning,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Same frame and row heights as [RecoveryProgressCard].
class RecoveryProgressCardSkeleton extends StatelessWidget {
  const RecoveryProgressCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: AppShimmer(
        // only layout widgets and SkeletonBox inside
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(
              height: _titleRowHeight,
              child: Row(
                children: [
                  SkeletonBox(width: 18, height: 18, circle: true),
                  SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SkeletonBox(width: 150, height: 12, radius: 4),
                    ),
                  ),
                  SizedBox(width: AppSizes.sm),
                  SkeletonBox(width: 90, height: 12, radius: 4),
                ],
              ),
            ),
            SizedBox(height: AppSizes.sm),
            SkeletonBox(
              width: double.infinity,
              height: _barHeight,
              radius: _barHeight / 2,
            ),
          ],
        ),
      ),
    );
  }
}
