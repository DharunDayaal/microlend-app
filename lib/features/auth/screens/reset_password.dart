import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_otp_input.dart';
import 'package:micro_lending_app/common/widgets/app_segmented_tabs.dart';
import 'package:micro_lending_app/common/widgets/app_text_field.dart';
import 'package:micro_lending_app/common/widgets/auth_app_bar.dart';
import 'package:micro_lending_app/data/services/auth_service.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/device/device_utils.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/helpers/validators.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

enum Type { email, phone }

class ResetPasswordScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
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
      final response = await AuthService.sendOtpCode(
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
      setState(() => _otpError = "Please enter the complete 6-digit code");
      return;
    }
    try {
      final response = await AuthService.verifyOtpCode(
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
      await AuthService.sendOtpCode(
        phoneNumber: '+91${_phoneController.text.trim()}',
        purpose: "RESET_PASSWORD",
      );
      if (!mounted) return;

      AppSnackbar.success(context, "A new verification code has been sent.");
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
      final response = await AuthService.resetPassword(
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
      appBar: AuthAppBar(title: "Password Reset"),
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
                              "Reset your passsword",
                              style: textTheme.headlineMedium,
                            ),
                            Text(
                              "Verify your registered email or phone number to create a secure new password for your account.",
                              style: textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        AppSegmentedTabs<Type>(
                          tabs: [
                            SegmentTab(
                              value: Type.email,
                              label: "Email Address",
                            ),
                            SegmentTab(
                              value: Type.phone,
                              label: "Phone Number",
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
                              text: "Remember your Password? ",
                              style: textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: "Back to login",
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
        ? "Registered email address"
        : "Registered phone number";
    final IconData prefixIcon = _selectedType == Type.email
        ? Icons.alternate_email_rounded
        : Icons.phone_android_rounded;
    final String? prefixText = _selectedType == Type.phone ? "+91" : null;
    final String placeholder = _selectedType == Type.email
        ? "Enter your email address"
        : "Enter your phone number";

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
                  return AppValidators.email(v);
                }
                return AppValidators.phone(v);
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
                label: "New Password",
                prefixIcon: Icons.lock_outline_rounded,
                hint: "Enter your strong new password",
                controller: _newPasswordController,
                isPassword: true,
                enabled: !_loading,
                validator: (v) => AppValidators.password(v),
              ),
              AppTextField(
                label: "Confirm New Password",
                prefixIcon: Icons.lock_reset_rounded,
                hint: "Re-type your password to confirm",
                controller: _confirmPasswordController,
                isPassword: true,
                enabled: !_loading,
                validator: (v) {
                  if (v != _newPasswordController.text) {
                    return "Passwords must match exactly";
                  }
                  return AppValidators.required(v, "Confirm Password");
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: _secondsRemaining > 0
                    ? Text(
                        "Resend code in ${_secondsRemaining}s",
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
                          "Resend OTP",
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
              label: _isOtpSent ? "Update Password" : "Get Verification Code",
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
