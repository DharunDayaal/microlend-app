import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_icon_button.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/payment_sheet.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/repayment_track_list.dart';
import 'package:micro_lending_app/shared/widgets/state_views.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/presentation/controllers/loan_details_controller.dart';
import 'package:micro_lending_app/features/loans/domain/entities/manual_loan_status.dart';
import 'package:micro_lending_app/shared/session/models/user_role.dart';
import 'package:micro_lending_app/features/loans/presentation/models/loan_snapshot.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/change_status_sheet.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/loan_detail_sections.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/device/launcher_utils.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/shared/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

enum _MenuAction { tracks, payments, call, changeStatus, history }

class LoanDetailsScreen extends ConsumerStatefulWidget {
  final String loanId;
  const LoanDetailsScreen({super.key, required this.loanId});

  @override
  ConsumerState<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends ConsumerState<LoanDetailsScreen> {
  bool _changed = false; // tells the previous screen to reload
  bool _paying = false;

  // ---------- state lives in LoanDetailsController ----------

  LoanDetailsState get _s => ref.read(loanDetailsProvider(widget.loanId));
  LoanDetailsController get _ctrl =>
      ref.read(loanDetailsProvider(widget.loanId).notifier);

  LoanModel? get _loan => _s.loan;
  CustomerDetails? get _customer => _s.customer;
  int? get _cycle => _s.cycle;
  bool? get _canIssueNew => _s.canIssueNew;
  List<PaymentModel> get _payments => _s.payments;
  bool get _loanLoading => _s.loanLoading;
  bool get _customerLoading => _s.customerLoading;
  bool get _paymentsLoading => _s.paymentsLoading;
  String? get _loanError => _s.loanError;
  String? get _customerError => _s.customerError;
  String? get _paymentsError => _s.paymentsError;

  /// With [silent] the current content stays visible while it reloads.
  Future<void> _load({bool silent = false}) => _ctrl.load(
    silent: silent,
    onRefreshError: (message) {
      if (mounted) AppSnackbar.error(context, message);
    },
  );

  Future<void> _changeStatus() async {
    final loan = _loan;
    if (loan == null) return;

    // Reopening a defaulted loan must not create a second open loan.
    final blocked = switch (_canIssueNew) {
      true => null,
      false => context.l10n.loanReopenBlockedOther,
      null => context.l10n.loanReopenCheckFailed,
    };

    final changed = await ChangeStatusSheet.show(
      context,
      snapshot: LoanSnapshot.of(loan),
      borrowerName: _customer?.customerName ?? loan.customerName ?? '',
      reopenBlockedReason: blocked,
    );
    if (!changed || !mounted) return;

    _changed = true; // the loans list reloads when we leave
    AppSnackbar.success(context, context.l10n.loanStatusUpdated);
    await _load(silent: true); // the status always comes from the server
  }

  void _retryPayments() => _ctrl.retryPayments();

  void _retryBorrower() => _ctrl.retryBorrower();

  // ---------- actions ----------

  void _close() => context.pop(_changed);

  Future<void> _openTracks() async {
    final changed = await context.push<bool>(
      AppRoutes.loanTrack(widget.loanId),
    );
    if (changed == true && mounted) {
      _changed = true;
      _load(silent: true);
    }
  }

  Future<void> _openPayments() async {
    final changed = await context.push<bool>(
      AppRoutes.loanPayment(widget.loanId),
    );
    if (changed == true && mounted) {
      _changed = true;
      _load(silent: true);
    }
  }

  Future<void> _collect(int week) async {
    final loan = _loan;
    if (loan == null || _paying) return;
    setState(() => _paying = true);

    try {
      final result = await PaymentSheet.showForWeek(
        context,
        customerId: loan.customerId,
        customerName: _customer?.customerName ?? loan.customerName ?? '',
        loan: loan,
        weekNumber: week,
      );
      if (result == null || !mounted) return;

      _changed = true;
      AppSnackbar.success(context, context.l10n.loanPaymentRecorded);
      await _load(silent: true); // balances always come from the server
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  void _issueNewLoan() {
    final loan = _loan;
    if (loan == null) return;
    // match this call to your issue-loan route
    context.push(AppRoutes.issueLoan(loan.customerId));
  }

  Future<void> _onMenu(_MenuAction action) async {
    switch (action) {
      case _MenuAction.tracks:
        await _openTracks();
      case _MenuAction.payments:
        await _openPayments();
      case _MenuAction.call:
        final phone = _customer?.phoneNumber;
        if (phone == null) return;
        final ok = await LauncherUtils.call(phone);
        if (!ok && mounted) {
          AppSnackbar.error(context, context.l10n.commonUnableOpenDialer);
        }
      case _MenuAction.changeStatus:
        await _changeStatus();
      case _MenuAction.history:
        context.push(
          AppRoutes.auditFor(
            entityType: 'LOAN',
            entityId: widget.loanId,
            label: context.l10n.loanTitleId(
              TextFormatter.dummyId(widget.loanId, '#LN'),
            ),
          ),
        );
    }
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
    ref.watch(loanDetailsProvider(widget.loanId));
    final loan = _loan;
    final snap = loan == null ? null : LoanSnapshot.of(loan);

    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: _appBar(snap),
        body: SafeArea(child: _body(snap)),
        bottomNavigationBar: snap == null ? null : _actionBar(snap),
      ),
    );
  }

  PreferredSizeWidget _appBar(LoanSnapshot? s) {
    final text = Theme.of(context).textTheme;

    return AppBar(
      leading: AppIconButton(icon: Icons.arrow_back_ios, onPressed: _close),
      titleSpacing: 4,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.loanTitleId(
              TextFormatter.dummyId(widget.loanId, '#LN'),
            ),
            style: text.headlineSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (s != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(s.view.icon, size: 14, color: s.view.color),
                const SizedBox(width: 4),
                Text(
                  s.stage.l10nLabel(context),
                  style: text.labelMedium?.copyWith(
                    color: s.view.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
        ],
      ),
      actions: [
        PopupMenuButton<_MenuAction>(
          enabled: s != null,
          onSelected: _onMenu,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: _MenuAction.tracks,
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.list_alt_outlined),
                title: Text(context.l10n.loanMenuTracks),
              ),
            ),
            PopupMenuItem(
              value: _MenuAction.payments,
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(context.l10n.loanMenuPayments),
              ),
            ),
            if (_customer != null)
              PopupMenuItem(
                value: _MenuAction.call,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.call_outlined),
                  title: Text(context.l10n.loanMenuCall),
                ),
              ),
            if (s != null &&
                ref.watch(sessionProvider).hasRole(UserRole.admin) &&
                allowedStatusChanges(
                  s.stage,
                  ref.watch(sessionProvider).role,
                ).isNotEmpty)
              PopupMenuItem(
                value: _MenuAction.changeStatus,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.swap_horiz_rounded),
                  title: Text(context.l10n.loanMenuChangeStatus),
                ),
              ),
            if (ref.watch(sessionProvider).hasRole(UserRole.admin))
              PopupMenuItem(
                value: _MenuAction.history,
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.history_rounded),
                  title: Text(context.l10n.commonHistory),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _body(LoanSnapshot? s) {
    if (s == null) {
      if (_loanLoading) {
        return const SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppSizes.lg),
          child: LoanDetailsSkeleton(),
        );
      }
      return ErrorView(
        message: _loanError ?? context.l10n.loanLoadFailed,
        onRetry: () => _load(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (s.hasBanner) ...[LoanStatusBanner(s: s), AppGap.h16],
            _borrower(),
            AppGap.h16,
            LoanBalanceCard(s: s),
            AppGap.h16,
            ..._schedule(s),
            RecentPaymentsSection(
              payments: _payments,
              isLoading: _paymentsLoading,
              error: _paymentsError,
              onRetry: _retryPayments,
              onViewAll: _openPayments,
            ),
            AppGap.h16,
            LoanContractCard(s: s),
            AppGap.h16,
          ],
        ),
      ),
    );
  }

  Widget _borrower() {
    final c = _customer;
    if (c != null) {
      return LoanBorrowerStrip(
        customer: c,
        cycle: _cycle,
        onTap: () => context.push(AppRoutes.customerDetail(c.id)),
      );
    }
    if (_customerLoading) return const LoanBorrowerStripSkeleton();
    return LoanBorrowerError(
      message: _customerError ?? context.l10n.issueLoadBorrowerFailed,
      onRetry: _retryBorrower,
    );
  }

  List<Widget> _schedule(LoanSnapshot s) {
    final preview = s.previewRows;
    if (preview.isEmpty) return const [];

    return [
      DetailSectionHeader(
        title: context.l10n.loanRepaymentSchedule,
        actionLabel: context.l10n.loanViewAllWeeks(s.rows.length),
        onAction: _openTracks,
      ),
      AppGap.h8,
      for (final row in preview) ...[
        RepaymentTrackCard(
          row: row,
          totalWeeks: s.loan.totalWeeks,
          // the Collect button shows on partial weeks of open loans only
          onCollect: s.isOpen && !_paying ? () => _collect(row.week) : null,
        ),
        AppGap.h8,
      ],
      if (s.hiddenPastDue > 0)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _openTracks,
            icon: const Icon(Icons.warning_amber_rounded, size: 18),
            label: Text(context.l10n.loanMoreOverdueWeeks(s.hiddenPastDue)),
          ),
        ),
      AppGap.h8,
    ];
  }

  Widget _actionBar(LoanSnapshot s) {
    if (s.isOpen) {
      final overdue = s.stage == LoanStage.overdue;
      final week = s.firstOwed?.week;
      return LoanActionBar(
        label: overdue
            ? context.l10n.loanCollectOverdue(
                CurrencyFormatter.format(s.overdueAmount),
              )
            : context.l10n.loanRecordPayment,
        icon: Icons.payments_outlined,
        urgent: overdue,
        isLoading: _paying,
        // nothing owed means nothing to collect
        onPressed: week == null || _paying ? null : () => _collect(week),
      );
    }

    final canIssue =
        _canIssueNew == true &&
        (s.stage == LoanStage.paidOff || s.stage == LoanStage.closed);
    if (canIssue) {
      return LoanActionBar(
        label: context.l10n.loanIssueNew,
        icon: Icons.add_circle_outline,
        onPressed: _issueNewLoan,
      );
    }

    return LoanActionBar(
      label: context.l10n.loanViewPaymentHistory,
      icon: Icons.receipt_long_outlined,
      outlined: true,
      onPressed: _openPayments,
    );
  }
}
