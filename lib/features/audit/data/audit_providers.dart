import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/network_providers.dart';
import 'package:micro_lending_app/features/audit/data/audit_repository_impl.dart';
import 'package:micro_lending_app/features/audit/data/sources/audit_remote_data_source.dart';
import 'package:micro_lending_app/features/audit/domain/audit_repository.dart';

final auditRemoteDataSourceProvider = Provider<AuditRemoteDataSource>(
  (ref) => AuditRemoteDataSource(ref.watch(apiClientProvider)),
);

/// Override in tests: `auditRepositoryProvider.overrideWithValue(fake)`.
final auditRepositoryProvider = Provider<AuditRepository>(
  (ref) => AuditRepositoryImpl(ref.watch(auditRemoteDataSourceProvider)),
);
