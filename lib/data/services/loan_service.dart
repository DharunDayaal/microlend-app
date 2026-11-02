import 'package:micro_lending_app/data/models/loan_model.dart';
import 'package:micro_lending_app/data/models/paged_modal.dart';
import 'package:micro_lending_app/data/models/payment_result_model.dart';
import 'package:micro_lending_app/data/services/response_parser.dart';
import 'package:micro_lending_app/features/customers/screens/loan_terms_model.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/network/api_client.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class LoanService {
  LoanService._();

  static final _api = ApiClient.instance;

  static Future<LoanModel> getLoanDetails({required String loanid}) async {
    final response = await _api.get(ApiEndpoints.getLoanDetails(loanid));

    return LoanModel.fromJson(ResponseParser.object(response, "loan"));
  }

  static Future<PagedResult<LoanModel>> listLoans({
    int page = 1,
    int limit = 20,
    String search = '',
    String status = '',
  }) async {
    final response = await _api.get(
      ApiEndpoints.getLoans,
      query: {
        "page": page,
        "limit": limit,
        if (status.isNotEmpty) 'status': status,
        if (search.isNotEmpty) 'search': search,
      },
    );

    return PagedResult(
      items: ResponseParser.list(
        response,
        "loans",
      ).map(LoanModel.fromListJson).toList(),
      page: page,
      hasNextPage: ResponseParser.hasNextPage(response),
    );
  }

  static Future<CollectionsLoanDueModel> getCollectionsDue({
    required String weekday,
    int page = 1,
    int limit = 20,
    String search = '',
    String issuedAdmin = '',
  }) async {
    final response = await _api.get(
      ApiEndpoints.collectionsDue,
      query: {
        "preferred_payment_day": weekday,
        "page": page,
        "limit": limit,
        if (search.isNotEmpty) "search": search,
        if (issuedAdmin.isNotEmpty) "issued_by_admin_id": issuedAdmin,
      },
    );

    final result = PagedResult(
      items: ResponseParser.list(
        response,
        "loans",
      ).map(LoanModel.fromJson).toList(),
      page: page,
      hasNextPage: ResponseParser.hasNextPage(response),
    );

    final summary = Summary.fromJson(
      ResponseParser.object(response, "summary"),
    );

    return CollectionsLoanDueModel(result: result, summary: summary);
  }

  static Future<PaymentResultModel> collectPayment({
    required String loanId,
    required int weekNumber,
    required double amount,
  }) async {
    final payload = {"week_number": weekNumber, "amount_paid": amount};
    final response = await _api.post(
      ApiEndpoints.collectPayment(loanId),
      data: payload,
    );
    return PaymentResultModel.fromJson(response['data']);
  }

  static Future<PagedResult<PaymentModel>> getPaymentList({
    required String loanId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get(
      ApiEndpoints.getPayments(loanId),
      query: {"page": page, "limit": limit},
    );

    return PagedResult(
      items: ResponseParser.list(
        response,
        'payments',
      ).map(PaymentModel.fromJson).toList(),
      page: page,
      hasNextPage: ResponseParser.hasNextPage(response),
    );
  }

  /// Issues a new loan. Throws ApiException on failure.
  /// Not safe to auto-retry after a timeout: the loan may already exist.
  static Future<LoanModel> issueLoan({
    required String customerId,
    required LoanTerms terms,
    DateTime? issuedAt,
  }) async {
    final res = await _api.post(
      ApiEndpoints.issueLoan,
      data: terms.toIssuePayload(customerId: customerId, issuedAt: issuedAt),
    );

    // Unwraps { data: { loan: {...} } } or { data: {...} }
    final loan = LoanModel.fromJson(ResponseParser.object(res, 'loan'));
    if (loan.id.isEmpty) {
      throw const ApiException(
        message: 'The server did not return the new loan.',
        code: 'BAD_RESPONSE',
      );
    }
    return loan;
  }
}
