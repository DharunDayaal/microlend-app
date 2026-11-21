import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/network_providers.dart';
import 'package:micro_lending_app/features/auth/data/auth_repository_impl.dart';
import 'package:micro_lending_app/features/auth/data/sources/auth_remote_data_source.dart';
import 'package:micro_lending_app/features/auth/domain/auth_repository.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(apiClientProvider)),
);

/// Override in tests: `authRepositoryProvider.overrideWithValue(fake)`.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider)),
);
