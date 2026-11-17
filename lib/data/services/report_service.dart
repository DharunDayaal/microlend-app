import 'package:micro_lending_app/data/models/report_model.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/network/api_client.dart';

/// The three classic reports. Always "as of now"; scope comes from the token.
class ReportsService {
  ReportsService._();
  static final ApiClient _api = ApiClient.instance;

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

  static Future<CashOutstanding> cashOutstanding() async =>
      CashOutstanding.fromJson(
        _map(_report(await _api.get(ApiEndpoints.reportCashOutstanding))),
      );

  static Future<EarningsReport> earnings() async => EarningsReport.fromJson(
    _map(_report(await _api.get(ApiEndpoints.reportEarnings))),
  );

  static Future<OverduePage> overdue({int page = 1, int limit = 20}) async {
    final res = await _api.get(
      ApiEndpoints.reportOverdue,
      query: {'page': page, 'limit': limit},
    );
    final raw = _report(res);
    final rows = raw is List
        ? [
            for (final e in raw)
              if (e is Map) OverdueRow.fromJson(Map<String, dynamic>.from(e)),
          ]
        : <OverdueRow>[];
    final meta = _meta(res);
    return OverduePage(
      rows: rows,
      page: page,
      hasNext: meta['has_next_page'] == true,
    );
  }
}
