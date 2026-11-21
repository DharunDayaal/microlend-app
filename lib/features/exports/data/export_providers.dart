import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/network_providers.dart';
import 'package:micro_lending_app/features/exports/data/device_export_files.dart';
import 'package:micro_lending_app/features/exports/data/export_repository_impl.dart';
import 'package:micro_lending_app/features/exports/data/sources/export_remote_data_source.dart';
import 'package:micro_lending_app/features/exports/domain/export_files.dart';
import 'package:micro_lending_app/features/exports/domain/export_repository.dart';

final exportRemoteDataSourceProvider = Provider<ExportRemoteDataSource>(
  (ref) => ExportRemoteDataSource(ref.watch(apiClientProvider)),
);

/// Override in tests: `exportRepositoryProvider.overrideWithValue(fake)`.
final exportRepositoryProvider = Provider<ExportRepository>(
  (ref) => ExportRepositoryImpl(ref.watch(exportRemoteDataSourceProvider)),
);

/// Device file handling. Override in tests so nothing touches plugins.
final exportFilesProvider = Provider<ExportFiles>((ref) => DeviceExportFiles());
