import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_chip_select.dart';
import 'package:micro_lending_app/common/widgets/app_text_field.dart';
import 'package:micro_lending_app/common/widgets/otp_verification_sheet.dart';
import 'package:micro_lending_app/common/widgets/referral_selection_sheet.dart';
import 'package:micro_lending_app/data/models/customer_model.dart';
import 'package:micro_lending_app/data/services/auth_service.dart';
import 'package:micro_lending_app/data/services/customer_service.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/duration.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/device/device_utils.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/helpers/validators.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class AddCustomerScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, String>> _weekdayOptions = [
    {"value": "MONDAY", "label": "MON"},
    {"value": "TUESDAY", "label": "TUE"},
    {"value": "WEDNESDAY", "label": "WED"},
    {"value": "THURSDAY", "label": "THR"},
    {"value": "FRIDAY", "label": "FRI"},
    {"value": "SATURDAY", "label": "SAT"},
    {"value": "SUNDAY", "label": "SUN"},
  ];

  String _weekday = DateFormatter.weekdayFull(DateTime.now());
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _ditrictController = TextEditingController();
  final _scroll = ScrollController();

  bool _showBottomNavigator = true;
  bool _loader = false;
  Customer? _selected;
  static const _otpPurpose = "VERIFY_PHONE_NUMBER";
  String? _verifiedPhone;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneNumberController.dispose();
    _streetNameController.dispose();
    _cityController.dispose();
    _ditrictController.dispose();
    _scroll.removeListener(_scrollListener);
    _scroll.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scroll.position.userScrollDirection == ScrollDirection.reverse) {
      if (_showBottomNavigator) {
        setState(() => _showBottomNavigator = false);
      }
    } else if (_scroll.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showBottomNavigator) {
        setState(() => _showBottomNavigator = true);
      }
    }
  }

  Future<void> _selectReferrer() async {
    final response = await ReferralSelectionSheet.show(
      context,
      selectedId: _selected?.id,
      loader: (page, search) => CustomerService.getCustomersByWeekday(
        weekday: _weekday,
        page: page,
        limit: 20,
        search: search,
      ),
    );

    if (response != null && mounted) {
      setState(() {
        _selected = response;
      });
    }
  }

  String _msg(String? serverMessage, String fallback) =>
      (serverMessage == null || serverMessage.trim().isEmpty)
      ? fallback
      : serverMessage;

  Future<void> _addBorrower() async {
    if (_loader) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      DeviceUtils.error();
      AppSnackbar.warning(context, 'Please fill the highlighted fields.');
      return;
    }

    DeviceUtils.hideKeyboard(context);
    final phone = PhoneFormatter.toE164(_phoneNumberController.text);
    final name = TextFormatter.titleCase(_nameController.text);

    setState(() => _loader = true);
    try {
      if (_verifiedPhone != phone) {
        final otp = await AuthService.sendOtpCode(
          phoneNumber: phone,
          purpose: _otpPurpose,
        );
        if (!mounted) return;

        if (!otp.success) {
          DeviceUtils.error();
          AppSnackbar.error(
            context,
            _msg(
              otp.message,
              "Couldn't send the verification code. Try again.",
            ),
          );
          return;
        }

        AppSnackbar.info(
          context,
          'Verification code sent to ${PhoneFormatter.masked(phone)}.',
        );

        setState(() => _loader = false); // no spinner behind the sheet
        final verified = await OtpVerificationSheet.show(
          context,
          phoneNumber: phone,
          purpose: _otpPurpose,
        );
        if (!mounted) return;

        if (!verified) {
          AppSnackbar.warning(
            context,
            'Verify the phone number to add this borrower.',
          );
          return;
        }

        setState(() {
          _verifiedPhone = phone;
          _loader = true;
        });
        AppSnackbar.success(context, 'Phone number verified.');
      }

      final response = await CustomerService.addCustomer(
        name: name,
        phoneNumber: phone,
        weekday: _weekday,
        referrerId: _selected?.id,
        streetName: _streetNameController.text.trim(),
        city: _cityController.text.trim(),
        district: _ditrictController.text.trim(),
      );
      if (!mounted) return;

      DeviceUtils.success();
      AppSnackbar.success(
        context,
        '${response.customerName} was added successfully.',
      );
      context.go(AppRoutes.customerDetail(response.id));
    } on ApiException catch (e) {
      DeviceUtils.error();
      if (mounted) {
        AppSnackbar.error(
          context,
          _msg(e.message, "Couldn't add the borrower. Please try again."),
        );
      }
    } catch (e, st) {
      AppLogger.error(
        'addBorrower failed',
        tag: 'AddCustomer',
        error: e,
        stack: st,
      );
      DeviceUtils.error();
      if (mounted) {
        AppSnackbar.error(context, 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loader = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scroll,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSizes.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _identityDetails(textTheme),
                      AppGap.h24,
                      _addressDetails(textTheme),
                      AppGap.h24,
                      _addReferrer(textTheme),
                      AppGap.h4,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: AnimatedAlign(
          duration: AppDurations.normal,
          curve: Curves.easeInOut,
          heightFactor: _showBottomNavigator ? 1 : 0,
          alignment: Alignment.topCenter,
          child: _WidgetContainer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  label: "Save & Add Borrower",
                  onPressed: _addBorrower,
                  prefixIcon: Icons.person_add_outlined,
                  radius: AppSizes.radiusLg,
                  isLoading: _loader,
                ),
                TextButton(
                  onPressed: () {
                    // dispose();
                    context.pop();
                  },
                  child: Text(
                    "Cancel & Discard",
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.darkHint,
                    ),
                  ),
                ),
                AppGap.h4,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _identityDetails(TextTheme textTheme) {
    return _WidgetContainer(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _WidgetContainer(
                width: 45,
                height: 45,
                bgColor: AppColors.approvalGlowIndigo.withAlpha(
                  AppAlphas.badgeFill,
                ),
                padding: EdgeInsets.zero,
                child: Center(
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.darkOnSurface,
                  ),
                ),
              ),
              AppGap.w12,
              Text("Identity Credentials", style: textTheme.bodyLarge),
              SizedBox(width: AppSizes.xl + 2),
              Expanded(
                child: _WidgetContainer(
                  padding: EdgeInsets.all(AppSizes.sm - 4),
                  bgColor: AppColors.warningContainer.withAlpha(
                    AppAlphas.badgeFill,
                  ),
                  borderColor: AppColors.warning.withAlpha(AppAlphas.badgeFill),
                  containerRadius: BorderRadius.all(
                    Radius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    "Required",
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.warning,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          AppGap.h16,
          _divider(),
          AppGap.h24,
          Column(
            children: [
              AppTextField(
                label: "Full Name",
                hint: "Enter full name",
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: AppValidators.name,
              ),
              AppGap.h16,
              AppTextField(
                label: "Mobile number",
                hint: "Enter mobile number",
                controller: _phoneNumberController,
                prefixIcon: Icons.call_outlined,
                prefixText: "+91",
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.phone,
                validator: (value) => AppValidators.phone(value),
                showValidIcon: _verifiedPhone != null ? true : false,
              ),
              AppGap.h16,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Preferred Day Batch",
                          style: textTheme.labelLarge,
                        ),
                        Text(
                          "Assigned to weekly field collection route",
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.darkHint,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _WidgetContainer(
                    width: null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.xs + 2,
                    ),
                    bgColor: AppColors.approvalGlowIndigo.withAlpha(
                      AppAlphas.badgeFill,
                    ),
                    containerRadius: BorderRadius.circular(AppSizes.radiusFull),
                    child: Text(
                      "${TextFormatter.titleCase(_weekday)} Batch",
                      style: textTheme.labelMedium,
                    ),
                  ),
                ],
              ),
              AppGap.h16,
              AppChipSelect(
                chipHeight: 80,
                selected: _weekday,
                onSelected: (value) {
                  setState(() => _weekday = value);
                },
                padding: EdgeInsets.all(0),
                radius: AppSizes.md,
                options: [
                  for (final option in _weekdayOptions)
                    ChipOption(
                      value: option["value"]!,
                      label: option["label"]!,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addressDetails(TextTheme textTheme) {
    return _WidgetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _WidgetContainer(
                width: 45,
                height: 45,
                bgColor: AppColors.successContainer.withAlpha(
                  AppAlphas.badgeFill,
                ),
                padding: EdgeInsets.zero,
                child: Center(
                  child: Icon(
                    Icons.location_on_outlined,
                    color: AppColors.success,
                  ),
                ),
              ),
              AppGap.w12,
              Text("Address & Location", style: textTheme.bodyLarge),
              SizedBox(width: AppSizes.xl + 2),
              Expanded(
                child: _WidgetContainer(
                  padding: EdgeInsets.all(AppSizes.sm - 4),
                  bgColor: AppColors.lightOnSurfaceMuted.withAlpha(
                    AppAlphas.badgeFill,
                  ),
                  containerRadius: BorderRadius.all(
                    Radius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    "Verification",
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.lightHint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          AppGap.h16,
          _divider(),
          AppGap.h16,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: "Street Name / House No.",
                hint: "Street name or number",
                controller: _streetNameController,
                prefixIcon: Icons.home_outlined,
                textInputAction: TextInputAction.next,
                validator: null,
              ),
              AppGap.h16,
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: "City / Town",
                      hint: "Enter city",
                      controller: _cityController,
                      prefixIcon: Icons.location_city_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (v) => AppValidators.required(v, "City"),
                    ),
                  ),
                  AppGap.w8,
                  Expanded(
                    child: AppTextField(
                      label: "District",
                      hint: "Enter district",
                      controller: _ditrictController,
                      prefixIcon: Icons.map_outlined,
                      textInputAction: TextInputAction.done,
                      validator: (v) => AppValidators.required(v, "District"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addReferrer(TextTheme textTheme) {
    return _WidgetContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _WidgetContainer(
                width: 45,
                height: 45,
                bgColor: AppColors.warningContainer.withAlpha(
                  AppAlphas.badgeFill,
                ),
                padding: EdgeInsets.zero,
                child: Center(
                  child: Icon(
                    Icons.person_3_outlined,
                    color: AppColors.warning,
                  ),
                ),
              ),
              AppGap.w12,
              Text("Referred By Borrower", style: textTheme.bodyLarge),
              SizedBox(width: AppSizes.xl + 2),
              Expanded(
                child: _WidgetContainer(
                  padding: EdgeInsets.all(AppSizes.sm - 4),
                  bgColor: AppColors.lightOnSurfaceMuted.withAlpha(
                    AppAlphas.badgeFill,
                  ),
                  containerRadius: BorderRadius.all(
                    Radius.circular(AppSizes.radiusFull),
                  ),
                  child: Text(
                    "Optional",
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.lightHint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          AppGap.h24,
          if (_selected?.id == null) ...[
            AppButton(
              label: "Select Referrer Borrower",
              radius: AppSizes.radiusXl,
              onPressed: _selectReferrer,
              outlined: true,
            ),
          ] else ...[
            _WidgetContainer(
              bgColor: AppColors.darkSurface.withAlpha(AppAlphas.scrim),
              borderColor: AppColors.darkBorder,
              padding: EdgeInsets.all(AppSizes.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _WidgetContainer(
                    width: 40,
                    height: 40,
                    padding: EdgeInsets.zero,
                    containerRadius: BorderRadius.all(
                      Radius.circular(AppSizes.radiusFull),
                    ),
                    bgColor: AppColors.darkPrimary.withAlpha(
                      AppAlphas.badgeFill,
                    ),
                    child: Center(
                      child: Text(
                        TextFormatter.initials(_selected!.customerName),
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.darkOnSurface,
                        ),
                      ),
                    ),
                  ),
                  AppGap.w8,
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          _selected!.customerName,
                          style: textTheme.bodyLarge,
                        ),
                        Text(
                          "ID ${TextFormatter.dummyId(_selected!.id, "USR")} • 2 Fully Repaid Loans",
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.normal,
                            color: AppColors.lightHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppGap.w8,
                  Expanded(
                    child: AppButton(
                      height: 20,
                      width: 12,
                      padding: EdgeInsets.all(AppSizes.sm),
                      label: "Change",
                      radius: AppSizes.radiusFull,
                      suffixIcon: Icons.keyboard_arrow_down_rounded,
                      onPressed: _selectReferrer,
                      outlined: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(height: 3, thickness: 1, color: AppColors.darkBorder);
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
