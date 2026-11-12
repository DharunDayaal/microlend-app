import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:micro_lending_app/data/services/analytics_service.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';

class AnalyticsFilters extends ChangeNotifier {
  static final _fmt = DateFormat('yyyy-MM-dd');
  static const maxDays = 366;

  late DateTime from;
  late DateTime to;
  String preset = '30d'; // 7d, 30d, 90d, this, last, custom
  String? employeeId;
  String? employeeName;
  String? adminId;
  String? adminName;
  int tick = 0; // bumped by pull to refresh

  AnalyticsFilters() {
    final r = rangeFor('30d');
    from = r.$1;
    to = r.$2;
  }

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static (DateTime, DateTime) rangeFor(String preset) {
    final t = _today();
    switch (preset) {
      case '7d':
        return (t.subtract(const Duration(days: 6)), t);
      case '90d':
        return (t.subtract(const Duration(days: 89)), t);
      case 'this':
        return (DateTime(t.year, t.month, 1), t);
      case 'last':
        final first = DateTime(t.year, t.month - 1, 1);
        return (first, DateTime(t.year, t.month, 0));
      default:
        return (t.subtract(const Duration(days: 29)), t);
    }
  }

  String get fromStr => _fmt.format(from);
  String get toStr => _fmt.format(to);

  String get rangeLabel => switch (preset) {
    '7d' => 'Last 7 days',
    '30d' => 'Last 30 days',
    '90d' => 'Last 90 days',
    'this' => 'This month',
    'last' => 'Last month',
    _ => '${DateFormatter.dayMonth(from)} - ${DateFormatter.dayMonth(to)}',
  };

  /// Calendar, aging and cohorts ignore the date range.
  String get scopeKey => '$employeeId|$adminId|$tick';
  String get key => '$fromStr|$toStr|$scopeKey';

  /// For endpoints that accept admin_id but not employee_id.
  Map<String, dynamic> get adminOnly => {
    if (adminId != null) 'admin_id': adminId,
  };

  /// admin_id and employee_id are ignored for a USER, so only admin level sends them.
  Map<String, dynamic> scope(String level) => level == 'admin'
      ? {
          if (adminId != null) 'admin_id': adminId,
          if (employeeId != null) 'employee_id': employeeId,
        }
      : const {};

  void apply(String preset, DateTime from, DateTime to) {
    this.preset = preset;
    this.from = from;
    this.to = to;
    notifyListeners();
  }

  void setEmployee(String? id, String? name) {
    employeeId = id;
    employeeName = name;
    notifyListeners();
  }

  void setAdmin(String? id, String? name) {
    adminId = id;
    adminName = name;
    employeeId = null; // the old employee belongs to another team
    employeeName = null;
    notifyListeners();
  }

  void refresh() {
    AnalyticsService.expireAll();
    tick++;
    notifyListeners();
  }
}
