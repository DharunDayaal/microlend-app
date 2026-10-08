import 'package:micro_lending_app/data/models/customer_model.dart';
import 'package:micro_lending_app/data/models/paged_modal.dart';
import 'package:micro_lending_app/data/services/response_parser.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/network/api_client.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class CustomerService {
  CustomerService._();

  static final _api = ApiClient.instance;

  static Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await _api.get(ApiEndpoints.getSummary);
      final data = response['data'] as Map<String, dynamic>;

      return DashboardSummary.fromJson(data['dashboard']);
    } on ApiException {
      rethrow;
    }
  }

  static Future<PagedResult<Customer>> getCustomersByWeekday({
    required String weekday,
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    final response = await _api.get(
      ApiEndpoints.getCustomersByWeekday,
      query: {'week': weekday, 'page': page, 'limit': limit, 'search': search},
    );

    return PagedResult(
      items: ResponseParser.list(
        response,
        'users',
      ).map(Customer.fromJson).toList(),
      page: page,
      hasNextPage: ResponseParser.hasNextPage(response),
    );
  }
}
