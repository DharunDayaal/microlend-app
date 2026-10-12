import 'dart:async';

import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/theme/custom_themes/status_colors.dart';

enum _SnackType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static OverlayEntry? _current;

  static void success(
    BuildContext c,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) => _show(c, message, _SnackType.success, duration);

  static void error(
    BuildContext c,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) => _show(c, message, _SnackType.error, duration);

  static void warning(
    BuildContext c,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) => _show(c, message, _SnackType.warning, duration);

  static void info(
    BuildContext c,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) => _show(c, message, _SnackType.info, duration);

  static void _show(
    BuildContext context,
    String message,
    _SnackType type,
    Duration duration,
  ) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final theme = Theme.of(context);
    final s = theme.extension<StatusColors>()!;

    final (bg, fg, border, icon) = switch (type) {
      _SnackType.success => (
        s.paidBg,
        s.paidFg,
        s.paidBorder,
        Icons.check_circle,
      ),
      _SnackType.error => (
        s.overdueBg,
        s.overdueFg,
        s.overdueBorder,
        Icons.error,
      ),
      _SnackType.warning => (
        s.pendingBg,
        s.pendingFg,
        s.pendingBorder,
        Icons.warning_amber_rounded,
      ),
      _SnackType.info => (
        theme.colorScheme.surface,
        theme.colorScheme.onSurface,
        theme.colorScheme.outline,
        Icons.info,
      ),
    };

    // Only one banner at a time: a new one replaces the old one.
    _current?.remove();
    _current = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TopBanner(
        message: message,
        icon: icon,
        background: bg,
        foreground: fg,
        borderColor: border,
        textStyle: theme.textTheme.bodyMedium!,
        duration: duration,
        onDismissed: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }

  /// Closes the banner right away (for example when leaving a screen).
  static void hide() {
    _current?.remove();
    _current = null;
  }
}

class _TopBanner extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color background;
  final Color foreground;
  final Color borderColor;
  final TextStyle textStyle;
  final Duration duration;
  final VoidCallback onDismissed;

  const _TopBanner({
    required this.message,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.borderColor,
    required this.textStyle,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_TopBanner> createState() => _TopBannerState();
}

class _TopBannerState extends State<_TopBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, _close);
  }

  Future<void> _close() async {
    if (_closing || !mounted) return;
    _closing = true;
    _timer?.cancel();
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: SlideTransition(
          position: _slide,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: _close,
                onVerticalDragEnd: (d) {
                  // swipe up to dismiss
                  if ((d.primaryVelocity ?? 0) < -100) _close();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.lg,
                    vertical: AppSizes.md + 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.background,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: widget.borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.foreground,
                        size: AppSizes.iconMd,
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: widget.textStyle.copyWith(
                            color: widget.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
