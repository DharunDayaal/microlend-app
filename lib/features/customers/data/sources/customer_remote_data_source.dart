import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_endpoints.dart';

/// Raw HTTP calls for customers. Returns decoded response bodies untouched.
class CustomerRemoteDataSource {
  final ApiClient _api;
  const CustomerRemoteDataSource(this._api);

  Future<dynamic> dashboardSummary() => _api.get(ApiEndpoints.getSummary);

  Future<dynamic> customersByWeekday({
    required String weekday,
    required int page,
    required int limit,
    required String search,
  }) => _api.get(
    ApiEndpoints.getCustomersByWeekday,
    query: {
      'week': weekday,
      'page': page,
      'limit': limit,
      if (search.isNotEmpty) 'search': search,
    },
  );

  Future<dynamic> addCustomer(Map<String, dynamic> payload) =>
      _api.post(ApiEndpoints.addCustomer, data: payload);

  Future<dynamic> details(String customerId) =>
      _api.get(ApiEndpoints.getCustomerDetails(customerId));

  Future<dynamic> loans(String customerId) =>
      _api.get(ApiEndpoints.getCustomerLoans(customerId));

  Future<dynamic> referrals(String customerId) =>
      _api.get(ApiEndpoints.getCustomerReferrals(customerId));
}
