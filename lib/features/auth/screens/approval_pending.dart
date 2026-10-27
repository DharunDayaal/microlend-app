import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/auth_app_bar.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/assets.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';

class ApprovalPendingScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusXl);
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        AppSnackbar.info(
          context,
          "Account verification is required to proceed further",
        );
      },
      child: Scaffold(
        appBar: AuthAppBar(title: "Approval Pending"),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                physics: AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.approvalBase,
                              borderRadius: radius,
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: radius,
                                gradient: RadialGradient(
                                  center: Alignment.topLeft,
                                  radius: 2.4,
                                  colors: [
                                    AppColors.approvalGlowWarm.withAlpha(90),
                                    AppColors.approvalGlowWarm.withAlpha(0),
                                  ],
                                ),
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: radius,
                                  gradient: RadialGradient(
                                    center: Alignment.bottomRight,
                                    radius: 2.1,
                                    colors: [
                                      AppColors.approvalGlowIndigo.withAlpha(
                                        210,
                                      ),
                                      AppColors.approvalGlowIndigo.withAlpha(0),
                                    ],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSizes.lg),
                                  child: Column(
                                    spacing: AppSizes.lg,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: 110,
                                            height: 110,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF1E293B),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(24),
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(20),
                                            child: Image.asset(
                                              Assets.logo,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: -6,
                                            right: -6,
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: const BoxDecoration(
                                                color: AppColors.warning,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(12),
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.hourglass_bottom_rounded,
                                                size: 20,
                                                color: AppColors.darkBackground,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSizes.lg,
                                          horizontal: AppSizes.xl,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.warningContainer
                                              .withAlpha(40),
                                          borderRadius: BorderRadius.circular(
                                            AppSizes.radiusXl,
                                          ),
                                          border: Border.all(
                                            color: AppColors.progressWarning
                                                .withAlpha(100),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          "APPLICATION UNDER REVIEW • PENDING ADMIN APPROVAL",
                                          style: textTheme.labelLarge?.copyWith(
                                            color: AppColors.warning,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(
                                        "Approval in Progress",
                                        style: textTheme.headlineLarge,
                                      ),
                                      Text(
                                        "Your profile and lending parameters have been submitted. An administrator will review and approve your account soon.",
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        AppGap.h16,
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.darkRim.withAlpha(
                                AppAlphas.badgeFill,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(AppSizes.lg),
                              ),
                            ),
                            padding: EdgeInsets.all(AppSizes.lg),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.darkRim,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(AppSizes.sm),
                                    ),
                                  ),
                                  padding: EdgeInsets.all(AppSizes.sm),
                                  child: Icon(
                                    Icons.access_time_rounded,
                                    size: AppSizes.xl,
                                  ),
                                ),
                                AppGap.w16,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "What to expect next",
                                        style: textTheme.headlineMedium,
                                      ),
                                      AppGap.w8,
                                      Text(
                                        "Your profile is currently under review by the administrator. You will be notified once your account has been approved and activated.",
                                        style: textTheme.labelLarge?.copyWith(
                                          color: const Color(0xFF94A3B8),
                                        ),
                                      ),
                                      AppGap.h12,
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.darkBackground,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(AppSizes.sm),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(AppSizes.sm),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.timer_outlined,
                                              color: AppColors.progressWarning,
                                            ),
                                            AppGap.w16,
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "REVIEW TIMEFRAME",
                                                    style: textTheme.labelLarge,
                                                  ),
                                                  Text(
                                                    "Typical reiview time: 24-48 business hours",
                                                    style: textTheme.labelMedium
                                                        ?.copyWith(
                                                          color: AppColors
                                                              .progressWarning,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
