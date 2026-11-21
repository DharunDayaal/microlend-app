import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/network_providers.dart';
import 'package:micro_lending_app/features/reports/data/report_repository_impl.dart';
import 'package:micro_lending_app/features/reports/data/sources/report_remote_data_source.dart';
import 'package:micro_lending_app/features/reports/domain/report_repository.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>(
  (ref) => ReportRemoteDataSource(ref.watch(apiClientProvider)),
);

/// Override in tests: `reportRepositoryProvider.overrideWithValue(fake)`.
final reportRepositoryProvider = Provider<ReportRepository>(
  (ref) => ReportRepositoryImpl(ref.watch(reportRemoteDataSourceProvider)),
);
