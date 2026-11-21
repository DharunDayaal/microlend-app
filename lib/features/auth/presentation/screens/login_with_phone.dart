import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_icon_button.dart';
import 'package:micro_lending_app/shared/widgets/app_otp_input.dart';
import 'package:micro_lending_app/shared/widgets/app_text_field.dart';
import 'package:micro_lending_app/shared/widgets/auth_app_bar.dart';
import 'package:micro_lending_app/features/auth/presentation/controllers/auth_actions.dart';
import 'package:micro_lending_app/features/auth/data/auth_providers.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/design_system/constants/alphas.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/device/device_utils.dart';
import 'package:micro_lending_app/core/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/shared/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/core/utils/validators.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';

class LoginWithPhoneScreen extends ConsumerStatefulWidget {
  const LoginWithPhoneScreen({super.key});

  @override
  ConsumerState<LoginWithPhoneScreen> createState() =>
      _LoginWithPhoneScreenState();
}

class _LoginWithPhoneScreenState extends ConsumerState<LoginWithPhoneScreen> {
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
      final response = await ref
          .read(authRepositoryProvider)
          .sendOtpCode(
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
      await ref
          .read(authRepositoryProvider)
          .sendOtpCode(
            phoneNumber: '+91${_phoneController.text.trim()}',
            purpose: "LOGIN",
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

  Future<void> _submit() async {
    if (_loading) return;
    if (_otp.text.length < 6) {
      setState(() => _otpError = context.l10n.authEnterComplete6);
      return;
    }
    DeviceUtils.hideKeyboard(context);
    setState(() => _loading = true);
    try {
      await ref
          .read(authActionsProvider)
          .loginWithPhone(
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

    final buttonText = _isOtpSent
        ? context.l10n.authVerifyContinue
        : context.l10n.authSendOtp;

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AuthAppBar(title: context.l10n.authOtpLogin),
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
                              context.l10n.authLoginWithOtp,
                              style: textTheme.headlineMedium,
                            ),
                            Text(
                              context.l10n.authOtpSubtitle,
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
                                label: context.l10n.authLoginWithEmail,
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
                            context.l10n.authRegisteredNumber,
                            style: textTheme.headlineSmall,
                            maxLines: 1,
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
                        context.l10n.otpResendIn(_secondsRemaining),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.darkOnSurfaceMuted,
                        ),
                      )
                    : TextButton(
                        onPressed: _loading ? null : _resendOtpCode,
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
          )
        : AppTextField(
            label: context.l10n.authPhoneNumber,
            hint: context.l10n.authEnterPhoneHint,
            prefixIcon: Icons.phone_android_rounded,
            prefixText: "+91",
            showValidIcon: true,
            controller: _phoneController,
            validator: (v) => context.validators.phone(v),
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.phone,
          );

    return child;
  }
}
