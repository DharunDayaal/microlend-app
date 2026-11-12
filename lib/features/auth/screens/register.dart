import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_chip_select.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_security_rating.dart';
import 'package:micro_lending_app/common/widgets/app_step_progress.dart';
import 'package:micro_lending_app/common/widgets/app_text_field.dart';
import 'package:micro_lending_app/common/widgets/auth_app_bar.dart';
import 'package:micro_lending_app/common/widgets/otp_verification_sheet.dart';
import 'package:micro_lending_app/data/services/auth_service.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/duration.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/device/device_utils.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/input_formatters.dart';
import 'package:micro_lending_app/utils/formatters/number_formatter.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';
import 'package:micro_lending_app/utils/helpers/password_strength.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/helpers/validators.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class RegisterScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final FocusNode _passwordFocusNode;
  final _stepOneFormKey = GlobalKey<FormState>();
  final _stepTwoFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _intrestController = TextEditingController();
  final _feeController = TextEditingController();
  final _monthsController = TextEditingController();
  late final ScrollController _scrollController;
  static const _otpPurpose = "VERIFY_PHONE_NUMBER";

  bool _showSecurityRating = false;
  bool _isBottomBarVisible = true;
  bool _sendingOtp = false;
  bool _isRegistering = false;
  int _step = 0;
  int _strength = 0;
  double _interestSelected = 10.0;
  double _feeSelected = 5.0;
  double _monthSelected = 2.5;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _passwordFocusNode = FocusNode();
    _passwordFocusNode.addListener(() {
      setState(() {
        _showSecurityRating = _passwordFocusNode.hasFocus;
      });
    });
    _intrestController.text = _interestSelected.toString();
    _feeController.text = _feeSelected.toString();
    _monthsController.text = _monthSelected.toString();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = false);
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_isBottomBarVisible) {
        setState(() => _isBottomBarVisible = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _passwordFocusNode.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _intrestController.dispose();
    _feeController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  LoanBreakdown get _loanBreakdown => LoanHelper.breakdown(
    principal: 10000,
    feePercent: double.tryParse(_feeController.text.trim()) ?? _feeSelected,
    interestPercent:
        double.tryParse(_intrestController.text.trim()) ?? _interestSelected,
    totalWeeks: LoanHelper.totalWeeksFromMonths(
      double.tryParse(_monthsController.text.trim()) ?? _monthSelected,
    ),
  );

  Future<void> _verifyOtp() async {
    if (_sendingOtp) return;
    if (!_stepOneFormKey.currentState!.validate()) return;
    DeviceUtils.hideKeyboard(context);
    final phone = PhoneFormatter.toE164(_phoneNumberController.text.trim());

    setState(() => _sendingOtp = true);
    try {
      final response = await AuthService.sendOtpCode(
        phoneNumber: phone,
        purpose: _otpPurpose,
      );
      if (!mounted) return;

      if (!response.success) {
        AppSnackbar.error(context, response.message);
      }
    } on ApiException catch (e) {
      DeviceUtils.error();
      if (mounted) AppSnackbar.error(context, e.message);
      return;
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }

    if (!mounted) return;
    final verified = await OtpVerificationSheet.show(
      context,
      phoneNumber: phone,
      purpose: _otpPurpose,
    );
    if (mounted && verified) {
      _goToStepTwo();
    }
  }

  void _goToStepTwo() {
    setState(() => _step = 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: AppDurations.normal,
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _register() async {
    if (_isRegistering) return;
    if (!_stepTwoFormKey.currentState!.validate()) return;
    setState(() => _isRegistering = true);

    try {
      final response = await AuthService.register(
        userName: _nameController.text.trim(),
        phoneNumber: PhoneFormatter.toE164(_phoneNumberController.text.trim()),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        defaultUpfrontFeePercentage:
            double.tryParse(_feeController.text.trim()) ?? 0.0,
        defaultInterestPercentage:
            double.tryParse(_intrestController.text.trim()) ?? 0.0,
        defaultTotalMonths:
            double.tryParse(_monthsController.text.trim()) ?? 0.0,
      );

      if (response != null && mounted) {
        context.go(AppRoutes.approvalPending, extra: response);
      }
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      setState(() => _isRegistering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textButtonTheme = Theme.of(context).textButtonTheme;

    return Scaffold(
      appBar: AuthAppBar(title: "Registeration"),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    spacing: AppSizes.lg,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_step == 1) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppIconButton(
                              icon: Icons.arrow_back_ios,
                              onPressed: () => setState(() => _step = 0),
                            ),
                            Text("Back to step 1", style: textTheme.bodyLarge),
                          ],
                        ),
                      ],
                      AppStepProgress(
                        steps: [
                          StepItem(
                            title: "Step 1",
                            subtitle: "Personal Details",
                            doneSubtitle: "Done",
                          ),
                          StepItem(
                            title: "Step 2",
                            subtitle: "Lending Terms",
                            doneSubtitle: "Done",
                          ),
                        ],
                        currentStep: _step,
                      ),
                      if (_step == 0) ...[
                        Text(
                          "Registeration",
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Step 1 of 2: Personal Details. Enter your information to create your account.",
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Form(
                          key: _stepOneFormKey,
                          child: Column(
                            spacing: AppSizes.xl,
                            children: [
                              AppTextField(
                                label: "Full name",
                                hint: "Enter your name",
                                prefixIcon: Icons.badge_outlined,
                                labelIcon: Icons.person_outline,
                                textInputAction: TextInputAction.next,
                                controller: _nameController,
                                isRequired: true,
                                validator: AppValidators.name,
                              ),
                              AppTextField(
                                label: "Phone Number",
                                hint: "Enter your mobile number",
                                prefixIcon: Icons.badge_outlined,
                                labelIcon: Icons.phone_android_outlined,
                                prefixText: "+91",
                                textInputAction: TextInputAction.next,
                                controller: _phoneNumberController,
                                keyboardType: TextInputType.phone,
                                isRequired: true,
                                validator: AppValidators.phone,
                              ),
                              AppTextField(
                                label: "Email Address",
                                hint: "Enter your email address",
                                prefixIcon: Icons.alternate_email_outlined,
                                labelIcon: Icons.email_outlined,
                                textInputAction: TextInputAction.next,
                                controller: _emailController,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return null;
                                  }

                                  return AppValidators.email(v);
                                },
                              ),
                              AppTextField(
                                label: "Create Password",
                                hint: "Enter your password",
                                prefixIcon: Icons.password_outlined,
                                labelIcon: Icons.lock_reset_rounded,
                                focusNode: _passwordFocusNode,
                                textInputAction: TextInputAction.done,
                                controller: _passwordController,
                                onChanged: (v) => setState(
                                  () => _strength = PasswordStrength.score(v),
                                ),
                                isPassword: true,
                                validator: (v) {
                                  return AppValidators.password(v);
                                },
                                isRequired: true,
                              ),
                              if (_showSecurityRating) ...[
                                AppSecurityRating(
                                  level: _strength,
                                  title: 'Security Rating',
                                  showLevelLabel: true,
                                  levelLabels: const [
                                    'Low',
                                    'Medium',
                                    'High',
                                    'Excellent',
                                  ],
                                  levelColors: const [
                                    Colors.red,
                                    Colors.orange,
                                    Colors.lightGreen,
                                    Colors.green,
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ] else ...[
                        Text(
                          "Lending Terms",
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Final step - set your standard lending parameters. These defaults will pre-populate your loan origination calculator.",
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Form(
                          key: _stepTwoFormKey,
                          child: Column(
                            children: [
                              _container(
                                Column(
                                  children: [
                                    Row(
                                      spacing: AppSizes.md,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        AppNameCard(name: _nameController.text),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              spacing: AppSizes.sm,
                                              children: [
                                                Text(
                                                  "VERIFIED PROFILE",
                                                  style: textTheme.labelLarge
                                                      ?.copyWith(
                                                        color:
                                                            AppColors.success,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Icon(
                                                  Icons.verified_outlined,
                                                  size: AppSizes.lg,
                                                  color: AppColors.success,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              TextFormatter.titleCase(
                                                _nameController.text,
                                              ),
                                              style: textTheme.headlineSmall,
                                            ),
                                            Text(
                                              TextFormatter.titleCase(
                                                "Field user",
                                              ),
                                              style: textTheme.labelLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              _container(
                                TermsContent(
                                  title: "Default Interest Rate",
                                  statusLabel: "Flat Rate",
                                  statusColor: AppColors.warningContainer
                                      .withAlpha(AppAlphas.badgeFill),
                                  statusLabelColor: AppColors.progressWarning,
                                  chipOptions: [
                                    ChipOption(value: 8.0, label: "8.0 %"),
                                    ChipOption(value: 10.0, label: "10.0 %"),
                                    ChipOption(value: 12.5, label: "12.5 %"),
                                    ChipOption(value: 15.5, label: "15.5 %"),
                                  ],
                                  prefixIcon: Icons.percent_outlined,
                                  controller: _intrestController,
                                  hint: "Enter your interest rate",
                                  selectedValue: _interestSelected,
                                  footerIcon: Icons.info_outline_rounded,
                                  footerLabel: "Applied flat across the full loan cycle duration.",
                                  onSelected: (value) {
                                    setState(() {
                                      _interestSelected = value;
                                    });
                                  },
                                  validatorText: "Interest rate",
                                ),
                              ),
                              _container(
                                TermsContent(
                                  title: "Upfront Processing Fee",
                                  statusLabel: "At Disbursement",
                                  statusColor: AppColors.darkBorder.withAlpha(
                                    AppAlphas.badgeFill,
                                  ),
                                  statusLabelColor: AppColors.progressSuccess,
                                  chipOptions: [
                                    ChipOption(value: 2.5, label: "2.5 %"),
                                    ChipOption(value: 5.0, label: "5.0 %"),
                                    ChipOption(value: 7.5, label: "7.5 %"),
                                    ChipOption(value: 10.0, label: "10.0 %"),
                                  ],
                                  prefixIcon: Icons.receipt_long_outlined,
                                  controller: _feeController,
                                  hint: "Enter your upfront fee",
                                  selectedValue: _feeSelected,
                                  footerIcon: Icons.payments_outlined,
                                  footerLabel: "Deducted immediately from cash handover upon spot disbursement.",
                                  onSelected: (value) {
                                    setState(() {
                                      _feeSelected = value;
                                    });
                                  },
                                  validatorText: "Upfront fee",
                                ),
                              ),
                              _container(
                                TermsContent(
                                  title: "Total Duration (Months)",
                                  statusLabel: "Weekly Schedule",
                                  statusColor: AppColors.darkPrimary.withAlpha(
                                    AppAlphas.badgeFill,
                                  ),
                                  statusLabelColor: AppColors.darkOnSurface,
                                  chipOptions: [
                                    ChipOption(value: 2.0, label: "2.0 MO"),
                                    ChipOption(value: 2.5, label: "2.5 MO"),
                                    ChipOption(value: 3.0, label: "3.0 MO"),
                                    ChipOption(value: 4.0, label: "4.0 MO"),
                                  ],
                                  prefixIcon: Icons.calendar_month_outlined,
                                  controller: _monthsController,
                                  hint: "Enter your interest rate",
                                  selectedValue: _monthSelected,
                                  footerIcon: Icons.info_outline_rounded,
                                  footerLabel: "Applied flat across the full loan cycle duration.",
                                  onSelected: (value) {
                                    setState(() {
                                      _monthSelected = value;
                                    });
                                  },
                                  showCalculatedTerm: true,
                                  validatorText: "Months",
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(AppSizes.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.darkSurface,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(AppSizes.radiusLg),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(AppSizes.lg),
                                      decoration: BoxDecoration(
                                        color: AppColors.darkBorder,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(
                                            AppSizes.radiusLg,
                                          ),
                                          topRight: Radius.circular(
                                            AppSizes.radiusLg,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.book_outlined),
                                          AppGap.w8,
                                          Text(
                                            "Standard Baseline\nPreview",
                                            style: textTheme.headlineSmall,
                                          ),
                                          Spacer(),
                                          Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  AppColors.lightOnSurfaceMuted,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                  AppSizes.radiusMd,
                                                ),
                                              ),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              vertical: AppSizes.xs,
                                              horizontal: AppSizes.sm,
                                            ),
                                            child: Text(
                                              "${CurrencyFormatter.format(10000)} \nLoan Model",
                                              style: textTheme.labelLarge
                                                  ?.copyWith(
                                                    color: AppColors
                                                        .stepCurrentLabel,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppGap.h8,
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(
                                              AppSizes.md,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: AppColors.darkBackground,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                  AppSizes.radiusLg,
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "NET HANDOVER CASH",
                                                  style: textTheme.labelMedium
                                                      ?.copyWith(
                                                        color: AppColors
                                                            .darkOnSurfaceMuted,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  CurrencyFormatter.format(
                                                    _loanBreakdown
                                                        .disbursedAmount,
                                                  ),
                                                  style: textTheme.headlineLarge
                                                      ?.copyWith(
                                                        color:
                                                            AppColors.success,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                AppGap.h4,
                                                Text.rich(
                                                  TextSpan(
                                                    text:
                                                        "Deducted fee: -${CurrencyFormatter.format(_loanBreakdown.upfrontFee)}\n",
                                                    style: textTheme.bodyMedium
                                                        ?.copyWith(
                                                          color: AppColors
                                                              .progressWarning,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            "(${NumberFormatter.percentSymbol(_feeController.text)})",
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSizes.md),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(
                                              AppSizes.md,
                                            ),
                                            decoration: const BoxDecoration(
                                              color: AppColors.darkBackground,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                  AppSizes.radiusLg,
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "TOTAL REPAYABLE",
                                                  style: textTheme.labelMedium
                                                      ?.copyWith(
                                                        color: AppColors
                                                            .darkOnSurfaceMuted,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.5,
                                                      ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  CurrencyFormatter.format(
                                                    _loanBreakdown.totalPayable,
                                                  ),
                                                  style: textTheme.headlineLarge
                                                      ?.copyWith(
                                                        color: AppColors
                                                            .stepCurrentLabel,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                AppGap.h4,
                                                Text(
                                                  "Includes ${CurrencyFormatter.format(_loanBreakdown.totalInterest)} (${NumberFormatter.percentSymbol(_intrestController.text)})",
                                                  style: textTheme.bodyMedium
                                                      ?.copyWith(
                                                        color: AppColors
                                                            .darkOnSurfaceMuted,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    AppGap.h8,
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.darkPrimary.withAlpha(
                                          AppAlphas.badgeFill,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(AppSizes.lg),
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: AppSizes.md,
                                        horizontal: AppSizes.sm,
                                      ),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "WEEKLY COLLECTION AMOUNT",
                                                style: textTheme.labelLarge
                                                    ?.copyWith(
                                                      color: AppColors
                                                          .stepCurrentLabel,
                                                      fontSize: AppSizes.lg,
                                                    ),
                                              ),
                                              Text(
                                                "Fixed installment every\nMonday",
                                              ),
                                            ],
                                          ),
                                          AppGap.w8,
                                          Expanded(
                                            child: Text.rich(
                                              TextSpan(
                                                style: textTheme.labelLarge
                                                    ?.copyWith(
                                                      color: AppColors
                                                          .stepCurrentLabel,
                                                      height: 1.4,
                                                    ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        "${CurrencyFormatter.format(_loanBreakdown.weeklyPayable)}\n",
                                                    style: textTheme
                                                        .headlineSmall
                                                        ?.copyWith(
                                                          color: AppColors
                                                              .stepCurrentLabel,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  const TextSpan(
                                                    text: "per week\n",
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        "(${LoanHelper.totalWeeksFromMonths(double.tryParse(_monthsController.text) ?? _monthSelected)}) weeks",
                                                    style: textTheme.labelMedium
                                                        ?.copyWith(
                                                          color: AppColors
                                                              .stepCurrentLabel
                                                              .withAlpha(200),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    AppGap.h8,
                                    Container(
                                      padding: EdgeInsets.all(AppSizes.sm),
                                      decoration: BoxDecoration(
                                        color: AppColors.darkBackground,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(AppSizes.sm),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Row(
                                            spacing: AppSizes.sm,
                                            children: [
                                              Text(
                                                "Installment Schedule",
                                                style: textTheme.labelLarge,
                                              ),
                                              Text(
                                                "Principal + Flat Int.",
                                                style: textTheme.labelLarge,
                                              ),
                                              Text(
                                                "Status",
                                                style: textTheme.labelLarge,
                                              ),
                                            ],
                                          ),
                                          AppGap.h12,
                                          Container(
                                            padding: EdgeInsets.all(
                                              AppSizes.sm,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.darkSurface,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(AppSizes.sm),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Week #01",
                                                  style: textTheme.labelLarge
                                                      ?.copyWith(
                                                        fontSize: AppSizes.lg,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Text(
                                                  CurrencyFormatter.format(
                                                    _loanBreakdown
                                                        .weeklyPayable,
                                                  ),
                                                  style: textTheme.labelLarge
                                                      ?.copyWith(
                                                        fontSize: AppSizes.lg,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: AppSizes.xs,
                                                    horizontal: AppSizes.sm,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.success,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(
                                                            AppSizes.xs,
                                                          ),
                                                        ),
                                                  ),
                                                  child: Text(
                                                    "SCHEDULED",
                                                    style: textTheme.labelLarge
                                                        ?.copyWith(
                                                          color: AppColors
                                                              .darkAppBar,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          AppGap.h12,
                                          Container(
                                            padding: EdgeInsets.all(
                                              AppSizes.sm,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.darkSurface,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(AppSizes.sm),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "Week #02",
                                                  style: textTheme.labelLarge
                                                      ?.copyWith(
                                                        fontSize: AppSizes.lg,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Text(
                                                  CurrencyFormatter.format(
                                                    _loanBreakdown
                                                        .weeklyPayable,
                                                  ),
                                                  style: textTheme.labelLarge
                                                      ?.copyWith(
                                                        fontSize: AppSizes.lg,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: AppSizes.xs,
                                                    horizontal: AppSizes.sm,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.success,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                          Radius.circular(
                                                            AppSizes.xs,
                                                          ),
                                                        ),
                                                  ),
                                                  child: Text(
                                                    "SCHEDULED",
                                                    style: textTheme.labelLarge
                                                        ?.copyWith(
                                                          color: AppColors
                                                              .darkAppBar,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          AppGap.h16,
                                          Text(
                                            "+ ${(LoanHelper.totalWeeksFromMonths(double.tryParse(_monthsController.text) ?? _monthSelected)) - 2} additonal Weekly cycles to maturity",
                                            style: textTheme.labelLarge,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Center(
                        child: TextButton(
                          onPressed: () => context.push(AppRoutes.login),
                          style: textButtonTheme.style,
                          child: Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              style: textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: "Sign In",
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.darkOnSurface,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.easeInOut,
        width: double.infinity,
        height: _isBottomBarVisible ? 120.0 : 0.0,
        child: Wrap(
          children: [
            Container(
              width: double.infinity,
              height: 110,
              padding: const EdgeInsets.only(
                top: AppSizes.sm,
                left: AppSizes.md,
                right: AppSizes.md,
                bottom: AppSizes.lg,
              ),
              decoration: const BoxDecoration(color: AppColors.darkSurface),
              child: _step == 0
                  ? _stepOneBottomNavigator(textTheme)
                  : _stepTwoBottomNavigator(textTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepOneBottomNavigator(TextTheme textTheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              spacing: AppSizes.sm,
              children: [
                const Icon(
                  Icons.storage_outlined,
                  size: AppSizes.lg,
                  color: AppColors.success,
                ),
                Text("Draft cached locally", style: textTheme.labelLarge),
              ],
            ),
            Text("STEP ${_step + 1} of 2", style: textTheme.labelLarge),
          ],
        ),
        AppGap.h4,
        AppButton(
          label: "Verify Phone Number",
          onPressed: _verifyOtp,
          isLoading: _sendingOtp,
        ),
      ],
    );
  }

  Widget _stepTwoBottomNavigator(TextTheme textTheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              spacing: AppSizes.sm,
              children: [
                const Icon(
                  Icons.storage_outlined,
                  size: AppSizes.lg,
                  color: AppColors.success,
                ),
                Text("Draft cached locally", style: textTheme.labelLarge),
              ],
            ),
            Text("STEP ${_step + 1} of 2", style: textTheme.labelLarge),
          ],
        ),
        AppGap.h4,
        AppButton(
          label: "Register",
          onPressed: _register,
          isLoading: _isRegistering,
        ),
      ],
    );
  }

  Widget _container(Widget child) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusLg)),
      ),
      child: Padding(padding: const EdgeInsets.all(AppSizes.sm), child: child),
    );
  }
}

class TermsContent extends StatefulWidget {
  final String title;
  final String statusLabel;
  final Color statusColor;
  final Color statusLabelColor;
  final List<ChipOption> chipOptions;
  final IconData prefixIcon;
  final TextEditingController controller;
  final String hint;
  final double selectedValue;
  final IconData footerIcon;
  final String footerLabel;
  final ValueChanged<double> onSelected;
  final bool showCalculatedTerm;
  final String validatorText;
  const TermsContent({
    super.key,
    required this.title,
    required this.statusLabel,
    required this.statusColor,
    required this.statusLabelColor,
    required this.chipOptions,
    required this.prefixIcon,
    required this.controller,
    required this.hint,
    required this.selectedValue,
    required this.footerIcon,
    required this.footerLabel,
    required this.onSelected,
    this.showCalculatedTerm = false,
    required this.validatorText,
  });

  @override
  State<TermsContent> createState() => _TermsContentState();
}

class _TermsContentState extends State<TermsContent> {
  @override
  void initState() {
    super.initState();
    widget.controller.text = _fmt(widget.selectedValue);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TermsContent old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  double? _liveMonths() {
    final v = double.tryParse(widget.controller.text.trim());
    return (v == null || v <= 0) ? null : v;
  }

  /// 3.0 -> "3", 2.5 -> "2.5"
  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final months = _liveMonths();
    final weeks = months == null
        ? null
        : LoanHelper.totalWeeksFromMonths(months);
    final days = weeks == null ? null : weeks * 7;

    return Column(
      spacing: AppSizes.sm,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: widget.title,
                style: textTheme.labelLarge,
                children: [
                  TextSpan(
                    text: " *",
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.progressWarning,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: widget.statusColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(AppSizes.radiusMd),
                ),
              ),
              padding: EdgeInsets.symmetric(
                vertical: AppSizes.xs,
                horizontal: AppSizes.sm,
              ),
              child: Text(
                widget.statusLabel,
                style: textTheme.labelLarge?.copyWith(
                  color: widget.statusLabelColor,
                ),
              ),
            ),
          ],
        ),
        AppChipSelect(
          options: widget.chipOptions,
          selected: months ?? widget.selectedValue,
          onSelected: (value) {
            setState(() {
              widget.controller.text = _fmt(value);
            });
            widget.onSelected(value);
          },
          showSelectedDot: false,
          radius: AppSizes.radiusLg,
          chipPadding: EdgeInsetsGeometry.symmetric(
            horizontal: AppSizes.xl,
            vertical: AppSizes.sm + 2,
          ),
          padding: EdgeInsets.all(0),
        ),
        AppTextField(
          label: "",
          hint: widget.hint,
          prefixIcon: widget.prefixIcon,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          showHeader: false,
          validator: (v) =>
              AppValidators.positiveNumber(v, widget.validatorText),
          controller: widget.controller,
          inputFormatters: [ProgressiveDecimalFormatter(decimalPlaces: 1)],
          onChanged: (_) => setState(() {}),
        ),
        if (!widget.showCalculatedTerm) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: AppSizes.sm,
            children: [
              Icon(widget.footerIcon, size: AppSizes.lg),
              Expanded(
                child: Text(widget.footerLabel, style: textTheme.labelLarge),
              ),
            ],
          ),
        ] else ...[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.darkRim.withAlpha(AppAlphas.badgeFill),
              borderRadius: BorderRadius.all(
                Radius.circular(AppSizes.radiusLg),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSizes.xl,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        color: AppColors.progressSuccess,
                      ),
                      AppGap.w8,
                      Text("Calculate Term:", style: textTheme.labelLarge),
                      AppGap.w8,
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit
                                .scaleDown, // shrinks only when it doesn't fit
                            child: Text.rich(
                              TextSpan(
                                text: "${weeks ?? 0} Weeks ",
                                style: textTheme.headlineSmall?.copyWith(
                                  color: AppColors.progressSuccess,
                                ),
                                children: [
                                  TextSpan(text: "(${days ?? 0} Days)"),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text.rich(
                    TextSpan(
                      text: "Auto calculated: ",
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.darkOnSurface,
                      ),
                      children: months == null
                          ? const [TextSpan(text: "enter the number of months")]
                          : [
                              TextSpan(text: "${_fmt(months)} months "),
                              const TextSpan(text: "x 4 weeks = "),
                              TextSpan(text: "$weeks weekly collections"),
                            ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
