import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_segmented_tabs.dart';
import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/data/models/payment_result_model.dart';
import 'package:micro_lending_app/data/services/loan_service.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

enum PaymentStatus { newPayment, partial, unpaid }

class PaymentSheet extends StatefulWidget {
  final String customerId;
  final String customerName;
  final int weekNumber;
  final int totalWeeks;
  final DateTime issuedAt;
  final double targetAmount;
  final double loanOutstandingAmount;
  final String loanId;
  final PaymentStatus status;
  final LoanTrackModel? existingTrack;

  const PaymentSheet({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.weekNumber,
    required this.totalWeeks,
    required this.issuedAt,
    required this.targetAmount,
    required this.loanOutstandingAmount,
    required this.loanId,
    this.status = PaymentStatus.newPayment,
    this.existingTrack,
  });

  static Future<PaymentResultModel?> show(
    BuildContext context, {
    required String customerId,
    required String customerName,
    required int weekNumber,
    required int totalWeeks,
    required DateTime issuedAt,
    required double targetAmount,
    required double loanOutstandingAmount,
    required String loanId,
    PaymentStatus status = PaymentStatus.newPayment,
    LoanTrackModel? existingTrack,
  }) async {
    return showModalBottomSheet<PaymentResultModel>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.85,
        child: PaymentSheet(
          customerId: customerId,
          customerName: customerName,
          weekNumber: weekNumber,
          totalWeeks: totalWeeks,
          issuedAt: issuedAt,
          targetAmount: targetAmount,
          loanOutstandingAmount: loanOutstandingAmount,
          loanId: loanId,
          status: status,
          existingTrack: existingTrack,
        ),
      ),
    );
  }

  static Future<PaymentResultModel?> showForWeek(
    BuildContext context, {
    required String customerId,
    required String customerName,
    required LoanModel loan,
    required int weekNumber,
  }) {
    final track = loan.tracks
        .where((t) => t.weekNumber == weekNumber)
        .firstOrNull;

    if (track != null && track.status == 'PAID') {
      AppSnackbar.error(context, 'Week $weekNumber is already paid in full');
      return Future.value(null);
    }

    final PaymentStatus status;
    if (track != null && track.status == 'PARTIAL') {
      status = PaymentStatus.partial;
    } else {
      final dueDate = LoanHelper.dueDateForWeek(loan.issuedAt, weekNumber);
      final today = DateTime.now();
      final isPast = dueDate.isBefore(
        DateTime(today.year, today.month, today.day),
      );
      status = isPast ? PaymentStatus.unpaid : PaymentStatus.newPayment;
    }

    return show(
      context,
      customerId: customerId,
      customerName: customerName,
      weekNumber: weekNumber,
      totalWeeks: loan.totalWeeks,
      issuedAt: loan.issuedAt,
      targetAmount: loan.weeklyPayableAmount,
      loanOutstandingAmount: loan.outstandingAmount,
      loanId: loan.id,
      status: status,
      existingTrack: track,
    );
  }

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

// ignore: unused_field
enum _PaymentMethod { cash, upi }

class _PaymentSheetState extends State<PaymentSheet> {
  final _amountController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitting = false;
  _PaymentMethod _method = _PaymentMethod.cash;

  late final DateTime _dueDate = LoanHelper.dueDateForWeek(
    widget.issuedAt,
    widget.weekNumber,
  );

  bool get _isDueToday {
    final today = DateTime.now();
    return _dueDate.year == today.year &&
        _dueDate.month == today.month &&
        _dueDate.day == today.day;
  }

  /// What's still owed for THIS week specifically.
  double get _remainingForWeek {
    if (widget.status == PaymentStatus.partial &&
        widget.existingTrack != null) {
      return widget.existingTrack!.remainingBalance;
    }
    return widget.targetAmount;
  }

  /// The real ceiling: an agent can collect up to the whole loan's
  /// remaining balance in one entry — not capped at this week's target.
  /// The backend already records any overflow correctly against this
  /// week's track and auto-closes the loan once the loan-wide total
  /// reaches total_payable_amount, whichever week the money landed on.
  double get _maxCollectable => widget.loanOutstandingAmount;

  double get _amount => CurrencyFormatter.parse(_amountController.text);

  bool get _clearsLoanEntirely =>
      _amount >= _maxCollectable && _maxCollectable > 0;
  bool get _clearsWeek => _amount >= _remainingForWeek;

  Color get _statusColor => switch (widget.status) {
    PaymentStatus.newPayment => AppColors.stepCurrentLabel,
    PaymentStatus.partial => AppColors.warning,
    PaymentStatus.unpaid => AppColors.progressDanger,
  };

  String get _statusHeadline => switch (widget.status) {
    PaymentStatus.newPayment => _isDueToday ? 'Due today' : 'Scheduled ahead',
    PaymentStatus.partial => 'Partial payment on file',
    PaymentStatus.unpaid => 'Overdue — not yet collected',
  };

  String get _statusDetail => switch (widget.status) {
    PaymentStatus.newPayment =>
      'Week ${widget.weekNumber} • ${DateFormatter.date(_dueDate)}',
    PaymentStatus.partial =>
      '${CurrencyFormatter.format(_remainingForWeek)} still owed for Week ${widget.weekNumber}',
    PaymentStatus.unpaid =>
      'Week ${widget.weekNumber} was due ${DateFormatter.date(_dueDate)}',
  };

  @override
  void initState() {
    super.initState();
    _amountController.text = _remainingForWeek.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setAmount(double value) {
    final next = value.clamp(0, _maxCollectable);
    _amountController.text = next.toStringAsFixed(0);
    _amountController.selection = TextSelection.collapsed(
      offset: _amountController.text.length,
    );
    setState(() {});
  }

  void _changeAmount(double delta) => _setAmount(_amount + delta);

  Future<void> collectPayment() async {
    final amount = _amount;
    if (amount <= 0) {
      AppSnackbar.error(context, 'Enter a valid payment amount');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await LoanService.collectPayment(
        loanId: widget.loanId,
        weekNumber: widget.weekNumber,
        amount: amount,
      );
      if (mounted) Navigator.of(context).pop(response);
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppGap.h12,
                  _dragHandle(),
                  AppGap.h8,
                  _statusBanner(text),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.lg,
                      AppSizes.lg,
                      AppSizes.lg,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(text),
                        AppGap.h4,
                        _borrowerRow(text),
                        AppGap.h16,
                        _amountHero(text),
                        AppGap.h16,
                        _quickActions(text),
                        AppGap.h12,
                        AppSegmentedTabs(
                          tabs: [
                            SegmentTab(
                              value: _PaymentMethod.cash,
                              label: "Cash",
                              icon: Icons.money_outlined,
                            ),
                            SegmentTab(
                              value: _PaymentMethod.upi,
                              label: "UPI",
                              icon: Icons.qr_code,
                            ),
                          ],
                          selected: _method,
                          onChanged: (value) => setState(() => _method = value),
                        ),
                        AppGap.h24,
                        _impactCard(text),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _footer(text),
        ],
      ),
    );
  }

  Widget _dragHandle() => Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.darkRim,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );

  Widget _statusBanner(TextTheme text) {
    final icon = switch (widget.status) {
      PaymentStatus.newPayment =>
        _isDueToday ? Icons.today_rounded : Icons.event_available_rounded,
      PaymentStatus.partial => Icons.hourglass_bottom_rounded,
      PaymentStatus.unpaid => Icons.error_outline_rounded,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.sm + 2,
      ),
      color: _statusColor.withAlpha(AppAlphas.watermark),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSm, color: _statusColor),
          AppGap.w8,
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: _statusHeadline,
                    style: text.labelMedium?.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: '  •  $_statusDetail',
                    style: text.labelSmall?.copyWith(
                      color: _statusColor.withAlpha(230),
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(TextTheme text) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Collect Payment',
            style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        AppIconButton(
          icon: Icons.close,
          color: AppColors.darkOnSurface,
          backgroundColor: AppColors.approvalBase.withAlpha(
            AppAlphas.badgeFill,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _borrowerRow(TextTheme text) {
    return Row(
      children: [
        AppNameCard(name: widget.customerName, width: 48, height: 48),
        AppGap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TextFormatter.titleCase(widget.customerName),
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${TextFormatter.dummyId(widget.customerId, "USR")} • Week ${widget.weekNumber} of ${widget.totalWeeks}',
                style: text.bodySmall?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _amountHero(TextTheme text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.lg,
        horizontal: AppSizes.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkPrimary.withAlpha(AppAlphas.watermark),
            AppColors.darkBackground.withAlpha(AppAlphas.scrim),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: AppColors.darkPrimary.withAlpha(AppAlphas.borderTint),
        ),
      ),
      child: Column(
        children: [
          Text(
            'AMOUNT TO COLLECT',
            style: text.labelSmall?.copyWith(
              letterSpacing: 1.0,
              color: AppColors.darkOnSurfaceMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          AppGap.h8,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stepperButton(Icons.remove_rounded, () => _changeAmount(-100)),
              AppGap.w12,
              IntrinsicWidth(
                child: TextField(
                  controller: _amountController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  onChanged: (_) => setState(() {}),
                  style: text.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: text.headlineMedium?.copyWith(
                      color: AppColors.darkOnSurfaceMuted,
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              AppGap.w12,
              _stepperButton(Icons.add_rounded, () => _changeAmount(100)),
            ],
          ),
          AppGap.h8,
          Text(
            'Up to ${CurrencyFormatter.format(_maxCollectable)} collectable on this loan',
            style: text.labelSmall?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepperButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: AppSizes.iconSm, color: Colors.white),
      ),
    );
  }

  Widget _quickActions(TextTheme text) {
    final clearWeek = _remainingForWeek;
    final twoWeeksAhead = (widget.targetAmount * 2)
        .clamp(0, _maxCollectable)
        .toDouble();
    final fullLoan = _maxCollectable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _chip(
                'Clear Week ${widget.weekNumber}',
                CurrencyFormatter.format(clearWeek),
                clearWeek,
                text,
              ),
            ),
            AppGap.w8,
            if (twoWeeksAhead > clearWeek && twoWeeksAhead < fullLoan)
              Expanded(
                child: _chip(
                  'Pay 2 Weeks',
                  CurrencyFormatter.format(twoWeeksAhead),
                  twoWeeksAhead,
                  text,
                ),
              ),
          ],
        ),
        AppGap.h8,
        InkWell(
          onTap: () => _setAmount(fullLoan),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm + 4,
            ),
            decoration: BoxDecoration(
              gradient: _clearsLoanEntirely
                  ? LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withAlpha(200),
                      ],
                    )
                  : null,
              color: _clearsLoanEntirely
                  ? null
                  : AppColors.success.withAlpha(AppAlphas.watermark),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: AppColors.success.withAlpha(AppAlphas.borderTint),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.celebration_rounded,
                  size: AppSizes.iconSm,
                  color: _clearsLoanEntirely ? Colors.white : AppColors.success,
                ),
                AppGap.w8,
                Expanded(
                  child: Text(
                    'Settle full loan — ${CurrencyFormatter.format(fullLoan)}',
                    style: text.labelMedium?.copyWith(
                      color: _clearsLoanEntirely
                          ? Colors.white
                          : AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (_clearsLoanEntirely)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: AppSizes.iconSm,
                    color: Colors.white,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, String amountLabel, double value, TextTheme text) {
    final selected = (_amount - value).abs() < 0.01;
    return InkWell(
      onTap: () => _setAmount(value),
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.darkPrimary.withAlpha(AppAlphas.badgeFill)
              : AppColors.darkBackground.withAlpha(AppAlphas.scrim),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: selected ? AppColors.darkPrimary : AppColors.darkBorder,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: text.labelSmall?.copyWith(
                color: selected
                    ? AppColors.darkPrimary
                    : AppColors.darkOnSurfaceMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              amountLabel,
              style: text.bodyMedium?.copyWith(
                color: selected ? Colors.white : AppColors.darkOnSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _impactCard(TextTheme text) {
    final weekAfter = (_remainingForWeek - _amount)
        .clamp(0, double.infinity)
        .toDouble();
    final loanAfter = (widget.loanOutstandingAmount - _amount)
        .clamp(0, double.infinity)
        .toDouble();

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(
        children: [
          _impactRow(
            'This week',
            _remainingForWeek,
            weekAfter,
            text,
            highlight: _clearsWeek,
          ),
          AppGap.h8,
          const Divider(height: 1),
          AppGap.h8,
          _impactRow(
            'Entire loan',
            widget.loanOutstandingAmount,
            loanAfter,
            text,
            highlight: _clearsLoanEntirely,
          ),
        ],
      ),
    );
  }

  Widget _impactRow(
    String label,
    double before,
    double after,
    TextTheme text, {
    required bool highlight,
  }) {
    final color = highlight ? AppColors.success : AppColors.darkOnSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label.toUpperCase(),
          style: text.labelSmall?.copyWith(color: AppColors.darkOnSurfaceMuted),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: CurrencyFormatter.format(before),
                style: text.bodySmall?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                ),
              ),
              TextSpan(
                text: '  →  ',
                style: text.bodySmall?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                ),
              ),
              TextSpan(
                text: highlight ? 'Cleared ✓' : CurrencyFormatter.format(after),
                style: text.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _footer(TextTheme text) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.md,
        AppSizes.lg,
        AppSizes.screenPaddingLight,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(
            color: AppColors.darkBorder.withAlpha(AppAlphas.borderTint),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: AppButton(
          label: _clearsLoanEntirely
              ? 'CONFIRM & CLOSE LOAN — ${CurrencyFormatter.format(_amount)}'
              : 'CONFIRM & RECORD ${CurrencyFormatter.format(_amount)}',
          onPressed: collectPayment,
          isLoading: _isSubmitting,
          prefixIcon: _clearsLoanEntirely
              ? Icons.celebration_rounded
              : Icons.check_circle_outline,
          backgroundColor: _clearsLoanEntirely
              ? AppColors.success
              : AppColors.darkPrimary,
          radius: AppSizes.radiusMd,
        ),
      ),
    );
  }
}
