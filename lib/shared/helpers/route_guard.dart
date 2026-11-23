import 'package:flutter/material.dart';

extension SafePop on BuildContext {
  /// Pops the route this context belongs to, but only while it is still the
  /// top route.
  ///
  /// Use it for a pop that runs after an `await`. If the sheet or screen was
  /// closed in the meantime, a plain `Navigator.pop` would close whatever is
  /// underneath instead, handing it a result of the wrong type (a
  /// `_TypeError` that also leaves the navigator locked).
  void popIfTop<T extends Object?>([T? result]) {
    if (!mounted) return;
    final route = ModalRoute.of(this);
    if (route == null || !route.isCurrent) return;
    Navigator.of(this).pop<T>(result);
  }
}

/// Keeps a sheet open while [busy]: blocks the back button, barrier taps
/// and drag-to-dismiss (the sheet's drag ignores [PopScope], so the drag is
/// taken here). Wrap the sheet's content with it.
class BusySheetGuard extends StatelessWidget {
  final bool busy;
  final Widget child;
  const BusySheetGuard({super.key, required this.busy, required this.child});

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: GestureDetector(
      onVerticalDragStart: busy ? (_) {} : null,
      child: child,
    ),
  );
}
