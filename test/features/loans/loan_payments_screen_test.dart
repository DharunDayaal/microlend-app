import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/features/loans/data/dtos/loan_dto.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/presentation/screens/loan_payments.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/payment_tile.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';

import 'fakes.dart';

/// The payments from the real `GET /loans/payments/:loanId` response.
final samplePayments = [
  {
    'id': '1baf7a20-d630-4b60-b72a-9e77a7ba499b',
    'track_id': '37c200f3-5ddd-44cc-8ad5-24862804a504',
    'loan_id': '804b86ed-032f-4a44-96d1-a928be8c5556',
    'amount_paid': 900,
    'paid_at': '2026-11-05T18:40:09.412Z',
    'collected_by_admin_id': 'eb4bc22a-eac5-479c-99e6-db854e860648',
    'week_number': 2,
  },
  {
    'id': '78a61e60-feb1-460e-9c84-c86c79685c18',
    'track_id': '347d4052-ef35-45df-93e1-dcfb2ee54509',
    'loan_id': '804b86ed-032f-4a44-96d1-a928be8c5556',
    'amount_paid': 100,
    'paid_at': '2026-11-03T16:40:49.705Z',
    'collected_by_admin_id': '98a98f60-6c3f-4dfc-be6c-8518b17ae216',
    'week_number': 1,
  },
  {
    'id': '4c5c76e5-3576-4f30-9fe8-f1e378267e18',
    'track_id': '347d4052-ef35-45df-93e1-dcfb2ee54509',
    'loan_id': '804b86ed-032f-4a44-96d1-a928be8c5556',
    'amount_paid': 100,
    'paid_at': '2026-11-03T16:40:21.739Z',
    'collected_by_admin_id': '98a98f60-6c3f-4dfc-be6c-8518b17ae216',
    'week_number': 1,
  },
].map(PaymentDto.fromJson).toList();

LoanTrackModel weekTrack(int week, double collected, String status) =>
    LoanTrackModel(
      id: 't$week',
      loanId: 'l1',
      weekNumber: week,
      totalCollected: collected,
      targetAmount: 900,
      status: status,
      isOverdued: false,
      remainingBalance: 900 - collected,
    );

void main() {
  late FakeLoanRepository repo;

  setUp(() {
    repo = FakeLoanRepository()
      ..loans['l1'] = loan(
        'l1',
        issuedAt: DateTime(2026, 10, 27),
        tracks: [weekTrack(1, 200, 'PARTIAL'), weekTrack(2, 900, 'PAID')],
      )
      ..payments = samplePayments;
  });

  Future<void> pump(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    Locale locale = const Locale('en'),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loanRepositoryProvider.overrideWithValue(repo),
          borrowerLookupProvider.overrideWithValue(FakeBorrowerLookup()),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const LoanPaymentsScreen(loanId: 'l1'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('payments are grouped by day with each day\'s total', (
    tester,
  ) async {
    await pump(tester);
    expect(tester.takeException(), isNull);

    expect(find.byType(PaymentRow), findsNWidgets(3));
    expect(find.text('Payment history'), findsOneWidget);
    expect(find.text('3 payments'), findsOneWidget);
    // 5 Nov: ₹900; 3 Nov: ₹100 + ₹100 (local dates of the UTC times)
    expect(find.text('+₹900'), findsOneWidget);
    expect(find.text('+₹100'), findsNWidgets(2));
    expect(find.textContaining('Week cleared'), findsOneWidget);
    expect(find.textContaining('left for this week'), findsNWidgets(2));
  });

  testWidgets('tapping a payment opens its details', (tester) async {
    await pump(tester);
    await tester.tap(find.byType(PaymentRow).first);
    await tester.pumpAndSettle();

    expect(find.byType(PaymentDetailsSheet), findsOneWidget);
    expect(find.text('Payment details'), findsOneWidget);
    expect(find.text('Collected by'), findsOneWidget);
    expect(find.text('Payment reference'), findsOneWidget);
    expect(find.byTooltip('Copy'), findsNWidgets(2));

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(PaymentDetailsSheet), findsNothing);
  });

  testWidgets('no payments shows the empty state', (tester) async {
    repo.payments = [];
    await pump(tester);
    expect(find.text('No payments found'), findsOneWidget);
    expect(find.byType(PaymentRow), findsNothing);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    for (final size in const [Size(320, 568), Size(360, 640)]) {
      for (final scale in [1.0, 1.3]) {
        testWidgets(
          'no overflow at ${size.width.toInt()}x${size.height.toInt()} '
          '$locale x$scale, list and sheet',
          (tester) async {
            await pump(tester, size: size, locale: locale, scale: scale);
            expect(tester.takeException(), isNull);
            await tester.drag(
              find.byType(CustomScrollView),
              const Offset(0, -1500),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await tester.tap(find.byType(PaymentRow).last);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
