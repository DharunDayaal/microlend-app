import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_icon_button.dart';
import 'package:micro_lending_app/shared/widgets/auth_app_bar.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/design_system/constants/alphas.dart';
import 'package:micro_lending_app/shared/design_system/constants/assets.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AuthAppBar(title: context.l10n.authSelectLoginMethod),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSizes.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  spacing: AppSizes.xl,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      padding: const EdgeInsets.all(AppSizes.sm),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      ),
                      child: Image.asset(Assets.logo, fit: BoxFit.cover),
                    ),
                    Column(
                      spacing: AppSizes.lg,
                      children: [
                        Text(
                          context.l10n.authWelcomeBack,
                          style: textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          context.l10n.authSelectMethodSubtitle,
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    AppGap.w8,
                    LoginCard(
                      icon: Icons.email_outlined,
                      title: context.l10n.authEmailPassword,
                      subTitle: context.l10n.authEmailPasswordSubtitle,
                      onPressed: () => context.push(AppRoutes.loginWithEmail),
                      bgColor: AppColors.darkPrimary.withAlpha(
                        AppAlphas.badgeFill,
                      ),
                      iconColor: AppColors.darkOnSurface,
                    ),
                    LoginCard(
                      icon: Icons.phone_android_rounded,
                      title: context.l10n.authPhoneOtp,
                      subTitle: context.l10n.authPhoneOtpSubtitle,
                      onPressed: () => context.push(AppRoutes.loginWithPhone),
                      bgColor: AppColors.successContainer.withAlpha(
                        AppAlphas.badgeFill,
                      ),
                      iconColor: AppColors.synced,
                    ),
                    AppGap.h8,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: AppSizes.xl,
                      children: [
                        const Expanded(
                          child: Divider(
                            thickness: 1,
                            color: AppColors.darkRim,
                            height: 10,
                          ),
                        ),
                        Text(context.l10n.commonOr, style: textTheme.bodySmall),
                        const Expanded(
                          child: Divider(
                            thickness: 1,
                            color: AppColors.darkRim,
                            height: 10,
                          ),
                        ),
                      ],
                    ),
                    AppGap.h8,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 4,
                      children: [
                        Text(
                          context.l10n.authNoAccount,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge,
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.register),
                          child: Text(
                            context.l10n.authRegisterHere,
                            style: textTheme.bodyLarge?.copyWith(
                              color: AppColors.progressSuccess,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LoginCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;
  final VoidCallback onPressed;
  final Color bgColor;
  final Color iconColor;

  const LoginCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.onPressed,
    required this.bgColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // The whole card is the tap target; the arrow is a visual cue that
    // also works on its own.
    return Material(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusLg)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSizes.md,
            horizontal: AppSizes.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppSizes.radiusLg),
                  ),
                ),
                padding: EdgeInsets.all(AppSizes.md),
                child: Icon(icon, color: iconColor),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subTitle,
                      style: textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AppIconButton(
                icon: Icons.chevron_right,
                color: AppColors.darkOnSurface,
                onPressed: onPressed,
                backgroundColor: AppColors.darkBorder,
                iconSize: AppSizes.xl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
