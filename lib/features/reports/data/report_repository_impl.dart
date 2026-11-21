import 'package:micro_lending_app/features/reports/data/dtos/report_dto.dart';
import 'package:micro_lending_app/features/reports/data/sources/report_remote_data_source.dart';
import 'package:micro_lending_app/features/reports/domain/entities/report.dart';
import 'package:micro_lending_app/features/reports/domain/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remote;
  const ReportRepositoryImpl(this._remote);

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  /// Accepts { report } and { data: { report } }.
  static dynamic _report(dynamic res) {
    final body = _map(res);
    if (body.containsKey('report')) return body['report'];
    return _map(body['data'])['report'];
  }

  static Map<String, dynamic> _meta(dynamic res) {
    final body = _map(res);
    return _map(body['metadata'] ?? _map(body['data'])['metadata']);
  }

  @override
  Future<CashOutstanding> cashOutstanding() async =>
      CashOutstandingDto.fromJson(
        _map(_report(await _remote.cashOutstanding())),
      );

  @override
  Future<EarningsReport> earnings() async =>
      EarningsReportDto.fromJson(_map(_report(await _remote.earnings())));

  @override
  Future<OverduePage> overdue({int page = 1, int limit = 20}) async {
    final res = await _remote.overdue(page, limit);
    final raw = _report(res);
    final rows = raw is List
        ? [
            for (final e in raw)
              if (e is Map)
                OverdueRowDto.fromJson(Map<String, dynamic>.from(e)),
          ]
        : <OverdueRow>[];
    return OverduePage(
      rows: rows,
      page: page,
      hasNext: _meta(res)['has_next_page'] == true,
    );
  }
}
