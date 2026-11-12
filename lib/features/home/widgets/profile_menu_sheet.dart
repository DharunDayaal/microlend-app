import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/helpers/dialog_helper.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

/// One row of the profile menu. [minimum] hides it from lower roles.
class ProfileMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final UserRole minimum;
  final VoidCallback onTap;

  const ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.minimum = UserRole.user,
  });
}

class ProfileMenuSheet extends StatelessWidget {
  final List<ProfileMenuItem> items;
  final Future<void> Function() onLogout;

  const ProfileMenuSheet({
    super.key,
    required this.items,
    required this.onLogout,
  });

  static Future<void> show(
    BuildContext context, {
    required List<ProfileMenuItem> items,
    required Future<void> Function() onLogout,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => ProfileMenuSheet(items: items, onLogout: onLogout),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final me = CurrentUser.instance;
    final user = me.user;

    // The role check lives here too, so a hidden item can't appear by mistake.
    final visible = items.where((i) => me.hasRole(i.minimum)).toList();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.darkRim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            AppGap.h16,

            // ----- who is signed in -----
            Row(
              children: [
                AppNameCard(name: user?.userName ?? '', width: 56, height: 56),
                AppGap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.userName ?? 'Signed out',
                        style: text.headlineSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user != null)
                        Text(
                          user.email.isNotEmpty
                              ? user.email
                              : PhoneFormatter.display(user.phoneNumber),
                          style: text.labelMedium?.copyWith(
                            color: AppColors.darkOnSurfaceMuted,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                AppGap.w8,
                AppChip(
                  label: me.role.label.toUpperCase(),
                  radius: AppSizes.radiusSm,
                  backgroundColor: me.isSuperAdmin
                      ? AppColors.warning.withAlpha(AppAlphas.badgeFill)
                      : AppColors.darkPrimary.withAlpha(AppAlphas.badgeFill),
                  textStyle: text.labelSmall?.copyWith(
                    color: me.isSuperAdmin
                        ? AppColors.warning
                        : AppColors.stepCurrentLabel,
                  ),
                ),
              ],
            ),
            AppGap.h16,
            const Divider(height: 1, color: AppColors.darkBorder),
            AppGap.h8,

            // ----- pages -----
            for (final item in visible)
              _MenuTile(
                item: item,
                onTap: () {
                  Navigator.of(context).pop(); // close first, then go
                  item.onTap();
                },
              ),

            AppGap.h8,
            const Divider(height: 1, color: AppColors.darkBorder),
            AppGap.h8,

            // ----- logout -----
            _MenuTile(
              item: ProfileMenuItem(
                icon: Icons.logout_rounded,
                title: 'Log out',
                subtitle: 'You will need to sign in again.',
                onTap: () {},
              ),
              danger: true,
              onTap: () async {
                final ok = await DialogHelper.confirm(
                  context,
                  title: 'Log out?',
                  message: 'You will need to sign in again.',
                  confirmText: 'Log out',
                );
                if (!ok || !context.mounted) return;
                Navigator.of(context).pop();
                await onLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final ProfileMenuItem item;
  final VoidCallback onTap;
  final bool danger;

  const _MenuTile({
    required this.item,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = danger ? AppColors.progressDanger : AppColors.darkOnSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (danger ? AppColors.dangerContainer : AppColors.darkBorder)
                    .withAlpha(AppAlphas.badgeFill),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(item.icon, color: color, size: AppSizes.iconMd - 2),
            ),
            AppGap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: text.bodyLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    item.subtitle,
                    style: text.labelMedium?.copyWith(
                      color: AppColors.darkOnSurfaceMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!danger)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.darkOnSurfaceMuted),
          ],
        ),
      ),
    );
  }
}