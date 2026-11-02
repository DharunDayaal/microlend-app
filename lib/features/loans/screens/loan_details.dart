import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_payment_sheet.dart';
import 'package:micro_lending_app/common/widgets/repayment_track_list.dart';
import 'package:micro_lending_app/common/widgets/state_views.dart';
import 'package:micro_lending_app/data/models/customer_model.dart';
import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/data/models/loan_status_change.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/data/services/customer_service.dart';
import 'package:micro_lending_app/data/services/loan_service.dart';
import 'package:micro_lending_app/features/loans/screens/loan_snapshot.dart';
import 'package:micro_lending_app/features/loans/widgets/change_status_sheet.dart';
import 'package:micro_lending_app/features/loans/widgets/loan_detail_sections.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/device/launcher_utils.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

enum _MenuAction { tracks, payments, call, changeStatus }

class LoanDetailsScreen extends StatefulWidget {
  final String loanId;
  const LoanDetailsScreen({super.key, required this.loanId});

  @override
  State<LoanDetailsScreen> createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen> {
  LoanModel? _loan;
  CustomerDetails? _customer;
  int? _cycle; // which loan this is for the borrower (1 = first)
  bool? _canIssueNew; // null = unknown, so the button stays hidden
  List<PaymentModel> _payments = const [];

  bool _loanLoading = true;
  bool _customerLoading = true;
  bool _paymentsLoading = true;
  String? _loanError;
  String? _customerError;
  String? _paymentsError;

  bool _changed = false; // tells the previous screen to reload
  bool _paying = false;

  /// A response from an older request (before a refresh) is ignored.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ---------- loading: each section has its own state ----------

  Future<void> _load({bool silent = false}) async {
    final id = ++_requestId;
    setState(() {
      if (!silent) {
        _loanLoading = true;
        _customerLoading = true;
        _paymentsLoading = true;
      }
      _loanError = null;
    });

    // payments only need the loan id, so they start right away
    final payments = _loadPayments(id);
    Future<void> borrower = Future.value();

    try {
      final loan = await LoanService.getLoanDetails(loanid: widget.loanId);
      if (!mounted || id != _requestId) return;
      setState(() => _loan = loan);
      borrower = _loadBorrower(loan.customerId, id);
    } on ApiException catch (e) {
      if (!mounted || id != _requestId) return;
      if (_loan == null) {
        setState(() => _loanError = e.message);
      } else {
        AppSnackbar.error(context, e.message); // keep what is on screen
      }
    } finally {
      if (mounted && id == _requestId) setState(() => _loanLoading = false);
    }

    await Future.wait([payments, borrower]);
  }

  Future<void> _loadPayments(int id) async {
    try {
      final res = await LoanService.getPaymentList(
        loanId: widget.loanId,
        page: 1,
        limit: 3,
      );
      if (!mounted || id != _requestId) return;
      setState(() {
        _payments = List.of(res.items);
        _paymentsError = null;
      });
    } on ApiException catch (e) {
      if (mounted && id == _requestId) {
        setState(() => _paymentsError = e.message);
      }
    } finally {
      if (mounted && id == _requestId) setState(() => _paymentsLoading = false);
    }
  }

  Future<void> _loadBorrower(String customerId, int id) =>
      Future.wait([_loadCustomer(customerId, id), _loadCycle(customerId, id)]);

  Future<void> _loadCustomer(String customerId, int id) async {
    try {
      final c = await CustomerService.getCustomerDetails(
        customerId: customerId,
      );
      if (!mounted || id != _requestId) return;
      setState(() {
        _customer = c;
        _customerError = null;
      });
    } on ApiException catch (e) {
      if (mounted && id == _requestId) {
        setState(() => _customerError = e.message);
      }
    } finally {
      if (mounted && id == _requestId) setState(() => _customerLoading = false);
    }
  }

  /// Optional extras: the cycle number and whether a new loan can be issued.
  /// A failure here only hides them. It never breaks the page.
  Future<void> _loadCycle(String customerId, int id) async {
    try {
      final res = await CustomerService.getCustomerLoans(
        customerId: customerId,
      );
      if (!mounted || id != _requestId) return;

      final loans = [...res.loans]
        ..sort((a, b) => a.issuedAt.compareTo(b.issuedAt));
      final index = loans.indexWhere((l) => l.id == widget.loanId);
      final hasOpen = loans.any((l) {
        final stage = loanStageOf(l.status);
        return stage == LoanStage.active || stage == LoanStage.overdue;
      });

      setState(() {
        _cycle = index < 0 ? null : index + 1;
        _canIssueNew = !hasOpen;
      });
    } on ApiException catch (e) {
      AppLogger.warning(
        'Could not load the borrower loans: ${e.message}',
        tag: 'LoanDetails',
      );
    }
  }

  Future<void> _changeStatus() async {
    final loan = _loan;
    if (loan == null) return;

    // Reopening a defaulted loan must not create a second open loan.
    final blocked = switch (_canIssueNew) {
      true => null,
      false => 'This borrower already has another active or overdue loan.',
      null =>
        'Could not check the borrower’s other loans. Refresh and try again.',
    };

    final changed = await ChangeStatusSheet.show(
      context,
      snapshot: LoanSnapshot.of(loan),
      borrowerName: _customer?.customerName ?? loan.customerName ?? '',
      reopenBlockedReason: blocked,
    );
    if (!changed || !mounted) return;

    _changed = true; // the loans list reloads when we leave
    AppSnackbar.success(context, 'Loan status updated.');
    await _load(silent: true); // the status always comes from the server
  }

  void _retryPayments() {
    setState(() => _paymentsLoading = true);
    _loadPayments(_requestId);
  }

  void _retryBorrower() {
    final loan = _loan;
    if (loan == null) return;
    setState(() => _customerLoading = true);
    _loadBorrower(loan.customerId, _requestId);
  }

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
      AppSnackbar.success(context, 'Payment recorded.');
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
        if (!ok && mounted) AppSnackbar.error(context, 'Unable to open dialer');
      case _MenuAction.changeStatus:
        await _changeStatus();
    }
  }

  // ---------- build ----------

  @override
  Widget build(BuildContext context) {
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
            'Loan ${TextFormatter.dummyId(widget.loanId, '#LN')}',
            style: text.headlineSmall,
          ),
          if (s != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(s.view.icon, size: 14, color: s.view.color),
                const SizedBox(width: 4),
                Text(
                  s.view.label,
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
            const PopupMenuItem(
              value: _MenuAction.tracks,
              child: ListTile(
                dense: true,
                leading: Icon(Icons.list_alt_outlined),
                title: Text('Repayment tracks'),
              ),
            ),
            const PopupMenuItem(
              value: _MenuAction.payments,
              child: ListTile(
                dense: true,
                leading: Icon(Icons.receipt_long_outlined),
                title: Text('Payment history'),
              ),
            ),
            if (_customer != null)
              const PopupMenuItem(
                value: _MenuAction.call,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.call_outlined),
                  title: Text('Call borrower'),
                ),
              ),
            if (s != null &&
                CurrentUser.instance.hasRole(UserRole.admin) &&
                allowedStatusChanges(
                  s.stage,
                  CurrentUser.instance.role,
                ).isNotEmpty)
              const PopupMenuItem(
                value: _MenuAction.changeStatus,
                child: ListTile(
                  dense: true,
                  leading: Icon(Icons.swap_horiz_rounded),
                  title: Text('Change status'),
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
        message: _loanError ?? 'Could not load this loan.',
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
      message: _customerError ?? 'Could not load the borrower.',
      onRetry: _retryBorrower,
    );
  }

  List<Widget> _schedule(LoanSnapshot s) {
    final preview = s.previewRows;
    if (preview.isEmpty) return const [];

    return [
      DetailSectionHeader(
        title: 'Repayment schedule',
        actionLabel: 'View all ${s.rows.length} weeks',
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
            label: Text('${s.hiddenPastDue} more overdue weeks'),
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
            ? 'Collect overdue • ${CurrencyFormatter.format(s.overdueAmount)}'
            : 'Record payment',
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
        label: 'Issue new loan',
        icon: Icons.add_circle_outline,
        onPressed: _issueNewLoan,
      );
    }

    return LoanActionBar(
      label: 'View payment history',
      icon: Icons.receipt_long_outlined,
      outlined: true,
      onPressed: _openPayments,
    );
  }
}
