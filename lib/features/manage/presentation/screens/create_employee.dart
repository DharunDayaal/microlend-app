import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/shared/helpers/route_guard.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_icon_button.dart';
import 'package:micro_lending_app/shared/widgets/app_step_field.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan_terms.dart';
import 'package:micro_lending_app/features/manage/domain/entities/managed_account.dart';
import 'package:micro_lending_app/shared/session/models/profile_limits.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';
import 'package:micro_lending_app/features/manage/data/manage_providers.dart';
import 'package:micro_lending_app/features/profile/presentation/widgets/profile_widgets.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/shared/helpers/dialog_helper.dart';
import 'package:micro_lending_app/features/loans/domain/loan_helper.dart';
import 'package:micro_lending_app/shared/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

class CreateEmployeeScreen extends ConsumerStatefulWidget {
  const CreateEmployeeScreen({super.key});

  @override
  ConsumerState<CreateEmployeeScreen> createState() =>
      _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends ConsumerState<CreateEmployeeScreen> {
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

  bool get _isSuper => ref.read(sessionProvider).isSuperAdmin;
  AdminUser? get _me => ref.read(sessionProvider).user;
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
      final page = await ref
          .read(manageRepositoryProvider)
          .admins(status: 'active', limit: 100);
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
          Text(
            ctx.l10n.empWorksUnder,
            style: Theme.of(ctx).textTheme.headlineSmall,
          ),
          AppGap.h8,
          if (list.isEmpty) Text(ctx.l10n.empNoActiveAdmins),
          for (final a in list)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: Text(a.displayName),
              subtitle: Text(ctx.l10n.empEmployeesCount(a.membersCount ?? 0)),
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
    if (v == null) return context.l10n.empEnterNumber;
    if (v < min || v > max) {
      return context.l10n.empRangeError(label, fmtNum(min), fmtNum(max));
    }
    if (((v * 10) - (v * 10).round()).abs() > 1e-9) {
      return context.l10n.empOneDecimal;
    }
    return null;
  }

  String? get _eFee =>
      _check(_v(_fee), 0, _lim.maxFeePercent, context.l10n.empFee);
  String? get _eInterest => _check(
    _v(_interest),
    0,
    _lim.maxInterestPercent,
    context.l10n.empInterest,
  );
  String? get _eMonths =>
      _check(_v(_months), _lim.minMonths, _lim.maxMonths, context.l10n.empTerm);
  bool get _defaultsValid =>
      _eFee == null && _eInterest == null && _eMonths == null;

  String? _vName(String? v) {
    final s = (v ?? '').trim();
    if (s.length < 2) return context.l10n.empNameTooShort;
    if (!RegExp(r"^[\p{L} .'\-]+$", unicode: true).hasMatch(s)) {
      return context.l10n.empNameChars;
    }
    return null;
  }

  String? _vPhone(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'[^\d]'), '');
    return digits.length < 10 || digits.length > 15
        ? context.l10n.empInvalidMobile
        : null;
  }

  String? _vEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null; // optional
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)
        ? null
        : context.l10n.empInvalidEmail;
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
      setState(() => _err = context.l10n.empChooseAdmin);
      return;
    }
    if (_customize && !_defaultsValid) {
      setState(() => _err = context.l10n.empFixDefaults);
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
      await ref.read(manageRepositoryProvider).createEmployee(body);
      if (!mounted) return;
      AppSnackbar.success(context, context.l10n.empAdded(_name.text.trim()));
      context.popIfTop(true); // not a dialog that opened on top meanwhile
    } on ApiException catch (e) {
      if (!mounted) return;
      final l = e.message.toLowerCase();
      setState(() {
        if (e.isNetworkError) {
          _err = context.l10n.empNoServerAnswer;
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
    if (!ref.watch(sessionProvider).hasRole(UserRole.admin)) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.empAddEmployee)),
        body: Center(
          child: Text(context.l10n.anNoAccess, textAlign: TextAlign.center),
        ),
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
          title: context.l10n.empDiscardTitle,
          message: context.l10n.empDiscardMessage,
          confirmText: context.l10n.empDiscard,
          cancelText: context.l10n.empKeepEditing,
        );
        if (leave && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppIconButton(
            icon: Icons.arrow_back_ios,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(context.l10n.empAddEmployee),
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
                label: context.l10n.empCreate,
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
                    title: context.l10n.empWorksUnder,
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
                              label: context.l10n.empAdmin,
                              value:
                                  _admin?.displayName ??
                                  context.l10n.empChooseAnAdmin,
                              trailing: const Icon(Icons.chevron_right_rounded),
                            ),
                          ),
                  ),
                  AppGap.h16,
                ],
                ProfileCard(
                  icon: Icons.badge_outlined,
                  color: AppColors.stepCurrentLabel,
                  title: context.l10n.empAccount,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _name,
                        enabled: !_saving,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                        forceErrorText: _nameErr,
                        validator: _vName,
                        decoration: InputDecoration(
                          labelText: context.l10n.empFullName,
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
                        decoration: InputDecoration(
                          labelText: context.l10n.empPhoneNumber,
                          helperText: context.l10n.empPhoneHelper,
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
                        decoration: InputDecoration(
                          labelText: context.l10n.empEmailOptional,
                        ),
                      ),
                    ],
                  ),
                ),
                AppGap.h16,
                ProfileCard(
                  icon: Icons.lock_outline,
                  color: AppColors.success,
                  title: context.l10n.empPassword,
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
                    label: Text(context.l10n.empGenerate),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _pass,
                        enabled: !_saving,
                        obscureText: !_showPass,
                        forceErrorText: _passErr,
                        validator: (v) =>
                            (v ?? '').length < 8 ? context.l10n.empMin8 : null,
                        decoration: InputDecoration(
                          labelText: context.l10n.empPassword,
                          suffixIcon: IconButton(
                            tooltip: _showPass
                                ? context.l10n.empHide
                                : context.l10n.empShow,
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
                        validator: (v) => v == _pass.text
                            ? null
                            : context.l10n.empPasswordsMismatch,
                        decoration: InputDecoration(
                          labelText: context.l10n.empConfirmPassword,
                        ),
                      ),
                      AppGap.h8,
                      Text(context.l10n.empSharePassword, style: muted),
                    ],
                  ),
                ),
                AppGap.h16,
                ProfileCard(
                  icon: Icons.tune_rounded,
                  color: AppColors.warning,
                  title: context.l10n.empLoanDefaults,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        type: MaterialType.transparency,
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.l10n.empCustomise),
                          subtitle: Text(
                            _customize
                                ? context.l10n.empOnlyThisEmployee
                                : _isSuper
                                ? context.l10n.empUsesAdminDefaults(
                                    _admin?.displayName ??
                                        context.l10n.empTheAdmin,
                                    fmtNum(_baseFee),
                                    fmtNum(_baseInterest),
                                    fmtNum(_baseMonths),
                                  )
                                : context.l10n.empUsesYourDefaults(
                                    fmtNum(_baseFee),
                                    fmtNum(_baseInterest),
                                    fmtNum(_baseMonths),
                                  ),
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
                      ),
                      if (_customize) ...[
                        AppGap.h8,
                        AppStepField(
                          label: context.l10n.empUpfrontFee,
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
                          label: context.l10n.empInterest,
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
                          label: context.l10n.empTerm,
                          controller: _months,
                          suffix: context.l10n.empMonthsSuffix,
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
                            child: Text(context.l10n.empResetInherited),
                          ),
                        ),
                      ],
                      AppGap.h8,
                      Text(
                        context.l10n.empExample(
                          money(10000),
                          money(b.upfrontFee),
                          money(b.disbursedAmount),
                          money(b.totalPayable),
                          money(b.weeklyPayable),
                          weeks,
                        ),
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
