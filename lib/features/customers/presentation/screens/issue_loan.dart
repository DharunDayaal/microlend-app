import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/features/customers/data/customer_providers.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_icon_button.dart';
import 'package:micro_lending_app/shared/widgets/app_step_progress.dart';
import 'package:micro_lending_app/shared/widgets/referral_selection_sheet.dart';
import 'package:micro_lending_app/shared/widgets/state_views.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan_terms.dart';
import 'package:micro_lending_app/features/customers/presentation/widgets/issue_loan/borrower_profile_step.dart';
import 'package:micro_lending_app/features/customers/presentation/widgets/issue_loan/loan_disburse_step.dart';
import 'package:micro_lending_app/features/customers/presentation/widgets/issue_loan/loan_terms_step.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/device/device_utils.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/shared/helpers/dialog_helper.dart';
import 'package:micro_lending_app/shared/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';

class IssueLoanScreen extends ConsumerStatefulWidget {
  final String customerId;
  const IssueLoanScreen({super.key, required this.customerId});

  @override
  ConsumerState<IssueLoanScreen> createState() => _IssueLoanScreenState();
}

class _IssueLoanScreenState extends ConsumerState<IssueLoanScreen> {
  CustomerDetails? _customerDetails;
  int _step = 0;

  late final LoanTerms _defaults = LoanTerms.fromDefaults(
    ref.read(sessionProvider).user,
  );
  late LoanTerms _terms = _defaults;

  PayoutMode _payout = PayoutMode.cash;
  bool _issuing = false;

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  bool _isLoading = true;
  String? _error;
  final String _weekday = DateFormatter.weekdayFull(DateTime.now())
      .toUpperCase();

  static const _stepCount = 3;

  List<StepItem> _steps(BuildContext context) {
    final l = context.l10n;
    return [
      StepItem(
        title: l.issueStepBorrower,
        subtitle: l.issueStepProfile,
        doneSubtitle: l.issueStepSelected,
      ),
      StepItem(
        title: l.issueStepTerms,
        subtitle: l.issueStepCalculator,
        doneSubtitle: l.issueStepConfirmed,
      ),
      StepItem(title: l.issueStepDisburse, subtitle: l.issueStepConfirmation),
    ];
  }

  List<String> _stepTitles(BuildContext context) {
    final l = context.l10n;
    return [l.issueTitleBorrower, l.issueTitleTerms, l.issueTitleDisburse];
  }

  @override
  void initState() {
    super.initState();
    _getCustomerDetails();
  }

  Future<void> _getCustomerDetails({String? customerId}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final String id = customerId ?? widget.customerId;
    try {
      final response = await ref.read(customerRepositoryProvider).details(id);
      if (!mounted) return;
      setState(() => _customerDetails = response);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<LoanItem?> _findOpenLoan(String customerId) async {
    final res = await ref.read(customerRepositoryProvider).loans(customerId);
    return res.loans.where((l) {
      final s = l.status.toUpperCase();
      return s == 'ACTIVE' || s == 'OVERDUE';
    }).firstOrNull;
  }

  Future<void> _switchBorrower() async {
    final picked = await ReferralSelectionSheet.show(
      context,
      sheetTitle: context.l10n.issueSwitchBorrowers,
      selectedId: _customerDetails?.id,
      loader: (page, search) => ref
          .read(customerRepositoryProvider)
          .customersByWeekday(
            weekday: _weekday,
            page: page,
            limit: 20,
            search: search,
          ),
    );
    if (picked == null || !mounted || picked.id == _customerDetails?.id) return;

    setState(() => _isLoading = true);

    try {
      final open = await _findOpenLoan(picked.id);
      if (!mounted) return;

      if (open != null) {
        setState(() => _isLoading = false);
        final overdue = open.status.toUpperCase() == 'OVERDUE';
        AppSnackbar.warning(
          context,
          overdue
              ? context.l10n.issueAlreadyHasOverdue(
                  picked.customerName,
                  TextFormatter.dummyId(open.id, '#LN'),
                )
              : context.l10n.issueAlreadyHasActive(
                  picked.customerName,
                  TextFormatter.dummyId(open.id, '#LN'),
                ),
        );
        return;
      }

      await _getCustomerDetails(customerId: picked.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppSnackbar.error(context, e.message);
    }
  }

  void _next() {
    if (_step < _stepCount - 1) setState(() => _step++);
  }

  Future<void> _issueLoan() async {
    if (_issuing) return;
    final customer = _customerDetails;
    if (customer == null || !_terms.isValid) return;

    final ok = await DialogHelper.confirm(
      context,
      title: context.l10n.issueConfirmTitle,
      message: context.l10n.issueConfirmBody(
        CurrencyFormatter.format(_terms.netDisbursed),
        _payout == PayoutMode.cash
            ? context.l10n.issuePayoutCash
            : context.l10n.issuePayoutBank,
        customer.customerName,
        CurrencyFormatter.format(_terms.totalPayable),
        _terms.totalWeeks,
        CurrencyFormatter.format(_terms.weeklyInstallment),
      ),
      confirmText: context.l10n.issueLoanAction,
      cancelText: context.l10n.issueReviewAgain,
    );
    if (!ok || !mounted) return;

    setState(() => _issuing = true);
    try {
      final loan = await ref
          .read(loanRepositoryProvider)
          .issueLoan(customerId: customer.id, terms: _terms);
      if (!mounted) return;

      DeviceUtils.success();
      AppSnackbar.success(
        context,
        context.l10n.issueLoanIssued(
          TextFormatter.dummyId(loan.id, '#LN'),
          customer.customerName,
        ),
      );
      context.pop(true);
    } on ApiException catch (e) {
      DeviceUtils.error();
      if (!mounted) return;
      AppSnackbar.error(
        context,
        e.isNetworkError ? context.l10n.issueNoServerAnswer : e.message,
      );
    } finally {
      if (mounted) setState(() => _issuing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => context.pop(),
        ),
        titleSpacing: 4,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.issueNewLoan,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              context.l10n.issueStepOfTitle(
                _step + 1,
                _stepCount,
                _stepTitles(context)[_step],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.darkOnSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStepProgress(
                steps: _steps(context),
                currentStep: _step,
                onStepTap: (i) => setState(() => _step = i),
              ),
              const SizedBox(height: AppSizes.lg),
              switch (_step) {
                0 => _profileStep(),
                1 => _termsStep(),
                _ => _disburseStep(),
              },
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _profileStep() {
    if (_isLoading) return const BorrowerProfileStepSkeleton();

    final customer = _customerDetails;
    if (customer == null) {
      return ErrorView(
        message: _error ?? context.l10n.issueLoadBorrowerFailed,
        onRetry: _getCustomerDetails,
      );
    }

    return BorrowerProfileStep(customer: customer, onSwitch: _switchBorrower);
  }

  Widget _termsStep() {
    final customer = _customerDetails;
    if (customer == null) {
      return ErrorView(
        message: context.l10n.issueChooseBorrower,
        onRetry: () => _getCustomerDetails(),
      );
    }

    return LoanTermsStep(
      customer: customer,
      initialTerms: _terms,
      defaults: _defaults,
      onChanged: (t) =>
          setState(() => _terms = t), // the parent always has the latest
    );
  }

  Widget _disburseStep() {
    final customer = _customerDetails;
    if (customer == null) {
      return ErrorView(
        message: context.l10n.issueChooseBorrower,
        onRetry: () => _getCustomerDetails(),
      );
    }

    return LoanDisburseStep(
      customer: customer,
      terms: _terms,
      mode: _payout,
      onModeChanged: (m) => setState(() => _payout = m),
      // bankAvailable: true once you have a verified account for the borrower
    );
  }

  Widget? _bottomBar() {
    final theme = Theme.of(context);

    final Widget buttons;
    if (_step == 0) {
      buttons = AppButton(
        label: context.l10n.issueContinueTerms,
        suffixIcon: Icons.arrow_forward,
        radius: AppSizes.md,
        onPressed: _customerDetails == null ? null : _next,
      );
    } else if (_step == 1) {
      buttons = Row(
        children: [
          Expanded(
            child: AppButton(
              label: context.l10n.commonBack,
              outlined: true,
              prefixIcon: Icons.arrow_back,
              radius: AppSizes.md,
              onPressed: _back,
            ),
          ),
          AppGap.w12,
          Expanded(
            child: AppButton(
              label: context.l10n.issueNextStep,
              suffixIcon: Icons.arrow_forward,
              radius: AppSizes.md,
              onPressed: _terms.isValid ? _next : null,
            ),
          ),
        ],
      );
    } else {
      return DisburseBar(
        netAmount: _terms.netDisbursed,
        mode: _payout,
        isLoading: _issuing,
        onPressed: (_customerDetails == null || !_terms.isValid)
            ? null
            : _issueLoan,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: buttons,
        ),
      ),
    );
  }
}
