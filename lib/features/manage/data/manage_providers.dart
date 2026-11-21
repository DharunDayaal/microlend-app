import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/network_providers.dart';
import 'package:micro_lending_app/features/manage/data/manage_repository_impl.dart';
import 'package:micro_lending_app/features/manage/data/sources/manage_remote_data_source.dart';
import 'package:micro_lending_app/features/manage/domain/manage_repository.dart';

final manageRemoteDataSourceProvider = Provider<ManageRemoteDataSource>(
  (ref) => ManageRemoteDataSource(ref.watch(apiClientProvider)),
);

/// Override in tests: `manageRepositoryProvider.overrideWithValue(fake)`.
final manageRepositoryProvider = Provider<ManageRepository>(
  (ref) => ManageRepositoryImpl(ref.watch(manageRemoteDataSourceProvider)),
);
