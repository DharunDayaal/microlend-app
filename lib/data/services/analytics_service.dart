import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:intl/intl.dart';
import 'package:micro_lending_app/data/models/analytics_model.dart';
import 'package:micro_lending_app/utils/constants/api_endpoints.dart';
import 'package:micro_lending_app/utils/network/api_client.dart';

class _Entry {
  final DateTime at;
  final Map<String, dynamic> data;
  _Entry(this.data, [DateTime? at]) : at = at ?? DateTime.now();
}

class AnalyticsStatus {
  final bool offline;
  final DateTime? updatedAt; // the last successful fetch
  const AnalyticsStatus({this.offline = false, this.updatedAt});
}

/// Runs at most [max] tasks at once; the rest wait in order.
class _Gate {
  final int max;
  int _running = 0;
  final _queue = <Completer<void>>[];
  _Gate(this.max);

  Future<T> run<T>(Future<T> Function() task) async {
    if (_running < max) {
      _running++;
    } else {
      final c = Completer<void>();
      _queue.add(c);
      await c.future; // the finishing task hands its slot over
    }
    try {
      return await task();
    } finally {
      if (_queue.isNotEmpty) {
        _queue.removeAt(0).complete();
      } else {
        _running--;
      }
    }
  }
}

/// Every analytics call: flat responses, a 2-minute cache, shared in-flight
/// requests and at most 3 requests at a time.
class AnalyticsService {
  AnalyticsService._();
  static final ApiClient _api = ApiClient.instance;
  static const _ttl = Duration(minutes: 2);
  static final _cache = <String, _Entry>{};
  static final _inflight = <String, Future<Map<String, dynamic>>>{};
  static final _gate = _Gate(3);

  /// Read by the screen for the offline banner and "Updated ... ago".
  static final connection = ValueNotifier<AnalyticsStatus>(
    const AnalyticsStatus(),
  );

  static void _mark({required bool offline, DateTime? at}) {
    final cur = connection.value;
    connection.value = AnalyticsStatus(
      offline: offline,
      updatedAt: at ?? cur.updatedAt,
    );
  }

  /// Everything goes (sign-out: the next user must not see these numbers).
  static void clearCache() {
    _cache.clear();
    connection.value = const AnalyticsStatus();
  }

  /// Entries count as old, but stay as a fallback for when the phone is offline.
  static void expireAll() => _cache.updateAll(
    (_, e) => _Entry(e.data, DateTime.fromMillisecondsSinceEpoch(0)),
  );

  /// Completes when the requests started by a refresh have finished.
  static Future<void> settled() async {
    await Future<void>.delayed(
      const Duration(milliseconds: 150),
    ); // cards refetch next frame
    final deadline = DateTime.now().add(const Duration(seconds: 12));
    while (_inflight.isNotEmpty && DateTime.now().isBefore(deadline)) {
      await Future.wait([
        for (final f in _inflight.values.toList())
          f.then<void>((_) {}, onError: (_) {}),
      ]);
    }
  }

  /// Warms the current month's calendar so the Collections chip opens instantly.
  static void prefetchCalendar(Map<String, dynamic> scope) {
    final ym = DateFormat('yyyy-MM').format(DateTime.now());
    calendar(month: ym, scope: scope).then<void>((_) {}, onError: (_) {});
  }

  // ---------- plumbing ----------

  /// Accepts both shapes: { success, message, ...fields } and
  /// { success, message, data: { ...fields } }.
  static Map<String, dynamic> _body(dynamic res) {
    if (res is! Map) return <String, dynamic>{};
    final body = Map<String, dynamic>.from(res);
    final inner = body['data'];
    return inner is Map ? {...body, ...Map<String, dynamic>.from(inner)} : body;
  }

  static Future<Map<String, dynamic>> _get(
    String path,
    Map<String, dynamic> query,
  ) {
    final sorted = query.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final key = '$path?${sorted.map((e) => '${e.key}=${e.value}').join('&')}';

    final hit = _cache[key];
    if (hit != null && DateTime.now().difference(hit.at) < _ttl) {
      return Future.value(hit.data);
    }
    return _inflight[key] ??= _gate.run(() async {
      try {
        final res = await _api.get(path, query: query);
        final data = _body(res);
        if (kDebugMode) {
          debugPrint('[Analytics] $path -> ${data.keys.toList()}');
        }
        _cache[key] = _Entry(data);
        _mark(offline: false, at: DateTime.now());
        return data;
      } on ApiException catch (e) {
        if (e.isNetworkError) {
          _mark(offline: true);
          final old = _cache[key];
          if (old != null) return old.data; // an old answer beats an error card
        }
        rethrow;
      } finally {
        _inflight.remove(key);
      }
    });
  }

  static Future<Map<String, dynamic>> _admin(
    String tail, [
    Map<String, dynamic> query = const {},
  ]) => _get(ApiEndpoints.analytics('admin', tail), query);

  static Future<Map<String, dynamic>> _super(
    String tail, [
    Map<String, dynamic> query = const {},
  ]) => _get(ApiEndpoints.analytics('super-admin', tail), query);

  /// The same endpoint for the admin or the platform level.
  static Future<Map<String, dynamic>> _level(
    bool platform,
    String tail,
    Map<String, dynamic> query,
  ) => platform ? _super(tail, query) : _admin(tail, query);

  static List<Map<String, dynamic>> _rows(dynamic v) => v is List
      ? [
          for (final e in v)
            if (e is Map) Map<String, dynamic>.from(e),
        ]
      : const [];

  /// Reads `response[key]` as a list of maps and builds one model per row.
  static Future<List<T>> _list<T>(
    Future<Map<String, dynamic>> response,
    String key,
    T Function(Map<String, dynamic>) make,
  ) async {
    final rows = _rows((await response)[key]);
    return [for (final r in rows) make(r)];
  }

  // ---------- admin: pulse ----------

  static Future<KpiCompare> kpisCompare({
    required String from,
    required String to,
    Map<String, dynamic> scope = const {},
  }) async => KpiCompare.fromJson(
    await _admin('kpis/compare', {'from': from, 'to': to, ...scope}),
  );

  static Future<List<Insight>> insights({
    Map<String, dynamic> scope = const {},
  }) => _list(_admin('insights', scope), 'insights', Insight.fromJson);

  static Future<Overview> overview({
    Map<String, dynamic> scope = const {},
  }) async => Overview(await _admin('overview', scope));

  // ---------- admin: collections ----------

  static Future<List<TrendPoint>> trend({
    required String from,
    required String to,
    required String groupBy, // day, week, month
    Map<String, dynamic> scope = const {},
  }) async => TrendPoint.list(
    await _admin('collections/trend', {
      'from': from,
      'to': to,
      'group_by': groupBy,
      ...scope,
    }),
  );

  static Future<CollectionCalendar> calendar({
    required String month, // yyyy-MM
    Map<String, dynamic> scope = const {},
  }) async => CollectionCalendar.fromJson(
    await _admin('collections/calendar', {'month': month, ...scope}),
  );

  static Future<List<WeekdayRow>> byWeekday({
    required String from,
    required String to,
    Map<String, dynamic> scope = const {},
  }) async => WeekdayRow.list(
    await _admin('collections/by-weekday', {'from': from, 'to': to, ...scope}),
  );

  static Future<PaymentBehaviour> behaviour({
    required String from,
    required String to,
    Map<String, dynamic> scope = const {},
  }) async => PaymentBehaviour(
    await _admin('payments/behaviour', {'from': from, 'to': to, ...scope}),
  );

  // ---------- admin: portfolio ----------

  static Future<List<AgingBucket>> aging({
    Map<String, dynamic> scope = const {},
  }) async => AgingBucket.list(await _admin('portfolio/aging', scope));

  static Future<List<StatusSlice>> status({
    Map<String, dynamic> scope = const {},
  }) async => StatusSlice.list(await _admin('portfolio/status', scope));

  static Future<List<Cohort>> cohorts({
    int months = 6,
    int weeks = 12,
    Map<String, dynamic> scope = const {},
  }) => _list(
    _admin('cohorts', {'months': months, 'weeks': weeks, ...scope}),
    'cohorts',
    Cohort.fromJson,
  );

  static Future<DisbursementData> disbursements({
    required String from,
    required String to,
    String groupBy = 'week',
    Map<String, dynamic> scope = const {},
  }) async => DisbursementData(
    await _admin('disbursements/trend', {
      'from': from,
      'to': to,
      'group_by': groupBy,
      ...scope,
    }),
  );

  /// [adminOnly] is just admin_id: earnings has no employee filter here.
  static Future<EarningsData> earnings({
    required String from,
    required String to,
    String groupBy = 'week',
    Map<String, dynamic> adminOnly = const {},
    bool platform = false,
    bool split = false,
  }) async => EarningsData(
    await _level(platform, 'earnings/trend', {
      'from': from,
      'to': to,
      'group_by': groupBy,
      if (platform) 'split_by_admin': split else ...adminOnly,
    }),
  );

  static Future<PagedRows<MaturingRow>> maturing({
    int days = 14,
    int page = 1,
    int limit = 20,
    Map<String, dynamic> scope = const {},
  }) async => PagedRows.from(
    await _admin('loans/maturing', {
      'days': days,
      'page': page,
      'limit': limit,
      ...scope,
    }),
    'rows',
    MaturingRow.new,
  );

  // ---------- admin: customers ----------

  static Future<PagedRows<RiskRow>> risk({
    int page = 1,
    int limit = 20,
    Map<String, dynamic> scope = const {},
  }) async => PagedRows.from(
    await _admin('customers/risk', {'page': page, 'limit': limit, ...scope}),
    'rows',
    RiskRow.new,
  );

  static Future<RepeatData> repeat({
    Map<String, dynamic> scope = const {},
  }) async => RepeatData(await _admin('customers/repeat', scope));

  static Future<List<Referrer>> referrals({
    int limit = 10,
    Map<String, dynamic> scope = const {},
  }) => _list(
    _admin('referrals/performance', {'limit': limit, ...scope}),
    'referrers',
    Referrer.new,
  );

  /// Platform routes take no scope filters.
  static Future<List<GeoArea>> geography({
    required String level, // district, city
    bool platform = false,
    Map<String, dynamic> scope = const {},
  }) => _list(
    _level(platform, 'geography', {'level': level, if (!platform) ...scope}),
    'areas',
    GeoArea.new,
  );

  // ---------- admin: team and forecast ----------

  /// Team performance, or the platform leaderboard when [platform].
  static Future<PagedRows<EmployeePerf>> employees({
    required String from,
    required String to,
    int page = 1,
    int limit = 20,
    bool platform = false,
    Map<String, dynamic> adminOnly = const {},
  }) async => PagedRows.from(
    await _level(
      platform,
      platform ? 'employees/leaderboard' : 'employees/performance',
      {
        'from': from,
        'to': to,
        'page': page,
        'limit': limit,
        if (!platform) ...adminOnly,
      },
    ),
    'employees',
    EmployeePerf.new,
  );

  static Future<EmployeeSummary> employeeSummary(
    String id, {
    required String from,
    required String to,
  }) async => EmployeeSummary(
    await _admin('employees/$id/summary', {'from': from, 'to': to}),
  );

  /// For the platform route only admin_id from [scope] is sent.
  static Future<Forecast> forecast({
    int weeks = 8,
    bool platform = false,
    Map<String, dynamic> scope = const {},
  }) async => Forecast(
    await _level(platform, 'forecast/cashflow', {
      'weeks': weeks,
      if (!platform)
        ...scope
      else if (scope['admin_id'] != null)
        'admin_id': scope['admin_id'],
    }),
  );

  // ---------- platform (SUPER_ADMIN) ----------

  static Future<Overview> spOverview() async =>
      Overview(await _super('overview'));

  static Future<List<AdminPerf>> spAdmins({
    required String from,
    required String to,
  }) => _list(
    _super('admins/performance', {'from': from, 'to': to}),
    'admins',
    AdminPerf.new,
  );

  static Future<List<GrowthPoint>> spGrowth({
    required String from,
    required String to,
    String groupBy = 'month',
  }) => _list(
    _super('admins/growth', {'from': from, 'to': to, 'group_by': groupBy}),
    'series',
    GrowthPoint.new,
  );

  static Future<List<TrendPoint>> spTrend({
    required String from,
    required String to,
    String groupBy = 'week',
    bool split = false,
  }) async => TrendPoint.list(
    await _super('collections/trend', {
      'from': from,
      'to': to,
      'group_by': groupBy,
      'split_by_admin': split,
    }),
  );

  static Future<List<AgingBucket>> spAging() async {
    final d = await _super('portfolio/aging');
    return AgingBucket.list({'buckets': d['platform']});
  }

  static Future<Map<String, dynamic>> spConcentration({int limit = 10}) =>
      _super('risk/concentration', {'limit': limit});

  static Future<Map<String, dynamic>> spAccounts() =>
      _super('accounts/summary');
}
