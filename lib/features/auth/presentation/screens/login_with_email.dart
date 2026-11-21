import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_text_field.dart';
import 'package:micro_lending_app/shared/widgets/auth_app_bar.dart';
import 'package:micro_lending_app/features/auth/presentation/controllers/auth_actions.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/design_system/constants/assets.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/device/device_utils.dart';
import 'package:micro_lending_app/shared/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/core/utils/validators.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';

class LoginWithEmailScreen extends ConsumerStatefulWidget {
  const LoginWithEmailScreen({super.key});

  @override
  ConsumerState<LoginWithEmailScreen> createState() =>
      _LoginWithEmailScreenState();
}

class _LoginWithEmailScreenState extends ConsumerState<LoginWithEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    DeviceUtils.hideKeyboard(context);
    setState(() => _loading = true);
    try {
      await ref
          .read(authActionsProvider)
          .loginWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    } on ApiException catch (e) {
      DeviceUtils.error();
      if (mounted) return AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AuthAppBar(title: context.l10n.authEmailLogin),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.lg),
                    child: Column(
                      spacing: AppSizes.xl,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Horizontal centering works now!
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.darkSurface,
                            borderRadius: BorderRadius.all(
                              Radius.circular(AppSizes.radiusLg),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.lightPrimary.withAlpha(40),
                                blurRadius: AppSizes.lg,
                                spreadRadius: AppSizes.sm,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSizes.sm),
                            child: Image.asset(Assets.logo, fit: BoxFit.cover),
                          ),
                        ),
                        Column(
                          spacing: AppSizes.xs,
                          children: [
                            Text(
                              context.l10n.authWelcomeBack,
                              style: textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              context.l10n.authSignInToAccess,
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            spacing: AppSizes.xl,
                            children: [
                              AppTextField(
                                label: context.l10n.authEmailAddress,
                                hint: context.l10n.authEnterEmailHint,
                                showValidIcon: true,
                                prefixIcon: Icons.alternate_email,
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                validator: (v) => context.validators.email(v),
                                textInputAction: TextInputAction.next,
                              ),
                              AppTextField(
                                label: context.l10n.authPassword,
                                hint: context.l10n.authEnterPasswordHint,
                                prefixIcon: Icons.lock,
                                isPassword: true,
                                controller: _passwordController,
                                validator: (v) => context.validators.required(
                                  v,
                                  context.l10n.authPassword,
                                ),
                                textInputAction: TextInputAction.done,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () =>
                                      context.push(AppRoutes.forgetPassword),
                                  child: Text(
                                    context.l10n.authForgotPassword,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.darkOnSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              AppGap.h4,
                              AppButton(
                                label: context.l10n.authSignIn,
                                onPressed: _submit,
                                isLoading: _loading,
                                suffixIcon: Icons.arrow_forward,
                              ),
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
                                  Flexible(
                                    child: Text(
                                      context.l10n.authOrQuickSwitch,
                                      style: textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(
                                      thickness: 1,
                                      color: AppColors.darkRim,
                                      height: 10,
                                    ),
                                  ),
                                ],
                              ),
                              AppButton(
                                label: context.l10n.authLoginWithPhone,
                                onPressed: () =>
                                    context.push(AppRoutes.loginWithPhone),
                                outlined: true,
                                icon: Icons.cell_tower,
                                iconColor: AppColors.success,
                              ),
                              AppGap.h4,
                              TextButton(
                                onPressed: () =>
                                    context.push(AppRoutes.register),
                                child: Text.rich(
                                  TextSpan(
                                    text: context.l10n.authNoAccountInline,
                                    style: textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: context.l10n.authCreateAccount,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
