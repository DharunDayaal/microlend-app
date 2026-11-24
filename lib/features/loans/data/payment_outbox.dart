import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/connectivity/connection_monitor.dart';
import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/core/utils/uuid.dart';
import 'package:micro_lending_app/features/loans/data/file_payment_outbox_store.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';
import 'package:micro_lending_app/features/loans/domain/entities/pending_payment.dart';
import 'package:micro_lending_app/features/loans/domain/payment_outbox_store.dart';
import 'package:micro_lending_app/features/loans/domain/pending_overlay.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

/// Override in tests with an in-memory store.
final paymentOutboxStoreProvider = Provider<PaymentOutboxStore>(
  (ref) => FilePaymentOutboxStore(),
);

/// Payments saved on this phone that the server hasn't confirmed, and the
/// engine that sends them. App-scoped: it keeps retrying in the background.
final paymentOutboxProvider =
    NotifierProvider<PaymentOutbox, PaymentOutboxState>(PaymentOutbox.new);

@immutable
class PaymentOutboxState {
  /// Every saved payment, oldest first, including other users' (they wait
  /// until that user signs in again on this phone).
  final List<PendingPayment> all;

  /// The signed-in collector, or null when signed out.
  final String? userId;
  final bool syncing;

  /// Bumped when a background sync settles payments (sent or rejected);
  /// [settledLoanIds] says which loans should reload.
  final int settledVersion;
  final Set<String> settledLoanIds;

  const PaymentOutboxState({
    this.all = const [],
    this.userId,
    this.syncing = false,
    this.settledVersion = 0,
    this.settledLoanIds = const {},
  });

  List<PendingPayment> get mine => userId == null
      ? const []
      : [
          for (final p in all)
            if (p.collectorId == userId) p,
        ];

  /// Still to be sent.
  List<PendingPayment> get waiting => [
    for (final p in mine)
      if (!p.isFailed) p,
  ];

  /// Rejected by the server; shown for review until dismissed.
  List<PendingPayment> get failed => [
    for (final p in mine)
      if (p.isFailed) p,
  ];

  PaymentOutboxState copyWith({
    List<PendingPayment>? all,
    Object? userId = _keep,
    bool? syncing,
    int? settledVersion,
    Set<String>? settledLoanIds,
  }) => PaymentOutboxState(
    all: all ?? this.all,
    userId: identical(userId, _keep) ? this.userId : userId as String?,
    syncing: syncing ?? this.syncing,
    settledVersion: settledVersion ?? this.settledVersion,
    settledLoanIds: settledLoanIds ?? this.settledLoanIds,
  );

  static const _keep = Object();
}

class PaymentOutbox extends Notifier<PaymentOutboxState> {
  /// Wait between retries after a failed send (the last one repeats). The
  /// connection coming back also starts a sync straight away.
  static const retryDelays = [
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 5),
  ];

  late Future<void> _ready;
  Future<void>? _running;
  Future<void> _saving = Future.value();
  Timer? _retry;
  int _failures = 0;

  /// The payment the collector is waiting on in the payment sheet, and the
  /// server's answer for it.
  String? _foreground;
  final Map<String, PaymentResultModel> _results = {};

  bool get _offline =>
      ref.read(connectionProvider) == ConnectionQuality.offline;

  @override
  PaymentOutboxState build() {
    ref.listen(
      sessionProvider.select((s) => s.isLoggedIn ? s.user?.id : null),
      (_, id) {
        state = state.copyWith(userId: id);
        if (id == null) {
          _retry?.cancel();
        } else {
          unawaited(syncNow());
        }
      },
    );
    // back online: send what's waiting
    ref.listen(connectionProvider, (prev, next) {
      if (prev == ConnectionQuality.offline &&
          next != ConnectionQuality.offline) {
        unawaited(syncNow());
      }
    });
    ref.onDispose(() => _retry?.cancel());

    final session = ref.read(sessionProvider);
    _ready = _load();
    return PaymentOutboxState(
      userId: session.isLoggedIn ? session.user?.id : null,
    );
  }

  /// The saved queue couldn't be read at start. Until it can, every write
  /// first reads it again and keeps what's there, so saved payments are
  /// never overwritten.
  bool _unreadable = false;

  Future<void> _load() async {
    final List<PendingPayment> saved;
    try {
      saved = await ref.read(paymentOutboxStoreProvider).read();
    } catch (e, st) {
      AppLogger.error('Could not read payment queue', error: e, stack: st);
      _unreadable = true;
      return;
    }
    if (!ref.mounted) return;
    state = state.copyWith(all: List.unmodifiable(saved));
    if (state.waiting.isNotEmpty) unawaited(syncNow());
  }

  /// Updates the list and writes it to the device. The returned future
  /// completes once it's on disk.
  Future<void> _save(List<PendingPayment> all) {
    state = state.copyWith(all: List.unmodifiable(all));
    final snapshot = state.all;
    final store = ref.read(paymentOutboxStoreProvider);
    return _saving = _saving.then((_) => _write(store, snapshot)).catchError((
      Object e,
      StackTrace st,
    ) {
      AppLogger.error('Could not save payment queue', error: e, stack: st);
    });
  }

  Future<void> _write(
    PaymentOutboxStore store,
    List<PendingPayment> snapshot,
  ) async {
    if (!_unreadable) return store.write(snapshot);
    // still unreadable: this throws and nothing is written
    final saved = await store.read();
    _unreadable = false;
    final known = {for (final p in snapshot) p.key};
    final merged = [
      for (final p in saved)
        if (!known.contains(p.key)) p,
      ...snapshot,
    ];
    if (ref.mounted) state = state.copyWith(all: List.unmodifiable(merged));
    await store.write(merged);
  }

  /// Records a payment. It is saved on the phone first, then sent.
  ///
  /// - Sent: returns the server's result.
  /// - Offline, no answer, or a server error: stays queued and returns a
  ///   local result with [PaymentResultModel.isQueued]; it syncs later.
  /// - Rejected (4xx): nothing is kept and the [ApiException] is rethrown so
  ///   the collector can fix it in the sheet.
  Future<PaymentResultModel> collect({
    required String loanId,
    required int weekNumber,
    required double amount,
    required double weekTarget,
    required double outstandingBefore,
    LoanTrackModel? currentTrack,
  }) async {
    await _ready;
    final userId = state.userId;
    if (userId == null) {
      throw const ApiException(
        statusCode: 401,
        message: 'Please sign in again',
        code: 'TOKEN_EXPIRED',
      );
    }

    final p = PendingPayment(
      key: uuidV4(),
      collectorId: userId,
      loanId: loanId,
      weekNumber: weekNumber,
      amount: amount,
      weekTarget: weekTarget,
      collectedAt: DateTime.now(),
    );
    await _save([...state.all, p]);

    // known to be offline: don't make the collector wait for a timeout
    if (!_offline) {
      _foreground = p.key;
      try {
        await _running; // a sync already going may send this one too
        await syncNow(); // sends anything older first, then this one
      } finally {
        _foreground = null;
      }
    }

    final sent = _results.remove(p.key);
    if (sent != null) return sent;

    final saved = state.all.where((e) => e.key == p.key).firstOrNull;
    if (saved != null && saved.isFailed) {
      await _save([
        for (final e in state.all)
          if (e.key != p.key) e,
      ]);
      throw ApiException(message: saved.failure!, code: 'REJECTED');
    }

    return PaymentResultModel(
      track: PendingOverlay.track(currentTrack, p),
      loanStatus: '',
      loanOutstandingAfter: math.max(outstandingBefore - amount, 0),
      isQueued: true,
    );
  }

  /// Sends every waiting payment, oldest first. Safe to call any time;
  /// calls while a sync runs join it.
  Future<void> syncNow() => _running ??= _drain().whenComplete(() {
    _running = null;
  });

  /// Forgets a payment the server rejected.
  Future<void> dismiss(String key) => _save([
    for (final p in state.all)
      if (!(p.key == key && p.isFailed)) p,
  ]);

  /// Worth trying again later: no answer, server trouble, or signed out.
  static bool _retryable(ApiException e) {
    final code = e.statusCode;
    return code == null || code >= 500 || const {401, 408, 429}.contains(code);
  }

  Future<void> _drain() async {
    await _ready;
    if (!ref.mounted) return;
    _retry?.cancel();
    if (state.userId == null || state.waiting.isEmpty || _offline) return;

    state = state.copyWith(syncing: true);
    final settled = <String>{};
    var stoppedEarly = false;
    try {
      while (ref.mounted) {
        final next = state.waiting.firstOrNull;
        if (next == null) break;

        String? rejection;
        try {
          final res = await ref
              .read(loanRepositoryProvider)
              .collectPayment(
                loanId: next.loanId,
                weekNumber: next.weekNumber,
                amount: next.amount,
                idempotencyKey: next.key,
                collectedAt: next.collectedAt,
              );
          if (!ref.mounted) return;
          _failures = 0;
          if (res.flags.isNotEmpty) {
            AppLogger.warning('Payment flagged: ${res.flags}', tag: 'SYNC');
          }
          if (next.key == _foreground) _results[next.key] = res;
        } on ApiException catch (e) {
          if (!ref.mounted) return;
          if (_retryable(e)) {
            await _bumpAttempts(next.key);
            stoppedEarly = true;
            break;
          }
          rejection = e.message;
        } catch (e, st) {
          // Unexpected (e.g. an answer we couldn't read). The server may
          // have saved it, so keep it: the retry reuses the same key.
          AppLogger.error('Payment sync failed', error: e, stack: st);
          if (!ref.mounted) return;
          await _bumpAttempts(next.key);
          stoppedEarly = true;
          break;
        }

        if (next.key != _foreground) settled.add(next.loanId);
        await _save([
          for (final p in state.all)
            if (p.key != next.key)
              p
            else if (rejection != null)
              p.copyWith(failure: rejection),
        ]);
      }
    } finally {
      if (ref.mounted) {
        state = state.copyWith(
          syncing: false,
          settledVersion: settled.isEmpty ? null : state.settledVersion + 1,
          settledLoanIds: settled.isEmpty ? null : settled,
        );
        if (stoppedEarly) _scheduleRetry();
      }
    }
  }

  Future<void> _bumpAttempts(String key) => _save([
    for (final p in state.all)
      p.key == key ? p.copyWith(attempts: p.attempts + 1) : p,
  ]);

  void _scheduleRetry() {
    final delay = retryDelays[math.min(_failures, retryDelays.length - 1)];
    _failures++;
    _retry?.cancel();
    _retry = Timer(delay, () => unawaited(syncNow()));
  }
}
