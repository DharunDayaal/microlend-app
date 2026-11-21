import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/network_providers.dart';
import 'package:micro_lending_app/features/loans/data/loan_repository_impl.dart';
import 'package:micro_lending_app/features/loans/data/sources/loan_remote_data_source.dart';
import 'package:micro_lending_app/features/loans/domain/borrower_lookup.dart';
import 'package:micro_lending_app/features/loans/domain/loan_repository.dart';

final loanRemoteDataSourceProvider = Provider<LoanRemoteDataSource>(
  (ref) => LoanRemoteDataSource(ref.watch(apiClientProvider)),
);

/// Override in tests: `loanRepositoryProvider.overrideWithValue(FakeRepo())`.
final loanRepositoryProvider = Provider<LoanRepository>(
  (ref) => LoanRepositoryImpl(ref.watch(loanRemoteDataSourceProvider)),
);

/// Borrower data comes from the customers feature. The app wires the real
/// implementation in `app/app_overrides.dart`; tests override it directly.
final borrowerLookupProvider = Provider<BorrowerLookup>(
  (ref) => throw UnimplementedError(
    'borrowerLookupProvider is wired in app/app_overrides.dart',
  ),
);
