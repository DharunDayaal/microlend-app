import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/network/network_providers.dart';
import 'package:micro_lending_app/core/storage/storage_providers.dart';
import 'package:micro_lending_app/features/analytics/data/analytics_gateway.dart';
import 'package:micro_lending_app/features/analytics/data/analytics_providers.dart';
import 'package:micro_lending_app/features/analytics/data/analytics_repository_impl.dart';
import 'package:micro_lending_app/features/analytics/domain/entities/analytics.dart';
import 'package:micro_lending_app/features/analytics/presentation/screens/due_list_screen.dart';
import 'package:micro_lending_app/features/analytics/presentation/widgets/analytics_common.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

import '../../shared/session/session_fakes.dart';
import '../loans/fakes.dart' as loans;

/// Records GETs; answers from [replies] (a Map, an error, or a gate to wait on).
class FakeApi extends Fake implements ApiClient {
  final List<String> calls = [];
  Object reply = <String, dynamic>{'success': true};
  int running = 0;
  int maxRunning = 0;
  Completer<void>? gate;

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool auth = true,
  }) async {
    calls.add(path);
    running++;
    if (running > maxRunning) maxRunning = running;
    try {
      if (gate != null) await gate!.future;
      final r = reply;
      if (r is Map) return r;
      throw r;
    } finally {
      running--;
    }
  }
}

void main() {
  late FakeApi api;
  late AnalyticsGateway gw;

  setUp(() {
    api = FakeApi();
    gw = AnalyticsGateway(api);
  });

  group('AnalyticsGateway', () {
    test('caches an answer and unwraps the data envelope', () async {
      api.reply = {
        'success': true,
        'data': {'total': 3},
      };
      final a = await gw.get('/x', {'b': 2, 'a': 1});
      final b = await gw.get('/x', {'a': 1, 'b': 2}); // same, other order
      expect(a['total'], 3);
      expect(b['total'], 3);
      expect(api.calls, ['/x']);
      expect(gw.connection.value.updatedAt, isNotNull);
    });

    test('shares one request and runs at most 3 at a time', () async {
      api.gate = Completer();
      final same = [gw.get('/same', {}), gw.get('/same', {})];
      final others = [for (var i = 0; i < 5; i++) gw.get('/o$i', {})];
      await Future<void>.delayed(Duration.zero);
      expect(api.calls.where((c) => c == '/same').length, 1);
      api.gate!.complete();
      await Future.wait([...same, ...others]);
      expect(api.maxRunning, 3);
    });

    test(
      'offline: the last good answer is used and the status says so',
      () async {
        api.reply = {'n': 1};
        await gw.get('/x', {});
        gw.expireAll(); // old now, but kept as a fallback
        api.reply = const ApiException(message: 'offline');
        expect((await gw.get('/x', {}))['n'], 1);
        expect(gw.connection.value.offline, true);

        gw.clearCache(); // sign-out: no fallback left
        expect(gw.connection.value.offline, false);
        await expectLater(gw.get('/x', {}), throwsA(isA<ApiException>()));
      },
    );
  });

  test('a USER reads user routes; an ADMIN reads admin routes', () async {
    var admin = false;
    final repo = AnalyticsRepositoryImpl(gw, isAdmin: () => admin);
    await repo.forecast();
    admin = true;
    await repo.forecast();
    await repo.forecast(platform: true);
    expect(api.calls, [
      '/analytics/user/forecast/next-weeks',
      '/analytics/admin/forecast/cashflow',
      '/analytics/super-admin/forecast/cashflow',
    ]);
  });

  test('signing out empties the shared analytics cache', () async {
    final c = ProviderContainer.test(
      overrides: [
        apiClientProvider.overrideWithValue(api),
        tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
        sessionStorageProvider.overrideWithValue(FakeSessionStorage()),
      ],
    );
    final repo = c.read(analyticsRepositoryProvider);
    c.read(sessionProvider.notifier).signedIn();
    await repo.overview();
    await repo.overview();
    expect(api.calls.length, 1); // cached

    c.read(sessionProvider.notifier).signedOut();
    await repo.overview();
    expect(api.calls.length, 2); // cache was cleared
  });

  testWidgets('cards load through ref.analytics', (tester) async {
    api.reply = {
      'customers': {'total': 42},
    };
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiClientProvider.overrideWithValue(api),
          tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
          sessionStorageProvider.overrideWithValue(FakeSessionStorage()),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AsyncCard<Overview>(
              cacheKey: 'test-overview',
              load: (ref) => ref.analytics.overview(),
              builder: (_, o) => Text('customers ${o.customers}'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('customers 42'), findsOneWidget);
  });

  testWidgets('due list reads the loan repository', (tester) async {
    final repo = loans.FakeLoanRepository()
      ..duePages = [
        loans.duePage([loans.loan('l1')]),
      ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [loanRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: DueListScreen(date: DateTime(2026, 11, 20)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(repo.dueCalls, 1);
    expect(find.text('No more loans'), findsOneWidget);
  });
}
