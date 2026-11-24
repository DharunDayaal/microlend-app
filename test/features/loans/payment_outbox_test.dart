import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/loans/data/payment_outbox.dart';
import 'package:micro_lending_app/features/loans/data/pending_aware_loan_repository.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';
import 'package:micro_lending_app/features/loans/domain/entities/pending_payment.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

import '../../shared/session/session_fakes.dart';
import 'fakes.dart';
import 'offline_fakes.dart';

/// Answers each payment with the next outcome (an [ApiException] is
/// thrown); runs out = success. Records every call.
class _Repo extends FakeLoanRepository {
  final List<Object?> outcomes;
  final calls = <({String loan, int week, String key, DateTime at})>[];
  _Repo([List<Object?>? outcomes]) : outcomes = outcomes ?? [];

  @override
  Future<PaymentResultModel> collectPayment({
    required String loanId,
    required int weekNumber,
    required double amount,
    required String idempotencyKey,
    required DateTime collectedAt,
  }) async {
    calls.add((
      loan: loanId,
      week: weekNumber,
      key: idempotencyKey,
      at: collectedAt,
    ));
    final next = outcomes.isEmpty ? null : outcomes.removeAt(0);
    if (next is ApiException) throw next;
    return PaymentResultModel(
      track: track(weekNumber),
      loanStatus: 'ACTIVE',
      loanOutstandingAfter: 900,
    );
  }
}

const _noNet = ApiException(
  message: 'No internet connection',
  code: 'NO_INTERNET',
);
const _down = ApiException(statusCode: 503, message: 'Unavailable');
const _bad = ApiException(statusCode: 400, message: 'Amount too high');

PendingPayment saved(String key, {String user = 'u1', String loan = 'l1'}) =>
    PendingPayment(
      key: key,
      collectorId: user,
      loanId: loan,
      weekNumber: 2,
      amount: 100,
      weekTarget: 100,
      collectedAt: DateTime(2026, 11, 20, 10),
    );

void main() {
  Future<PaymentResultModel> collect(
    ProviderContainer c, {
    String loan = 'l1',
  }) => c
      .read(paymentOutboxProvider.notifier)
      .collect(
        loanId: loan,
        weekNumber: 3,
        amount: 100,
        weekTarget: 100,
        outstandingBefore: 1000,
      );

  test('online: sent straight away, nothing left on the phone', () async {
    final repo = _Repo();
    final store = MemoryOutboxStore();
    final c = await offlineContainer(repo: repo, store: store);
    final r = await collect(c);

    expect(r.isQueued, false);
    expect(repo.calls.single.week, 3);
    expect(store.saved, isEmpty);
    expect(store.writes, 2); // saved before sending, removed after
  });

  test('offline: queued without trying, shown on the loan, sent when the '
      'connection is back with the same key and time', () async {
    final repo = _Repo();
    final store = MemoryOutboxStore();
    final c = await offlineContainer(repo: repo, store: store);
    goOffline(c);

    final r = await collect(c);
    expect(r.isQueued, true);
    expect(r.track.pendingSync, true);
    expect(r.loanOutstandingAfter, 900);
    expect(repo.calls, isEmpty);
    expect(store.saved.single.weekNumber, 3);
    final queued = store.saved.single;

    // the loan shows it before it syncs
    final fake = FakeLoanRepository()
      ..loans['l1'] = loan('l1', outstanding: 1000);
    final shown = await PendingAwareLoanRepository(
      fake,
      () => c.read(paymentOutboxProvider).waiting,
    ).getLoan('l1');
    expect(shown.outstandingAmount, 900);
    expect(shown.tracks.single.pendingSync, true);

    goOnline(c);
    await drainMicrotasks();
    expect(repo.calls.single.key, queued.key);
    expect(repo.calls.single.at, queued.collectedAt);
    expect(store.saved, isEmpty);
    final s = c.read(paymentOutboxProvider);
    expect(s.settledVersion, 1);
    expect(s.settledLoanIds, {'l1'});
  });

  test(
    'no answer or a server error: stays queued, retried with the same key',
    () async {
      for (final failure in [_noNet, _down]) {
        final repo = _Repo([failure]);
        final store = MemoryOutboxStore();
        final c = await offlineContainer(repo: repo, store: store);

        final r = await collect(c);
        expect(r.isQueued, true);
        expect(store.saved.single.attempts, 1);

        await c.read(paymentOutboxProvider.notifier).syncNow();
        expect(repo.calls, hasLength(2));
        expect(repo.calls[0].key, repo.calls[1].key); // never recorded twice
        expect(store.saved, isEmpty);
        c.dispose();
      }
    },
  );

  test('rejected while the collector waits: thrown, nothing kept', () async {
    final store = MemoryOutboxStore();
    final c = await offlineContainer(repo: _Repo([_bad]), store: store);
    await expectLater(
      collect(c),
      throwsA(
        isA<ApiException>().having(
          (e) => e.message,
          'message',
          'Amount too high',
        ),
      ),
    );
    expect(store.saved, isEmpty);
  });

  test(
    'rejected in a background sync: kept for review, the rest still go',
    () async {
      final repo = _Repo([_bad]);
      final store = MemoryOutboxStore([saved('a'), saved('b')]);
      final c = await offlineContainer(repo: repo, store: store);
      await c.read(paymentOutboxProvider.notifier).syncNow();

      final s = c.read(paymentOutboxProvider);
      expect(repo.calls.map((e) => e.key), ['a', 'b']); // oldest first
      expect(s.failed.single.key, 'a');
      expect(s.failed.single.failure, 'Amount too high');
      expect(s.waiting, isEmpty);

      await c.read(paymentOutboxProvider.notifier).dismiss('a');
      expect(store.saved, isEmpty);
    },
  );

  test("another collector's payments wait for them to sign in", () async {
    final repo = _Repo();
    final store = MemoryOutboxStore([
      saved('mine'),
      saved('theirs', user: 'u2'),
    ]);
    final c = await offlineContainer(repo: repo, store: store);
    await c.read(paymentOutboxProvider.notifier).syncNow();

    expect(repo.calls.map((e) => e.key), ['mine']);
    expect(store.saved.single.key, 'theirs'); // still on the phone
    expect(c.read(paymentOutboxProvider).waiting, isEmpty); // not shown to u1
  });

  test('signed out: nothing is sent; signing in sends it', () async {
    final repo = _Repo();
    final store = MemoryOutboxStore([saved('a')]);
    final c = await offlineContainer(repo: repo, store: store, signedIn: false);
    await c.read(paymentOutboxProvider.notifier).syncNow();
    expect(repo.calls, isEmpty);

    final session = c.read(sessionProvider.notifier);
    await session.setUser(adminUser());
    session.signedIn();
    await drainMicrotasks();
    expect(repo.calls.single.key, 'a');
  });

  test('a store that could not be read is merged, never overwritten', () async {
    final store = MemoryOutboxStore([saved('old')], 1); // first read fails
    final c = await offlineContainer(repo: _Repo(), store: store);
    goOffline(c);
    await collect(c);
    await drainMicrotasks();

    expect(store.saved.map((p) => p.key), contains('old'));
    expect(store.saved, hasLength(2));
    expect(c.read(paymentOutboxProvider).waiting, hasLength(2));
  });

  test('saved payments survive a restart (JSON round trip)', () {
    final p = saved('k').copyWith(attempts: 2, failure: 'nope');
    final back = PendingPayment.fromJson(p.toJson());
    expect(back.key, 'k');
    expect(back.collectedAt, p.collectedAt);
    expect(back.attempts, 2);
    expect(back.failure, 'nope');
  });
}
