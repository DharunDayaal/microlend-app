/// The three classic reports. Plain Dart: parsing lives in
/// `features/reports/data/dtos/report_dto.dart`.
class CashOutstanding {
  final int activeLoans;
  final double disbursed, payable, collected, outstanding;

  const CashOutstanding({
    required this.activeLoans,
    required this.disbursed,
    required this.payable,
    required this.collected,
    required this.outstanding,
  });

  /// Collected as a share of total payable, 0 to 1.
  double get collectedShare =>
      payable <= 0 ? 0 : (collected / payable).clamp(0.0, 1.0);
}

class EarningsReport {
  final double fees, interest, expected, total;

  const EarningsReport({
    required this.fees,
    required this.interest,
    required this.expected,
    required this.total,
  });
}

class OverdueRow {
  final String loanId, customerId, customerName, phone;
  final double collected, outstanding;
  final int daysPastDue;

  const OverdueRow({
    required this.loanId,
    required this.customerId,
    required this.customerName,
    required this.phone,
    required this.collected,
    required this.outstanding,
    required this.daysPastDue,
  });
}

class OverduePage {
  final List<OverdueRow> rows;
  final int page;
  final bool hasNext;
  const OverduePage({
    required this.rows,
    required this.page,
    required this.hasNext,
  });
}
