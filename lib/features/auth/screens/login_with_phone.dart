import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_otp_input.dart';
import 'package:micro_lending_app/common/widgets/app_text_field.dart';
import 'package:micro_lending_app/common/widgets/auth_app_bar.dart';
import 'package:micro_lending_app/data/services/auth_service.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/device/device_utils.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/helpers/validators.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class LoginWithPhoneScreen extends StatefulWidget {
  const LoginWithPhoneScreen({super.key});

  @override
  State<LoginWithPhoneScreen> createState() => _LoginWithPhoneScreenState();
}

class _LoginWithPhoneScreenState extends State<LoginWithPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otp = TextEditingController();
  final _otpFocus = FocusNode();
  String? _otpError;
  bool _loading = false;
  bool _isOtpSent = false;
  Timer? _timer;
  int _secondsRemaining = 0;
  int _cooldown = 30;

  @override
  void dispose() {
    _timer?.cancel();
    _otpFocus.dispose();
    _phoneController.dispose();
    _otp.dispose();
    super.dispose();
  }

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
        purpose: "LOGIN",
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

  Future<void> _resendOtpCode() async {
    if (_secondsRemaining > 0 || _loading) return;
    setState(() => _loading = true);
    try {
      await AuthService.sendOtpCode(
        phoneNumber: '+91${_phoneController.text.trim()}',
        purpose: "RESEND_OTP",
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

  Future<void> _submit() async {
    if (_loading) return;
    if (_otp.text.length < 6) {
      setState(() => _otpError = "Please enter the complete 6-digit code");
      return;
    }
    DeviceUtils.hideKeyboard(context);
    setState(() => _loading = true);
    try {
      await AuthService.loginWithPhone(
        phoneNumber: '+91${_phoneController.text.trim()}',
        purpose: "LOGIN",
        optCode: _otp.text.trim(),
      );
    } on ApiException catch (e) {
      DeviceUtils.error();
      _otp.clear(); // so they can retype straight away
      if (mounted) setState(() => _otpError = e.message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _focusOtpSoon();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textTheme = Theme.of(context).textTheme;

    final buttonText = _isOtpSent ? "Verify & continue" : "Send OTP";

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AuthAppBar(title: "OTP Login"),
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: AppSizes.xs,
                          children: [
                            Text(
                              "Login with OTP",
                              style: textTheme.headlineMedium,
                            ),
                            Text(
                              "Enter 6 digit verification code sent via secure SMS to your registered mobile.",
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Form(
                          key: _formKey,
                          child: Column(
                            spacing: AppSizes.xl,
                            children: [
                              _phoneWidget(textTheme),
                              AppGap.h4,
                              AppButton(
                                label: buttonText,
                                onPressed: _loading
                                    ? null
                                    : () => _isOtpSent ? _submit() : _sendOtp(),
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
                                label: "Log in with email",
                                onPressed: () =>
                                    context.push(AppRoutes.loginWithEmail),
                                outlined: true,
                                icon: Icons.email_outlined,
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

  Widget _phoneWidget(TextTheme textTheme) {
    Widget child = _isOtpSent
        ? Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.all(
                    Radius.circular(AppSizes.radiusLg),
                  ),
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
                        color: AppColors.successContainer.withAlpha(
                          AppAlphas.badgeFill,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(AppSizes.radiusLg),
                        ),
                      ),
                      padding: EdgeInsets.all(AppSizes.md),
                      child: Icon(
                        Icons.phone_android_rounded,
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Registered number",
                            style: textTheme.headlineSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            PhoneFormatter.masked(
                              _phoneController.text.toString(),
                            ),
                            style: textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    AppIconButton(
                      icon: Icons.edit,
                      color: AppColors.darkOnSurface,
                      onPressed: () {
                        _timer?.cancel();
                        setState(() {
                          _isOtpSent = false;
                          _secondsRemaining = 0;
                          _otpError = null;
                        });
                        _otp.clear();
                      },
                      backgroundColor: AppColors.darkBorder,
                      iconSize: AppSizes.xl,
                    ),
                  ],
                ),
              ),
              AppGap.h16,
              AppOtpInput(
                controller: _otp,
                focusNode: _otpFocus,
                errorText: _otpError,
                enabled: !_loading,
                onChanged: (_) {
                  if (_otpError != null) setState(() => _otpError = null);
                },
                onCompleted: (_) => _submit(),
              ),
              AppGap.h16,
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
          )
        : AppTextField(
            label: "Phone Number",
            hint: "Enter your phone number...",
            prefixIcon: Icons.phone_android_rounded,
            prefixText: "+91",
            showValidIcon: true,
            controller: _phoneController,
            validator: (v) => AppValidators.phone(v),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.phone,
          );

    return child;
  }
}
