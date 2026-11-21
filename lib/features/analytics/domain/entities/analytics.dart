double? _n(dynamic v) => v == null ? null : num.tryParse('$v')?.toDouble();
double _d(dynamic v) => _n(v) ?? 0;
int _i(dynamic v) => (_n(v) ?? 0).round();
String _s(dynamic v) => v == null ? '' : '$v';
Map<String, dynamic> _m(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
List<Map<String, dynamic>> _ms(dynamic v) => v is List
    ? [
        for (final e in v)
          if (e is Map) Map<String, dynamic>.from(e),
      ]
    : const [];
DateTime? _day(dynamic v) {
  final d = DateTime.tryParse(_s(v));
  return d == null ? null : DateTime(d.year, d.month, d.day);
}

class KpiMetric {
  final String key;
  final String label;
  final String unit; // INR, %, or a count
  final double current;
  final double previous;
  final double change;
  final double? changePct;
  final String direction; // up, down, flat
  final bool? isGood;

  const KpiMetric({
    required this.key,
    required this.label,
    required this.unit,
    required this.current,
    required this.previous,
    required this.change,
    required this.changePct,
    required this.direction,
    required this.isGood,
  });

  factory KpiMetric.fromJson(Map<String, dynamic> j) => KpiMetric(
    key: _s(j['key']),
    label: _s(j['label']),
    unit: _s(j['unit']),
    current: _d(j['current']),
    previous: _d(j['previous']),
    change: _d(j['change']),
    changePct: _n(j['change_pct']),
    direction: _s(j['direction']),
    isGood: j['is_good'] is bool ? j['is_good'] as bool : null,
  );
}

class KpiCompare {
  final int days;
  final List<KpiMetric> metrics;
  const KpiCompare({required this.days, required this.metrics});

  factory KpiCompare.fromJson(Map<String, dynamic> j) => KpiCompare(
    days: _i(j['days']),
    metrics: _ms(j['metrics']).map(KpiMetric.fromJson).toList(),
  );

  KpiMetric? by(String key) => metrics.where((m) => m.key == key).firstOrNull;
}

class InsightAction {
  final String label;
  final String screen;
  final Map<String, dynamic> params;
  const InsightAction({
    required this.label,
    required this.screen,
    required this.params,
  });
}

class Insight {
  final String id;
  final String severity; // critical, warning, positive, info
  final String title;
  final String detail;
  final InsightAction? action;

  const Insight({
    required this.id,
    required this.severity,
    required this.title,
    required this.detail,
    required this.action,
  });

  factory Insight.fromJson(Map<String, dynamic> j) {
    final a = j['action'];
    return Insight(
      id: _s(j['id']),
      severity: _s(j['severity']),
      title: _s(j['title']),
      detail: _s(j['detail']),
      action: a is Map
          ? InsightAction(
              label: _s(a['label']),
              screen: _s(a['screen']),
              params: _m(a['params']),
            )
          : null,
    );
  }
}

class CalendarDay {
  final DateTime date;
  final String weekday;
  final bool isFuture;
  final double target;
  final double collected;
  final double? ratePct;

  const CalendarDay({
    required this.date,
    required this.weekday,
    required this.isFuture,
    required this.target,
    required this.collected,
    required this.ratePct,
  });

  factory CalendarDay.fromJson(Map<String, dynamic> j) => CalendarDay(
    date: _day(j['date']) ?? DateTime(1970),
    weekday: _s(j['weekday']),
    isFuture: j['is_future'] == true,
    target: _d(j['target']),
    collected: _d(j['collected']),
    ratePct: _n(j['collection_rate_pct']),
  );
}

class CollectionCalendar {
  final String month; // yyyy-MM
  final int firstWeekday; // 1 Monday .. 7 Sunday
  final List<CalendarDay> days;
  final double target;
  final double collected;
  final double? ratePct;
  final DateTime? bestDay;
  final DateTime? worstDay;

  const CollectionCalendar({
    required this.month,
    required this.firstWeekday,
    required this.days,
    required this.target,
    required this.collected,
    required this.ratePct,
    required this.bestDay,
    required this.worstDay,
  });

  factory CollectionCalendar.fromJson(Map<String, dynamic> j) {
    final t = _m(j['totals']);
    return CollectionCalendar(
      month: _s(j['month']),
      firstWeekday: _i(j['first_weekday']).clamp(1, 7),
      days: _ms(j['days']).map(CalendarDay.fromJson).toList(),
      target: _d(t['target']),
      collected: _d(t['collected']),
      ratePct: _n(t['collection_rate_pct']),
      bestDay: j['best_day'] is Map ? _day(_m(j['best_day'])['date']) : null,
      worstDay: j['worst_day'] is Map ? _day(_m(j['worst_day'])['date']) : null,
    );
  }
}

class CohortPoint {
  final int week;
  final int loansObserved;
  final double? repaidPct;
  final double? onTrackPct;
  const CohortPoint({
    required this.week,
    required this.loansObserved,
    required this.repaidPct,
    required this.onTrackPct,
  });
}

class Cohort {
  final String cohort; // yyyy-MM
  final int loans;
  final double nominal;
  final int defaulted;
  final double? defaultRatePct;
  final List<CohortPoint> curve;

  const Cohort({
    required this.cohort,
    required this.loans,
    required this.nominal,
    required this.defaulted,
    required this.defaultRatePct,
    required this.curve,
  });

  factory Cohort.fromJson(Map<String, dynamic> j) => Cohort(
    cohort: _s(j['cohort']),
    loans: _i(j['loans']),
    nominal: _d(j['nominal']),
    defaulted: _i(j['defaulted']),
    defaultRatePct: _n(j['default_rate_pct']),
    curve: [
      for (final p in _ms(j['curve']))
        CohortPoint(
          week: _i(p['week']),
          loansObserved: _i(p['loans_observed']),
          repaidPct: _n(p['repaid_pct']),
          onTrackPct: _n(p['on_track_pct']),
        ),
    ],
  );
}

class TrendPoint {
  final String label;
  final double collected;
  final double? target;
  final String? adminId;

  const TrendPoint({
    required this.label,
    required this.collected,
    required this.target,
    this.adminId,
  });

  static List<TrendPoint> list(Map<String, dynamic> data) {
    final raw = data['series'] ?? data['points'] ?? data['trend'];
    return [
      for (final p in _ms(raw))
        TrendPoint(
          label: _s(p['period'] ?? p['label'] ?? p['date']),
          collected: _d(p['collected'] ?? p['amount']),
          target: _n(p['target']),
          adminId: p['admin_id']?.toString(),
        ),
    ];
  }
}

/// ASSUMED: data.buckets | aging, each { label|bucket, loans|loan_count, outstanding }
class AgingBucket {
  final String label;
  final int loans;
  final double outstanding;
  const AgingBucket({
    required this.label,
    required this.loans,
    required this.outstanding,
  });

  static List<AgingBucket> list(Map<String, dynamic> data) => [
    for (final b in _ms(data['buckets'] ?? data['aging']))
      AgingBucket(
        label: _s(b['label'] ?? b['bucket']),
        loans: _i(b['loans'] ?? b['loan_count']),
        outstanding: _d(b['outstanding']),
      ),
  ];
}

/// ASSUMED: data.statuses | status | breakdown, each { status, count|loans }
class StatusSlice {
  final String status;
  final int count;
  const StatusSlice({required this.status, required this.count});

  static List<StatusSlice> list(Map<String, dynamic> data) => [
    for (final s in _ms(
      data['statuses'] ?? data['status'] ?? data['breakdown'],
    ))
      StatusSlice(status: _s(s['status']), count: _i(s['count'] ?? s['loans'])),
  ];
}

/// ASSUMED: data.weekdays | by_weekday | days, each { weekday, target, collected, customers }
class WeekdayRow {
  final String weekday;
  final double target;
  final double collected;
  final int customers;
  const WeekdayRow({
    required this.weekday,
    required this.target,
    required this.collected,
    required this.customers,
  });

  static List<WeekdayRow> list(Map<String, dynamic> data) => [
    for (final w in _ms(data['weekdays'] ?? data['by_weekday'] ?? data['days']))
      WeekdayRow(
        weekday: _s(w['weekday']),
        target: _d(w['target']),
        collected: _d(w['collected']),
        customers: _i(w['customers'] ?? w['customer_count']),
      ),
  ];
}

typedef Json = Map<String, dynamic>;

class PagedRows<T> {
  final List<T> rows;
  final int total;
  final int page;
  final int limit;
  const PagedRows(this.rows, this.total, this.page, this.limit);

  factory PagedRows.from(Json j, String key, T Function(Json) make) =>
      PagedRows(
        [for (final r in _ms(j[key])) make(r)],
        _i(j['total']),
        _i(j['page']),
        _i(j['limit']),
      );
}

class Overview {
  final Json j;
  const Overview(this.j);
  int get customers => _i(_m(j['customers'])['total']);
  int get activeBorrowers => _i(_m(j['customers'])['active_borrowers']);
  int get activeLoans => _i(_m(j['loans'])['active']);
  int get overdue => _i(_m(j['loans'])['overdue']);
  int get defaulted => _i(_m(j['loans'])['defaulted']);
  double get totalCollected => _d(_m(j['money'])['total_collected']);
  double get totalOutstanding => _d(_m(j['money'])['total_outstanding']);
  double get parAmount => _d(_m(j['money'])['par_amount']);
  double get collectionRatePct => _d(_m(j['rates'])['collection_rate_pct']);
  double get parPct => _d(_m(j['rates'])['par_pct']);
  double get today => _d(_m(j['collected'])['today']);
  double get week => _d(_m(j['collected'])['this_week']);
  double get month => _d(_m(j['collected'])['this_month']);
  int? get admins =>
      j['accounts'] is Map ? _i(_m(j['accounts'])['admins']) : null;
  int? get employees =>
      j['accounts'] is Map ? _i(_m(j['accounts'])['employees']) : null;
  double? get totalEarned =>
      j['earnings'] is Map ? _d(_m(j['earnings'])['total_earned']) : null;
  double? get interestExpected =>
      j['earnings'] is Map ? _d(_m(j['earnings'])['interest_expected']) : null;
}

class PaymentBehaviour {
  final Json j;
  const PaymentBehaviour(this.j);
  int get count => _i(_m(j['payments'])['count']);
  double get onTimePct => _d(_m(j['payments'])['on_time_pct']);
  double get latePct => _d(_m(j['payments'])['late_pct']);
  double get avgDaysLate => _d(_m(j['payments'])['avg_days_late']);
  int get maxDaysLate => _i(_m(j['payments'])['max_days_late']);
  int get dueWeeks => _i(_m(j['weekly_instalments'])['due_weeks']);
  double get paidPct => _d(_m(j['weekly_instalments'])['paid_pct']);
  double get partialPct => _d(_m(j['weekly_instalments'])['partial_pct']);
  double get unpaidPct => _d(_m(j['weekly_instalments'])['unpaid_pct']);
  double get overpaidPct => _d(_m(j['weekly_instalments'])['overpaid_pct']);
}

class DisbursementData {
  final Json j;
  const DisbursementData(this.j);
  int get loans => _i(_m(j['totals'])['loans']);
  double get disbursed => _d(_m(j['totals'])['disbursed']);
  List<Json> get series => _ms(j['series']);
}

class EarningsData {
  final Json j;
  const EarningsData(this.j);
  double get fees => _d(_m(j['totals'])['fees_earned']);
  double get interest => _d(_m(j['totals'])['interest_earned']);
  double get expected => _d(_m(j['totals'])['interest_expected']);
  double get total => _d(_m(j['totals'])['total_earned']);
  List<Json> get series => _ms(j['series']);
}

class MaturingRow {
  final Json j;
  const MaturingRow(this.j);
  String get loanId => _s(j['loan_id']);
  String get name => _s(j['customer_name']);
  String get phone => _s(j['phone_number']);
  int get daysLeft => _i(j['days_left']);
  double get outstanding => _d(j['outstanding']);
  double get weekly => _d(j['weekly_payable_amount']);
  DateTime? get maturity => DateTime.tryParse(_s(j['maturity_date']));
}

class RiskRow {
  final Json j;
  const RiskRow(this.j);
  String get loanId => _s(j['loan_id']);
  String get name => _s(j['customer_name']);
  String get phone => _s(j['phone_number']);
  String get status => _s(j['status']);
  double get outstanding => _d(j['outstanding']);
  int get daysPastDue => _i(j['days_past_due']);
  int get missedWeeks => _i(j['missed_weeks']);
  bool get referrerAtRisk => j['referrer_at_risk'] == true;
  double get score => _d(j['risk_score']);
}

class RepeatData {
  final Json j;
  const RepeatData(this.j);
  double get repeatRate => _d(j['repeat_rate_pct']);
  double get retentionRate => _d(j['retention_rate_pct']);
  double get avgLoans => _d(j['avg_loans_per_customer']);
  List<Json> get buckets => _ms(j['loans_per_customer']);
}

class Referrer {
  final Json j;
  const Referrer(this.j);
  String get name => _s(j['customer_name']);
  int get referred => _i(j['referred']);
  int get converted => _i(j['converted']);
  int get atRisk => _i(j['at_risk']);
  double get conversionPct => _d(j['conversion_pct']);
}

class GeoArea {
  final Json j;
  const GeoArea(this.j);
  String get area => _s(j['area']);
  int get borrowers => _i(j['borrowers']);
  double get outstanding => _d(j['outstanding']);
  double get parPct => _d(j['par_pct']);
  double get overduePct => _d(j['overdue_pct']);
}

class EmployeePerf {
  final Json j;
  const EmployeePerf(this.j);
  String get id => _s(j['employee_id']);
  String get name => _s(j['name']);
  String get adminName => _s(j['admin_name']);
  int get customers => _i(j['customers']);
  int get overdueLoans => _i(j['overdue_loans']);
  double get collected => _d(j['collected_in_range']);
  double get rate => _d(j['collection_rate_pct']);
  double get parPct => _d(j['par_pct']);
}

class EmployeeSummary {
  final Json j;
  const EmployeeSummary(this.j);
  String get name => _s(_m(j['employee'])['name']);
  Overview get overview => Overview(_m(j['overview']));
  List<TrendPoint> get trend => TrendPoint.list(_m(j['collections_trend']));
  List<AgingBucket> get aging => AgingBucket.list({'buckets': j['aging']});
  List<RiskRow> get risky => [
    for (final r in _ms(j['top_risky_customers'])) RiskRow(r),
  ];
}

class Forecast {
  final Json j;
  const Forecast(this.j);
  String get assumption => _s(j['assumption']);
  double get arrears => _d(j['arrears_due_now']);
  double get total => _d(j['total_expected']);
  List<Json> get series => _ms(j['series']);
}

/// First non-empty value among [keys], for fields the server may name differently.
dynamic _pick(Json j, List<String> keys) {
  for (final k in keys) {
    final v = j[k];
    if (v != null && '$v'.isNotEmpty) return v;
  }
  return null;
}

class AdminPerf {
  final Json j;
  const AdminPerf(this.j);

  String get id => _s(_pick(j, ['admin_id', 'id']));

  /// Falls back to the email or phone, so a row never shows "?".
  String get name {
    final n = _s(_pick(j, ['name', 'user_name', 'admin_name', 'full_name']));
    return n.isNotEmpty ? n : _s(_pick(j, ['email', 'phone_number']));
  }

  int get employees =>
      _i(_pick(j, ['employees', 'employees_count', 'employee_count']));
  int get overdueLoans => _i(_pick(j, ['overdue_loans', 'overdue_count']));
  double get collected =>
      _d(_pick(j, ['collected_in_range', 'collected', 'total_collected']));
  double get rate =>
      _d(_pick(j, ['collection_rate_pct', 'collection_rate', 'rate']));
  double get parPct => _d(_pick(j, ['par_pct', 'par']));
}

class GrowthPoint {
  final Json j;
  const GrowthPoint(this.j);
  String get period => _s(j['period']);
  String get adminId => _s(j['admin_id']);
  String get adminName => _s(j['admin_name']);
  double get disbursed => _d(j['disbursed']);
}
