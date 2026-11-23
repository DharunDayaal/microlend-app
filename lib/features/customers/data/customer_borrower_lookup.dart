import 'package:micro_lending_app/features/customers/domain/customer_repository.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';
import 'package:micro_lending_app/features/loans/domain/borrower_lookup.dart';

/// Serves the loans feature's [BorrowerLookup] port from the customers
/// repository. Wired in `app/app_overrides.dart`.
class CustomerBorrowerLookup implements BorrowerLookup {
  final CustomerRepository _customers;
  const CustomerBorrowerLookup(this._customers);

  @override
  Future<CustomerDetails> details(String customerId) =>
      _customers.details(customerId);

  @override
  Future<List<LoanItem>> loansOf(String customerId) =>
      _customers.loans(customerId);
}
