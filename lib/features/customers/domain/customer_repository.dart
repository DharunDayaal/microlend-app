import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';

/// Everything the app can do with customers (borrowers). Implementations
/// throw `ApiException` on failure.
abstract interface class CustomerRepository {
  /// Today's route totals for the Field tab.
  Future<DashboardSummary> dashboardSummary();

  /// Customers whose collection day is [weekday].
  Future<PagedResult<Customer>> customersByWeekday({
    required String weekday,
    int page = 1,
    int limit = 10,
    String search = '',
  });

  Future<CreateCustomer> addCustomer({
    required String name,
    required String phoneNumber,
    required String weekday,
    String? streetName,
    String? referrerId,
    required String city,
    required String district,
  });

  Future<CustomerDetails> details(String customerId);

  /// One page of the customer's loans, newest first.
  Future<PagedResult<LoanItem>> loansPage(
    String customerId, {
    int page = 1,
    int limit = kMaxPageLimit,
  });

  /// Every loan the customer has had (all pages).
  Future<List<LoanItem>> loans(String customerId);

  /// One page of the customers this customer referred, newest first.
  Future<PagedResult<ReferralItem>> referralsPage(
    String customerId, {
    int page = 1,
    int limit = kMaxPageLimit,
  });

  /// Every customer this customer referred (all pages).
  Future<List<ReferralItem>> referrals(String customerId);
}
