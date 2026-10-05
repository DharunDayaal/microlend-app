import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/auth_app_bar.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/assets.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AuthAppBar(title: 'Select Login Method'),
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
                        Text('Welcome back', style: textTheme.headlineMedium),
                        Text(
                          'Select your preferred sign in method to access you field ledger and daily collections.',
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    AppGap.w8,
                    LoginCard(
                      icon: Icons.email_outlined,
                      title: "Email & Password",
                      subTitle:
                          "Sign in using your registered email address...",
                      onPressed: () => context.push(AppRoutes.loginWithEmail),
                      bgColor: AppColors.darkPrimary.withAlpha(
                        AppAlphas.badgeFill,
                      ),
                      iconColor: AppColors.darkOnSurface,
                    ),
                    LoginCard(
                      icon: Icons.phone_android_rounded,
                      title: "Phone OTP verification",
                      subTitle: "Instant login via 6-digit OTP verification directly to the registered mobile number",
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
                        Text("OR", style: textTheme.bodySmall),
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
                          "Don't have an account?",
                          style: textTheme.bodyLarge,
                        ),
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.register),
                          child: Text(
                            "Register here",
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

    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusLg)),
      ),
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
    );
  }
}
