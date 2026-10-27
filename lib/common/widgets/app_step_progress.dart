import 'package:flutter/material.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

class StepItem {
  final String title; // "Borrower"
  final String? subtitle; // "Profile"
  final String?
  doneSubtitle; // shown once the step is finished, e.g. "Selected"

  const StepItem({required this.title, this.subtitle, this.doneSubtitle});
}

enum _StepState { done, current, upcoming }

/// Tab-style step indicator.
/// current  = filled primary tile, done = green check, upcoming = muted.
/// Tiles share the width for 2 steps or fewer, and scroll for more.
class AppStepProgress extends StatefulWidget {
  final List<StepItem> steps;
  final int currentStep; // 0-based
  final ValueChanged<int>? onStepTap; // only finished steps are tappable
  final bool? scrollable; // null = scroll only when steps.length > 2

  // Layout
  final double circleSize;
  final double gap;
  final EdgeInsetsGeometry padding; // inside the outer container
  final EdgeInsetsGeometry tilePadding;
  final double radius; // outer container
  final double tileRadius;

  // Colors (null = default)
  final Color? backgroundColor;
  final Color? currentColor; // current tile fill
  final Color? doneColor; // check circle and "Selected" text

  const AppStepProgress({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTap,
    this.scrollable,
    this.circleSize = 32,
    this.gap = AppSizes.xs,
    this.padding = const EdgeInsets.all(AppSizes.xs),
    this.tilePadding = const EdgeInsets.symmetric(
      horizontal: AppSizes.md,
      vertical: AppSizes.sm + 2,
    ),
    this.radius = AppSizes.radiusLg,
    this.tileRadius = AppSizes.radiusMd + 2,
    this.backgroundColor,
    this.currentColor,
    this.doneColor,
  }) : assert(steps.length > 0, 'AppStepProgress needs at least 1 step');

  @override
  State<AppStepProgress> createState() => _AppStepProgressState();
}

class _AppStepProgressState extends State<AppStepProgress> {
  late List<GlobalKey> _keys = _makeKeys();

  List<GlobalKey> _makeKeys() =>
      List.generate(widget.steps.length, (_) => GlobalKey());

  bool get _scroll => widget.scrollable ?? widget.steps.length > 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
  }

  @override
  void didUpdateWidget(covariant AppStepProgress old) {
    super.didUpdateWidget(old);
    if (old.steps.length != widget.steps.length) _keys = _makeKeys();
    if (old.currentStep != widget.currentStep) _scrollToCurrent();
  }

  void _scrollToCurrent() {
    if (!_scroll) return;
    final i = widget.currentStep;
    if (i < 0 || i >= _keys.length) return;
    final ctx = _keys[i].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  _StepState _stateOf(int i) {
    if (i < widget.currentStep) return _StepState.done;
    if (i == widget.currentStep) return _StepState.current;
    return _StepState.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final steps = widget.steps;
    final children = <Widget>[];

    for (var i = 0; i < steps.length; i++) {
      final state = _stateOf(i);
      final tile = _StepTile(
        key: _keys[i],
        index: i,
        item: steps[i],
        state: state,
        circleSize: widget.circleSize,
        padding: widget.tilePadding,
        radius: widget.tileRadius,
        currentColor: widget.currentColor ?? scheme.primary,
        doneColor: widget.doneColor ?? AppColors.successContainer,
        onTap: (widget.onStepTap != null && state == _StepState.done)
            ? () => widget.onStepTap!(i)
            : null,
      );

      if (i > 0) children.add(SizedBox(width: widget.gap));
      children.add(_scroll ? tile : Expanded(child: tile));
    }

    final row = Row(
      mainAxisSize: _scroll ? MainAxisSize.min : MainAxisSize.max,
      children: children,
    );

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? scheme.surface,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: _scroll
          ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: row)
          : row,
    );
  }
}

class _StepTile extends StatelessWidget {
  final int index;
  final StepItem item;
  final _StepState state;
  final double circleSize;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color currentColor;
  final Color doneColor;
  final VoidCallback? onTap;

  const _StepTile({
    super.key,
    required this.index,
    required this.item,
    required this.state,
    required this.circleSize,
    required this.padding,
    required this.radius,
    required this.currentColor,
    required this.doneColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    final isCurrent = state == _StepState.current;
    final isDone = state == _StepState.done;

    final tileColor = isCurrent ? currentColor : Colors.transparent;

    final circleColor = switch (state) {
      _StepState.current => AppColors.stepCurrentLabel,
      _StepState.done => doneColor,
      _StepState.upcoming => scheme.outlineVariant.withAlpha(120),
    };

    final titleColor = switch (state) {
      _StepState.current => Colors.white,
      _StepState.done => scheme.onSurface,
      _StepState.upcoming => scheme.onSurfaceVariant.withAlpha(150),
    };

    final subtitleColor = switch (state) {
      _StepState.current => AppColors.stepCurrentLabel,
      _StepState.done => AppColors.progressSuccess,
      _StepState.upcoming => scheme.onSurfaceVariant.withAlpha(110),
    };

    final subtitle = isDone
        ? (item.doneSubtitle ?? item.subtitle)
        : item.subtitle;

    final circle = Container(
      width: circleSize,
      height: circleSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
      child: isDone
          ? Icon(Icons.check, size: circleSize * 0.6, color: scheme.surface)
          : Text(
              '${index + 1}',
              style: text.labelLarge!.copyWith(
                color: isCurrent
                    ? currentColor
                    : scheme.onSurfaceVariant.withAlpha(170),
                fontWeight: FontWeight.w700,
              ),
            ),
    );

    return Semantics(
      button: onTap != null,
      selected: isCurrent,
      label:
          '${index + 1}. ${item.title}${subtitle == null ? '' : ', $subtitle'}',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: padding,
          decoration: BoxDecoration(
            color: tileColor,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              circle,
              const SizedBox(width: AppSizes.md),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${index + 1}. ${item.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge!.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium!.copyWith(color: subtitleColor),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
