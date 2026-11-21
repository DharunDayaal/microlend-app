import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_endpoints.dart';

/// Raw HTTP calls for the reports.
class ReportRemoteDataSource {
  final ApiClient _api;
  const ReportRemoteDataSource(this._api);

  Future<dynamic> cashOutstanding() =>
      _api.get(ApiEndpoints.reportCashOutstanding);

  Future<dynamic> earnings() => _api.get(ApiEndpoints.reportEarnings);

  Future<dynamic> overdue(int page, int limit) => _api.get(
    ApiEndpoints.reportOverdue,
    query: {'page': page, 'limit': limit},
  );
}
