import 'package:micro_lending_app/features/reports/domain/entities/report.dart';

/// JSON -> entity mapping for the reports API. Unchanged from the old
/// `fromJson` factories.

double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
int _i(dynamic v) => v is num ? v.round() : int.tryParse('$v') ?? 0;
String _s(dynamic v) => v?.toString() ?? '';

abstract final class CashOutstandingDto {
  static CashOutstanding fromJson(Map<String, dynamic> j) => CashOutstanding(
    activeLoans: _i(j['active_loans']),
    disbursed: _d(j['total_disbursed']),
    payable: _d(j['total_payable']),
    collected: _d(j['total_collected']),
    outstanding: _d(j['outstanding_receivable']),
  );
}

abstract final class EarningsReportDto {
  static EarningsReport fromJson(Map<String, dynamic> j) => EarningsReport(
    fees: _d(j['fees_earned']),
    interest: _d(j['interest_earned']),
    expected: _d(j['interest_expected']),
    total: _d(j['total_earned']),
  );
}

abstract final class OverdueRowDto {
  static OverdueRow fromJson(Map<String, dynamic> j) => OverdueRow(
    loanId: _s(j['id']),
    customerId: _s(j['customer_id']),
    customerName: _s(j['customer_name']),
    phone: _s(j['phone_number']),
    collected: _d(j['total_collected']),
    outstanding: _d(j['outstanding_balance']),
    daysPastDue: _i(j['days_past_due']),
  );
}
