import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

const double kHeaderH = 28;
const double kRowH = 52;

// USER muted, ADMIN indigo, SUPER_ADMIN amber.
Color roleColor(UserRole r) => switch (r) {
  UserRole.superAdmin => AppColors.warning,
  UserRole.admin => AppColors.stepCurrentLabel,
  UserRole.user => AppColors.darkOnSurfaceMuted,
};

String fmtNum(double v) =>
    v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

class ProfileFrame extends StatelessWidget {
  final Widget child;
  const ProfileFrame({super.key, required this.child});

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

class ProfileCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget? trailing;
  final Widget child;

  const ProfileCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ProfileFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: kHeaderH,
            child: Row(
              children: [
                Icon(icon, size: AppSizes.iconMd, color: color),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    title,
                    style: text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          AppGap.h12,
          child,
        ],
      ),
    );
  }
}

class CardMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const CardMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.cloud_off_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.darkOnSurfaceMuted),
        AppGap.w12,
        Expanded(
          child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: kRowH),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Icon(icon, size: AppSizes.iconMd - 4),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                ),
                Text(
                  value,
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class MiniTile extends StatelessWidget {
  final String label;
  final String value;
  final String caption;
  final Color color;

  const MiniTile({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 84),
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.labelSmall?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: text.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            caption,
            style: text.labelMedium?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ---------- skeletons (only layout widgets and SkeletonBox inside the shimmer) ----------

class ProfileCardSkeleton extends StatelessWidget {
  final int rows;
  const ProfileCardSkeleton({super.key, this.rows = 2});

  @override
  Widget build(BuildContext context) {
    return ProfileFrame(
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: kHeaderH,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SkeletonBox(width: 130, height: 14, radius: 4),
              ),
            ),
            AppGap.h12,
            for (var i = 0; i < rows; i++)
              const SizedBox(
                height: kRowH,
                child: Row(
                  children: [
                    SkeletonBox(
                      width: 36,
                      height: 36,
                      radius: AppSizes.radiusMd,
                    ),
                    SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 90, height: 10, radius: 4),
                          SizedBox(height: 8),
                          SkeletonBox(width: 170, height: 14, radius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class HeaderSkeleton extends StatelessWidget {
  const HeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProfileFrame(
      child: AppShimmer(
        child: Row(
          children: [
            SkeletonBox(width: 76, height: 76, radius: 24),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 150, height: 18, radius: 4),
                  SizedBox(height: 10),
                  SkeletonBox(
                    width: 110,
                    height: 22,
                    radius: AppSizes.radiusSm,
                  ),
                  SizedBox(height: 10),
                  SkeletonBox(width: 120, height: 10, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TilesSkeleton extends StatelessWidget {
  const TilesSkeleton({super.key});

  Widget _tile() => Expanded(
    child: Container(
      height: 84,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: const AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 70, height: 10, radius: 4),
            SizedBox(height: 10),
            SkeletonBox(width: 90, height: 20, radius: 4),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(spacing: AppSizes.sm, children: [_tile(), _tile()]),
        const SizedBox(height: AppSizes.sm),
        Row(spacing: AppSizes.sm, children: [_tile(), _tile()]),
      ],
    );
  }
}
