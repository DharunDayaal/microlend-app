import 'dart:math' as math;

import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/domain/entities/pending_payment.dart';

/// Shows payments that are saved on the phone but not synced yet on top of
/// what the server (or the offline cache) sent. Rejected
/// ([PendingPayment.isFailed]) ones are left out.
abstract final class PendingOverlay {
  /// [withTracks] is false for list rows, which carry no weekly tracks.
  static LoanModel apply(
    LoanModel loan,
    Iterable<PendingPayment> pending, {
    bool withTracks = true,
  }) {
    final mine =
        pending.where((p) => p.loanId == loan.id && !p.isFailed).toList()
          ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
    if (mine.isEmpty) return loan;

    final byWeek = {for (final t in loan.tracks) t.weekNumber: t};
    var added = 0.0;
    for (final p in mine) {
      added += p.amount;
      if (withTracks) byWeek[p.weekNumber] = track(byWeek[p.weekNumber], p);
    }

    return loan.copyWith(
      tracks: withTracks
          ? (byWeek.values.toList()
              ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber)))
          : null,
      totalCollected: loan.totalCollected + added,
      outstandingAmount: math.max(loan.outstandingAmount - added, 0),
    );
  }

  /// [current] (the server's week, if any) with [p] added to it.
  static LoanTrackModel track(LoanTrackModel? current, PendingPayment p) {
    final target = current?.targetAmount ?? p.weekTarget;
    final collected = (current?.totalCollected ?? 0) + p.amount;
    return LoanTrackModel(
      id: current?.id ?? 'pending-${p.key}',
      loanId: p.loanId,
      weekNumber: p.weekNumber,
      totalCollected: collected,
      targetAmount: target,
      status: collected >= target ? 'PAID' : 'PARTIAL',
      isOverdued: current?.isOverdued ?? false,
      remainingBalance: math.max(target - collected, 0),
      pendingSync: true,
    );
  }
}
