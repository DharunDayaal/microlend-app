import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/network_providers.dart';
import 'package:micro_lending_app/features/customers/data/customer_repository_impl.dart';
import 'package:micro_lending_app/features/customers/data/sources/customer_remote_data_source.dart';
import 'package:micro_lending_app/features/customers/domain/customer_repository.dart';

final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>(
  (ref) => CustomerRemoteDataSource(ref.watch(apiClientProvider)),
);

/// Override in tests: `customerRepositoryProvider.overrideWithValue(fake)`.
final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => CustomerRepositoryImpl(ref.watch(customerRemoteDataSourceProvider)),
);
