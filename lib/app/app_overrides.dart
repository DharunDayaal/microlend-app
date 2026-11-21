import 'package:micro_lending_app/features/customers/data/customer_borrower_lookup.dart';
import 'package:micro_lending_app/features/customers/data/customer_providers.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';

/// Composition root: connects one feature's port to another feature's
/// implementation, so features never import each other's data layer.
final appOverrides = [
  borrowerLookupProvider.overrideWith(
    (ref) => CustomerBorrowerLookup(ref.watch(customerRepositoryProvider)),
  ),
];
