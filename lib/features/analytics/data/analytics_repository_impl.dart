import 'package:intl/intl.dart';
import 'package:micro_lending_app/core/network/api_endpoints.dart';
import 'package:micro_lending_app/features/analytics/data/analytics_gateway.dart';
import 'package:micro_lending_app/features/analytics/domain/analytics_repository.dart';
import 'package:micro_lending_app/features/analytics/domain/entities/analytics.dart';
import 'package:micro_lending_app/features/analytics/domain/entities/analytics_status.dart';
import 'package:flutter/foundation.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  AnalyticsRepositoryImpl(this._gateway, {required this.isAdmin});

  final AnalyticsGateway _gateway;

  /// A USER has no admin routes (403), so their cards read the user routes.
  final bool Function() isAdmin;

  // ---------- cache control ----------

  @override
  ValueListenable<AnalyticsStatus> get connection => _gateway.connection;

  @override
  void clearCache() => _gateway.clearCache();

  @override
  void expireAll() => _gateway.expireAll();

  @override
  Future<void> settled() => _gateway.settled();

  @override
  void prefetchCalendar(Map<String, dynamic> scope) {
    final ym = DateFormat('yyyy-MM').format(DateTime.now());
    calendar(month: ym, scope: scope).then<void>((_) {}, onError: (_) {});
  }

  // ---------- plumbing ----------

  static const _userTails = {
    'forecast/cashflow': 'forecast/next-weeks',
    'referrals/performance': 'referrals',
  };

  /// A USER has no admin routes (403), so the same card reads the user route.
  Future<Map<String, dynamic>> _admin(
    String tail, [
    Map<String, dynamic> query = const {},
  ]) => isAdmin()
      ? _gateway.get(ApiEndpoints.analytics('admin', tail), query)
      : _gateway.get(
          ApiEndpoints.analytics('user', _userTails[tail] ?? tail),
          query,
        );

  Future<Map<String, dynamic>> _super(
    String tail, [
    Map<String, dynamic> query = const {},
  ]) => _gateway.get(ApiEndpoints.analytics('super-admin', tail), query);

  /// The same endpoint for the admin or the platform level.
  Future<Map<String, dynamic>> _level(
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
  Future<List<T>> _list<T>(
    Future<Map<String, dynamic>> response,
    String key,
    T Function(Map<String, dynamic>) make,
  ) async {
    final rows = _rows((await response)[key]);
    return [for (final r in rows) make(r)];
  }

  // ---------- admin: pulse ----------

  @override
  Future<KpiCompare> kpisCompare({
    required String from,
    required String to,
    Map<String, dynamic> scope = const {},
  }) async => KpiCompare.fromJson(
    await _admin('kpis/compare', {'from': from, 'to': to, ...scope}),
  );

  @override
  Future<List<Insight>> insights({Map<String, dynamic> scope = const {}}) =>
      _list(_admin('insights', scope), 'insights', Insight.fromJson);

  @override
  Future<Overview> overview({Map<String, dynamic> scope = const {}}) async =>
      Overview(await _admin('overview', scope));

  // ---------- admin: collections ----------

  @override
  Future<List<TrendPoint>> trend({
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

  @override
  Future<CollectionCalendar> calendar({
    required String month, // yyyy-MM
    Map<String, dynamic> scope = const {},
  }) async => CollectionCalendar.fromJson(
    await _admin('collections/calendar', {'month': month, ...scope}),
  );

  @override
  Future<List<WeekdayRow>> byWeekday({
    required String from,
    required String to,
    Map<String, dynamic> scope = const {},
  }) async => WeekdayRow.list(
    await _admin('collections/by-weekday', {'from': from, 'to': to, ...scope}),
  );

  @override
  Future<PaymentBehaviour> behaviour({
    required String from,
    required String to,
    Map<String, dynamic> scope = const {},
  }) async => PaymentBehaviour(
    await _admin('payments/behaviour', {'from': from, 'to': to, ...scope}),
  );

  // ---------- admin: portfolio ----------

  @override
  Future<List<AgingBucket>> aging({
    Map<String, dynamic> scope = const {},
  }) async => AgingBucket.list(await _admin('portfolio/aging', scope));

  @override
  Future<List<StatusSlice>> status({
    Map<String, dynamic> scope = const {},
  }) async => StatusSlice.list(await _admin('portfolio/status', scope));

  @override
  Future<List<Cohort>> cohorts({
    int months = 6,
    int weeks = 12,
    Map<String, dynamic> scope = const {},
  }) => _list(
    _admin('cohorts', {'months': months, 'weeks': weeks, ...scope}),
    'cohorts',
    Cohort.fromJson,
  );

  @override
  Future<DisbursementData> disbursements({
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
  @override
  Future<EarningsData> earnings({
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

  @override
  Future<PagedRows<MaturingRow>> maturing({
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

  @override
  Future<PagedRows<RiskRow>> risk({
    int page = 1,
    int limit = 20,
    Map<String, dynamic> scope = const {},
  }) async => PagedRows.from(
    await _admin('customers/risk', {'page': page, 'limit': limit, ...scope}),
    'rows',
    RiskRow.new,
  );

  @override
  Future<RepeatData> repeat({Map<String, dynamic> scope = const {}}) async =>
      RepeatData(await _admin('customers/repeat', scope));

  @override
  Future<List<Referrer>> referrals({
    int limit = 10,
    Map<String, dynamic> scope = const {},
  }) => _list(
    _admin('referrals/performance', {'limit': limit, ...scope}),
    'referrers',
    Referrer.new,
  );

  /// Platform routes take no scope filters.
  @override
  Future<List<GeoArea>> geography({
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
  @override
  Future<PagedRows<EmployeePerf>> employees({
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

  @override
  Future<EmployeeSummary> employeeSummary(
    String id, {
    required String from,
    required String to,
  }) async => EmployeeSummary(
    await _admin('employees/$id/summary', {'from': from, 'to': to}),
  );

  /// For the platform route only admin_id from [scope] is sent.
  @override
  Future<Forecast> forecast({
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

  @override
  Future<Overview> spOverview() async => Overview(await _super('overview'));

  @override
  Future<List<AdminPerf>> spAdmins({
    required String from,
    required String to,
  }) => _list(
    _super('admins/performance', {'from': from, 'to': to}),
    'admins',
    AdminPerf.new,
  );

  @override
  Future<List<GrowthPoint>> spGrowth({
    required String from,
    required String to,
    String groupBy = 'month',
  }) => _list(
    _super('admins/growth', {'from': from, 'to': to, 'group_by': groupBy}),
    'series',
    GrowthPoint.new,
  );

  @override
  Future<List<TrendPoint>> spTrend({
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

  @override
  Future<List<AgingBucket>> spAging() async {
    final d = await _super('portfolio/aging');
    return AgingBucket.list({'buckets': d['platform']});
  }

  @override
  Future<Map<String, dynamic>> spConcentration({int limit = 10}) =>
      _super('risk/concentration', {'limit': limit});

  @override
  Future<Map<String, dynamic>> spAccounts() => _super('accounts/summary');
}
