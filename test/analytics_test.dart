import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/data/models/analytics_model.dart';
import 'package:micro_lending_app/features/analytics/analytics_filter.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_cards_more.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_common.dart';

void main() {
  group('Money.compact', () {
    test('lakh and crore', () {
      expect(Money.compact(120000), '₹1.2L');
      expect(Money.compact(100000), '₹1L');
      expect(Money.compact(45000000), '₹4.5Cr');
      expect(Money.compact(-250000), '-₹2.5L');
    });
  });

  group('KpiCompare', () {
    final json = {
      'days': 30,
      'metrics': [
        {
          'key': 'collected',
          'label': 'Collected',
          'unit': 'INR',
          'current': 182000,
          'previous': 161000,
          'change': 21000,
          'change_pct': 13.0,
          'direction': 'up',
          'is_good': true,
        },
        {
          'key': 'collection_rate',
          'label': 'Collection rate',
          'unit': '%',
          'current': 86.7,
          'previous': 88.1,
          'change': -1.4,
          'change_pct': null,
          'direction': 'down',
          'is_good': false,
        },
      ],
    };

    test('parses amounts and rates', () {
      final c = KpiCompare.fromJson(json);
      expect(c.days, 30);
      expect(c.by('collected')!.changePct, 13.0);
      expect(c.by('collection_rate')!.changePct, isNull);
      expect(c.by('collection_rate')!.isGood, false);
      expect(c.by('missing'), isNull);
    });
  });

  group('CollectionCalendar', () {
    test('parses days, totals and a null worst day', () {
      final c = CollectionCalendar.fromJson({
        'month': '2026-11',
        'first_weekday': 7,
        'days': [
          {
            'date': '2026-11-02',
            'weekday': 'MONDAY',
            'is_future': false,
            'target': 9000,
            'collected': 7500,
            'collection_rate_pct': 83.3,
          },
        ],
        'totals': {
          'target': 42000,
          'collected': 36500,
          'collection_rate_pct': 86.9,
        },
        'best_day': {'date': '2026-11-02'},
        'worst_day': null,
      });
      expect(c.firstWeekday, 7);
      expect(c.days.single.collected, 7500);
      expect(c.bestDay, DateTime(2026, 11, 2));
      expect(c.worstDay, isNull);
    });
  });

  group('Trend and paging', () {
    test('TrendPoint reads series with and without admin_id', () {
      final pts = TrendPoint.list({
        'series': [
          {'period': '2026-10-05', 'target': 48000, 'collected': 41000},
          {'period': '2026-10-12', 'admin_id': 'a1', 'collected': 5},
        ],
      });
      expect(pts.length, 2);
      expect(pts[0].adminId, isNull);
      expect(pts[1].adminId, 'a1');
    });

    test('PagedRows reads total and rows', () {
      final p = PagedRows.from(
        {
          'rows': [
            {'loan_id': 'l1', 'customer_name': 'Ravi K', 'risk_score': 59.0},
          ],
          'total': 17,
          'page': 1,
          'limit': 20,
        },
        'rows',
        RiskRow.new,
      );
      expect(p.total, 17);
      expect(p.rows.single.score, 59.0);
    });
  });

  group('Overview and AdminPerf', () {
    test('Overview reads nested groups', () {
      final o = Overview({
        'loans': {'overdue': 12},
        'rates': {'par_pct': 22.9},
        'collected': {'this_month': 182000},
        'accounts': {'admins': 4},
      });
      expect(o.overdue, 12);
      expect(o.parPct, 22.9);
      expect(o.month, 182000);
      expect(o.admins, 4);
    });

    test('AdminPerf survives null name and rates', () {
      final a = AdminPerf({
        'admin_id': 'x',
        'name': null,
        'employees': 0,
        'collected_in_range': 0,
        'collection_rate_pct': null,
      });
      expect(a.employees, 0);
      expect(a.rate, 0);
    });
  });

  group('splitSeries', () {
    test('keeps the top four admins and groups the rest as Others', () {
      final rows = [
        for (var i = 1; i <= 6; i++) ('2026-10-01', 'a$i', i * 100.0),
      ];
      final (labels, series) = splitSeries(rows, {
        for (var i = 1; i <= 6; i++) 'a$i': 'Admin $i',
      });
      expect(labels, ['2026-10-01']);
      expect(series.length, 5);
      expect(series.last.name, 'Others');
      expect(series.first.name, 'Admin 6');
    });
  });

  group('AnalyticsFilters', () {
    test('7 days spans 7 calendar days', () {
      final r = AnalyticsFilters.rangeFor('7d');
      expect(r.$2.difference(r.$1).inDays, 6);
    });

    test('last month starts on the 1st', () {
      final r = AnalyticsFilters.rangeFor('last');
      expect(r.$1.day, 1);
      expect(r.$2.isBefore(DateTime.now()), isTrue);
    });

    test('scope sends admin_id and employee_id only at admin level', () {
      final f = AnalyticsFilters()
        ..setAdmin('a', 'A')
        ..setEmployee('e', 'E');
      expect(f.scope('admin'), {'admin_id': 'a', 'employee_id': 'e'});
      expect(f.adminOnly, {'admin_id': 'a'});
    });
  });
}
