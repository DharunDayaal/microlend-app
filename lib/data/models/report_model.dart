double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _i(dynamic v) => v is num ? v.round() : int.tryParse('$v') ?? 0;
String _s(dynamic v) => v?.toString() ?? '';

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

  factory CashOutstanding.fromJson(Map<String, dynamic> j) => CashOutstanding(
    activeLoans: _i(j['active_loans']),
    disbursed: _d(j['total_disbursed']),
    payable: _d(j['total_payable']),
    collected: _d(j['total_collected']),
    outstanding: _d(j['outstanding_receivable']),
  );
}

class EarningsReport {
  final double fees, interest, expected, total;

  const EarningsReport({
    required this.fees,
    required this.interest,
    required this.expected,
    required this.total,
  });

  factory EarningsReport.fromJson(Map<String, dynamic> j) => EarningsReport(
    fees: _d(j['fees_earned']),
    interest: _d(j['interest_earned']),
    expected: _d(j['interest_expected']),
    total: _d(j['total_earned']),
  );
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

  factory OverdueRow.fromJson(Map<String, dynamic> j) => OverdueRow(
    loanId: _s(j['id']),
    customerId: _s(j['customer_id']),
    customerName: _s(j['customer_name']),
    phone: _s(j['phone_number']),
    collected: _d(j['total_collected']),
    outstanding: _d(j['outstanding_balance']),
    daysPastDue: _i(j['days_past_due']),
  );
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
