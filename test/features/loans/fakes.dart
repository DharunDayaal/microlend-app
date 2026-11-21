import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/customers/data/dtos/customer_dto.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';
import 'package:micro_lending_app/features/loans/domain/borrower_lookup.dart';
import 'package:micro_lending_app/features/loans/domain/entities/collections_due.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan_terms.dart';
import 'package:micro_lending_app/features/loans/domain/entities/manual_loan_status.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';
import 'package:micro_lending_app/features/loans/domain/loan_repository.dart';

LoanModel loan(
  String id, {
  String customerId = 'c1',
  String status = 'ACTIVE',
  double outstanding = 1000,
  List<LoanTrackModel> tracks = const [],
}) => LoanModel(
  id: id,
  customerId: customerId,
  nominalAmount: 1000,
  upfrontFee: 0,
  disbursedAmount: 1000,
  totalPayableAmount: 1200,
  weeklyPayableAmount: 100,
  totalMonths: 3,
  totalWeeks: 12,
  status: status,
  issuedAt: DateTime(2026, 1, 1),
  issuedByAdminId: 'a1',
  updatedAt: DateTime(2026, 1, 1),
  owningAdminId: 'a1',
  totalCollected: 1200 - outstanding,
  paidWeeks: 0,
  partialWeeks: 0,
  tracks: tracks,
  outstandingAmount: outstanding,
  preferredPaymentDay: 'MONDAY',
  isOverdue: false,
);

LoanTrackModel track(int week, {String status = 'PAID'}) => LoanTrackModel(
  id: 't$week',
  loanId: 'l1',
  weekNumber: week,
  totalCollected: 100,
  targetAmount: 100,
  status: status,
  isOverdued: false,
  remainingBalance: 0,
);

PaymentModel payment(String id) => PaymentModel(
  id: id,
  trackId: 't1',
  loanId: 'l1',
  amountPaid: 100,
  paidAt: DateTime(2026, 1, 8),
  collectedByAdminId: 'a1',
  weekNumber: 1,
);

CustomerDetails customer(String id) => CustomerDetailsDto.fromJson({
  'success': true,
  'data': {
    'user': {
      'id': id,
      'customer_name': 'Kavya',
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
    },
  },
});

LoanItem loanItem(String id, String status, DateTime issuedAt) =>
    LoanItemDto.fromJson({
      'id': id,
      'status': status,
      'issued_at': issuedAt.toIso8601String(),
    });

/// In-memory [LoanRepository]. Set the fields to steer each test.
class FakeLoanRepository implements LoanRepository {
  /// Pages of the loans list, keyed by search text.
  final Map<String, List<PagedResult<LoanModel>>> loanPages = {};
  final Map<String, LoanModel> loans = {};
  List<PaymentModel> payments = [];
  ApiException? failLoan;
  ApiException? failListPage;
  final List<String> listCalls = [];

  @override
  Future<LoanModel> getLoan(String loanId) async {
    if (failLoan != null) throw failLoan!;
    return loans[loanId]!;
  }

  @override
  Future<PagedResult<LoanModel>> listLoans({
    int page = 1,
    int limit = 20,
    String search = '',
    String status = '',
  }) async {
    listCalls.add('$search|$status|$page');
    if (failListPage != null && page > 1) throw failListPage!;
    return loanPages[search]![page - 1];
  }

  @override
  Future<PagedResult<PaymentModel>> listPayments({
    required String loanId,
    int page = 1,
    int limit = 20,
  }) async => PagedResult(items: payments, page: page, hasNextPage: false);

  /// Pages of the collections-due list, in order.
  List<CollectionsLoanDueModel> duePages = [];

  /// Thrown as-is by [collectionsDue] (any error type, to test bugs too).
  Object? failDue;

  /// When set, [collectionsDue] waits for it, to test overlapping requests.
  Future<void>? dueGate;
  int dueCalls = 0;

  @override
  Future<CollectionsLoanDueModel> collectionsDue({
    required String weekday,
    int page = 1,
    int limit = 20,
    String search = '',
    String issuedAdmin = '',
  }) async {
    dueCalls++;
    if (dueGate != null) await dueGate;
    if (failDue != null) throw failDue!;
    return duePages[page - 1];
  }

  @override
  Future<PaymentResultModel> collectPayment({
    required String loanId,
    required int weekNumber,
    required double amount,
  }) => throw UnimplementedError();

  @override
  Future<LoanModel> issueLoan({
    required String customerId,
    required LoanTerms terms,
    DateTime? issuedAt,
  }) => throw UnimplementedError();

  @override
  Future<void> changeStatus({
    required String loanId,
    required ManualLoanStatus status,
  }) => throw UnimplementedError();
}

class FakeBorrowerLookup implements BorrowerLookup {
  List<LoanItem> loans = [];
  ApiException? failDetails;

  @override
  Future<CustomerDetails> details(String customerId) async {
    if (failDetails != null) throw failDetails!;
    return customer(customerId);
  }

  @override
  Future<List<LoanItem>> loansOf(String customerId) async => loans;
}

/// Lets queued microtasks and completed futures run.
Future<void> settle() async {
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

CollectionsLoanDueModel duePage(
  List<LoanModel> loans, {
  int page = 1,
  bool hasNext = false,
  int active = 5,
}) => CollectionsLoanDueModel(
  result: PagedResult(items: loans, page: page, hasNextPage: hasNext),
  summary: Summary(
    totalCustomers: 9,
    totalActiveLoans: active,
    totalOverdueLoans: 1,
    totalReferredCustomers: 2,
  ),
);
