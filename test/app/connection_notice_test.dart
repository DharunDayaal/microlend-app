import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/app/connection_notice.dart';
import 'package:micro_lending_app/core/connectivity/connection_monitor.dart';
import 'package:micro_lending_app/features/loans/data/payment_outbox.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';
import 'package:micro_lending_app/features/loans/domain/entities/pending_payment.dart';
import 'package:micro_lending_app/l10n/app_localizations.dart';
import 'package:micro_lending_app/shared/design_system/theme/theme.dart';

import '../features/loans/fakes.dart';
import '../features/loans/offline_fakes.dart';

class _Repo extends FakeLoanRepository {
  @override
  Future<PaymentResultModel> collectPayment({
    required String loanId,
    required int weekNumber,
    required double amount,
    required String idempotencyKey,
    required DateTime collectedAt,
  }) async => PaymentResultModel(
    track: track(weekNumber),
    loanStatus: 'ACTIVE',
    loanOutstandingAfter: 0,
  );
}

PendingPayment queued(String key, {String? failure}) => PendingPayment(
  key: key,
  collectorId: 'u1',
  loanId: 'l1',
  weekNumber: 1,
  amount: 100,
  weekTarget: 100,
  collectedAt: DateTime(2026, 11, 24),
  failure: failure,
);

const good = NetSnapshot();
const weak = NetSnapshot(quality: ConnectionQuality.weak);
const offline = NetSnapshot(quality: ConnectionQuality.offline);

void main() {
  group('when a notice shows', () {
    NoticeKind? next(NetSnapshot a, NetSnapshot b, [NoticeKind? now]) =>
        ConnectionNotices.next(a, b, now);

    test('nothing on a good start or when nothing changes', () {
      expect(next(good, good), isNull);
      expect(next(good, const NetSnapshot(waiting: 2)), isNull);
    });

    test('each connection change is said once', () {
      expect(next(good, offline), NoticeKind.offline);
      expect(next(good, weak), NoticeKind.weak);
      expect(next(offline, good, NoticeKind.offline), NoticeKind.backOnline);
      expect(next(weak, good), NoticeKind.backOnline);
      // dismissed while offline: stays hidden until the next change
      expect(
        next(
          offline,
          const NetSnapshot(quality: ConnectionQuality.offline, waiting: 3),
        ),
        isNull,
      );
    });

    test('syncing, then synced; a sync that stops offline says offline', () {
      const syncing = NetSnapshot(syncing: true, waiting: 2);
      expect(next(good, syncing, NoticeKind.backOnline), NoticeKind.syncing);
      expect(next(syncing, good, NoticeKind.syncing), NoticeKind.synced);
      expect(
        next(
          syncing,
          const NetSnapshot(quality: ConnectionQuality.offline, waiting: 2),
        ),
        NoticeKind.offline,
      );
    });

    test('a new rejection wins and stays until reviewed', () {
      expect(next(offline, const NetSnapshot(failed: 1)), NoticeKind.failed);
      expect(
        next(
          const NetSnapshot(failed: 1),
          const NetSnapshot(failed: 1),
          NoticeKind.failed,
        ),
        NoticeKind.failed,
      );
      expect(
        next(const NetSnapshot(failed: 1), good, NoticeKind.failed),
        isNull, // all reviewed
      );
    });

    test('only offline, syncing and rejections stay; the rest hide', () {
      expect(ConnectionNotices.lifetime(NoticeKind.offline), isNull);
      expect(ConnectionNotices.lifetime(NoticeKind.syncing), isNull);
      expect(ConnectionNotices.lifetime(NoticeKind.failed), isNull);
      expect(ConnectionNotices.lifetime(NoticeKind.weak), isNotNull);
      expect(ConnectionNotices.lifetime(NoticeKind.backOnline), isNotNull);
      expect(ConnectionNotices.lifetime(NoticeKind.synced), isNotNull);
    });
  });

  group('the notice on screen', () {
    Future<ProviderContainer> pump(
      WidgetTester tester, {
      MemoryOutboxStore? store,
      bool offline = false,
      Locale locale = const Locale('en'),
    }) async {
      final c = await offlineContainer(
        repo: _Repo(),
        store: store,
        offline: offline,
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: c,
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => ConnectionFrame(child: child!),
            home: Scaffold(appBar: AppBar(title: const Text('Screen'))),
          ),
        ),
      );
      await tester.pump();
      return c;
    }

    final notice = find.byType(ConnectionNotice);

    testWidgets('a good connection shows nothing, and the screen keeps its '
        'place', (tester) async {
      await pump(tester);
      expect(notice, findsNothing);
      final appBarTop = tester.getTopLeft(find.byType(AppBar)).dy;
      expect(appBarTop, 0); // nothing pushes it down
    });

    testWidgets('offline stays; back online shows briefly, then hides', (
      tester,
    ) async {
      final c = await pump(tester);
      final appBarTop = tester.getTopLeft(find.byType(AppBar)).dy;

      goOffline(c);
      await tester.pumpAndSettle();
      expect(find.text("You're offline"), findsOneWidget);
      // floats over the screen instead of moving it
      expect(tester.getTopLeft(find.byType(AppBar)).dy, appBarTop);

      await tester.pump(const Duration(minutes: 1));
      expect(find.text("You're offline"), findsOneWidget); // still there

      goOnline(c);
      await tester.pumpAndSettle();
      expect(find.text('Back online'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(notice, findsNothing);
    });

    testWidgets('weak connection hides on its own', (tester) async {
      final c = await pump(tester);
      c
          .read(connectionProvider.notifier)
          .report(Duration.zero, NetworkOutcome.timedOut);
      await tester.pumpAndSettle();
      expect(find.text('Weak connection'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(notice, findsNothing);
    });

    testWidgets('dismissed with ✕ it does not come back for the same state', (
      tester,
    ) async {
      final c = await pump(tester);
      goOffline(c);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('notice-dismiss')));
      await tester.pumpAndSettle();
      expect(notice, findsNothing);

      goOffline(c); // still offline
      await tester.pumpAndSettle();
      expect(notice, findsNothing);
    });

    testWidgets('offline with payments waiting shows the count', (
      tester,
    ) async {
      await pump(
        tester,
        store: MemoryOutboxStore([queued('a'), queued('b')]),
        offline: true,
      );
      await tester.pumpAndSettle();
      expect(find.text("You're offline"), findsOneWidget);
      expect(find.text('2 payments waiting to sync'), findsOneWidget);
    });

    testWidgets('coming back online syncs, then says all synced', (
      tester,
    ) async {
      final store = MemoryOutboxStore([queued('a')]);
      final c = await pump(tester, store: store, offline: true);
      await tester.pumpAndSettle();

      goOnline(c);
      await c.read(paymentOutboxProvider.notifier).syncNow();
      await tester.pumpAndSettle();
      expect(find.text('All payments synced'), findsOneWidget);
      expect(store.saved, isEmpty);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(notice, findsNothing);
    });

    testWidgets('a rejected payment shows Review until handled', (
      tester,
    ) async {
      await pump(
        tester,
        store: MemoryOutboxStore([queued('a', failure: 'Amount too high')]),
      );
      await tester.pumpAndSettle();
      expect(find.text("1 payment couldn't sync"), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
      await tester.pump(const Duration(minutes: 1));
      expect(find.text('Review'), findsOneWidget); // stays
    });

    testWidgets('every notice fits in Tamil on a small phone', (tester) async {
      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      final c = await pump(
        tester,
        store: MemoryOutboxStore([queued('a'), queued('b', failure: 'x')]),
        locale: const Locale('ta'),
        offline: true,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      c
          .read(connectionProvider.notifier)
          .report(Duration.zero, NetworkOutcome.timedOut);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      goOnline(c);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
