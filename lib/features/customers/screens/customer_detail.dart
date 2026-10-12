import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/data/models/customer_model.dart';
import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/data/services/customer_service.dart';
import 'package:micro_lending_app/data/services/loan_service.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/device/launcher_utils.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/features/customers/widgets/active_facility_card.dart';
import 'package:micro_lending_app/features/customers/widgets/address_card.dart';
import 'package:micro_lending_app/features/customers/widgets/credit_history_card.dart';
import 'package:micro_lending_app/features/customers/widgets/issue_loan_bar.dart';
import 'package:micro_lending_app/features/customers/widgets/social_network_card.dart';

class CustomerDetailScreen extends StatefulWidget {
  final String customerId;
  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  CustomerDetails? _customerDetails;
  final List<LoanItem> _customerLoans = [];
  LoanModel? _loanDetails;
  LoanModel? _activeOrOverdueLoanDetails;
  final List<ReferralItem> _customerReferrals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDatas();
  }

  Future<void> _loadDatas() async {
    setState(() {
      _isLoading = true;
    });
    await Future.wait([
      _getCustomerDetails(),
      _getCustomerLoans(),
      _getCustomerReferrals(),
    ]);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCustomerDetails() async {
    try {
      final response = await CustomerService.getCustomerDetails(
        customerId: widget.customerId,
      );

      if (!mounted) return;

      if (response.success) {
        setState(() => _customerDetails = response);
      }
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    }
  }

  Future<void> _getCustomerLoans() async {
    try {
      final res = await CustomerService.getCustomerLoans(
        customerId: widget.customerId,
      );
      if (!mounted) return;

      debugPrint(
        'loans: success=${res.success} count=${res.loans.length} '
        'statuses=${res.loans.map((l) => l.status).toList()}',
      );
      if (!res.success) return;

      setState(() {
        _customerLoans
          ..clear()
          ..addAll(res.loans);
      });

      final current = res.loans.where((l) {
        final s = l.status.toUpperCase();
        return s == 'ACTIVE' || s == 'OVERDUE';
      }).firstOrNull;
      if (current == null) {
        setState(() => _activeOrOverdueLoanDetails = null);
        return;
      }

      final details = await LoanService.getLoanDetails(loanid: current.id);
      if (!mounted) return;

      debugPrint('loan details: id=${details.id}');
      setState(() => _activeOrOverdueLoanDetails = details);
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    }
  }

  Future<void> _getCustomerReferrals() async {
    try {
      final response = await CustomerService.getCustomerReferrals(
        customerId: widget.customerId,
      );
      if (!mounted) return;
      if (response.success) {
        setState(() {
          _customerReferrals
            ..clear()
            ..addAll(response.referrals);
        });
      }
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    }
  }

  /// Based on the loans list, not the details call: if details fail to load
  /// the customer still has an open loan, and the button must stay disabled.
  bool get _hasOpenLoan => _customerLoans.any((l) {
    final s = l.status.toUpperCase();
    return s == 'ACTIVE' || s == 'OVERDUE';
  });

  /// Finished loans, newest first. Cycle numbers count from the first loan ever.
  List<CycleSummary> get _completedCycles {
    final all = [..._customerLoans]
      ..sort((a, b) => a.issuedAt.compareTo(b.issuedAt)); // field assumed

    final cycles = <CycleSummary>[];
    for (var i = 0; i < all.length; i++) {
      final l = all[i];
      final s = l.status.toUpperCase();
      if (s == 'ACTIVE' || s == 'OVERDUE') continue;

      cycles.add(
        CycleSummary(
          cycleNo: i + 1,
          loanId: l.id,
          amount: l.nominalAmount.toDouble(), // field assumed
          closedAt: l.closedAt, // field assumed
          outcome: switch (s) {
            'PAID_OFF' =>
              CycleOutcome.paid, // needs a backend flag to be "delayed"
            'DEFAULTED' => CycleOutcome.defaulted,
            _ => CycleOutcome.closed,
          },
        ),
      );
    }
    return cycles.reversed.toList();
  }

  Future<void> _issueLoan() async {
    // await context.push(AppRoutes.issueLoan(1, widget.customerId));
    if (mounted) _loadDatas(); // the loan may exist now
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loan = _activeOrOverdueLoanDetails;
    final nextDue = loan == null ? null : LoanHelper.nextDueDate(loan);
    final nextTrack = loan == null ? null : LoanHelper.nextDueTrack(loan);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: ((context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(AppSizes.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppIconButton(
                          icon: Icons.arrow_back_ios,
                          onPressed: () => context.go(AppRoutes.customersList),
                        ),
                        Text("Back to Home", style: textTheme.bodyLarge),
                      ],
                    ),
                    AppGap.h24,
                    _WidgetContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _isLoading
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const AppShimmer(
                                      child: SkeletonBox(
                                        width: 45,
                                        height: 45,
                                        radius: AppSizes.radiusMd,
                                      ),
                                    ),
                                    AppGap.w16,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const AppShimmer(
                                            child: SkeletonBox(
                                              width: 140,
                                              height: 24,
                                            ),
                                          ),
                                          AppGap.h8,
                                          const AppShimmer(
                                            child: SkeletonBox(
                                              width: 190,
                                              height: 16,
                                            ),
                                          ),
                                          AppGap.h8,
                                          Row(
                                            spacing: AppSizes.sm,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: const [
                                              AppShimmer(
                                                child: SkeletonBox(
                                                  width: 20,
                                                  height: 20,
                                                ),
                                              ),
                                              AppShimmer(
                                                child: SkeletonBox(
                                                  width: 100,
                                                  height: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    AppNameCard(
                                      width: 54,
                                      height: 54,
                                      textColor: AppColors.stepCurrentLabel,
                                      name:
                                          _customerDetails?.customerName ?? '',
                                    ),
                                    AppGap.w16,
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            TextFormatter.titleCase(
                                              _customerDetails?.customerName ??
                                                  '',
                                            ),
                                            style: textTheme.headlineMedium,
                                          ),
                                          Text.rich(
                                            TextSpan(
                                              style: textTheme.bodyLarge
                                                  ?.copyWith(
                                                    color: AppColors
                                                        .stepCurrentLabel,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      "#${TextFormatter.dummyId(_customerDetails?.id ?? '', "USR")} ",
                                                ),
                                                TextSpan(
                                                  style: textTheme.labelLarge,
                                                  text:
                                                      "• Reg: ${DateFormatter.dateTime(_customerDetails?.createdAt)}",
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (_customerDetails
                                                  ?.creditHistory
                                                  .totalLoans !=
                                              0) ...[
                                            AppGap.h4,
                                            Row(
                                              spacing: AppSizes.sm,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.stars_outlined,
                                                  color: AppColors.warning,
                                                  size: 20,
                                                ),
                                                Text(
                                                  "Cycle ${_customerDetails?.creditHistory.totalLoans.toString() ?? '0'} Eligible",
                                                  style: textTheme.labelMedium
                                                      ?.copyWith(
                                                        color:
                                                            AppColors.warning,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                          AppGap.h16,
                          _isLoading
                              ? _WidgetContainer(
                                  bgColor: AppColors.darkBackground.withAlpha(
                                    AppAlphas.badgeFill,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const AppShimmer(
                                        child: SkeletonBox(
                                          width: 40,
                                          height: 40,
                                          radius: AppSizes.radiusMd,
                                        ),
                                      ),
                                      AppGap.w16,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const AppShimmer(
                                              child: SkeletonBox(
                                                width: 110,
                                                height: 16,
                                              ),
                                            ),
                                            AppGap.h8,
                                            const AppShimmer(
                                              child: SkeletonBox(
                                                width: 90,
                                                height: 14,
                                              ),
                                            ),
                                            AppGap.h8,
                                          ],
                                        ),
                                      ),
                                      Spacer(),
                                      AppShimmer(
                                        child: SkeletonBox(
                                          width: 90,
                                          height: 22,
                                          radius: AppSizes.radiusFull,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _WidgetContainer(
                                  bgColor: AppColors.darkBackground.withAlpha(
                                    AppAlphas.badgeFill,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      _WidgetContainer(
                                        width: 40,
                                        height: 40,
                                        padding: EdgeInsets.all(AppSizes.sm),
                                        child: Icon(Icons.fire_truck_outlined),
                                      ),
                                      AppGap.w16,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Assigned Route",
                                              style: textTheme.labelLarge
                                                  ?.copyWith(
                                                    color: AppColors.lightHint,
                                                  ),
                                            ),
                                            Text(
                                              "${TextFormatter.titleCase(_customerDetails?.preferredPaymentDay ?? '')} Route",
                                              style: textTheme.headlineSmall,
                                            ),
                                          ],
                                        ),
                                      ),
                                      _WidgetContainer(
                                        width: 85,
                                        padding: EdgeInsets.all(
                                          AppSizes.sm - 4,
                                        ),
                                        bgColor: AppColors.lightOnSurfaceMuted
                                            .withAlpha(AppAlphas.badgeFill),
                                        containerRadius: BorderRadius.all(
                                          Radius.circular(AppSizes.radiusFull),
                                        ),
                                        child: Text(
                                          DateFormatter.formatTimeString(
                                            _customerDetails
                                                    ?.preferredPaymentTime ??
                                                '',
                                          ),
                                          style: textTheme.labelMedium
                                              ?.copyWith(
                                                color: AppColors.lightHint,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          AppGap.h16,
                          if (!_isLoading)
                            AppButton(
                              label: "Call Borrower",
                              prefixIcon: Icons.call_outlined,
                              outlined: true,
                              iconColor: AppColors.success,
                              onPressed: () async {
                                final ok = await LauncherUtils.call(
                                  _customerDetails?.phoneNumber ?? '',
                                );
                                if (!ok && context.mounted) {
                                  AppSnackbar.error(
                                    context,
                                    'Unable to open dialer',
                                  );
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                    AppGap.h24,
                    if (_isLoading) ...[
                      const AppShimmer(
                        child: SkeletonBox(
                          height: 160,
                          radius: AppSizes.radiusLg,
                        ),
                      ),
                      AppGap.h24,
                      const AppShimmer(
                        child: SkeletonBox(
                          height: 220,
                          radius: AppSizes.radiusLg,
                        ),
                      ),
                    ] else ...[
                      if (loan != null) ...[
                        ActiveFacilityCard(
                          loan: loan,
                          preferredDay: _customerDetails?.preferredPaymentDay,
                        ),
                        AppGap.h24,
                      ],
                      CreditHistoryCard(cycles: _completedCycles),
                      AppGap.h24,
                      SocialNetworkCard(
                        referrerName:
                            _customerDetails?.referredByName, // field assumed
                        customerName: _customerDetails?.customerName ?? '',
                        referredCount: _customerReferrals.length,
                      ),
                      AppGap.h24,
                      AddressCard(
                        street: _customerDetails?.streetName, // fields assumed
                        city: _customerDetails?.city,
                        district: _customerDetails?.district,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
      bottomNavigationBar: IssueLoanBar(
        customerName: _customerDetails?.customerName ?? '',
        cycleNo: _customerLoans.length + 1,
        canIssue: !_isLoading && _customerDetails != null && !_hasOpenLoan,
        blockedMessage: _hasOpenLoan
            ? 'Close the current active loan before issuing a new one.'
            : null,
        onPressed: _issueLoan,
      ),
    );
  }
}

class _WidgetContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final Color? bgColor;
  final BorderRadius? containerRadius;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  const _WidgetContainer({
    required this.child,
    this.width = double.infinity,
    this.height,
    this.bgColor,
    this.containerRadius,
    this.padding,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color:
            bgColor ??
            AppColors.lightOnSurfaceMuted.withAlpha(AppAlphas.badgeFill),
        borderRadius:
            containerRadius ?? BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color:
              borderColor ??
              bgColor ??
              AppColors.darkSurface.withAlpha(AppAlphas.badgeFill),
        ),
      ),
      child: child,
    );
  }
}
