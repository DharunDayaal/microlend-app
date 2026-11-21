import 'package:micro_lending_app/features/exports/domain/entities/export.dart';

/// JSON -> entity mapping for the export APIs. Unchanged from the old
/// `fromJson` factory.

num? _n(dynamic v) => v == null ? null : num.tryParse('$v');
DateTime? _t(dynamic v) => DateTime.tryParse('${v ?? ''}')?.toUtc();

abstract final class ExportJobDto {
  static ExportJob fromJson(Map<String, dynamic> j) {
    final f = j['filters'];
    final status = '${j['status'] ?? ''}'.toLowerCase();
    final format = '${j['format'] ?? ''}'.toLowerCase();

    return ExportJob(
      id: '${j['id'] ?? ''}',
      type: '${j['type'] ?? ''}',
      format:
          ExportFormat.values.where((e) => e.name == format).firstOrNull ??
          ExportFormat.xlsx,
      status:
          ExportStatus.values.where((e) => e.name == status).firstOrNull ??
          ExportStatus.queued,
      filters: f is Map ? Map<String, dynamic>.from(f) : <String, dynamic>{},
      totalRows: _n(j['total_rows'])?.round(),
      processedRows: _n(j['processed_rows'])?.round() ?? 0,
      progress: _n(j['progress'])?.toDouble().clamp(0.0, 1.0).toDouble(),
      fileName: j['file_name']?.toString(),
      fileSize: _n(j['file_size'])?.round(),
      error: j['error']?.toString(),
      createdAt: _t(j['created_at']),
      finishedAt: _t(j['finished_at']),
      expiresAt: _t(j['expires_at']),
      downloadUrl: j['download_url']?.toString(),
    );
  }
}
