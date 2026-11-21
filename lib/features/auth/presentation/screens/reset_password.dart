import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_otp_input.dart';
import 'package:micro_lending_app/shared/widgets/app_segmented_tabs.dart';
import 'package:micro_lending_app/shared/widgets/app_text_field.dart';
import 'package:micro_lending_app/shared/widgets/auth_app_bar.dart';
import 'package:micro_lending_app/features/auth/data/auth_providers.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/device/device_utils.dart';
import 'package:micro_lending_app/shared/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/core/utils/validators.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';

enum Type { email, phone }

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  Type _selectedType = Type.phone;
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otp = TextEditingController();
  final _otpFocus = FocusNode();
  String? _otpError;
  bool _loading = false;
  bool _isOtpSent = false;
  Timer? _timer;
  int _secondsRemaining = 0;
  int _cooldown = 30;

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = _cooldown);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        t.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _focusOtpSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isOtpSent) _otpFocus.requestFocus();
    });
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    DeviceUtils.hideKeyboard(context);
    setState(() => _loading = true);
    try {
      final response = await ref
          .read(authRepositoryProvider)
          .sendOtpCode(
            phoneNumber: '+91${_phoneController.text.trim()}',
            purpose: "RESET_PASSWORD",
          );
      if (!mounted) return;

      if (response.success) {
        setState(() {
          _isOtpSent = true;
          _otpError = null;
          _cooldown = 30;
        });
        AppSnackbar.success(context, response.message);
        _startTimer();
      } else {
        AppSnackbar.error(context, response.message);
      }
    } on ApiException catch (e) {
      DeviceUtils.error();
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _focusOtpSoon();
      }
    }
  }

  Future<void> _verifyOtp() async {
    DeviceUtils.hideKeyboard(context);
    setState(() => _loading = true);
    if (_otp.text.trim().length < 6) {
      setState(() => _otpError = context.l10n.authEnterComplete6);
      return;
    }
    try {
      final response = await ref
          .read(authRepositoryProvider)
          .verifyOtpCode(
            phoneNumber: '+91${_phoneController.text.trim()}',
            otpCode: _otp.text.trim(),
            purpose: "RESET_PASSWORD",
          );
      if (!mounted) return;

      if (response.success) {
        setState(() {
          _isOtpSent = true;
          _otpError = null;
          _cooldown = 30;
        });
        AppSnackbar.success(context, response.message);
      } else {
        AppSnackbar.error(context, response.message);
      }
    } on ApiException catch (e) {
      DeviceUtils.error();
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _focusOtpSoon();
      }
    }
  }

  Future<void> _resendOtpCode() async {
    if (_secondsRemaining > 0 || _loading) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .sendOtpCode(
            phoneNumber: '+91${_phoneController.text.trim()}',
            purpose: "RESET_PASSWORD",
          );
      if (!mounted) return;

      AppSnackbar.success(context, context.l10n.authNewCodeSent);
      _otp.clear();
      setState(() {
        _cooldown += 30;
        _otpError = null;
      });
      _startTimer();
    } on ApiException catch (e) {
      DeviceUtils.error();
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _focusOtpSoon();
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    DeviceUtils.hideKeyboard(context);
    setState(() => _loading = true);
    try {
      final response = await ref
          .read(authRepositoryProvider)
          .resetPassword(
            "+91${_phoneController.text.trim()}",
            _emailController.text.trim(),
            newPassword: _newPasswordController.text.trim(),
          );

      if (response.success) {
        if (mounted) {
          AppSnackbar.success(context, response.message);

          context.pushReplacement(AppRoutes.login);
        }
      }
    } on ApiException catch (e) {
      DeviceUtils.error();
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AuthAppBar(title: context.l10n.resetTitle),
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
                    padding: EdgeInsetsGeometry.all(AppSizes.lg),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: AppSizes.xl,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              alignment: Alignment.center,
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
                              child: const Icon(
                                Icons.lock_reset_rounded,
                                size: 44,
                                color: AppColors.darkOnSurface,
                              ),
                            ),
                            Positioned(
                              bottom: -6,
                              right: -6,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.verified_user_rounded,
                                  size: 18,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          spacing: AppSizes.xs,
                          children: [
                            Text(
                              context.l10n.resetHeading,
                              style: textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              context.l10n.resetSubtitle,
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        AppSegmentedTabs<Type>(
                          tabs: [
                            SegmentTab(
                              value: Type.email,
                              label: context.l10n.authEmailAddress,
                            ),
                            SegmentTab(
                              value: Type.phone,
                              label: context.l10n.authPhoneNumber,
                            ),
                          ],
                          selected: _selectedType,
                          onChanged: (t) {
                            setState(() => _selectedType = t);
                          },
                        ),
                        _formContainer(textTheme),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.login),
                          child: Text.rich(
                            TextSpan(
                              text: context.l10n.resetRememberPassword,
                              style: textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: context.l10n.resetBackToLogin,
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
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _formContainer(TextTheme textTheme) {
    final String label = _selectedType == Type.email
        ? context.l10n.resetRegisteredEmail
        : context.l10n.resetRegisteredPhone;
    final IconData prefixIcon = _selectedType == Type.email
        ? Icons.alternate_email_rounded
        : Icons.phone_android_rounded;
    final String? prefixText = _selectedType == Type.phone ? "+91" : null;
    final String placeholder = _selectedType == Type.email
        ? context.l10n.resetEnterEmail
        : context.l10n.resetEnterPhone;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusMd)),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.md,
        horizontal: AppSizes.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          spacing: AppSizes.md,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppTextField(
              label: label,
              prefixIcon: prefixIcon,
              prefixText: prefixText,
              hint: placeholder,
              controller: _selectedType == Type.email
                  ? _emailController
                  : _phoneController,
              enabled: !_isOtpSent && !_loading,
              validator: (v) {
                if (_selectedType == Type.email) {
                  return context.validators.email(v);
                }
                return context.validators.phone(v);
              },
            ),
            if (_isOtpSent) ...[
              AppOtpInput(
                controller: _otp,
                focusNode: _otpFocus,
                errorText: _otpError,
                enabled: !_loading,
                onChanged: (_) {
                  if (_otpError != null) setState(() => _otpError = null);
                },
                onCompleted: (_) => _verifyOtp(),
              ),

              AppTextField(
                label: context.l10n.resetNewPassword,
                prefixIcon: Icons.lock_outline_rounded,
                hint: context.l10n.resetNewPasswordHint,
                controller: _newPasswordController,
                isPassword: true,
                enabled: !_loading,
                validator: (v) => context.validators.password(v),
              ),
              AppTextField(
                label: context.l10n.resetConfirmPassword,
                prefixIcon: Icons.lock_reset_rounded,
                hint: context.l10n.resetConfirmHint,
                controller: _confirmPasswordController,
                isPassword: true,
                enabled: !_loading,
                validator: (v) {
                  if (v != _newPasswordController.text) {
                    return context.l10n.resetPasswordsMustMatch;
                  }
                  return context.validators.required(
                    v,
                    context.l10n.valFieldConfirmPassword,
                  );
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _secondsRemaining > 0
                    ? Text(
                        context.l10n.otpResendIn(_secondsRemaining),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.darkOnSurfaceMuted,
                        ),
                      )
                    : TextButton(
                        onPressed: _loading ? null : _resendOtpCode,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          context.l10n.otpResend,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
            AppGap.h16,
            AppButton(
              label: _isOtpSent
                  ? context.l10n.resetUpdatePassword
                  : context.l10n.resetGetCode,
              isLoading: _loading,
              suffixIcon: _isOtpSent
                  ? Icons.check_circle_outline
                  : Icons.arrow_forward_rounded,
              onPressed: _loading
                  ? null
                  : () {
                      if (_isOtpSent) {
                        _resetPassword();
                      } else {
                        _sendOtp();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
