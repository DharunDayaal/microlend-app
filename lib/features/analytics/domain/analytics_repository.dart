import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:flutter/foundation.dart';
import 'package:micro_lending_app/features/analytics/domain/entities/analytics.dart';
import 'package:micro_lending_app/features/analytics/domain/entities/analytics_status.dart';

/// Every analytics number on the Reports tab and Advanced analytics.
/// Implementations cache answers (2 minutes), share in-flight requests and
/// fall back to the last answer offline. They throw `ApiException`.
abstract interface class AnalyticsRepository {
  /// Offline banner and "Updated ... ago".
  ValueListenable<AnalyticsStatus> get connection;

  /// Sign-out: the next user must not see these numbers.
  void clearCache();

  /// Pull to refresh: entries count as old, but stay as an offline fallback.
  void expireAll();

  /// Completes when the requests started by a refresh have finished.
  Future<void> settled();

  /// Warms this month's calendar so the Collections chip opens instantly.
  void prefetchCalendar(Map<String, dynamic> scope);

  Future<KpiCompare> kpisCompare({
    required String from,
    required String to,
    Map<String, dynamic> scope = const {},
  });

  Future<List<Insight>> insights({Map<String, dynamic> scope = const {}});

  Future<Overview> overview({Map<String, dynamic> scope = const {}});

  Future<List<TrendPoint>> trend({
    required String from,
    required String to,
    required String groupBy, // day, week, month
    Map<String, dynamic> scope = const {},
  });

  Future<CollectionCalendar> calendar({
    required String month, // yyyy-MM
    Map<String, dynamic> scope = const {},
  });

  Future<List<WeekdayRow>> byWeekday({
    required String from,
    required String to,
    Map<String, dynamic> scope = const {},
  });

  Future<PaymentBehaviour> behaviour({
    required String from,
    required String to,
    Map<String, dynamic> scope = const {},
  });

  Future<List<AgingBucket>> aging({Map<String, dynamic> scope = const {}});

  Future<List<StatusSlice>> status({Map<String, dynamic> scope = const {}});

  Future<List<Cohort>> cohorts({
    int months = 6,
    int weeks = 12,
    Map<String, dynamic> scope = const {},
  });

  Future<DisbursementData> disbursements({
    required String from,
    required String to,
    String groupBy = 'week',
    Map<String, dynamic> scope = const {},
  });

  /// [adminOnly] is just admin_id: earnings has no employee filter here.
  Future<EarningsData> earnings({
    required String from,
    required String to,
    String groupBy = 'week',
    Map<String, dynamic> adminOnly = const {},
    bool platform = false,
    bool split = false,
  });

  Future<PagedRows<MaturingRow>> maturing({
    int days = 14,
    int page = 1,
    int limit = 20,
    Map<String, dynamic> scope = const {},
  });

  Future<PagedRows<RiskRow>> risk({
    int page = 1,
    int limit = 20,
    Map<String, dynamic> scope = const {},
  });

  Future<RepeatData> repeat({Map<String, dynamic> scope = const {}});

  /// One page of referrers, most referrals first (limit max 50).
  Future<PagedResult<Referrer>> referrals({
    int page = 1,
    int limit = 10,
    Map<String, dynamic> scope = const {},
  });

  /// One page of areas, highest outstanding first (limit max 100).
  /// Platform routes take no scope filters.
  Future<PagedResult<GeoArea>> geography({
    required String level, // district, city
    bool platform = false,
    int page = 1,
    int limit = 50,
    Map<String, dynamic> scope = const {},
  });

  /// Team performance, or the platform leaderboard when [platform].
  Future<PagedRows<EmployeePerf>> employees({
    required String from,
    required String to,
    int page = 1,
    int limit = 20,
    bool platform = false,
    Map<String, dynamic> adminOnly = const {},
  });

  Future<EmployeeSummary> employeeSummary(
    String id, {
    required String from,
    required String to,
  });

  /// For the platform route only admin_id from [scope] is sent.
  Future<Forecast> forecast({
    int weeks = 8,
    bool platform = false,
    Map<String, dynamic> scope = const {},
  });

  Future<Overview> spOverview();

  /// One page of admins, highest collections first.
  Future<PagedResult<AdminPerf>> spAdminsPage({
    required String from,
    required String to,
    int page = 1,
    int limit = kMaxPageLimit,
  });

  /// Every admin (all pages).
  Future<List<AdminPerf>> spAdmins({required String from, required String to});

  Future<List<GrowthPoint>> spGrowth({
    required String from,
    required String to,
    String groupBy = 'month',
  });

  Future<List<TrendPoint>> spTrend({
    required String from,
    required String to,
    String groupBy = 'week',
    bool split = false,
  });

  Future<List<AgingBucket>> spAging();

  /// The platform totals and `by_admin` (always whole-platform), plus one
  /// page of `top_exposures` (limit max 50).
  Future<Concentration> spConcentration({int page = 1, int limit = 10});

  Future<Map<String, dynamic>> spAccounts();
}
