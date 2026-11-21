import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/features/reports/data/dtos/report_dto.dart';
import 'package:micro_lending_app/features/reports/data/report_providers.dart';
import 'package:micro_lending_app/features/reports/data/report_repository_impl.dart';
import 'package:micro_lending_app/features/reports/data/sources/report_remote_data_source.dart';
import 'package:micro_lending_app/features/reports/domain/entities/report.dart';
import 'package:micro_lending_app/features/reports/domain/report_repository.dart';
import 'package:micro_lending_app/features/reports/presentation/widgets/report_cards.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';

/// Answers each endpoint with a canned body.
class FakeRemote extends ReportRemoteDataSource {
  FakeRemote() : super(_NoApi());
  dynamic cash, earn;
  final Map<int, dynamic> overduePages = {};

  @override
  Future<dynamic> cashOutstanding() async => cash;
  @override
  Future<dynamic> earnings() async => earn;
  @override
  Future<dynamic> overdue(int page, int limit) async => overduePages[page];
}

class _NoApi extends Fake implements ApiClient {}

OverdueRow row(String id, {String name = 'Kavya'}) => OverdueRowDto.fromJson({
  'id': id,
  'customer_name': name,
  'outstanding_balance': 900,
  'days_past_due': 3,
});

class FakeReportRepository implements ReportRepository {
  final List<int> overdueCalls = [];
  int overdueTotal = 30;

  @override
  Future<CashOutstanding> cashOutstanding() async =>
      CashOutstandingDto.fromJson({
        'active_loans': 4,
        'total_payable': 10000,
        'total_collected': 4000,
        'outstanding_receivable': 6000,
      });

  @override
  Future<EarningsReport> earnings() async => EarningsReportDto.fromJson({
    'fees_earned': 300,
    'interest_earned': 700,
    'total_earned': 1000,
  });

  @override
  Future<OverduePage> overdue({int page = 1, int limit = 20}) async {
    overdueCalls.add(page);
    final start = (page - 1) * limit;
    final end = (start + limit).clamp(0, overdueTotal);
    return OverduePage(
      rows: [for (var i = start; i < end; i++) row('l$i', name: 'Borrower $i')],
      page: page,
      hasNext: end < overdueTotal,
    );
  }
}

void main() {
  group('ReportRepositoryImpl', () {
    late FakeRemote remote;
    late ReportRepositoryImpl repo;
    setUp(() {
      remote = FakeRemote();
      repo = ReportRepositoryImpl(remote);
    });

    test('reads a report at the top level or inside data', () async {
      remote.cash = {
        'report': {'active_loans': 4, 'outstanding_receivable': 6000},
      };
      remote.earn = {
        'data': {
          'report': {'total_earned': 1000},
        },
      };
      expect((await repo.cashOutstanding()).outstanding, 6000);
      expect((await repo.earnings()).total, 1000);
    });

    test('overdue rows come with paging from either metadata shape', () async {
      remote.overduePages[1] = {
        'report': [
          {'id': 'l1', 'customer_name': 'Kavya', 'days_past_due': 5},
        ],
        'metadata': {'has_next_page': true},
      };
      remote.overduePages[2] = {
        'data': {
          'report': [],
          'metadata': {'has_next_page': false},
        },
      };
      final p1 = await repo.overdue();
      expect(p1.rows.single.customerName, 'Kavya');
      expect(p1.hasNext, true);
      final p2 = await repo.overdue(page: 2);
      expect(p2.rows, isEmpty);
      expect(p2.hasNext, false);
    });
  });

  group('cards', () {
    late FakeReportRepository repo;
    setUp(() => repo = FakeReportRepository());

    Future<void> pump(WidgetTester tester, Widget child) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [reportRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: SingleChildScrollView(child: child)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    testWidgets('cash outstanding and earnings show their totals', (
      tester,
    ) async {
      await pump(
        tester,
        const Column(
          children: [CashOutstandingCard(tick: 0), ReportEarningsCard(tick: 0)],
        ),
      );
      expect(find.text('Outstanding receivable'), findsOneWidget);
      expect(find.text('4 loans in the book'), findsOneWidget);
      expect(find.text('Total earned'), findsOneWidget);
    });

    testWidgets('overdue card opens the full list, which pages on scroll', (
      tester,
    ) async {
      await pump(tester, const OverdueCard(tick: 0));
      expect(find.text('Borrower 0'), findsOneWidget);
      await tester.tap(find.text('See all'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).last, const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(repo.overdueCalls, contains(2));
      await tester.drag(find.byType(ListView).last, const Offset(0, -4000));
      await tester.pumpAndSettle();
      expect(find.text('Borrower 29'), findsOneWidget);
    });
  });
}
