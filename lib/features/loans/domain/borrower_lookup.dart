import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';

/// What the loans feature needs to know about a borrower. The customers
/// feature owns this data and implements the port (`CustomerBorrowerLookup`),
/// wired in `app/app_overrides.dart`.
abstract interface class BorrowerLookup {
  Future<CustomerDetails> details(String customerId);

  /// Every loan the borrower has had, newest data from the server.
  Future<List<LoanItem>> loansOf(String customerId);
}
