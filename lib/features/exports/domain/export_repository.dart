import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/exports/domain/entities/export.dart';

/// Report exports on the server. Implementations throw `ApiException`.
abstract interface class ExportRepository {
  /// Starts a job, or returns the one already running for the same request.
  Future<ExportCreated> create({
    required ExportType type,
    required ExportFormat format,
    required Map<String, dynamic> filters,
  });

  /// Current state of one job, with a fresh download link when it is done.
  Future<ExportJob> get(String id);

  /// One page of exports, newest first (max `limit` 50). Never carries a
  /// download link.
  Future<PagedResult<ExportJob>> list({int page = 1, int limit = 20});
}
