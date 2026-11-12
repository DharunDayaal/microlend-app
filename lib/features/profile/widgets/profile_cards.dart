import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_progress_bar.dart';
import 'package:micro_lending_app/common/widgets/app_status_chip.dart';
import 'package:micro_lending_app/common/widgets/app_step_field.dart';
import 'package:micro_lending_app/data/models/profile_model.dart';
import 'package:micro_lending_app/features/profile/controller/profile_controller.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_widgets.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';

// =============== 1. header ===============

class HeaderCard extends StatelessWidget {
  final UserProfile p;
  const HeaderCard({super.key, required this.p});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = roleColor(p.role);
    final pending = !p.isVerified;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withAlpha(AppAlphas.watermark),
            AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: color.withAlpha(AppAlphas.borderTint)),
      ),
      child: Row(
        children: [
          _Ring(name: p.userName, color: color),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.userName,
                  style: text.headlineSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: AppSizes.sm,
                  runSpacing: AppSizes.xs,
                  children: [
                    AppChip(
                      label: p.role.label.toUpperCase(),
                      radius: AppSizes.radiusSm,
                      backgroundColor: color.withAlpha(AppAlphas.badgeFill),
                      textStyle: text.labelSmall?.copyWith(color: color),
                    ),
                    AppChip(
                      label: !p.isActive
                          ? 'INACTIVE'
                          : pending
                              ? 'AWAITING APPROVAL'
                              : 'VERIFIED',
                      radius: AppSizes.radiusSm,
                      backgroundColor: (pending || !p.isActive
                              ? AppColors.warning
                              : AppColors.successContainer)
                          .withAlpha(AppAlphas.badgeFill),
                      leading: Icon(
                        pending || !p.isActive
                            ? Icons.hourglass_top_rounded
                            : Icons.verified_rounded,
                        size: 12,
                        color: pending || !p.isActive
                            ? AppColors.warning
                            : AppColors.progressSuccess,
                      ),
                      textStyle: text.labelSmall?.copyWith(
                        color: pending || !p.isActive
                            ? AppColors.warning
                            : AppColors.progressSuccess,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Member since ${DateFormatter.date(p.createdAt)}',
                  style: text.labelMedium?.copyWith(color: AppColors.darkOnSurfaceMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final String name;
  final Color color;
  const _Ring({required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withAlpha(90)],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.circular(23),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AppNameCard(name: name, width: 64, height: 64),
        ),
      ),
    );
  }
}

// =============== 2. contact (inline edit) ===============

class ContactCard extends StatefulWidget {
  final UserProfile p;
  final Future<String?> Function({String? name, String? email}) onSave;
  final VoidCallback onChangePhone;
  final ValueChanged<bool> onDirty;

  const ContactCard({
    super.key,
    required this.p,
    required this.onSave,
    required this.onChangePhone,
    required this.onDirty,
  });

  @override
  State<ContactCard> createState() => _ContactCardState();
}

class _ContactCardState extends State<ContactCard> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  bool _editing = false;
  bool _saving = false;
  String? _nameErr;
  String? _emailErr;
  String? _err;

  UserProfile get p => widget.p;

  String get _nameNow => _name.text.trim();
  String get _emailNow => _email.text.trim();
  bool get _changed =>
      _nameNow != p.userName || (_emailNow.isNotEmpty && _emailNow != p.email);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  void _touch() {
    setState(() {
      _nameErr = null;
      _emailErr = null;
      _err = null;
    });
    widget.onDirty(_editing && _changed);
  }

  void _start() {
    _name.text = p.userName;
    _email.text = p.email;
    setState(() {
      _editing = true;
      _nameErr = _emailErr = _err = null;
    });
  }

  void _cancel() {
    setState(() => _editing = false);
    widget.onDirty(false);
  }

  String? _vName(String? v) {
    final s = (v ?? '').trim();
    if (s.length < 2) return 'Name needs at least 2 characters';
    if (!RegExp(r"^[\p{L} .'\-]+$", unicode: true).hasMatch(s)) {
      return "Use letters, spaces and . ' - only";
    }
    return null;
  }

  String? _vEmail(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)
        ? null
        : 'Enter a valid email';
  }

  Future<void> _save() async {
    if (_saving || !(_form.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    // send only what changed
    final err = await widget.onSave(
      name: _nameNow != p.userName ? _nameNow : null,
      email: (_emailNow.isNotEmpty && _emailNow != p.email) ? _emailNow : null,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (err == null) {
      setState(() => _editing = false);
      widget.onDirty(false);
      AppSnackbar.success(context, 'Profile updated.');
      return;
    }
    final l = err.toLowerCase();
    setState(() {
      if (l.contains('email')) {
        _emailErr = err;
      } else if (l.contains('name')) {
        _nameErr = err;
      } else {
        _err = err;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ProfileCard(
      icon: Icons.badge_outlined,
      color: AppColors.stepCurrentLabel,
      title: 'Contact',
      trailing: _editing
          ? null
          : IconButton(
              tooltip: 'Edit name and email',
              onPressed: _start,
              icon: const Icon(Icons.edit_outlined, size: 20),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_editing)
            Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    forceErrorText: _nameErr,
                    validator: _vName,
                    onChanged: (_) => _touch(),
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  AppGap.h12,
                  TextFormField(
                    controller: _email,
                    enabled: !_saving,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    forceErrorText: _emailErr,
                    validator: _vEmail,
                    onChanged: (_) => _touch(),
                    decoration: const InputDecoration(labelText: 'Email'),
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
                  AppGap.h12,
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Cancel',
                          outlined: true,
                          radius: AppSizes.md,
                          onPressed: _saving ? null : _cancel,
                        ),
                      ),
                      AppGap.w12,
                      Expanded(
                        child: AppButton(
                          label: 'Save',
                          radius: AppSizes.md,
                          isLoading: _saving,
                          onPressed: _changed ? _save : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            InfoRow(
              icon: Icons.mail_outline,
              label: 'Email',
              value: p.email.isEmpty ? 'Not added' : p.email,
            ),
          const Divider(height: 1, color: AppColors.darkBorder),
          InfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: PhoneFormatter.display(p.phoneNumber),
            trailing: TextButton(
              onPressed: _saving ? null : widget.onChangePhone,
              child: const Text('Change'),
            ),
          ),
        ],
      ),
    );
  }
}

// =============== 3. my numbers ===============

class StatsCard extends StatelessWidget {
  final ProfileController c;
  const StatsCard({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = c.stats;
    final d = s.data;

    return ProfileCard(
      icon: Icons.insights_outlined,
      color: AppColors.success,
      title: 'My numbers',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<String>(
            showSelectedIcon: false,
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
            segments: const [
              ButtonSegment(value: 'week', label: Text('This week')),
              ButtonSegment(value: 'month', label: Text('This month')),
            ],
            selected: {c.range},
            onSelectionChanged: (v) => c.setRange(v.first),
          ),
          if (c.isAdmin) ...[
            AppGap.h8,
            SegmentedButton<String>(
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: [
                const ButtonSegment(value: 'me', label: Text('Me')),
                ButtonSegment(value: 'team', label: Text(c.isSuper ? 'Team' : 'My team')),
                if (c.isSuper)
                  const ButtonSegment(value: 'all', label: Text('Everyone')),
              ],
              selected: {c.scope},
              onSelectionChanged: (v) => c.setScope(v.first),
            ),
          ],
          if (c.isSuper && c.scope == 'team' && (c.team.data?.teams.isNotEmpty ?? false)) ...[
            AppGap.h8,
            DropdownButton<String>(
              isExpanded: true,
              value: c.teamAdminId,
              underline: const SizedBox.shrink(),
              hint: const Text('Choose an admin'),
              items: [
                for (final t in c.team.data!.teams)
                  DropdownMenuItem(value: t.adminId, child: Text(t.userName)),
              ],
              onChanged: (v) {
                if (v != null) c.setTeam(v);
              },
            ),
          ],
          AppGap.h12,
          if (d == null)
            s.loading
                ? const TilesSkeleton()
                : CardMessage(
                    message: s.error ?? 'Could not load the numbers.',
                    onRetry: () => c.loadStats(),
                  )
          else
            Opacity(
              opacity: s.loading ? 0.5 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${DateFormatter.dayMonth(DateTime.tryParse(d.from))} - '
                    '${DateFormatter.dayMonth(DateTime.tryParse(d.to))}',
                    style: text.labelMedium?.copyWith(color: AppColors.darkOnSurfaceMuted),
                  ),
                  AppGap.h8,
                  AppProgressBar(
                    value: d.collectedFraction,
                    height: 8,
                    semanticsLabel: 'Collected against target',
                  ),
                  AppGap.h12,
                  Row(
                    spacing: AppSizes.sm,
                    children: [
                      Expanded(
                        child: MiniTile(
                          label: 'COLLECTED',
                          value: CurrencyFormatter.format(d.collected),
                          caption: 'of ${CurrencyFormatter.format(d.target)} target',
                          color: AppColors.success,
                        ),
                      ),
                      Expanded(
                        child: MiniTile(
                          label: 'CUSTOMERS PAID',
                          value: '${d.customersPaid}',
                          caption: 'in this period',
                          color: AppColors.stepCurrentLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    spacing: AppSizes.sm,
                    children: [
                      Expanded(
                        child: MiniTile(
                          label: 'OVERDUE',
                          value: '${d.overdueCount}',
                          caption: 'loans right now',
                          color: d.overdueCount > 0
                              ? AppColors.progressDanger
                              : AppColors.success,
                        ),
                      ),
                      Expanded(
                        child: MiniTile(
                          label: 'ON TIME',
                          value: d.onTimeRatio == null
                              ? '-'
                              : '${(d.onTimeRatio! * 100).round()}%',
                          caption: 'payments by due date',
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// =============== 4. loan defaults ===============

class DefaultsCard extends StatefulWidget {
  final UserProfile p;
  final Future<String?> Function({double? fee, double? interest, double? months}) onSave;
  final ValueChanged<bool> onDirty;

  const DefaultsCard({
    super.key,
    required this.p,
    required this.onSave,
    required this.onDirty,
  });

  @override
  State<DefaultsCard> createState() => _DefaultsCardState();
}

class _DefaultsCardState extends State<DefaultsCard> {
  final _fee = TextEditingController();
  final _interest = TextEditingController();
  final _months = TextEditingController();
  bool _editing = false;
  bool _saving = false;
  String? _err;

  UserProfile get p => widget.p;
  ProfileLimits get lim => p.limits;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void dispose() {
    _fee.dispose();
    _interest.dispose();
    _months.dispose();
    super.dispose();
  }

  void _reset() {
    _fee.text = fmtNum(p.defaultFee);
    _interest.text = fmtNum(p.defaultInterest);
    _months.text = fmtNum(p.defaultMonths);
  }

  double? _v(TextEditingController c) => double.tryParse(c.text.trim());

  String? _check(double? v, double min, double max, String label) {
    if (v == null) return 'Enter a number';
    if (v < min || v > max) return '$label must be ${fmtNum(min)} to ${fmtNum(max)}';
    if (((v * 10) - (v * 10).round()).abs() > 1e-9) return 'One decimal place at most';
    return null;
  }

  String? get _eFee => _check(_v(_fee), 0, lim.maxFeePercent, 'Fee');
  String? get _eInterest => _check(_v(_interest), 0, lim.maxInterestPercent, 'Interest');
  String? get _eMonths => _check(_v(_months), lim.minMonths, lim.maxMonths, 'Term');
  bool get _valid => _eFee == null && _eInterest == null && _eMonths == null;
  bool get _changed =>
      _v(_fee) != p.defaultFee ||
      _v(_interest) != p.defaultInterest ||
      _v(_months) != p.defaultMonths;

  void _touch() {
    setState(() => _err = null);
    widget.onDirty(_editing && _changed);
  }

  Future<void> _save() async {
    if (_saving || !_valid || !_changed) return;
    setState(() => _saving = true);

    final err = await widget.onSave(
      fee: _v(_fee) != p.defaultFee ? _v(_fee) : null,
      interest: _v(_interest) != p.defaultInterest ? _v(_interest) : null,
      months: _v(_months) != p.defaultMonths ? _v(_months) : null,
    );
    if (!mounted) return;
    setState(() => _saving = false);

    if (err == null) {
      setState(() => _editing = false);
      widget.onDirty(false);
      AppSnackbar.success(context, 'Loan defaults updated.');
    } else {
      setState(() => _err = err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.labelMedium?.copyWith(color: AppColors.darkOnSurfaceMuted);

    // the preview follows the fields while editing
    final fee = (_editing ? _v(_fee) : null) ?? p.defaultFee;
    final interest = (_editing ? _v(_interest) : null) ?? p.defaultInterest;
    final months = (_editing ? _v(_months) : null) ?? p.defaultMonths;
    final weeks = LoanHelper.totalWeeksFromMonths(months);
    final b = LoanHelper.breakdown(
      principal: 10000,
      feePercent: fee,
      interestPercent: interest,
      totalWeeks: weeks,
    );
    final money = CurrencyFormatter.format;

    return ProfileCard(
      icon: Icons.tune_rounded,
      color: AppColors.warning,
      title: 'Loan defaults',
      trailing: (p.canEditDefaults && !_editing)
          ? IconButton(
              tooltip: 'Edit loan defaults',
              onPressed: () {
                _reset();
                setState(() => _editing = true);
              },
              icon: const Icon(Icons.edit_outlined, size: 20),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_editing) ...[
            AppStepField(
              label: 'Upfront fee',
              controller: _fee,
              suffix: '%',
              max: lim.maxFeePercent,
              min: 0,
              error: _eFee,
              enabled: !_saving,
              onChanged: _touch,
            ),
            AppGap.h8,
            AppStepField(
              label: 'Interest',
              controller: _interest,
              suffix: '%',
              max: lim.maxInterestPercent,
              min: 0,
              error: _eInterest,
              enabled: !_saving,
              onChanged: _touch,
            ),
            AppGap.h8,
            AppStepField(
              label: 'Term',
              controller: _months,
              suffix: 'months',
              max: lim.maxMonths,
              min: lim.minMonths,
              error: _eMonths,
              enabled: !_saving,
              onChanged: _touch,
            ),
          ] else
            Row(
              spacing: AppSizes.sm,
              children: [
                Expanded(
                  child: MiniTile(
                    label: 'UPFRONT FEE',
                    value: '${fmtNum(p.defaultFee)}%',
                    caption: 'on principal',
                    color: AppColors.warning,
                  ),
                ),
                Expanded(
                  child: MiniTile(
                    label: 'INTEREST',
                    value: '${fmtNum(p.defaultInterest)}%',
                    caption: 'flat, once',
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: MiniTile(
                    label: 'TERM',
                    value: '${fmtNum(p.defaultMonths)} mo',
                    caption: '${p.defaultWeeks} weeks',
                    color: AppColors.stepCurrentLabel,
                  ),
                ),
              ],
            ),
          AppGap.h12,
          Text(
            'On a ${money(10000)} loan: fee ${money(b.upfrontFee)}, '
            '${money(b.disbursedAmount)} handed over, ${money(b.totalPayable)} '
            'repayable, ${money(b.weeklyPayable)} a week for $weeks weeks.',
            style: muted,
          ),
          AppGap.h8,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  size: AppSizes.iconSm, color: AppColors.darkOnSurfaceMuted),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  p.defaultsInherited
                      ? 'Set by your admin. Only new loans use these values.'
                      : p.canEditDefaults
                          ? 'Applies to new loans only, never existing ones. '
                              'Employees who inherit these values pick them up at once.'
                          : 'Only admins can change these. Only new loans use them.',
                  style: muted,
                ),
              ),
            ],
          ),
          if (_err != null) ...[
            AppGap.h8,
            Text(
              _err!,
              style: text.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_editing) ...[
            AppGap.h12,
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    outlined: true,
                    radius: AppSizes.md,
                    onPressed: _saving
                        ? null
                        : () {
                            setState(() {
                              _editing = false;
                              _err = null;
                            });
                            widget.onDirty(false);
                          },
                  ),
                ),
                AppGap.w12,
                Expanded(
                  child: AppButton(
                    label: 'Save',
                    radius: AppSizes.md,
                    isLoading: _saving,
                    onPressed: (_valid && _changed) ? _save : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// =============== 5. security ===============

class SecurityCard extends StatelessWidget {
  final ProfileController c;
  final VoidCallback onChangePassword;
  final ValueChanged<SessionInfo> onRevokeOne;
  final VoidCallback onRevokeAll;

  const SecurityCard({
    super.key,
    required this.c,
    required this.onChangePassword,
    required this.onRevokeOne,
    required this.onRevokeAll,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = c.sessions;
    final list = s.data;

    return ProfileCard(
      icon: Icons.shield_outlined,
      color: AppColors.stepCurrentLabel,
      title: 'Security',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(
            icon: Icons.password_rounded,
            label: 'Password',
            value: 'Change your password',
            trailing: TextButton(onPressed: onChangePassword, child: const Text('Change')),
          ),
          const Divider(height: 1, color: AppColors.darkBorder),
          AppGap.h12,
          Text(
            'SIGNED-IN DEVICES',
            style: text.labelMedium?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          AppGap.h8,
          if (list == null)
            s.loading
                ? const ProfileCardSkeleton(rows: 1)
                : CardMessage(
                    message: s.error ?? 'Could not load your sessions.',
                    onRetry: () => c.loadSessions(),
                  )
          else if (list.isEmpty)
            Text('No active sessions.', style: text.bodyMedium)
          else ...[
            for (final session in list)
              InfoRow(
                icon: Icons.smartphone_outlined,
                label: 'Expires ${DateFormatter.date(session.expiresAt)}',
                value: 'Signed in on ${DateFormatter.dateTime(session.createdAt, fallback: '--')}',
                trailing: IconButton(
                  tooltip: 'Sign out this device',
                  onPressed: () => onRevokeOne(session),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                ),
              ),
            Text(
              'Device names are not recorded, so the current device is not marked.',
              style: text.labelSmall?.copyWith(color: AppColors.darkOnSurfaceMuted),
            ),
            AppGap.h8,
            AppButton(
              label: 'Sign out of all devices',
              outlined: true,
              prefixIcon: Icons.devices_other_outlined,
              radius: AppSizes.md,
              onPressed: onRevokeAll,
            ),
          ],
        ],
      ),
    );
  }
}

// =============== 7. team (ADMIN and above) ===============

class TeamCard extends StatelessWidget {
  final ProfileController c;
  final VoidCallback onManageUsers;
  const TeamCard({super.key, required this.c, required this.onManageUsers});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = c.team;
    final d = s.data;

    Widget body;
    if (d == null) {
      body = s.loading
          ? const ProfileCardSkeleton(rows: 2)
          : CardMessage(
              message: s.error ?? 'Could not load the team.',
              onRetry: () => c.loadTeam(),
            );
    } else if (d.isOverview) {
      body = d.teams.isEmpty
          ? Text('No approved teams yet.', style: text.bodyMedium)
          : Column(
              children: [
                for (final t in d.teams)
                  InfoRow(
                    icon: Icons.groups_2_outlined,
                    label: '${t.membersCount} members'
                        '${t.pendingCount > 0 ? ' • ${t.pendingCount} pending' : ''}',
                    value: t.userName,
                    trailing: t.isActive
                        ? null
                        : const AppChip(label: 'INACTIVE', radius: AppSizes.radiusSm),
                  ),
              ],
            );
    } else {
      body = d.members.isEmpty
          ? Text('No team members yet.', style: text.bodyMedium)
          : Column(
              children: [
                for (final m in d.members.take(5))
                  InfoRow(
                    icon: Icons.person_outline,
                    label: '${PhoneFormatter.display(m.phoneNumber)} • '
                        '${m.customersCount} customers',
                    value: m.userName,
                    trailing: !m.isActive
                        ? const AppChip(label: 'INACTIVE', radius: AppSizes.radiusSm)
                        : !m.isVerified
                            ? const AppChip(label: 'PENDING', radius: AppSizes.radiusSm)
                            : null,
                  ),
                if (d.members.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.xs),
                    child: Text(
                      '+${d.members.length - 5} more in Manage users',
                      style: text.labelMedium?.copyWith(color: AppColors.darkOnSurfaceMuted),
                    ),
                  ),
              ],
            );
    }

    return ProfileCard(
      icon: Icons.groups_outlined,
      color: AppColors.stepCurrentLabel,
      title: 'Team',
      trailing: (d != null && !d.isOverview && d.pendingCount > 0)
          ? AppChip(
              label: '${d.pendingCount} pending',
              radius: AppSizes.radiusSm,
              backgroundColor: AppColors.warning.withAlpha(AppAlphas.badgeFill),
              textStyle: text.labelSmall?.copyWith(color: AppColors.warning),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          body,
          AppGap.h12,
          AppButton(
            label: 'Manage users',
            outlined: true,
            prefixIcon: Icons.manage_accounts_outlined,
            radius: AppSizes.md,
            onPressed: onManageUsers,
          ),
        ],
      ),
    );
  }
}

// =============== 8. system (SUPER_ADMIN) ===============

class SystemCard extends StatelessWidget {
  final ProfileController c;
  final String? busyAdminId;
  final void Function(AdminAccount admin, bool approve) onDecide;
  final VoidCallback onAllAdmins;
  final VoidCallback onEditLimits;

  const SystemCard({
    super.key,
    required this.c,
    required this.busyAdminId,
    required this.onDecide,
    required this.onAllAdmins,
    required this.onEditLimits,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = c.pendingAdmins;
    final list = s.data;
    final lim = c.profile.data?.limits ?? ProfileLimits.fallback;
    final money = CurrencyFormatter.format;
    final waiting = c.team.data?.pendingAdminApprovals ?? list?.length ?? 0;

    return ProfileCard(
      icon: Icons.admin_panel_settings_outlined,
      color: AppColors.warning,
      title: 'System',
      trailing: waiting > 0
          ? AppChip(
              label: '$waiting waiting',
              radius: AppSizes.radiusSm,
              backgroundColor: AppColors.warning.withAlpha(AppAlphas.badgeFill),
              textStyle: text.labelSmall?.copyWith(color: AppColors.warning),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ADMIN APPROVALS',
            style: text.labelMedium?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          AppGap.h8,
          if (list == null)
            s.loading
                ? const ProfileCardSkeleton(rows: 1)
                : CardMessage(
                    message: s.error ?? 'Could not load the approval queue.',
                    onRetry: () => c.loadPendingAdmins(),
                  )
          else if (list.isEmpty)
            Text('No admins are waiting for approval.', style: text.bodyMedium)
          else
            for (final a in list)
              InfoRow(
                icon: Icons.person_add_alt_1_outlined,
                label: a.email.isNotEmpty ? a.email : PhoneFormatter.display(a.phoneNumber),
                value: a.userName,
                trailing: busyAdminId == a.id
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Reject ${a.userName}',
                            onPressed: () => onDecide(a, false),
                            icon: const Icon(Icons.close_rounded,
                                color: AppColors.progressDanger),
                          ),
                          IconButton(
                            tooltip: 'Approve ${a.userName}',
                            onPressed: () => onDecide(a, true),
                            icon: const Icon(Icons.check_rounded, color: AppColors.success),
                          ),
                        ],
                      ),
              ),
          AppGap.h8,
          AppButton(
            label: 'All admins',
            outlined: true,
            prefixIcon: Icons.admin_panel_settings_outlined,
            radius: AppSizes.md,
            onPressed: onAllAdmins,
          ),
          AppGap.h16,
          Text(
            'LOAN LIMITS',
            style: text.labelMedium?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          AppGap.h8,
          Text(
            'Principal ${money(lim.minPrincipal)} to ${money(lim.maxPrincipal)}\n'
            'Term ${fmtNum(lim.minMonths)} to ${fmtNum(lim.maxMonths)} months\n'
            'Fee up to ${fmtNum(lim.maxFeePercent)}% • Interest up to ${fmtNum(lim.maxInterestPercent)}%',
            style: text.bodyMedium,
          ),
          AppGap.h8,
          AppButton(
            label: 'Edit loan limits',
            prefixIcon: Icons.rule_rounded,
            radius: AppSizes.md,
            onPressed: onEditLimits,
          ),
        ],
      ),
    );
  }
}

// =============== 6. app ===============

class AppInfoCard extends StatelessWidget {
  const AppInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      icon: Icons.info_outline,
      color: AppColors.darkOnSurfaceMuted,
      title: 'App',
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (_, snap) {
          final i = snap.data;
          return InfoRow(
            icon: Icons.numbers_rounded,
            label: 'Version',
            value: i == null ? '...' : '${i.version} (${i.buildNumber})',
          );
        },
      ),
    );
  }
}