import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_step_field.dart';
import 'package:micro_lending_app/data/models/loan_terms_model.dart';
import 'package:micro_lending_app/data/models/managed_account.dart';
import 'package:micro_lending_app/data/models/profile_limits.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/data/services/management_service.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_cards.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_widgets.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/helpers/dialog_helper.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

class CreateEmployeeScreen extends StatefulWidget {
  const CreateEmployeeScreen({super.key});

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _fee = TextEditingController();
  final _interest = TextEditingController();
  final _months = TextEditingController();

  bool _showPass = false;
  bool _customize = false;
  bool _saving = false;

  String? _nameErr;
  String? _phoneErr;
  String? _emailErr;
  String? _passErr;
  String? _err;

  // SUPER_ADMIN only: which admin the employee works under
  List<ManagedAccount>? _admins;
  String? _adminsError;
  ManagedAccount? _admin;

  bool get _isSuper => CurrentUser.instance.isSuperAdmin;
  AdminUser? get _me => CurrentUser.instance.user;
  ProfileLimits get _lim => _me?.limits ?? ProfileLimits.fallback;

  // ---------- the defaults this employee would inherit ----------

  double get _baseFee =>
      (_isSuper ? _admin?.fee : null) ??
      _me?.defaultUpfrontFeePercentage ??
      LoanTerms.fallbackFeePercent;
  double get _baseInterest =>
      (_isSuper ? _admin?.interest : null) ??
      _me?.defaultInterestPercentage ??
      LoanTerms.fallbackInterestPercent;
  double get _baseMonths =>
      (_isSuper ? _admin?.months : null) ??
      _me?.defaultTotalMonths ??
      LoanTerms.fallbackMonths;

  @override
  void initState() {
    super.initState();
    _resetDefaults();
    if (_isSuper) _loadAdmins();
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _phone,
      _email,
      _pass,
      _confirm,
      _fee,
      _interest,
      _months,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _resetDefaults() {
    _fee.text = fmtNum(_baseFee);
    _interest.text = fmtNum(_baseInterest);
    _months.text = fmtNum(_baseMonths);
  }

  Future<void> _loadAdmins() async {
    setState(() => _adminsError = null);
    try {
      final page = await ManagementService.admins(status: 'active', limit: 100);
      if (mounted) setState(() => _admins = page.items);
    } on ApiException catch (e) {
      if (mounted) setState(() => _adminsError = e.message);
    }
  }

  Future<void> _pickAdmin() async {
    final list = _admins;
    if (list == null) return;
    final picked = await showModalBottomSheet<ManagedAccount>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        shrinkWrap: true,
        children: [
          Text('Works under', style: Theme.of(ctx).textTheme.headlineSmall),
          AppGap.h8,
          if (list.isEmpty) const Text('There are no active admins.'),
          for (final a in list)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: Text(a.displayName),
              subtitle: Text('${a.membersCount ?? 0} employees'),
              onTap: () => Navigator.of(ctx).pop(a),
            ),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _admin = picked;
      _err = null;
    });
    _resetDefaults(); // follow the chosen admin's defaults
  }

  // ---------- validation ----------

  double? _v(TextEditingController c) => double.tryParse(c.text.trim());

  String? _check(double? v, double min, double max, String label) {
    if (v == null) return 'Enter a number';
    if (v < min || v > max) {
      return '$label must be ${fmtNum(min)} to ${fmtNum(max)}';
    }
    if (((v * 10) - (v * 10).round()).abs() > 1e-9) {
      return 'One decimal place at most';
    }
    return null;
  }

  String? get _eFee => _check(_v(_fee), 0, _lim.maxFeePercent, 'Fee');
  String? get _eInterest =>
      _check(_v(_interest), 0, _lim.maxInterestPercent, 'Interest');
  String? get _eMonths =>
      _check(_v(_months), _lim.minMonths, _lim.maxMonths, 'Term');
  bool get _defaultsValid =>
      _eFee == null && _eInterest == null && _eMonths == null;

  String? _vName(String? v) {
    final s = (v ?? '').trim();
    if (s.length < 2) return 'Name needs at least 2 characters';
    if (!RegExp(r"^[\p{L} .'\-]+$", unicode: true).hasMatch(s)) {
      return "Use letters, spaces and . ' - only";
    }
    return null;
  }

  String? _vPhone(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'[^\d]'), '');
    return digits.length < 10 || digits.length > 15
        ? 'Enter a valid mobile number'
        : null;
  }

  String? _vEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null; // optional
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)
        ? null
        : 'Enter a valid email';
  }

  bool get _dirty =>
      !_saving &&
      (_name.text.isNotEmpty ||
          _phone.text.isNotEmpty ||
          _pass.text.isNotEmpty);

  String _generate() {
    const chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final r = math.Random.secure();
    return List.generate(10, (_) => chars[r.nextInt(chars.length)]).join();
  }

  // ---------- submit ----------

  Future<void> _submit() async {
    if (_saving || !(_form.currentState?.validate() ?? false)) return;
    if (_isSuper && _admin == null) {
      setState(() => _err = 'Choose the admin this employee works under.');
      return;
    }
    if (_customize && !_defaultsValid) {
      setState(() => _err = 'Fix the loan defaults first.');
      return;
    }

    // Defaults are sent only when changed. Otherwise the employee keeps
    // inheriting the admin's, including later changes.
    final fee = _customize ? _v(_fee)! : _baseFee;
    final interest = _customize ? _v(_interest)! : _baseInterest;
    final months = _customize ? _v(_months)! : _baseMonths;

    final body = <String, dynamic>{
      'user_name': _name.text.trim(),
      'phone_number': PhoneFormatter.toE164(_phone.text),
      if (_email.text.trim().isNotEmpty) 'email': _email.text.trim(),
      'password': _pass.text,
      if (_isSuper) 'admin_id': _admin!.id,
      'default_upfront_fee_percentage': fee,
      'default_interest_percentage': interest,
      'default_total_months': months,
    };

    setState(() {
      _saving = true;
      _err = _nameErr = _phoneErr = _emailErr = _passErr = null;
    });

    try {
      await ManagementService.createEmployee(body);
      if (!mounted) return;
      AppSnackbar.success(
        context,
        '${_name.text.trim()} was added. If they cannot sign in yet, approve them under Pending.',
      );
      context.pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      final l = e.message.toLowerCase();
      setState(() {
        if (e.isNetworkError) {
          _err =
              'No answer from the server. Check Manage users before trying again, '
              'in case the account was already created.';
        } else if (l.contains('phone')) {
          _phoneErr = e.message;
        } else if (l.contains('email')) {
          _emailErr = e.message;
        } else if (l.contains('password')) {
          _passErr = e.message;
        } else if (l.contains('name')) {
          _nameErr = e.message;
        } else {
          _err = e.message;
        }
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    if (!CurrentUser.instance.hasRole(UserRole.admin)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add employee')),
        body: const Center(child: Text("You don't have access to this view.")),
      );
    }

    final text = Theme.of(context).textTheme;
    final muted = text.labelMedium?.copyWith(
      color: AppColors.darkOnSurfaceMuted,
    );
    final money = CurrencyFormatter.format;

    final fee = (_customize ? _v(_fee) : null) ?? _baseFee;
    final interest = (_customize ? _v(_interest) : null) ?? _baseInterest;
    final months = (_customize ? _v(_months) : null) ?? _baseMonths;
    final weeks = LoanHelper.totalWeeksFromMonths(months);
    final b = LoanHelper.breakdown(
      principal: 10000,
      feePercent: fee,
      interestPercent: interest,
      totalWeeks: weeks,
    );

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await DialogHelper.confirm(
          context,
          title: 'Discard this employee?',
          message: 'You have details that are not saved.',
          confirmText: 'Discard',
          cancelText: 'Keep editing',
        );
        if (leave && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppIconButton(
            icon: Icons.arrow_back_ios,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text('Add employee'),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: AppButton(
                label: 'Create employee',
                prefixIcon: Icons.person_add_alt_1_outlined,
                radius: AppSizes.md,
                isLoading: _saving,
                onPressed: _submit,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.lg),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                if (_isSuper) ...[
                  ProfileCard(
                    icon: Icons.admin_panel_settings_outlined,
                    color: AppColors.warning,
                    title: 'Works under',
                    child: _admins == null && _adminsError == null
                        ? const Padding(
                            padding: EdgeInsets.all(AppSizes.sm),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : _adminsError != null
                        ? CardMessage(
                            message: _adminsError!,
                            onRetry: _loadAdmins,
                          )
                        : InkWell(
                            onTap: _pickAdmin,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            child: InfoRow(
                              icon: Icons.person_search_outlined,
                              label: 'Admin',
                              value: _admin?.displayName ?? 'Choose an admin',
                              trailing: const Icon(Icons.chevron_right_rounded),
                            ),
                          ),
                  ),
                  AppGap.h16,
                ],
                ProfileCard(
                  icon: Icons.badge_outlined,
                  color: AppColors.stepCurrentLabel,
                  title: 'Account',
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _name,
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        forceErrorText: _nameErr,
                        validator: _vName,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                        ),
                      ),
                      AppGap.h12,
                      TextFormField(
                        controller: _phone,
                        enabled: !_saving,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        forceErrorText: _phoneErr,
                        validator: _vPhone,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          helperText: 'They sign in with this number.',
                        ),
                      ),
                      AppGap.h12,
                      TextFormField(
                        controller: _email,
                        enabled: !_saving,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        forceErrorText: _emailErr,
                        validator: _vEmail,
                        decoration: const InputDecoration(
                          labelText: 'Email (optional)',
                        ),
                      ),
                    ],
                  ),
                ),
                AppGap.h16,
                ProfileCard(
                  icon: Icons.lock_outline,
                  color: AppColors.success,
                  title: 'Password',
                  trailing: TextButton.icon(
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                            final p = _generate();
                            _pass.text = p;
                            _confirm.text = p;
                            _showPass = true;
                          }),
                    icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
                    label: const Text('Generate'),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _pass,
                        enabled: !_saving,
                        obscureText: !_showPass,
                        forceErrorText: _passErr,
                        validator: (v) => (v ?? '').length < 8
                            ? 'Use at least 8 characters'
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            tooltip: _showPass ? 'Hide' : 'Show',
                            onPressed: () =>
                                setState(() => _showPass = !_showPass),
                            icon: Icon(
                              _showPass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                          ),
                        ),
                      ),
                      AppGap.h12,
                      TextFormField(
                        controller: _confirm,
                        enabled: !_saving,
                        obscureText: !_showPass,
                        validator: (v) =>
                            v == _pass.text ? null : 'Passwords do not match',
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                        ),
                      ),
                      AppGap.h8,
                      Text(
                        'Share this password with them. They can change it later from their profile.',
                        style: muted,
                      ),
                    ],
                  ),
                ),
                AppGap.h16,
                ProfileCard(
                  icon: Icons.tune_rounded,
                  color: AppColors.warning,
                  title: 'Loan defaults',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Customise for this employee'),
                        subtitle: Text(
                          _customize
                              ? 'These values are only for this employee.'
                              : 'Uses ${_isSuper ? (_admin?.displayName ?? 'the admin') : 'your'} '
                                    'defaults: fee ${fmtNum(_baseFee)}%, interest ${fmtNum(_baseInterest)}%, '
                                    '${fmtNum(_baseMonths)} months. Later changes apply to them too.',
                          style: muted,
                        ),
                        value: _customize,
                        onChanged: _saving
                            ? null
                            : (v) => setState(() {
                                _customize = v;
                                if (!v) _resetDefaults();
                              }),
                      ),
                      if (_customize) ...[
                        AppGap.h8,
                        AppStepField(
                          label: 'Upfront fee',
                          controller: _fee,
                          suffix: '%',
                          min: 0,
                          max: _lim.maxFeePercent,
                          error: _eFee,
                          enabled: !_saving,
                          onChanged: () => setState(() => _err = null),
                        ),
                        AppGap.h8,
                        AppStepField(
                          label: 'Interest',
                          controller: _interest,
                          suffix: '%',
                          min: 0,
                          max: _lim.maxInterestPercent,
                          error: _eInterest,
                          enabled: !_saving,
                          onChanged: () => setState(() => _err = null),
                        ),
                        AppGap.h8,
                        AppStepField(
                          label: 'Term',
                          controller: _months,
                          suffix: 'months',
                          min: _lim.minMonths,
                          max: _lim.maxMonths,
                          error: _eMonths,
                          enabled: !_saving,
                          onChanged: () => setState(() => _err = null),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _saving
                                ? null
                                : () => setState(_resetDefaults),
                            child: const Text('Reset to inherited values'),
                          ),
                        ),
                      ],
                      AppGap.h8,
                      Text(
                        'On a ${money(10000)} loan: fee ${money(b.upfrontFee)}, '
                        '${money(b.disbursedAmount)} handed over, ${money(b.totalPayable)} repayable, '
                        '${money(b.weeklyPayable)} a week for $weeks weeks.',
                        style: muted,
                      ),
                    ],
                  ),
                ),
                if (_err != null) ...[
                  AppGap.h12,
                  Text(
                    _err!,
                    style: text.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.bottomClearance),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
