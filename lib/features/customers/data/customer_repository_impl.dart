import 'package:micro_lending_app/core/network/response_parser.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/customers/data/dtos/customer_dto.dart';
import 'package:micro_lending_app/features/customers/data/sources/customer_remote_data_source.dart';
import 'package:micro_lending_app/features/customers/domain/customer_repository.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource _remote;
  const CustomerRepositoryImpl(this._remote);

  @override
  Future<DashboardSummary> dashboardSummary() async {
    final res = await _remote.dashboardSummary();
    final data = res['data'] as Map<String, dynamic>;
    return DashboardSummaryDto.fromJson(data['dashboard']);
  }

  @override
  Future<PagedResult<Customer>> customersByWeekday({
    required String weekday,
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    final res = await _remote.customersByWeekday(
      weekday: weekday,
      page: page,
      limit: limit,
      search: search,
    );
    return PagedResult(
      items: ResponseParser.list(
        res,
        'users',
      ).map(CustomerDto.fromJson).toList(),
      page: page,
      hasNextPage: ResponseParser.hasNextPage(res),
    );
  }

  @override
  Future<CreateCustomer> addCustomer({
    required String name,
    required String phoneNumber,
    required String weekday,
    String? streetName,
    String? referrerId,
    required String city,
    required String district,
  }) async {
    final res = await _remote.addCustomer({
      "customer_name": name,
      "phone_number": phoneNumber,
      "preferred_payment_day": weekday,
      if (referrerId != null && referrerId.isNotEmpty)
        "referred_by_id": referrerId,
      if (streetName != null && streetName.isNotEmpty)
        "street_name": streetName,
      "city": city,
      "district": district,
    });
    final customer = ResponseParser.object(res, 'user');
    return CreateCustomerDto.fromJson({"success": res['success'], ...customer});
  }

  @override
  Future<CustomerDetails> details(String customerId) async =>
      CustomerDetailsDto.fromJson(await _remote.details(customerId));

  @override
  Future<CustomerLoans> loans(String customerId) async =>
      CustomerLoansDto.fromJson(await _remote.loans(customerId));

  @override
  Future<CustomerReferrals> referrals(String customerId) async =>
      CustomerReferralsDto.fromJson(await _remote.referrals(customerId));
}
