import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/utils/uuid.dart';
import 'package:micro_lending_app/features/loans/data/dtos/loan_dto.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/data/sources/loan_remote_data_source.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/payment_sheet.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';

import 'fakes.dart';

/// Records the one POST the payment call makes.
class _PostApi extends Fake implements ApiClient {
  String? path;
  Object? data;
  Map<String, String>? headers;

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    bool auth = true,
    Map<String, String>? headers,
  }) async {
    this.path = path;
    this.data = data;
    this.headers = headers;
    return {'success': true};
  }
}

typedef _Call = ({String key, double amount, DateTime collectedAt});

/// Answers each payment with the next outcome: an [ApiException] is thrown,
/// anything else means success.
class _PayRepo extends FakeLoanRepository {
  final List<Object?> outcomes;
  final List<_Call> calls = [];
  _PayRepo(this.outcomes);

  @override
  Future<PaymentResultModel> collectPayment({
    required String loanId,
    required int weekNumber,
    required double amount,
    required String idempotencyKey,
    required DateTime collectedAt,
  }) async {
    calls.add((key: idempotencyKey, amount: amount, collectedAt: collectedAt));
    final next = outcomes.removeAt(0);
    if (next is ApiException) throw next;
    return PaymentResultModel(
      track: track(weekNumber),
      loanStatus: 'ACTIVE',
      loanOutstandingAfter: 900,
    );
  }
}

/// Holds the payment until [gate] completes.
class _SlowRepo extends FakeLoanRepository {
  final gate = Completer<void>();

  @override
  Future<PaymentResultModel> collectPayment({
    required String loanId,
    required int weekNumber,
    required double amount,
    required String idempotencyKey,
    required DateTime collectedAt,
  }) async {
    await gate.future;
    return PaymentResultModel(
      track: track(weekNumber),
      loanStatus: 'ACTIVE',
      loanOutstandingAfter: 900,
    );
  }
}

const _offline = ApiException(message: 'No internet connection');
const _serverDown = ApiException(statusCode: 503, message: 'Unavailable');
const _rejected = ApiException(statusCode: 400, message: 'Amount too high');

void main() {
  test('uuidV4 makes distinct version-4 UUIDs', () {
    final re = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    final keys = {for (var i = 0; i < 500; i++) uuidV4()};
    expect(keys.length, 500);
    expect(keys.every(re.hasMatch), true);
  });

  test(
    'collect payment sends the key header and collected_at in UTC',
    () async {
      final api = _PostApi();
      await LoanRemoteDataSource(api).collectPayment(
        loanId: 'l1',
        weekNumber: 3,
        amount: 500,
        idempotencyKey: 'k-1',
        collectedAt: DateTime.utc(2026, 11, 23, 4, 30, 15, 123, 456),
      );
      expect(api.headers, {'Idempotency-Key': 'k-1'});
      expect(api.data, {
        'week_number': 3,
        'amount_paid': 500.0,
        // milliseconds only, ISO 8601 with Z
        'collected_at': '2026-11-23T04:30:15.123Z',
      });
    },
  );

  group('PaymentResultDto', () {
    Map<String, dynamic> body([Map<String, dynamic> extra = const {}]) => {
      'track': {'id': 't2', 'week_number': 2, 'status': 'PAID'},
      'loan': {'status': 'ACTIVE', 'total_payable_amount': 1200},
      ...extra,
    };

    test('reads replayed and flags', () {
      final r = PaymentResultDto.fromJson(
        body({
          'replayed': true,
          'flags': ['WEEK_ALREADY_PAID', 'OTHER_COLLECTOR_THIS_WEEK'],
        }),
      );
      expect(r.replayed, true);
      expect(r.flags, ['WEEK_ALREADY_PAID', 'OTHER_COLLECTOR_THIS_WEEK']);
    });

    test('an older server without them reads as a new, unflagged payment', () {
      final r = PaymentResultDto.fromJson(body());
      expect(r.replayed, false);
      expect(r.flags, isEmpty);
    });
  });

  group('payment sheet retries', () {
    Future<_PayRepo> openSheet(
      WidgetTester tester,
      List<Object?> outcomes,
    ) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      final repo = _PayRepo(outcomes);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [loanRepositoryProvider.overrideWithValue(repo)],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => PaymentSheet.show(
                    context,
                    customerId: 'c1',
                    customerName: 'Kavya',
                    weekNumber: 3,
                    totalWeeks: 12,
                    issuedAt: DateTime.now(),
                    targetAmount: 100,
                    loanOutstandingAmount: 1000,
                    loanId: 'l1',
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return repo;
    }

    Future<void> confirm(WidgetTester tester) async {
      await tester.tap(find.textContaining('CONFIRM'));
      await tester.pumpAndSettle();
    }

    testWidgets('after a network or server error, retry reuses the key', (
      tester,
    ) async {
      final repo = await openSheet(tester, [_offline, _serverDown, null]);
      await confirm(tester);
      await tester.pump(const Duration(seconds: 5)); // snackbar away
      await confirm(tester);
      await tester.pump(const Duration(seconds: 5));
      await confirm(tester);

      expect(repo.calls, hasLength(3));
      expect(repo.calls.map((c) => c.key).toSet(), hasLength(1));
      expect(repo.calls.map((c) => c.collectedAt).toSet(), hasLength(1));
      expect(find.byType(PaymentSheet), findsNothing); // closed on success
    });

    testWidgets('after a rejection, the next try is a new payment', (
      tester,
    ) async {
      final repo = await openSheet(tester, [_rejected, null]);
      await confirm(tester);
      expect(find.text('Amount too high'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await confirm(tester);

      expect(repo.calls, hasLength(2));
      expect(repo.calls[0].key, isNot(repo.calls[1].key));
    });

    testWidgets('changing the amount after a network error uses a new key', (
      tester,
    ) async {
      final repo = await openSheet(tester, [_offline, null]);
      await confirm(tester);
      await tester.pump(const Duration(seconds: 5));
      await tester.enterText(find.byType(TextField), '200');
      await tester.pump();
      await confirm(tester);

      expect(repo.calls.map((c) => c.amount), [100, 200]);
      expect(repo.calls[0].key, isNot(repo.calls[1].key));
    });
  });

  testWidgets('the sheet cannot be closed while a payment is being sent', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repo = _SlowRepo();
    Object? sheetResult = 'not closed';
    bool? pageResult;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [loanRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              // like the tracker: a pushed screen that returns a bool
              onPressed: () async {
                pageResult = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      body: TextButton(
                        onPressed: () async {
                          sheetResult = await PaymentSheet.show(
                            context,
                            customerId: 'c1',
                            customerName: 'Kavya',
                            weekNumber: 3,
                            totalWeeks: 12,
                            issuedAt: DateTime.now(),
                            targetAmount: 100,
                            loanOutstandingAmount: 1000,
                            loanId: 'l1',
                          );
                        },
                        child: const Text('pay'),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('open screen'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open screen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('pay'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('CONFIRM'));
    await tester.pump();

    // every way out while the request is pending
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tapAt(const Offset(20, 20)); // the barrier above the sheet
    await tester.pump(const Duration(milliseconds: 600));
    await tester.drag(find.text('Collect Payment'), const Offset(0, 600));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.binding.handlePopRoute(); // Android back
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(PaymentSheet), findsOneWidget);

    repo.gate.complete();
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(PaymentSheet), findsNothing);
    expect(sheetResult, isA<PaymentResultModel>()); // reached the screen
    expect(find.text('pay'), findsOneWidget); // the screen is still open
    expect(pageResult, isNull);
  });
}
