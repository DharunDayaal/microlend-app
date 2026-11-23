import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_endpoints.dart';

/// Raw HTTP calls for loans. Returns the decoded response body untouched;
/// mapping to entities happens in the repository.
class LoanRemoteDataSource {
  final ApiClient _api;
  const LoanRemoteDataSource(this._api);

  Future<dynamic> getLoan(String loanId) =>
      _api.get(ApiEndpoints.getLoanDetails(loanId));

  Future<dynamic> listLoans({
    required int page,
    required int limit,
    required String search,
    required String status,
  }) => _api.get(
    ApiEndpoints.getLoans,
    query: {
      "page": page,
      "limit": limit,
      if (status.isNotEmpty) 'status': status,
      if (search.isNotEmpty) 'search': search,
    },
  );

  Future<dynamic> collectionsDue({
    required String weekday,
    required int page,
    required int limit,
    required String search,
    required String issuedAdmin,
  }) => _api.get(
    ApiEndpoints.collectionsDue,
    query: {
      "preferred_payment_day": weekday,
      "page": page,
      "limit": limit,
      if (search.isNotEmpty) "search": search,
      if (issuedAdmin.isNotEmpty) "issued_by_admin_id": issuedAdmin,
    },
  );

  Future<dynamic> listPayments({
    required String loanId,
    required int page,
    required int limit,
  }) => _api.get(
    ApiEndpoints.getPayments(loanId),
    query: {"page": page, "limit": limit},
  );

  /// [idempotencyKey] is sent as the `Idempotency-Key` header: the same key
  /// on a retry returns the saved payment instead of recording it twice.
  /// [collectedAt] is when the money was taken (device time).
  Future<dynamic> collectPayment({
    required String loanId,
    required int weekNumber,
    required double amount,
    required String idempotencyKey,
    required DateTime collectedAt,
  }) => _api.post(
    ApiEndpoints.collectPayment(loanId),
    headers: {'Idempotency-Key': idempotencyKey},
    data: {
      "week_number": weekNumber,
      "amount_paid": amount,
      // milliseconds only: what JavaScript dates hold
      "collected_at": DateTime.fromMillisecondsSinceEpoch(
        collectedAt.millisecondsSinceEpoch,
        isUtc: true,
      ).toIso8601String(),
    },
  );

  Future<dynamic> issueLoan(Map<String, dynamic> payload) =>
      _api.post(ApiEndpoints.issueLoan, data: payload);

  Future<dynamic> changeStatus(String loanId, String status) =>
      _api.patch(ApiEndpoints.loanStatus(loanId), data: {'status': status});
}
