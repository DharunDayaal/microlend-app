import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/network/response_parser.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/loans/data/dtos/loan_dto.dart';
import 'package:micro_lending_app/features/loans/data/sources/loan_remote_data_source.dart';
import 'package:micro_lending_app/features/loans/domain/entities/collections_due.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan_terms.dart';
import 'package:micro_lending_app/features/loans/domain/entities/manual_loan_status.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';
import 'package:micro_lending_app/features/loans/domain/loan_repository.dart';

class LoanRepositoryImpl implements LoanRepository {
  final LoanRemoteDataSource _remote;
  const LoanRepositoryImpl(this._remote);

  @override
  Future<LoanModel> getLoan(String loanId) async {
    final res = await _remote.getLoan(loanId);
    return LoanDto.fromJson(ResponseParser.object(res, "loan"));
  }

  @override
  Future<PagedResult<LoanModel>> listLoans({
    int page = 1,
    int limit = 20,
    String search = '',
    String status = '',
  }) async {
    final res = await _remote.listLoans(
      page: page,
      limit: limit,
      search: search,
      status: status,
    );
    return PagedResult(
      items: ResponseParser.list(
        res,
        "loans",
      ).map(LoanDto.fromListJson).toList(),
      page: page,
      hasNextPage: ResponseParser.hasNextPage(res),
    );
  }

  @override
  Future<CollectionsLoanDueModel> collectionsDue({
    required String weekday,
    int page = 1,
    int limit = 20,
    String search = '',
    String issuedAdmin = '',
  }) async {
    final res = await _remote.collectionsDue(
      weekday: weekday,
      page: page,
      limit: limit,
      search: search,
      issuedAdmin: issuedAdmin,
    );
    return CollectionsLoanDueModel(
      result: PagedResult(
        items: ResponseParser.list(res, "loans").map(LoanDto.fromJson).toList(),
        page: page,
        hasNextPage: ResponseParser.hasNextPage(res),
      ),
      summary: CollectionsSummaryDto.fromJson(
        ResponseParser.object(res, "summary"),
      ),
    );
  }

  @override
  Future<PagedResult<PaymentModel>> listPayments({
    required String loanId,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _remote.listPayments(
      loanId: loanId,
      page: page,
      limit: limit,
    );
    return PagedResult(
      items: ResponseParser.list(
        res,
        'payments',
      ).map(PaymentDto.fromJson).toList(),
      page: page,
      hasNextPage: ResponseParser.hasNextPage(res),
    );
  }

  @override
  Future<PaymentResultModel> collectPayment({
    required String loanId,
    required int weekNumber,
    required double amount,
    required String idempotencyKey,
    required DateTime collectedAt,
  }) async {
    final res = await _remote.collectPayment(
      loanId: loanId,
      weekNumber: weekNumber,
      amount: amount,
      idempotencyKey: idempotencyKey,
      collectedAt: collectedAt,
    );
    return PaymentResultDto.fromJson(res['data']);
  }

  @override
  Future<LoanModel> issueLoan({
    required String customerId,
    required LoanTerms terms,
    DateTime? issuedAt,
  }) async {
    final res = await _remote.issueLoan(
      LoanTermsDto.issuePayload(
        terms,
        customerId: customerId,
        issuedAt: issuedAt,
      ),
    );
    // Unwraps { data: { loan: {...} } } or { data: {...} }
    final loan = LoanDto.fromJson(ResponseParser.object(res, 'loan'));
    if (loan.id.isEmpty) {
      throw const ApiException(
        message: 'The server did not return the new loan.',
        code: 'BAD_RESPONSE',
      );
    }
    return loan;
  }

  @override
  Future<void> changeStatus({
    required String loanId,
    required ManualLoanStatus status,
  }) => _remote.changeStatus(loanId, status.apiValue);
}
