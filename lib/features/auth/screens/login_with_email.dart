import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_text_field.dart';
import 'package:micro_lending_app/common/widgets/auth_app_bar.dart';
import 'package:micro_lending_app/data/services/auth_service.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/assets.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/device/device_utils.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/helpers/validators.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class LoginWithEmailScreen extends StatefulWidget {
  const LoginWithEmailScreen({super.key});

  @override
  State<LoginWithEmailScreen> createState() => _LoginWithEmailScreenState();
}

class _LoginWithEmailScreenState extends State<LoginWithEmailScreen> {
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
      await AuthService.loginWithEmail(
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
      appBar: AuthAppBar(title: "Email Login"),
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
                              "Welcome back",
                              style: textTheme.headlineMedium,
                            ),
                            Text(
                              "Sign in to access your account.",
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            spacing: AppSizes.xl,
                            children: [
                              AppTextField(
                                label: "Email Address",
                                hint: "Enter your email...",
                                showValidIcon: true,
                                prefixIcon: Icons.alternate_email,
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                validator: (v) =>
                                    AppValidators.required(v, 'Email') ??
                                    AppValidators.email(v),
                                textInputAction: TextInputAction.next,
                              ),
                              AppTextField(
                                label: "Password",
                                hint: "Enter your password...",
                                prefixIcon: Icons.lock,
                                isPassword: true,
                                controller: _passwordController,
                                validator: (v) =>
                                    AppValidators.password(v, minLength: 6),
                                textInputAction: TextInputAction.done,
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () =>
                                      context.push(AppRoutes.forgetPassword),
                                  child: Text(
                                    "Forgot password?",
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: AppColors.darkOnSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              AppGap.h4,
                              AppButton(
                                label: "SIGN IN",
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
                                  Text(
                                    "OR QUICK SWITCH",
                                    style: textTheme.bodySmall,
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
                                label: "Log in with phone number",
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
                                    text: "Don't have an account? ",
                                    style: textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: "Create account",
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
