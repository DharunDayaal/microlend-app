import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/customers/data/dtos/customer_dto.dart';
import 'package:micro_lending_app/features/customers/domain/customer_repository.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';

Customer customerRow(String id, {String name = 'Kavya'}) =>
    CustomerDto.fromJson({
      'id': id,
      'customer_name': name,
      'phone_number': '+919876543210',
      'preferred_payment_day': 'MONDAY',
      'city': 'Puducherry',
      'district': 'Puducherry',
    });

CustomerDetails customerDetails(String id, {bool success = true}) =>
    CustomerDetailsDto.fromJson({
      'success': success,
      'data': {
        'user': {
          'id': id,
          'customer_name': 'Kavya',
          'phone_number': '+919876543210',
          'preferred_payment_day': 'MONDAY',
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2026-01-01T00:00:00Z',
        },
      },
    });

List<LoanItem> customerLoans(List<Map<String, dynamic>> loans) =>
    loans.map(LoanItemDto.fromJson).toList();

/// In-memory [CustomerRepository]. Set fields to steer each test.
class FakeCustomerRepository implements CustomerRepository {
  final Map<String, List<PagedResult<Customer>>> pages = {};
  final List<String> listCalls = [];
  DashboardSummary summary = DashboardSummaryDto.fromJson({
    'totalTarget': 5000,
    'totalCollected': 2000,
    'borrowersPending': 3,
  });
  ApiException? failSummary;
  ApiException? failDetails;
  ApiException? failReferrals;
  List<LoanItem> loanList = const [];
  List<ReferralItem> referralList = const [];

  @override
  Future<DashboardSummary> dashboardSummary() async {
    if (failSummary != null) throw failSummary!;
    return summary;
  }

  @override
  Future<PagedResult<Customer>> customersByWeekday({
    required String weekday,
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    listCalls.add('$weekday|$search|$page');
    return pages[weekday]![page - 1];
  }

  int detailCalls = 0;

  @override
  Future<CustomerDetails> details(String customerId) async {
    detailCalls++;
    if (failDetails != null) throw failDetails!;
    return customerDetails(customerId);
  }

  @override
  Future<PagedResult<LoanItem>> loansPage(
    String customerId, {
    int page = 1,
    int limit = kMaxPageLimit,
  }) async => PagedResult(items: loanList, page: page, hasNextPage: false);

  @override
  Future<List<LoanItem>> loans(String customerId) async => loanList;

  @override
  Future<PagedResult<ReferralItem>> referralsPage(
    String customerId, {
    int page = 1,
    int limit = kMaxPageLimit,
  }) async => PagedResult(
    items: await referrals(customerId),
    page: page,
    hasNextPage: false,
  );

  @override
  Future<List<ReferralItem>> referrals(String customerId) async {
    if (failReferrals != null) throw failReferrals!;
    return referralList;
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
  }) => throw UnimplementedError();
}
