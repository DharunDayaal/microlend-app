import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/data/models/profile_model.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_widgets.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/data/models/profile_limits.dart';

Future<T?> showProfileSheet<T>(BuildContext context, WidgetBuilder builder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusXl),
      ),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: builder(ctx),
      ),
    ),
  );
}

class _SheetTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SheetTitle(this.title, [this.subtitle]);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: text.headlineSmall),
        if (subtitle != null)
          Text(
            subtitle!,
            style: text.labelLarge?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
          ),
        AppGap.h16,
      ],
    );
  }
}

// =============== change password ===============

class ChangePasswordSheet extends StatefulWidget {
  final Future<String?> Function(String current, String next) onSubmit;
  const ChangePasswordSheet({super.key, required this.onSubmit});

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _show = false;
  bool _saving = false;
  String? _currentErr;
  String? _err;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _err = null;
      _currentErr = null;
    });

    final err = await widget.onSubmit(_current.text, _next.text);
    if (!mounted) return;

    if (err == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _saving = false;
      if (err.toLowerCase().contains('current')) {
        _currentErr = err;
      } else {
        _err = err;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    InputDecoration deco(String label) => InputDecoration(
      labelText: label,
      suffixIcon: IconButton(
        tooltip: _show ? 'Hide passwords' : 'Show passwords',
        onPressed: () => setState(() => _show = !_show),
        icon: Icon(
          _show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
      ),
    );

    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetTitle(
            'Change password',
            'Your other devices will be signed out.',
          ),
          TextFormField(
            controller: _current,
            enabled: !_saving,
            obscureText: !_show,
            forceErrorText: _currentErr,
            validator: (v) =>
                (v ?? '').isEmpty ? 'Enter your current password' : null,
            decoration: deco('Current password'),
          ),
          AppGap.h12,
          TextFormField(
            controller: _next,
            enabled: !_saving,
            obscureText: !_show,
            validator: (v) {
              final s = v ?? '';
              if (s.length < 8) return 'Use at least 8 characters';
              if (s == _current.text) return 'Choose a different password';
              return null;
            },
            decoration: deco('New password'),
          ),
          AppGap.h12,
          TextFormField(
            controller: _confirm,
            enabled: !_saving,
            obscureText: !_show,
            validator: (v) => v == _next.text ? null : 'Passwords do not match',
            decoration: deco('Confirm new password'),
          ),
          if (_err != null) ...[
            AppGap.h8,
            Text(
              _err!,
              style: text.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          AppGap.h16,
          AppButton(
            label: 'Update password',
            radius: AppSizes.md,
            isLoading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}

// =============== change phone: new number, OTP, save ===============

class ChangePhoneSheet extends StatefulWidget {
  final String currentPhone;
  final Future<void> Function(String phone) sendOtp;
  final Future<void> Function(String phone, String code) verifyOtp;
  final Future<String?> Function(String phone) save;

  const ChangePhoneSheet({
    super.key,
    required this.currentPhone,
    required this.sendOtp,
    required this.verifyOtp,
    required this.save,
  });

  @override
  State<ChangePhoneSheet> createState() => _ChangePhoneSheetState();
}

class _ChangePhoneSheetState extends State<ChangePhoneSheet> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  Timer? _timer;
  int _step = 0; // 0 = number, 1 = code
  int _cooldown = 0;
  bool _busy = false;
  String? _err;
  String _target = '';

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || _cooldown <= 1) {
        t.cancel();
        if (mounted) setState(() => _cooldown = 0);
        return;
      }
      setState(() => _cooldown--);
    });
  }

  Future<void> _send() async {
    final digits = _phone.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 10 || digits.length > 15) {
      setState(() => _err = 'Enter a valid mobile number');
      return;
    }
    final phone = PhoneFormatter.toE164(_phone.text);
    if (phone == widget.currentPhone) {
      setState(() => _err = 'That is already your phone number');
      return;
    }

    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await widget.sendOtp(phone);
      if (!mounted) return;
      _target = phone;
      _code.clear();
      setState(() => _step = 1);
      _startCooldown();
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    } catch (_) {
      if (mounted) setState(() => _err = 'Could not send the code. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    if (_code.text.length != 6) {
      setState(() => _err = 'Enter the 6-digit code');
      return;
    }
    setState(() {
      _busy = true;
      _err = null;
    });
    try {
      await widget.verifyOtp(_target, _code.text);
      final err = await widget.save(_target);
      if (!mounted) return;
      if (err == null) {
        Navigator.of(context).pop(true);
        return;
      }
      setState(() {
        _err = err;
        // a lapsed verification sends the user back to the code step
        if (err.toLowerCase().contains('verified')) _code.clear();
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _err = e.message);
    } catch (_) {
      if (mounted) setState(() => _err = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SheetTitle(
          'Change phone number',
          _step == 0
              ? 'We will send a code to the new number.'
              : 'Code sent to ${PhoneFormatter.display(_target)}',
        ),
        if (_step == 0)
          TextField(
            controller: _phone,
            enabled: !_busy,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d+ ]')),
            ],
            decoration: const InputDecoration(labelText: 'New phone number'),
          )
        else
          TextField(
            controller: _code,
            enabled: !_busy,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: '6-digit code',
              counterText: '',
            ),
          ),
        if (_err != null) ...[
          AppGap.h8,
          Text(
            _err!,
            style: text.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
        AppGap.h16,
        AppButton(
          label: _step == 0 ? 'Send code' : 'Verify and update',
          radius: AppSizes.md,
          isLoading: _busy,
          onPressed: _step == 0 ? _send : _verify,
        ),
        if (_step == 1) ...[
          AppGap.h8,
          Row(
            children: [
              TextButton(
                onPressed: _busy
                    ? null
                    : () => setState(() {
                        _step = 0;
                        _err = null;
                      }),
                child: const Text('Use another number'),
              ),
              const Spacer(),
              TextButton(
                onPressed: (_busy || _cooldown > 0) ? null : _send,
                child: Text(
                  _cooldown > 0 ? 'Resend in ${_cooldown}s' : 'Resend code',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// =============== edit loan limits (SUPER_ADMIN) ===============

class EditLimitsSheet extends StatefulWidget {
  final ProfileLimits limits;
  final Future<String?> Function(Map<String, double> changes) onSave;
  const EditLimitsSheet({
    super.key,
    required this.limits,
    required this.onSave,
  });

  @override
  State<EditLimitsSheet> createState() => _EditLimitsSheetState();
}

class _EditLimitsSheetState extends State<EditLimitsSheet> {
  final _form = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _c;
  late final Map<String, double> _old;
  bool _saving = false;
  String? _err;

  // key, label, decimals allowed, upper bound from the contract (null = none)
  static const _fields = [
    ('min_principal', 'Minimum principal (₹)', false, null),
    ('max_principal', 'Maximum principal (₹)', false, null),
    ('min_months', 'Minimum term (months)', true, null),
    ('max_months', 'Maximum term (months)', true, null),
    ('max_fee_percent', 'Maximum upfront fee (%)', true, 100.0),
    ('max_interest_percent', 'Maximum interest (%)', true, 1000.0),
  ];

  @override
  void initState() {
    super.initState();
    final l = widget.limits;
    _old = {
      'min_principal': l.minPrincipal,
      'max_principal': l.maxPrincipal,
      'min_months': l.minMonths,
      'max_months': l.maxMonths,
      'max_fee_percent': l.maxFeePercent,
      'max_interest_percent': l.maxInterestPercent,
    };
    _c = {
      for (final e in _old.entries)
        e.key: TextEditingController(text: fmtNum(e.value)),
    };
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  double? _v(String key) => double.tryParse(_c[key]!.text.trim());

  Future<void> _submit() async {
    if (_saving || !(_form.currentState?.validate() ?? false)) return;

    if (_v('min_principal')! > _v('max_principal')!) {
      setState(
        () => _err = 'Minimum principal cannot exceed maximum principal',
      );
      return;
    }
    if (_v('min_months')! > _v('max_months')!) {
      setState(() => _err = 'Minimum term cannot exceed maximum term');
      return;
    }

    final changes = <String, double>{
      for (final e in _old.entries)
        if (_v(e.key) != e.value) e.key: _v(e.key)!,
    };
    if (changes.isEmpty) {
      setState(() => _err = 'Change at least one limit');
      return;
    }

    setState(() {
      _saving = true;
      _err = null;
    });
    final err = await widget.onSave(changes);
    if (!mounted) return;
    if (err == null) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _saving = false;
        _err = err;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetTitle(
            'Loan limits',
            'Existing admin defaults are not rewritten. A tighter limit applies the next time defaults are saved.',
          ),
          for (final f in _fields) ...[
            TextFormField(
              controller: _c[f.$1],
              enabled: !_saving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(f.$3 ? r'^\d{0,7}\.?\d{0,2}' : r'^\d{0,9}'),
                ),
              ],
              validator: (v) {
                final n = double.tryParse((v ?? '').trim());
                if (n == null || n <= 0) {
                  return f.$1 == 'max_fee_percent' && n == 0
                      ? null
                      : 'Enter a positive number';
                }
                if (f.$3 && ((n * 10) - (n * 10).round()).abs() > 1e-9) {
                  return 'One decimal place at most';
                }
                if (f.$4 != null && n > f.$4!) {
                  return 'Must be ${fmtNum(f.$4!)} or less';
                }
                return null;
              },
              decoration: InputDecoration(labelText: f.$2),
            ),
            AppGap.h12,
          ],
          if (_err != null) ...[
            Text(
              _err!,
              style: text.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            AppGap.h12,
          ],
          AppButton(
            label: 'Save limits',
            radius: AppSizes.md,
            isLoading: _saving,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
