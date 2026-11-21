import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/features/loans/data/dtos/loan_dto.dart';

void main() {
  test('detail JSON maps every field and its tracks', () {
    final l = LoanDto.fromJson({
      'id': 'l1',
      'customer_id': 'c1',
      'nominal_amount': 10000,
      'total_payable_amount': 12000,
      'total_collected': 3000,
      'outstanding_amount': 9000,
      'total_weeks': 12,
      'status': 'ACTIVE',
      'issued_at': '2026-01-01T00:00:00Z',
      'is_overdue': true,
      'tracks': [
        {'id': 't1', 'week_number': 1, 'status': 'PAID', 'target_amount': 1000},
      ],
    });
    expect(l.id, 'l1');
    expect(l.outstandingAmount, 9000);
    expect(l.isOverdue, true);
    expect(l.tracks.single.weekNumber, 1);
    expect(l.tracks.single.targetAmount, 1000);
  });

  test('list JSON works out outstanding and fills defaults', () {
    final l = LoanDto.fromListJson({
      'id': 'l1',
      'total_payable_amount': 12000,
      'total_collected': 2000,
    });
    expect(l.outstandingAmount, 10000);
    expect(l.status, 'UNKNOWN');
    expect(l.customerName, 'N/A');
    expect(l.tracks, isEmpty);
  });

  test('payment result reads the track and the loan balance', () {
    final r = PaymentResultDto.fromJson({
      'track': {'id': 't2', 'week_number': 2, 'status': 'PARTIAL'},
      'loan': {
        'status': 'PAID_OFF',
        'total_payable_amount': 12000,
        'total_collected': 12000,
      },
    });
    expect(r.track.weekNumber, 2);
    expect(r.loanOutstandingAfter, 0);
    expect(r.isLoanClosed, true);
  });
}
