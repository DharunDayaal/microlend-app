import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_icon_button.dart';
import 'package:micro_lending_app/shared/widgets/app_status_chip.dart';
import 'package:micro_lending_app/features/loans/domain/entities/manual_loan_status.dart';
import 'package:micro_lending_app/features/loans/presentation/models/manual_status_look.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/presentation/models/loan_snapshot.dart';
import 'package:micro_lending_app/shared/design_system/constants/alphas.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/device/device_utils.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/shared/helpers/dialog_helper.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

/// Returns true when the status was changed, false if the sheet was closed.
class ChangeStatusSheet extends ConsumerStatefulWidget {
  final LoanSnapshot snapshot;
  final String borrowerName;

  /// Set when reopening must not be offered, for example because the borrower
  /// already has another open loan. The text is shown on the disabled option.
  final String? reopenBlockedReason;

  const ChangeStatusSheet({
    super.key,
    required this.snapshot,
    required this.borrowerName,
    this.reopenBlockedReason,
  });

  static Future<bool> show(
    BuildContext context, {
    required LoanSnapshot snapshot,
    required String borrowerName,
    String? reopenBlockedReason,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false, // can't be swiped away mid-request
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (ctx) => Padding(
        // lifts the sheet above the keyboard
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: ChangeStatusSheet(
          snapshot: snapshot,
          borrowerName: borrowerName,
          reopenBlockedReason: reopenBlockedReason,
        ),
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<ChangeStatusSheet> createState() => _ChangeStatusSheetState();
}

class _ChangeStatusSheetState extends ConsumerState<ChangeStatusSheet> {
  ManualLoanStatus? _selected;
  bool _saving = false;
  String? _error;

  List<ManualLoanStatus> get _options => allowedStatusChanges(
    widget.snapshot.stage,
    ref.read(sessionProvider).role,
  );

  bool _blocked(ManualLoanStatus o) =>
      o.isReopen && widget.reopenBlockedReason != null;

  @override
  void initState() {
    super.initState();
    final selectable = _options.where((o) => !_blocked(o)).toList();
    if (selectable.length == 1) {
      _selected = selectable.first; // nothing to choose
    }
  }

  Future<void> _submit() async {
    final target = _selected;
    if (target == null || _saving || _blocked(target)) return;

    final loan = widget.snapshot.loan;
    final owed = loan.outstandingAmount;
    final money = CurrencyFormatter.format;
    final who =
        '${widget.borrowerName} • ${TextFormatter.dummyId(loan.id, '#LN')}';

    final footer = switch (target) {
      ManualLoanStatus.closed => context.l10n.statusFooterClosed,
      ManualLoanStatus.defaulted => context.l10n.statusFooterDefaulted,
      ManualLoanStatus.active => context.l10n.statusFooterReopen,
    };

    final message = target.isReopen
        ? context.l10n.statusReopenMessage(who, money(owed), footer)
        : '$who\n\n'
              '${owed > 0 ? context.l10n.statusWriteOffLine(money(owed)) : ''}'
              '$footer';

    // confirm before anything is sent
    final ok = await DialogHelper.confirm(
      context,
      title: target.isReopen
          ? context.l10n.statusReopenTitle
          : context.l10n.statusMarkAsTitle(
              target.l10nLabel(context).toLowerCase(),
            ),
      message: message,
      confirmText: target.isReopen
          ? context.l10n.statusReopenLoan
          : context.l10n.statusMarkAs(target.l10nLabel(context)),
      cancelText: context.l10n.statusGoBack,
    );
    if (!ok || !mounted) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await ref
          .read(loanRepositoryProvider)
          .changeStatus(loanId: loan.id, status: target);
      if (!mounted) return;
      DeviceUtils.success();
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      DeviceUtils.error();
      if (!mounted) return;
      setState(() {
        _error = e.isNetworkError
            ? context.l10n.statusNoServerAnswer
            : e.message;
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = widget.snapshot;
    final loan = s.loan;
    final options = _options;
    final owed = loan.outstandingAmount;
    final target = _selected;
    final destructive = target == ManualLoanStatus.defaulted;

    return PopScope(
      canPop: !_saving, // back is blocked while the request runs
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----- header -----
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.statusSheetTitle,
                    style: text.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppIconButton(
                  icon: Icons.close,
                  color: AppColors.darkOnSurface,
                  onPressed: () {
                    if (!_saving) Navigator.of(context).pop(false);
                  },
                ),
              ],
            ),
            Text(
              '${widget.borrowerName} • ${TextFormatter.dummyId(loan.id, '#LN')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelLarge?.copyWith(
                color: AppColors.darkOnSurfaceMuted,
              ),
            ),
            AppGap.h16,

            // ----- current status -----
            _CurrentStatusTile(view: s.view, label: s.stage.l10nLabel(context)),
            AppGap.h8,
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: AppSizes.iconSm,
                  color: AppColors.darkOnSurfaceMuted,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    context.l10n.statusAutoNote,
                    style: text.labelMedium?.copyWith(
                      color: AppColors.darkOnSurfaceMuted,
                    ),
                  ),
                ),
              ],
            ),
            AppGap.h16,

            if (options.isEmpty)
              Text(
                s.stage == LoanStage.closed
                    ? context.l10n.statusClosedCannotChange
                    : context.l10n.statusNoPermission,
                style: text.bodyMedium,
              )
            else ...[
              Text(
                context.l10n.statusMoveTo,
                style: text.labelMedium?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              AppGap.h8,
              for (final option in options) ...[
                _OptionTile(
                  option: option,
                  selected: _selected == option,
                  enabled: !_saving && !_blocked(option),
                  blockedReason: _blocked(option)
                      ? widget.reopenBlockedReason
                      : null,
                  onTap: () => setState(() {
                    _selected = option;
                    _error = null;
                  }),
                ),
                AppGap.h8,
              ],

              // ----- warnings -----
              if (target?.isReopen == true) ...[
                AppGap.h8,
                _Warning(text: context.l10n.statusReopenWarning),
              ] else if (target != null && owed > 0) ...[
                AppGap.h8,
                _Warning(
                  text: destructive
                      ? context.l10n.statusDefaultWarning(
                          CurrencyFormatter.format(owed),
                        )
                      : context.l10n.statusCloseWarning(
                          CurrencyFormatter.format(owed),
                        ),
                ),
              ],

              if (_error != null) ...[
                AppGap.h12,
                Text(
                  _error!,
                  style: text.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              AppGap.h16,

              // ----- buttons -----
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: context.l10n.commonCancel,
                      outlined: true,
                      radius: AppSizes.md,
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).pop(false),
                    ),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: AppButton(
                      label: context.l10n.statusUpdate,
                      radius: AppSizes.md,
                      isLoading: _saving,
                      backgroundColor: destructive
                          ? AppColors.dangerContainer
                          : null,
                      foregroundColor: destructive ? Colors.white : null,
                      // nothing chosen yet, or the choice is blocked
                      onPressed: (target == null || _blocked(target))
                          ? null
                          : _submit,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CurrentStatusTile extends StatelessWidget {
  final LoanStatusView view;
  final String label;
  const _CurrentStatusTile({required this.view, required this.label});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: view.color.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: view.color.withAlpha(AppAlphas.borderTint)),
      ),
      child: Row(
        children: [
          Icon(view.icon, color: view.color),
          AppGap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.statusCurrentStatus,
                  style: text.labelSmall?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                ),
                Text(
                  label,
                  style: text.bodyLarge?.copyWith(
                    color: view.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          AppChip(label: context.l10n.statusCurrent, radius: AppSizes.radiusSm),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final ManualLoanStatus option;
  final bool selected;
  final bool enabled;
  final String? blockedReason; // shown in place of the description
  final VoidCallback onTap;

  const _OptionTile({
    required this.option,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.blockedReason,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppSizes.radiusMd);

    return Opacity(
      opacity: blockedReason == null ? 1 : 0.5,
      child: Semantics(
        button: true,
        selected: selected,
        enabled: enabled,
        label: option.l10nLabel(context),
        child: Material(
          color: selected
              ? option.color.withAlpha(AppAlphas.watermark)
              : AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: enabled ? onTap : null,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(
                  color: selected ? option.color : AppColors.darkBorder,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? option.color
                        : AppColors.darkOnSurfaceMuted,
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              option.icon,
                              size: AppSizes.iconSm,
                              color: option.color,
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Flexible(
                              child: Text(
                                option.l10nLabel(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          blockedReason ?? option.l10nDescription(context),
                          style: text.labelMedium?.copyWith(
                            color: AppColors.darkOnSurfaceMuted,
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
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  final String text;
  const _Warning({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(AppAlphas.watermark),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: AppColors.warning.withAlpha(AppAlphas.borderTint),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: AppSizes.iconSm,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
