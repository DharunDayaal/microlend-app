import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/app/router/router_provider.dart';
import 'package:micro_lending_app/core/connectivity/connection_monitor.dart';
import 'package:micro_lending_app/features/loans/data/payment_outbox.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/sync_review_sheet.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';

/// What the app tells the user about the network, once per change.
enum NoticeKind { offline, weak, backOnline, syncing, synced, failed }

/// The parts of the network and payment queue that notices depend on.
@immutable
class NetSnapshot {
  final ConnectionQuality quality;
  final bool syncing;
  final int waiting;
  final int failed;

  const NetSnapshot({
    this.quality = ConnectionQuality.good,
    this.syncing = false,
    this.waiting = 0,
    this.failed = 0,
  });

  factory NetSnapshot.of(ConnectionQuality q, PaymentOutboxState o) =>
      NetSnapshot(
        quality: q,
        syncing: o.syncing && o.waiting.isNotEmpty,
        waiting: o.waiting.length,
        failed: o.failed.length,
      );
}

abstract final class ConnectionNotices {
  /// How long a notice stays before hiding itself. Null: it stays until the
  /// situation changes or the user dismisses it.
  static Duration? lifetime(NoticeKind k) => switch (k) {
    NoticeKind.weak => const Duration(seconds: 4),
    NoticeKind.backOnline ||
    NoticeKind.synced => const Duration(milliseconds: 2500),
    NoticeKind.offline || NoticeKind.syncing || NoticeKind.failed => null,
  };

  /// The notice to show after [prev] became [next], given what is showing
  /// now ([current]). Returns [current] when nothing worth saying changed,
  /// or null to hide it.
  static NoticeKind? next(
    NetSnapshot prev,
    NetSnapshot next,
    NoticeKind? current,
  ) {
    // most important first
    if (next.failed > prev.failed) return NoticeKind.failed;
    if (next.syncing && !prev.syncing) return NoticeKind.syncing;
    if (prev.syncing && !next.syncing) {
      if (next.waiting == 0) return NoticeKind.synced;
      if (next.quality == ConnectionQuality.offline) {
        return NoticeKind.offline;
      }
      return current == NoticeKind.syncing ? null : current;
    }
    if (next.quality != prev.quality) {
      return switch (next.quality) {
        ConnectionQuality.offline => NoticeKind.offline,
        ConnectionQuality.weak => NoticeKind.weak,
        ConnectionQuality.good =>
          // a sync starting right after takes over from this
          NoticeKind.backOnline,
      };
    }
    if (current == NoticeKind.failed && next.failed == 0) return null;
    return current;
  }
}

/// Wraps every screen (MaterialApp.builder). Shows a floating notice at the
/// top when the connection or the payment sync changes, then hides it; on a
/// good connection with nothing to say, nothing is shown.
class ConnectionFrame extends ConsumerStatefulWidget {
  final Widget child;
  const ConnectionFrame({super.key, required this.child});

  @override
  ConsumerState<ConnectionFrame> createState() => _ConnectionFrameState();
}

class _ConnectionFrameState extends ConsumerState<ConnectionFrame> {
  NoticeKind? _notice;
  NetSnapshot _last = const NetSnapshot();
  Timer? _hide;

  NetSnapshot _snapshot() => NetSnapshot.of(
    ref.read(connectionProvider),
    ref.read(paymentOutboxProvider),
  );

  @override
  void initState() {
    super.initState();
    _last = _snapshot();
    // something already worth saying at start (good: nothing)
    _show(ConnectionNotices.next(const NetSnapshot(), _last, null));
  }

  @override
  void dispose() {
    _hide?.cancel();
    super.dispose();
  }

  void _onChange() {
    final now = _snapshot();
    final kind = ConnectionNotices.next(_last, now, _notice);
    _last = now;
    if (kind != _notice) {
      _show(kind);
    } else if (mounted) {
      setState(() {}); // same notice, new counts
    }
  }

  void _show(NoticeKind? kind) {
    _hide?.cancel();
    if (mounted) setState(() => _notice = kind);
    final life = kind == null ? null : ConnectionNotices.lifetime(kind);
    if (life != null) {
      _hide = Timer(life, () {
        if (mounted && _notice == kind) setState(() => _notice = null);
      });
    }
  }

  void _review() {
    _show(null);
    final ctx = ref
        .read(routerProvider)
        .routerDelegate
        .navigatorKey
        .currentContext;
    if (ctx != null) showSyncReviewSheet(ctx);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(connectionProvider, (_, _) => _onChange());
    ref.listen(paymentOutboxProvider, (_, _) => _onChange());
    final top = MediaQuery.paddingOf(context).top;
    final notice = _notice;

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: top + AppSizes.sm,
          left: AppSizes.md,
          right: AppSizes.md,
          child: Align(
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              reverseDuration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.6),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: notice == null
                  ? const SizedBox.shrink()
                  : ConnectionNotice(
                      key: ValueKey(notice),
                      kind: notice,
                      waiting: _last.waiting,
                      failed: _last.failed,
                      onDismiss: () => _show(null),
                      onReview: _review,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The floating card: tinted icon, title, one line of detail, and an action
/// or a close button. Swipe up to dismiss.
class ConnectionNotice extends StatelessWidget {
  final NoticeKind kind;
  final int waiting;
  final int failed;
  final VoidCallback onDismiss;
  final VoidCallback onReview;

  const ConnectionNotice({
    super.key,
    required this.kind,
    required this.waiting,
    required this.failed,
    required this.onDismiss,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;

    final (
      Color color,
      IconData icon,
      String title,
      String? body,
    ) = switch (kind) {
      NoticeKind.offline => (
        AppColors.progressDanger,
        Icons.cloud_off_rounded,
        l.netOfflineTitle,
        waiting > 0 ? l.syncWaiting(waiting) : l.netOfflineBody,
      ),
      NoticeKind.weak => (
        AppColors.warning,
        Icons.network_check_rounded,
        l.netWeak,
        l.netWeakBody,
      ),
      NoticeKind.backOnline => (
        AppColors.success,
        Icons.wifi_rounded,
        l.netBackOnline,
        null,
      ),
      NoticeKind.syncing => (
        AppColors.stepCurrentLabel,
        Icons.sync_rounded,
        l.netSyncing(waiting),
        null,
      ),
      NoticeKind.synced => (
        AppColors.success,
        Icons.cloud_done_rounded,
        l.netSynced,
        null,
      ),
      NoticeKind.failed => (
        AppColors.progressDanger,
        Icons.error_outline_rounded,
        l.syncFailed(failed),
        l.syncFailedTitle,
      ),
    };

    final sticky = ConnectionNotices.lifetime(kind) == null;

    return Semantics(
      liveRegion: true,
      container: true,
      child: Dismissible(
        key: ValueKey('dismiss-$kind'),
        direction: DismissDirection.up,
        onDismissed: (_) => onDismiss(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Material(
            color: AppColors.darkSurface,
            elevation: 8,
            shadowColor: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              side: BorderSide(color: color.withAlpha(90)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.sm + 2,
                AppSizes.sm + 2,
                AppSizes.xs,
                AppSizes.sm + 2,
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: color.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: kind == NoticeKind.syncing
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: color,
                            ),
                          )
                        : Icon(icon, size: 18, color: color),
                  ),
                  const SizedBox(width: AppSizes.sm + 2),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkOnSurface,
                          ),
                        ),
                        if (body != null)
                          Text(
                            body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelSmall?.copyWith(
                              color: AppColors.darkOnSurfaceMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (kind == NoticeKind.failed)
                    TextButton(
                      onPressed: onReview,
                      style: TextButton.styleFrom(foregroundColor: color),
                      child: Text(l.syncReview),
                    ),
                  if (sticky && kind != NoticeKind.syncing)
                    // no tooltip: this sits above the Navigator, which
                    // owns the overlay tooltips need
                    Semantics(
                      button: true,
                      label: l.netDismiss,
                      excludeSemantics: true,
                      child: IconButton(
                        key: const ValueKey('notice-dismiss'),
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.darkOnSurfaceMuted,
                        ),
                        onPressed: onDismiss,
                      ),
                    )
                  else
                    const SizedBox(width: AppSizes.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
