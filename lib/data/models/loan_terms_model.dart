import 'package:micro_lending_app/data/models/profile_limits.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';

class LoanTerms {
  // Starting values when nothing else is known.
  static const double defaultPrincipal = 10000;
  static const double fallbackFeePercent = 5;
  static const double fallbackInterestPercent = 10;
  static const double fallbackMonths = 2.5;

  final double principal;
  final double months;
  final double feePercent;
  final double interestPercent;

  /// The server's limits (from GET /api/me). The form is checked against
  /// these, and the server checks them again.
  final ProfileLimits limits;

  const LoanTerms({
    required this.principal,
    required this.months,
    required this.feePercent,
    required this.interestPercent,
    this.limits = ProfileLimits.fallback,
  });

  /// The logged-in user's saved defaults and limits.
  factory LoanTerms.fromDefaults(
    AdminUser? user, {
    double principal = defaultPrincipal,
  }) {
    final limits = user?.limits ?? ProfileLimits.fallback;
    return LoanTerms(
      // keeps the starting amount inside the allowed range
      principal: principal.clamp(limits.minPrincipal, limits.maxPrincipal).toDouble(),
      months: user?.defaultTotalMonths ?? fallbackMonths,
      feePercent: user?.defaultUpfrontFeePercentage ?? fallbackFeePercent,
      interestPercent: user?.defaultInterestPercentage ?? fallbackInterestPercent,
      limits: limits,
    );
  }

  // ----- derived: all of it comes from LoanHelper, so the formula lives once -----

  int get totalWeeks => LoanHelper.totalWeeksFromMonths(months);

  LoanBreakdown get breakdown => LoanHelper.breakdown(
        principal: principal,
        feePercent: feePercent,
        interestPercent: interestPercent,
        totalWeeks: totalWeeks,
      );

  double get upfrontFee => breakdown.upfrontFee;
  double get netDisbursed => breakdown.disbursedAmount;
  double get interest => breakdown.totalInterest;
  double get totalPayable => breakdown.totalPayable;
  double get weeklyInstallment => breakdown.weeklyPayable;

  static String _n(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  String? get error {
    final l = limits;
    if (principal < l.minPrincipal) {
      return 'Minimum amount is ${CurrencyFormatter.format(l.minPrincipal)}';
    }
    if (principal > l.maxPrincipal) {
      return 'Maximum amount is ${CurrencyFormatter.format(l.maxPrincipal)}';
    }
    if (months < l.minMonths) return 'Term must be at least ${_n(l.minMonths)} months';
    if (months > l.maxMonths) return 'Term can be at most ${_n(l.maxMonths)} months';
    if (feePercent < 0 || feePercent > l.maxFeePercent) {
      return 'Processing fee must be between 0% and ${_n(l.maxFeePercent)}%';
    }
    if (interestPercent < 0 || interestPercent > l.maxInterestPercent) {
      return 'Interest must be between 0% and ${_n(l.maxInterestPercent)}%';
    }
    return null;
  }

  bool get isValid => error == null;

  bool sameRatesAs(LoanTerms o) =>
      feePercent == o.feePercent &&
      interestPercent == o.interestPercent &&
      months == o.months;

  LoanTerms copyWith({
    double? principal,
    double? months,
    double? feePercent,
    double? interestPercent,
  }) {
    return LoanTerms(
      principal: principal ?? this.principal,
      months: months ?? this.months,
      feePercent: feePercent ?? this.feePercent,
      interestPercent: interestPercent ?? this.interestPercent,
      limits: limits,
    );
  }

  /// Body for the issue-loan call. Optional fields are omitted when null.
  Map<String, dynamic> toIssuePayload({
    required String customerId,
    DateTime? issuedAt,
  }) =>
      {
        'customer_id': customerId,
        'nominal_amount': principal,
        'total_months': months,
        'upfront_fee_percentage': feePercent,
        'interest_percentage': interestPercent,
        if (issuedAt != null) 'issued_at': issuedAt.toUtc().toIso8601String(),
      };
}