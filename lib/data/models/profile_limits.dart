double _dbl(dynamic v, double fallback) =>
    v == null ? fallback : (num.tryParse('$v')?.toDouble() ?? fallback);

class ProfileLimits {
  final double minPrincipal;
  final double maxPrincipal;
  final double minMonths;
  final double maxMonths;
  final double maxFeePercent;
  final double maxInterestPercent;

  const ProfileLimits({
    required this.minPrincipal,
    required this.maxPrincipal,
    required this.minMonths,
    required this.maxMonths,
    required this.maxFeePercent,
    required this.maxInterestPercent,
  });

  /// Used only until the server's limits arrive (for example right after
  /// login, before GET /api/me has answered).
  static const fallback = ProfileLimits(
    minPrincipal: 500,
    maxPrincipal: 1000000,
    minMonths: 0.5,
    maxMonths: 12,
    maxFeePercent: 20,
    maxInterestPercent: 100,
  );

  factory ProfileLimits.fromJson(Map<String, dynamic> j) => ProfileLimits(
        minPrincipal: _dbl(j['min_principal'], fallback.minPrincipal),
        maxPrincipal: _dbl(j['max_principal'], fallback.maxPrincipal),
        minMonths: _dbl(j['min_months'], fallback.minMonths),
        maxMonths: _dbl(j['max_months'], fallback.maxMonths),
        maxFeePercent: _dbl(j['max_fee_percent'], fallback.maxFeePercent),
        maxInterestPercent:
            _dbl(j['max_interest_percent'], fallback.maxInterestPercent),
      );

  Map<String, dynamic> toJson() => {
        'min_principal': minPrincipal,
        'max_principal': maxPrincipal,
        'min_months': minMonths,
        'max_months': maxMonths,
        'max_fee_percent': maxFeePercent,
        'max_interest_percent': maxInterestPercent,
      };
}