import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_chip_select.dart';
import 'package:micro_lending_app/shared/widgets/app_name_card.dart';
import 'package:micro_lending_app/shared/widgets/app_status_chip.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan_terms.dart';
import 'package:micro_lending_app/shared/design_system/constants/alphas.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/input_formatters.dart';
import 'package:micro_lending_app/core/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/features/loans/domain/loan_helper.dart';

/// Step 2 of issuing a loan. Starts from [initialTerms] (the user's saved
/// defaults), and reports every change through [onChanged].
class LoanTermsStep extends StatefulWidget {
  final CustomerDetails customer;
  final LoanTerms initialTerms;
  final LoanTerms defaults;
  final ValueChanged<LoanTerms> onChanged;

  const LoanTermsStep({
    super.key,
    required this.customer,
    required this.initialTerms,
    required this.defaults,
    required this.onChanged,
  });

  @override
  State<LoanTermsStep> createState() => _LoanTermsStepState();
}

class _LoanTermsStepState extends State<LoanTermsStep> {
  late LoanTerms _terms = widget.initialTerms;
  bool _showSchedule = false;

  static const _principalChips = [5000, 10000, 15000, 20000, 25000];
  static const _monthChips = [1.5, 2.0, 2.5, 3.0, 4.0];

  void _update(LoanTerms t) {
    setState(() => _terms = t);
    widget.onChanged(t);
  }

  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  DateTime _due(int week) => LoanHelper.scheduledDueDate(
    week: week,
    preferredDay: widget.customer.preferredPaymentDay,
  );

  List<int> _milestoneWeeks(int total) {
    if (total < 1) return const [];
    final mid = (total / 2).round();
    return ({1, mid, total}.where((w) => w >= 1 && w <= total).toList())
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final t = _terms;
    final d = widget.defaults;
    final usingDefaults = t.sameRatesAs(d);
    final weeks = t.totalWeeks;
    final day = widget.customer.preferredPaymentDay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BorrowerStrip(customer: widget.customer),
        AppGap.h12,

        // ----- saved defaults / reset -----
        Row(
          children: [
            Icon(
              usingDefaults ? Icons.verified_outlined : Icons.edit_outlined,
              size: AppSizes.iconSm,
              color: usingDefaults ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                usingDefaults
                    ? context.l10n.termsUsingDefaults(
                        _pct(d.feePercent),
                        _pct(d.interestPercent),
                        _num(d.months),
                      )
                    : context.l10n.termsChangedDefaults,
                style: text.labelMedium?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                ),
              ),
            ),
            if (!usingDefaults)
              TextButton(
                onPressed: () => _update(
                  t.copyWith(
                    months: d.months,
                    feePercent: d.feePercent,
                    interestPercent: d.interestPercent,
                  ),
                ),
                child: Text(context.l10n.commonReset),
              ),
          ],
        ),
        AppGap.h12,

        // ----- principal -----
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel(context.l10n.termsPrincipal),
              AppGap.h12,
              _NumberStepper(
                value: t.principal,
                step: 500,
                min: t.limits.minPrincipal,
                max: t.limits.maxPrincipal,
                prefix: '₹',
                grouped: true,
                formatters: AppInputFormatters.amount,
                onChanged: (v) => _update(t.copyWith(principal: v)),
              ),
              AppGap.h12,
              AppChipSelect<double>(
                selected: t.principal,
                onSelected: (v) => _update(t.copyWith(principal: v)),
                showSelectedDot: false,
                padding: EdgeInsets.zero,
                radius: AppSizes.radiusMd,
                options: [
                  for (final v in _principalChips)
                    ChipOption(
                      value: v.toDouble(),
                      label: CurrencyFormatter.format(v),
                    ),
                ],
              ),
            ],
          ),
        ),
        AppGap.h12,

        // ----- term -----
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SectionLabel(context.l10n.termsRepaymentMonths),
                  ),
                  AppGap.w8,
                  Flexible(
                    child: Text(
                      context.l10n.termsWeeklyMeetings,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: text.labelMedium?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              AppGap.h12,
              _NumberStepper(
                value: t.months,
                step: 0.5,
                min: t.limits.minMonths,
                max: t.limits.maxMonths,
                suffix: context.l10n.termsMonths,
                formatters: [
                  ProgressiveDecimalFormatter(
                    decimalPlaces: 1,
                    max: t.limits.maxMonths,
                  ),
                ],
                onChanged: (v) => _update(t.copyWith(months: v)),
              ),
              AppGap.h12,
              Container(
                padding: const EdgeInsets.all(AppSizes.sm + 2),
                decoration: BoxDecoration(
                  color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.termsCalculatedWeeks(weeks),
                        style: text.labelMedium,
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    AppChip(
                      label: context.l10n.termsAutoComputed,
                      radius: AppSizes.radiusSm,
                      backgroundColor: AppColors.successContainer.withAlpha(
                        AppAlphas.badgeFill,
                      ),
                      textStyle: text.labelSmall?.copyWith(
                        color: AppColors.progressSuccess,
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h12,
              AppChipSelect<double>(
                selected: t.months,
                onSelected: (v) => _update(t.copyWith(months: v)),
                showSelectedDot: false,
                padding: EdgeInsets.zero,
                radius: AppSizes.radiusMd,
                options: [
                  for (final m in _monthChips)
                    ChipOption(
                      value: m,
                      label: context.l10n.termsMonthChip(
                        m.toStringAsFixed(1),
                        (m * 4).round(),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        AppGap.h12,

        // ----- fee and interest -----
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _RatePanel(
                title: context.l10n.termsUpfrontFeeLower,
                amountText: '-${CurrencyFormatter.format(t.upfrontFee)}',
                amountColor: AppColors.warning,
                value: t.feePercent,
                max: t.limits.maxFeePercent,
                caption: context.l10n.termsProcessingRisk,
                onChanged: (v) => _update(t.copyWith(feePercent: v)),
              ),
            ),
            AppGap.w12,
            Expanded(
              child: _RatePanel(
                title: context.l10n.termsInterestRate,
                amountText: '+${CurrencyFormatter.format(t.interest)}',
                amountColor: AppColors.success,
                value: t.interestPercent,
                max: t.limits.maxInterestPercent,
                caption: context.l10n.termsFlatOnPrincipal,
                onChanged: (v) => _update(t.copyWith(interestPercent: v)),
              ),
            ),
          ],
        ),
        AppGap.h12,

        // ----- dates -----
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.termsDisbursedToday(
                  DateFormatter.dayMonth(_today),
                ),
                style: text.labelMedium,
              ),
            ),
            AppGap.w8,
            Flexible(
              child: Text(
                context.l10n.termsFirstDue(DateFormatter.weekdayDate(_due(1))),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: text.labelMedium?.copyWith(color: AppColors.success),
              ),
            ),
          ],
        ),
        AppGap.h12,

        if (t.error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: AppColors.dangerContainer.withAlpha(AppAlphas.badgeFill),
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.dangerContainer),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: AppSizes.iconSm,
                  color: AppColors.progressDanger,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    t.error!,
                    style: text.labelMedium?.copyWith(
                      color: AppColors.progressDanger,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppGap.h12,
        ],

        // ----- disbursement breakdown -----
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.termsBreakdown,
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              AppGap.h12,
              _Line(
                label: context.l10n.termsGrossPrincipal,
                value: CurrencyFormatter.format(t.principal),
              ),
              _Line(
                label: context.l10n.termsProcessingRiskPct(_pct(t.feePercent)),
                value: '-${CurrencyFormatter.format(t.upfrontFee)}',
                valueColor: AppColors.progressDanger,
              ),
              AppGap.h8,
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.successContainer.withAlpha(
                    AppAlphas.badgeFill,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: AppColors.successContainer.withAlpha(
                      AppAlphas.borderTint,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSizes.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.disburseNetCash,
                            style: text.labelSmall?.copyWith(
                              color: AppColors.progressSuccess,
                            ),
                          ),
                          Text(
                            context.l10n.termsPhysicalDisbursement,
                            style: text.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormatter.format(t.netDisbursed),
                        style: text.headlineMedium?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppGap.h8,
              _Line(
                label: context.l10n.termsFlatInterestAdded(
                  _pct(t.interestPercent),
                ),
                value: '+${CurrencyFormatter.format(t.interest)}',
                valueColor: AppColors.progressSuccess,
              ),
              _Line(
                label: context.l10n.termsTotalRepayablePI,
                value: CurrencyFormatter.format(t.totalPayable),
                bold: true,
              ),
              AppGap.h8,
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.darkPrimary.withAlpha(AppAlphas.badgeFill),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.termsWeeklyInstallmentWeeks(weeks),
                            style: text.labelLarge?.copyWith(
                              color: AppColors.stepCurrentLabel,
                            ),
                          ),
                          Text(
                            day.isEmpty
                                ? context.l10n.termsWeeklyCollection
                                : context.l10n.termsEveryDayCollection(
                                    weekdayLabel(context, day),
                                  ),
                            style: text.labelMedium?.copyWith(
                              color: AppColors.darkOnSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Text.rich(
                      TextSpan(
                        text: CurrencyFormatter.format(t.weeklyInstallment),
                        style: text.headlineSmall?.copyWith(
                          color: AppColors.stepCurrentLabel,
                          fontWeight: FontWeight.w800,
                        ),
                        children: [
                          TextSpan(
                            text: context.l10n.termsPerWeekShort,
                            style: text.labelMedium?.copyWith(
                              color: AppColors.stepCurrentLabel,
                            ),
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
        AppGap.h12,

        // ----- schedule preview -----
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _SectionLabel(context.l10n.termsMilestonePreview),
                  ),
                  AppGap.w8,
                  Text(
                    context.l10n.termsTotalWeeks(weeks),
                    style: text.labelMedium,
                  ),
                ],
              ),
              AppGap.h12,
              Row(
                spacing: AppSizes.sm,
                children: [
                  for (final w in _milestoneWeeks(weeks))
                    Expanded(child: _milestoneTile(w, weeks)),
                ],
              ),
              AppGap.h8,
              Center(
                child: TextButton.icon(
                  onPressed: weeks < 1
                      ? null
                      : () => setState(() => _showSchedule = !_showSchedule),
                  icon: Icon(
                    _showSchedule
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                  label: Text(
                    _showSchedule
                        ? context.l10n.termsHideAmortization
                        : context.l10n.termsViewAmortization(weeks),
                  ),
                ),
              ),
              if (_showSchedule && weeks > 0) _amortization(weeks),
              AppGap.h8,
              Text(
                context.l10n.termsPreviewOnly,
                style: text.labelSmall?.copyWith(
                  color: AppColors.darkOnSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _num(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
  String _pct(double v) => '${_num(v)}%';

  Widget _milestoneTile(int week, int total) {
    final text = Theme.of(context).textTheme;
    final last = week == total;

    return Container(
      padding: const EdgeInsets.all(AppSizes.sm + 2),
      decoration: BoxDecoration(
        color: (last ? AppColors.warning : AppColors.darkBackground).withAlpha(
          last ? AppAlphas.watermark : AppAlphas.scrim,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: last
            ? Border.all(
                color: AppColors.warning.withAlpha(AppAlphas.borderTint),
              )
            : null,
      ),
      child: Column(
        children: [
          Text(
            context.l10n.termsWeekDate(
              week,
              DateFormatter.dayMonth(_due(week)),
            ),
            style: text.labelSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            last
                ? context.l10n.termsFinalSettlement
                : CurrencyFormatter.format(_terms.weeklyInstallment),
            textAlign: TextAlign.center,
            style: text.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: last ? AppColors.warning : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amortization(int weeks) {
    final text = Theme.of(context).textTheme;
    final t = _terms;
    final head = text.labelSmall?.copyWith(color: AppColors.darkOnSurfaceMuted);

    Widget row(List<String> cells, {TextStyle? style}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(cells[0], style: style)),
          Expanded(flex: 3, child: Text(cells[1], style: style)),
          Expanded(
            flex: 3,
            child: Text(cells[2], style: style, textAlign: TextAlign.end),
          ),
          Expanded(
            flex: 3,
            child: Text(cells[3], style: style, textAlign: TextAlign.end),
          ),
        ],
      ),
    );

    return Column(
      children: [
        row([
          context.l10n.termsColWeek,
          context.l10n.termsColDue,
          context.l10n.termsColInstallment,
          context.l10n.termsColBalance,
        ], style: head),
        const Divider(height: 1, color: AppColors.darkBorder),
        for (var w = 1; w <= weeks; w++)
          row([
            '#$w',
            DateFormatter.dayMonth(_due(w)),
            CurrencyFormatter.format(t.weeklyInstallment),
            CurrencyFormatter.format(
              math.max(0.0, t.totalPayable - t.weeklyInstallment * w),
            ),
          ], style: text.labelMedium),
      ],
    );
  }
}

// ---------- small building blocks ----------

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.darkOnSurfaceMuted,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  const _Line({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: text.bodyMedium)),
          const SizedBox(width: AppSizes.sm),
          Text(
            value,
            style: text.bodyLarge?.copyWith(
              color: valueColor,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BorrowerStrip extends StatelessWidget {
  final CustomerDetails customer;
  const _BorrowerStrip({required this.customer});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final route = customer.preferredPaymentDay.isEmpty
        ? ''
        : context.l10n.termsDayRoute(
            weekdayLabel(context, customer.preferredPaymentDay),
          );

    return _Card(
      child: Row(
        children: [
          AppNameCard(name: customer.customerName, width: 40, height: 40),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.customerName,
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${TextFormatter.dummyId(customer.id, '#USR')}$route',
                  style: text.labelMedium?.copyWith(
                    color: AppColors.darkOnSurfaceMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatePanel extends StatelessWidget {
  final String title;
  final String amountText;
  final Color amountColor;
  final double value;
  final double max;
  final String caption;
  final ValueChanged<double> onChanged;

  const _RatePanel({
    required this.title,
    required this.amountText,
    required this.amountColor,
    required this.value,
    required this.max,
    required this.caption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionLabel(title),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amountText,
              style: text.bodyLarge?.copyWith(
                color: amountColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AppGap.h8,
          _NumberStepper(
            value: value,
            step: 0.5,
            min: 0,
            max: max,
            suffix: '%',
            compact: true,
            formatters: [
              ProgressiveDecimalFormatter(decimalPlaces: 1, max: max),
            ],
            onChanged: onChanged,
          ),
          AppGap.h8,
          Text(
            caption,
            style: text.labelSmall?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- the - [ number ] + control ----------

class _NumberStepper extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double step;
  final double min;
  final double max;
  final String? prefix;
  final String? suffix;
  final bool grouped; // 12,50,000 style
  final bool compact;
  final List<TextInputFormatter> formatters;

  const _NumberStepper({
    required this.value,
    required this.onChanged,
    required this.step,
    required this.min,
    required this.max,
    required this.formatters,
    this.prefix,
    this.suffix,
    this.grouped = false,
    this.compact = false,
  });

  @override
  State<_NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<_NumberStepper> {
  late final TextEditingController _controller = TextEditingController(
    text: _format(widget.value),
  );
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (_focus.hasFocus != _focused) {
        setState(() => _focused = _focus.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _format(double v) {
    if (widget.grouped) {
      return CurrencyFormatter.groupIndian(v.round().toString());
    }
    return v == v.truncateToDouble() ? v.toInt().toString() : v.toString();
  }

  double _parse(String s) => double.tryParse(s.replaceAll(',', '')) ?? 0;

  @override
  void didUpdateWidget(covariant _NumberStepper old) {
    super.didUpdateWidget(old);
    // A chip, the +/- buttons or Reset changed the value from outside: show
    // it. Typing never lands here, because the text already matches.
    if (_parse(_controller.text) != widget.value) {
      final t = _format(widget.value);
      _controller.value = TextEditingValue(
        text: t,
        selection: TextSelection.collapsed(offset: t.length),
      );
    }
  }

  void _bump(double delta) {
    final v = (widget.value + delta).clamp(widget.min, widget.max).toDouble();
    widget.onChanged(double.parse(v.toStringAsFixed(2)));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final primary = Theme.of(context).colorScheme.primary;

    final compact = widget.compact;
    final btn = compact ? 36.0 : 48.0;
    final height = compact ? 44.0 : 64.0;
    final style = (compact ? text.bodyLarge : text.headlineMedium)?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final affix = style?.copyWith(
      color: AppColors.darkOnSurfaceMuted,
      fontWeight: FontWeight.w500,
    );

    return Row(
      children: [
        _StepButton(
          icon: Icons.remove,
          tooltip: context.l10n.commonDecrease,
          size: btn,
          onTap: widget.value <= widget.min ? null : () => _bump(-widget.step),
        ),
        SizedBox(width: compact ? 6 : AppSizes.sm),
        Expanded(
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 4 : AppSizes.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: _focused ? primary : AppColors.darkBorder,
                width: _focused ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                if (widget.prefix != null) Text(widget.prefix!, style: affix),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    textAlign: TextAlign.center,
                    style: style,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: widget.formatters,
                    onChanged: (v) => widget.onChanged(_parse(v)),
                    // the theme draws borders on every TextField: turn them all off
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (widget.suffix != null) Text(widget.suffix!, style: affix),
              ],
            ),
          ),
        ),
        SizedBox(width: compact ? 6 : AppSizes.sm),
        _StepButton(
          icon: Icons.add,
          tooltip: context.l10n.commonIncrease,
          size: btn,
          onTap: widget.value >= widget.max ? null : () => _bump(widget.step),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final double size;
  final VoidCallback? onTap;
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSizes.radiusMd);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.darkBorder,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(
              icon,
              size: 20,
              color: onTap == null
                  ? AppColors.darkOnSurfaceMuted.withAlpha(120)
                  : AppColors.darkOnSurface,
            ),
          ),
        ),
      ),
    );
  }
}
