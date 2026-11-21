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

  /// Every loan the customer has had.
  Future<CustomerLoans> loans(String customerId);

  /// Customers this customer referred.
  Future<CustomerReferrals> referrals(String customerId);
}
