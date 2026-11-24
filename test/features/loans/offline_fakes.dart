import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/connectivity/connection_monitor.dart';
import 'package:micro_lending_app/core/storage/storage_providers.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/data/payment_outbox.dart';
import 'package:micro_lending_app/features/loans/domain/entities/pending_payment.dart';
import 'package:micro_lending_app/features/loans/domain/loan_repository.dart';
import 'package:micro_lending_app/features/loans/domain/payment_outbox_store.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

import '../../shared/session/session_fakes.dart';

/// The payment queue kept in memory. [failRead] makes the first reads
/// throw, like a store that can't be opened yet.
class MemoryOutboxStore implements PaymentOutboxStore {
  List<PendingPayment> saved;
  int failReads;
  int writes = 0;
  MemoryOutboxStore([List<PendingPayment>? saved, this.failReads = 0])
    : saved = saved ?? [];

  @override
  Future<List<PendingPayment>> read() async {
    if (failReads > 0) {
      failReads--;
      throw Exception('store not ready');
    }
    return [...saved];
  }

  @override
  Future<void> write(List<PendingPayment> payments) async {
    writes++;
    saved = [...payments];
  }
}

/// A container with [repo], [store], a probe that never runs, and the
/// collector `u1` signed in (unless [signedIn] is false).
Future<ProviderContainer> offlineContainer({
  required LoanRepository repo,
  MemoryOutboxStore? store,
  bool signedIn = true,
  bool offline = false,
}) async {
  final c = ProviderContainer.test(
    overrides: [
      loanRepositoryProvider.overrideWithValue(repo),
      paymentOutboxStoreProvider.overrideWithValue(
        store ?? MemoryOutboxStore(),
      ),
      sessionStorageProvider.overrideWithValue(FakeSessionStorage()),
      tokenStorageProvider.overrideWithValue(FakeTokenStorage()),
      connectionProbeProvider.overrideWithValue(() async => null),
    ],
  );
  if (offline) goOffline(c); // before the queue loads, so nothing is sent
  if (signedIn) {
    final session = c.read(sessionProvider.notifier);
    await session.setUser(adminUser());
    session.signedIn();
  }
  c.read(paymentOutboxProvider); // load the store
  await drainMicrotasks();
  return c;
}

/// Lets queued microtasks run (store reads and writes). Works inside
/// testWidgets too, where timers would need a pump.
Future<void> drainMicrotasks() async {
  for (var i = 0; i < 20; i++) {
    await Future<void>.value();
  }
}

void goOffline(ProviderContainer c) => c
    .read(connectionProvider.notifier)
    .report(Duration.zero, NetworkOutcome.unreachable);

void goOnline(ProviderContainer c) => c
    .read(connectionProvider.notifier)
    .report(const Duration(milliseconds: 200), NetworkOutcome.reached);
