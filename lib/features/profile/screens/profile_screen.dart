import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/state_views.dart';
import 'package:micro_lending_app/data/models/profile_model.dart';
import 'package:micro_lending_app/data/services/auth_service.dart';
import 'package:micro_lending_app/features/profile/controller/profile_controller.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_cards.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_sheets.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_widgets.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/helpers/dialog_helper.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _c = ProfileController();
  final _dirty = <String>{}; // cards with unsaved edits
  String? _busyAdmin;

  @override
  void initState() {
    super.initState();
    _c.load();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _setDirty(String key, bool value) {
    final changed = value ? _dirty.add(key) : _dirty.remove(key);
    if (changed) setState(() {});
  }

  // ---------- actions ----------

  // Match these two to your AuthService signatures. The purpose for a number
  // that is not registered yet is VERIFY_PHONE_NUMBER.
  Future<void> _sendOtp(String phone) async {
    await AuthService.sendOtpCode(
      phoneNumber: phone,
      purpose: "VERIFY_PHONE_NUMBER",
    );
  }

  Future<void> _verifyOtp(String phone, String code) async {
    await AuthService.verifyOtpCode(
      phoneNumber: phone,
      otpCode: code,
      purpose: "VERIFY_PHONE_NUMBER",
    );
  }

  Future<void> _changePhone() async {
    final p = _c.profile.data;
    if (p == null) return;
    final done = await showProfileSheet<bool>(
      context,
      (_) => ChangePhoneSheet(
        currentPhone: p.phoneNumber,
        sendOtp: _sendOtp,
        verifyOtp: _verifyOtp,
        save: _c.changePhone,
      ),
    );
    if (done == true && mounted) {
      AppSnackbar.success(context, context.l10n.profPhoneUpdated);
    }
  }

  Future<void> _changePassword() async {
    final done = await showProfileSheet<bool>(
      context,
      (_) => ChangePasswordSheet(
        onSubmit: (current, next) =>
            _c.changePassword(current: current, next: next),
      ),
    );
    if (done == true && mounted) {
      AppSnackbar.success(context, context.l10n.profPasswordChanged);
    }
  }

  Future<void> _revokeOne(SessionInfo s) async {
    final ok = await DialogHelper.confirm(
      context,
      title: context.l10n.profSignOutDevice,
      message: context.l10n.profSignedInOn(
        DateFormatter.dateTime(s.createdAt, fallback: '--'),
      ),
      confirmText: context.l10n.profSignOut,
    );
    if (!ok || !mounted) return;
    final err = await _c.revokeSession(s.id);
    if (err != null && mounted) AppSnackbar.error(context, err);
  }

  Future<void> _revokeAll() async {
    final ok = await DialogHelper.confirm(
      context,
      title: context.l10n.profSignOutAllTitle,
      message: context.l10n.profSignOutAllMsg,
      confirmText: context.l10n.profSignOutAll,
    );
    if (!ok || !mounted) return;
    final err = await _c.revokeAllSessions();
    if (err != null && mounted) AppSnackbar.error(context, err);
  }

  Future<void> _decideAdmin(AdminAccount a, bool approve) async {
    final ok = await DialogHelper.confirm(
      context,
      title: approve
          ? context.l10n.profApproveTitle(a.userName)
          : context.l10n.manRejectTitle(a.userName),
      message: approve
          ? context.l10n.profApproveMsg
          : context.l10n.profRejectMsg,
      confirmText: approve ? context.l10n.manApprove : context.l10n.manReject,
    );
    if (!ok || !mounted) return;

    setState(() => _busyAdmin = a.id);
    final err = await _c.decideAdmin(a, approve: approve);
    if (!mounted) return;
    setState(() => _busyAdmin = null);
    if (err != null) {
      AppSnackbar.error(context, err);
    } else {
      AppSnackbar.success(
        context,
        approve
            ? context.l10n.profAdminApproved
            : context.l10n.profAdminRejected,
      );
    }
  }

  Future<void> _editLimits() async {
    final lim = _c.profile.data?.limits ?? ProfileLimits.fallback;
    final done = await showProfileSheet<bool>(
      context,
      (_) => EditLimitsSheet(limits: lim, onSave: _c.updateLimits),
    );
    if (done == true && mounted) {
      AppSnackbar.success(context, context.l10n.profLimitsUpdated);
    }
  }

  Future<void> _logout() async {
    final ok = await DialogHelper.confirm(
      context,
      title: context.l10n.menuLogOutConfirm,
      message: context.l10n.menuLogOutSub,
      confirmText: context.l10n.menuLogOut,
    );
    if (ok) await AuthService.logout();
  }

  Future<void> _confirmLeave() async {
    final leave = await DialogHelper.confirm(
      context,
      title: context.l10n.profDiscardChanges,
      message: context.l10n.profUnsavedEdits,
      confirmText: context.l10n.empDiscard,
      cancelText: context.l10n.empKeepEditing,
    );
    if (leave && mounted) {
      _dirty.clear();
      context.pop();
    }
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _dirty.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: AppIconButton(
            icon: Icons.arrow_back_ios,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(context.l10n.menuMyProfile),
        ),
        body: SafeArea(
          child: ListenableBuilder(listenable: _c, builder: (_, _) => _body()),
        ),
      ),
    );
  }

  Widget _body() {
    final pad = EdgeInsets.fromLTRB(
      AppSizes.lg,
      AppSizes.md,
      AppSizes.lg,
      AppSizes.bottomClearance,
    );
    final section = _c.profile;
    final p = section.data;

    if (p == null) {
      if (section.loading) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: pad,
          children: const [
            HeaderSkeleton(),
            AppGap.h16,
            ProfileCardSkeleton(),
            AppGap.h16,
            ProfileCardSkeleton(rows: 3),
            AppGap.h16,
            ProfileCardSkeleton(),
          ],
        );
      }
      return ErrorView(
        message: section.error ?? context.l10n.profLoadFailed,
        onRetry: _c.load,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _c.load(silent: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: pad,
        children: [
          HeaderCard(p: p),
          AppGap.h16,
          ContactCard(
            p: p,
            onSave: _c.saveContact,
            onChangePhone: _changePhone,
            onDirty: (v) => _setDirty('contact', v),
          ),
          AppGap.h16,
          StatsCard(c: _c),
          AppGap.h16,
          DefaultsCard(
            p: p,
            onSave: _c.saveDefaults,
            onDirty: (v) => _setDirty('defaults', v),
          ),
          AppGap.h16,
          SecurityCard(
            c: _c,
            onChangePassword: _changePassword,
            onRevokeOne: _revokeOne,
            onRevokeAll: _revokeAll,
          ),
          if (_c.isAdmin) ...[
            AppGap.h16,
            TeamCard(
              c: _c,
              onManageUsers: () {
                context.push(AppRoutes.manageUsers);
              },
            ),
          ],
          if (_c.isSuper) ...[
            AppGap.h16,
            SystemCard(
              c: _c,
              busyAdminId: _busyAdmin,
              onDecide: _decideAdmin,
              onAllAdmins: () {
                context.push(AppRoutes.manageAdmins);
              },
              onEditLimits: _editLimits,
            ),
          ],
          AppGap.h16,
          const AppInfoCard(),
          AppGap.h16,
          AppButton(
            label: context.l10n.menuLogOut,
            outlined: true,
            prefixIcon: Icons.logout_rounded,
            radius: AppSizes.md,
            onPressed: _logout,
          ),
        ],
      ),
    );
  }
}
