import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/features/customers/data/customer_providers.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_chip_select.dart';
import 'package:micro_lending_app/shared/widgets/app_text_field.dart';
import 'package:micro_lending_app/shared/widgets/otp_verification_sheet.dart';
import 'package:micro_lending_app/shared/widgets/referral_selection_sheet.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';
import 'package:micro_lending_app/features/auth/data/auth_providers.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/design_system/constants/alphas.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/duration.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/device/device_utils.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/shared/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/core/utils/validators.dart';
import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';

class AddCustomerScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends ConsumerState<AddCustomerScreen> {
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
      loader: (page, search) => ref
          .read(customerRepositoryProvider)
          .customersByWeekday(
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
      AppSnackbar.warning(context, context.l10n.custFillHighlighted);
      return;
    }

    DeviceUtils.hideKeyboard(context);
    final phone = PhoneFormatter.toE164(_phoneNumberController.text);
    final name = TextFormatter.titleCase(_nameController.text);

    setState(() => _loader = true);
    try {
      if (_verifiedPhone != phone) {
        final otp = await ref
            .read(authRepositoryProvider)
            .sendOtpCode(phoneNumber: phone, purpose: _otpPurpose);
        if (!mounted) return;

        if (!otp.success) {
          DeviceUtils.error();
          AppSnackbar.error(
            context,
            _msg(otp.message, context.l10n.custOtpSendFailed),
          );
          return;
        }

        AppSnackbar.info(
          context,
          context.l10n.custOtpSentTo(PhoneFormatter.masked(phone)),
        );

        setState(() => _loader = false); // no spinner behind the sheet
        final verified = await OtpVerificationSheet.show(
          context,
          phoneNumber: phone,
          purpose: _otpPurpose,
        );
        if (!mounted) return;

        if (!verified) {
          AppSnackbar.warning(context, context.l10n.custVerifyToAdd);
          return;
        }

        setState(() {
          _verifiedPhone = phone;
          _loader = true;
        });
        AppSnackbar.success(context, context.l10n.custPhoneVerified);
      }

      final response = await ref
          .read(customerRepositoryProvider)
          .addCustomer(
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
        context.l10n.custAddedSuccess(response.customerName),
      );
      context.go(AppRoutes.customerDetail(response.id));
    } on ApiException catch (e) {
      DeviceUtils.error();
      if (mounted) {
        AppSnackbar.error(context, _msg(e.message, context.l10n.custAddFailed));
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
        AppSnackbar.error(context, context.l10n.commonSomethingWrong);
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
                  label: context.l10n.custSaveAdd,
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
                    context.l10n.custCancelDiscard,
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
              Expanded(
                flex: 2,
                child: Text(
                  context.l10n.custIdentityCredentials,
                  style: textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppGap.w8,
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
                    context.l10n.custRequiredBadge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                label: context.l10n.custFullName,
                hint: context.l10n.custEnterFullName,
                controller: _nameController,
                prefixIcon: Icons.person_outline,
                textInputAction: TextInputAction.next,
                validator: context.validators.name,
              ),
              AppGap.h16,
              AppTextField(
                label: context.l10n.custMobileNumber,
                hint: context.l10n.custEnterMobile,
                controller: _phoneNumberController,
                prefixIcon: Icons.call_outlined,
                prefixText: "+91",
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.phone,
                validator: (value) => context.validators.phone(value),
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
                          context.l10n.custPreferredDayBatch,
                          style: textTheme.labelLarge,
                        ),
                        Text(
                          context.l10n.custAssignedRoute,
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
                      context.l10n.custDayBatch(
                        weekdayLabel(context, _weekday),
                      ),
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
                      label: weekdayLabel(
                        context,
                        option["value"]!,
                        short: true,
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
              Expanded(
                flex: 2,
                child: Text(
                  context.l10n.custAddressLocation,
                  style: textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppGap.w8,
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
                    context.l10n.custVerification,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                label: context.l10n.custStreet,
                hint: context.l10n.custStreetHint,
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
                      label: context.l10n.custCity,
                      hint: context.l10n.custEnterCity,
                      controller: _cityController,
                      prefixIcon: Icons.location_city_outlined,
                      textInputAction: TextInputAction.next,
                      validator: (v) => context.validators.required(
                        v,
                        context.l10n.valFieldCity,
                      ),
                    ),
                  ),
                  AppGap.w8,
                  Expanded(
                    child: AppTextField(
                      label: context.l10n.custDistrict,
                      hint: context.l10n.custEnterDistrict,
                      controller: _ditrictController,
                      prefixIcon: Icons.map_outlined,
                      textInputAction: TextInputAction.done,
                      validator: (v) => context.validators.required(
                        v,
                        context.l10n.custDistrict,
                      ),
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
              Expanded(
                flex: 2,
                child: Text(
                  context.l10n.custReferredBy,
                  style: textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppGap.w8,
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
                    context.l10n.custOptional,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
              label: context.l10n.custSelectReferrer,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          context.l10n.custReferrerIdLine(
                            TextFormatter.dummyId(_selected!.id, "USR"),
                          ),
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
                      label: context.l10n.custChange,
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
