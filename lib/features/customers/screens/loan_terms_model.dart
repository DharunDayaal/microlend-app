import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/utils/helpers/loan_helper.dart';

class LoanTerms {
  // Starting values when nothing else is known.
  static const double defaultPrincipal = 10000;
  static const double fallbackFeePercent = 5;
  static const double fallbackInterestPercent = 10;
  static const double fallbackMonths = 2.5;

  // Form limits. Align them with what your backend accepts.
  static const double minPrincipal = 100;
  static const double maxPrincipal = 1000000;
  static const double minMonths = 0.5;
  static const double maxMonths = 12;
  static const double maxFeePercent = 20;
  static const double maxInterestPercent = 100;

  final double principal;
  final double months;
  final double feePercent;
  final double interestPercent;

  const LoanTerms({
    required this.principal,
    required this.months,
    required this.feePercent,
    required this.interestPercent,
  });

  /// The logged-in user's saved defaults.
  factory LoanTerms.fromDefaults(
    AdminUser? user, {
    double principal = defaultPrincipal,
  }) {
    return LoanTerms(
      principal: principal,
      months: user?.defaultTotalMonths ?? fallbackMonths,
      feePercent: user?.defaultUpfrontFeePercentage ?? fallbackFeePercent,
      interestPercent:
          user?.defaultInterestPercentage ?? fallbackInterestPercent,
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

  String? get error {
    if (principal < minPrincipal) {
      return 'Minimum amount is ${CurrencyFormatter.format(minPrincipal)}';
    }
    if (principal > maxPrincipal) {
      return 'Maximum amount is ${CurrencyFormatter.format(maxPrincipal)}';
    }
    if (months < minMonths) return 'Term must be at least $minMonths months';
    if (months > maxMonths) {
      return 'Term can be at most ${maxMonths.toInt()} months';
    }
    if (feePercent < 0 || feePercent > maxFeePercent) {
      return 'Processing fee must be between 0% and ${maxFeePercent.toInt()}%';
    }
    if (interestPercent < 0 || interestPercent > maxInterestPercent) {
      return 'Interest must be between 0% and ${maxInterestPercent.toInt()}%';
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
    );
  }

  /// Keys follow the issue-loan call from earlier. Adjust if your API differs.
  Map<String, dynamic> toJson() => {
    'nominal_amount': principal,
    'upfront_fee_percentage': feePercent,
    'interest_percentage': interestPercent,
    'total_months': months,
  };

  /// Body for the issue-loan call. Optional fields are omitted when null, so
  /// the backend applies its own defaults for them.
  Map<String, dynamic> toIssuePayload({
    required String customerId,
    DateTime? issuedAt,
  }) => {
    'customer_id': customerId,
    'nominal_amount': principal,
    'total_months': months,
    'upfront_fee_percentage': feePercent,
    'interest_percentage': interestPercent,
    if (issuedAt != null) 'issued_at': issuedAt.toUtc().toIso8601String(),
  };
}
