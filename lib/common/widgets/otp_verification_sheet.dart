import 'dart:async';

import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_otp_input.dart';
import 'package:micro_lending_app/data/services/auth_service.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/device/device_utils.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

/// Bottom sheet that verifies an OTP that was already sent.
/// Returns true when the code was verified, false if the user closed it.
class OtpVerificationSheet extends StatefulWidget {
  final String phoneNumber; // +91XXXXXXXXXX
  final String purpose;
  final int length;
  final int initialCooldown;

  const OtpVerificationSheet({
    super.key,
    required this.phoneNumber,
    required this.purpose,
    this.length = 6,
    this.initialCooldown = 30,
  });

  static Future<bool> show(
    BuildContext context, {
    required String phoneNumber,
    required String purpose,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true, // lets the sheet rise above the keyboard
      enableDrag: false, // can't be swiped away mid-request
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) =>
          OtpVerificationSheet(phoneNumber: phoneNumber, purpose: purpose),
    );
    return result ?? false;
  }

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  final _otp = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 0;
  int _cooldown = 30; // grows by 30s on every resend
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cooldown = widget.initialCooldown;
    _secondsRemaining = _cooldown; // the code was sent just before opening
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otp.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
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

  Future<void> _verify(String code) async {
    if (_loading) return;
    if (code.length != widget.length) {
      setState(() => _error = 'Enter the complete ${widget.length}-digit code');
      return;
    }

    DeviceUtils.hideKeyboard(context);
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.verifyOtpCode(
        phoneNumber: widget.phoneNumber,
        purpose: widget.purpose,
        otpCode: code,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      DeviceUtils.error();
      _otp.clear(); // so they can retype straight away
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    if (_secondsRemaining > 0 || _loading) return;
    setState(() => _loading = true);

    try {
      final res = await AuthService.sendOtpCode(
        phoneNumber: widget.phoneNumber,
        purpose: widget.purpose,
      );
      if (!mounted) return;

      if (!res.success) {
        setState(() => _error = res.message);
        return;
      }

      _otp.clear();
      setState(() {
        _error = null;
        _cooldown += 30;
        _secondsRemaining = _cooldown;
      });
      _startTimer();
      AppSnackbar.success(context, 'A new code has been sent.');
    } on ApiException catch (e) {
      DeviceUtils.error();
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_loading, // back button is blocked while verifying
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSizes.lg,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Verify phone number',
                        style: textTheme.headlineSmall,
                      ),
                    ),
                    AppIconButton(
                      icon: Icons.close,
                      color: AppColors.darkOnSurface,
                      onPressed: () => _loading
                          ? null
                          : () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                Text(
                  'Enter the ${widget.length}-digit code sent to '
                  '${PhoneFormatter.masked(widget.phoneNumber)}.',
                  style: textTheme.bodyMedium,
                ),
                AppOtpInput(
                  controller: _otp,
                  length: widget.length,
                  autofocus: true,
                  errorText: _error,
                  enabled: !_loading,
                  filledColor: AppColors.darkBorder,
                  focusedColor: AppColors.darkRim,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  onCompleted: _verify,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _secondsRemaining > 0
                      ? Text(
                          'Resend code in ${_secondsRemaining}s',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.darkOnSurfaceMuted,
                          ),
                        )
                      : TextButton(
                          onPressed: _loading ? null : _resend,
                          child: Text(
                            'Resend OTP',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                AppButton(
                  label: 'Continue',
                  suffixIcon: Icons.arrow_forward,
                  isLoading: _loading,
                  onPressed: () => _verify(_otp.text.trim()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
