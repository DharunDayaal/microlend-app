import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/data/models/audit_model.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_common.dart';
import 'package:micro_lending_app/features/audit/domain/audit_catalog.dart';
import 'package:micro_lending_app/features/audit/domain/audit_diff.dart';
import 'package:micro_lending_app/features/audit/domain/audit_time.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';

// =============== module chips ===============

class ModuleChipRow extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onSelected;
  final EdgeInsets padding;

  const ModuleChipRow({
    super.key,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSizes.lg),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        children: [
          _ModChip(
            label: 'All',
            icon: Icons.apps_rounded,
            color: AppColors.stepCurrentLabel,
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final k in moduleOrder)
            _ModChip(
              label: moduleStyle(k).label,
              icon: moduleStyle(k).icon,
              color: moduleStyle(k).color(context),
              selected: selected == k,
              onTap: () => onSelected(selected == k ? null : k),
            ),
        ],
      ),
    );
  }
}

class _ModChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _ModChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.sm),
      child: Center(
        child: Semantics(
          button: true,
          selected: selected,
          label: '$label module',
          child: Material(
            color: selected ? color.withAlpha(46) : AppColors.darkSurface,
            shape: StadiumBorder(
              side: BorderSide(color: selected ? color : AppColors.darkBorder),
            ),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: selected ? color : AppColors.darkOnSurfaceMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: text.labelLarge?.copyWith(
                          color: selected ? color : null,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
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

// =============== list row ===============

class AuditRow extends StatelessWidget {
  final AuditLog log;
  final VoidCallback onTap;
  final VoidCallback onCopy;
  final VoidCallback? onActorTap;
  final VoidCallback? onSubjectTap;

  const AuditRow({
    super.key,
    required this.log,
    required this.onTap,
    required this.onCopy,
    this.onActorTap,
    this.onSubjectTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final m = moduleStyle(log.module);
    final color = m.color(context);
    final attention = needsAttention(log);
    final muted = text.labelMedium?.copyWith(
      color: AppColors.darkOnSurfaceMuted,
    );
    final summary = summaryLine(log);
    final system = log.actor?.isSystem == true;

    Widget link(Widget child, VoidCallback? f) => f == null
        ? child
        : InkWell(
            onTap: f,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: child,
            ),
          );

    return Semantics(
      button: true,
      label:
          '${m.label}. ${actionLabel(log.action)}. '
          '${attention ? 'Needs attention. ' : ''}${istTime(log.createdAt)}. '
          '${actorText(log)}. ${subjectText(log)}',
      child: Material(
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onCopy,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color.withAlpha(31), // 12% tint
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(m.icon, size: 20, color: color),
                        ),
                        AppGap.w12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    m.label.toUpperCase(),
                                    style: text.labelSmall?.copyWith(
                                      color: color,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(istTime(log.createdAt), style: muted),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      actionLabel(log.action),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: text.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  if (attention) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.progressDanger,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  link(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (system) ...[
                                          const Icon(
                                            Icons.settings_rounded,
                                            size: 14,
                                            color: AppColors.darkOnSurfaceMuted,
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(actorText(log), style: muted),
                                      ],
                                    ),
                                    onActorTap,
                                  ),
                                  if (subjectText(log).isNotEmpty) ...[
                                    Text('  •  ', style: muted),
                                    link(
                                      Text(subjectText(log), style: muted),
                                      onSubjectTap,
                                    ),
                                  ],
                                ],
                              ),
                              if (summary != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  summary,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.labelMedium?.copyWith(
                                    color: AppColors.darkOnSurface,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuditRowSkeleton extends StatelessWidget {
  const AuditRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.darkBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: AppColors.darkBorder),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(AppSizes.md),
                child: AppShimmer(
                  child: Row(
                    children: [
                      SkeletonBox(width: 40, height: 40, radius: 12),
                      SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonBox(width: 60, height: 9, radius: 4),
                            SizedBox(height: 8),
                            SkeletonBox(width: 160, height: 14, radius: 4),
                            SizedBox(height: 8),
                            SkeletonBox(width: 130, height: 10, radius: 4),
                            SizedBox(height: 8),
                            SkeletonBox(
                              width: double.infinity,
                              height: 10,
                              radius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DayHeader extends StatelessWidget {
  final DateTime day;
  const DayHeader(this.day, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.sm, bottom: 2),
      child: Text(
        dayHeader(day),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.darkOnSurfaceMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

// =============== the old vs new diff ===============

void showValueSheet(BuildContext context, String title, dynamic raw) {
  final text = raw is String
      ? raw
      : const JsonEncoder.withIndent('  ').convert(raw);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => FractionallySizedBox(
      heightFactor: 0.7,
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.lg),
        children: [
          Text(title, style: Theme.of(ctx).textTheme.headlineSmall),
          AppGap.h12,
          SelectableText(
            text,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ],
      ),
    ),
  );
}

class DiffView extends StatelessWidget {
  final List<DiffRow> rows;
  final bool created;
  const DiffView({super.key, required this.rows, required this.created});

  Widget _line(
    BuildContext context,
    DiffRow r,
    Fmt f, {
    required bool removed,
  }) {
    final color = removed ? AppColors.progressDanger : AppColors.success;
    final text = Theme.of(context).textTheme;

    return Semantics(
      label: '${removed ? 'Before' : 'After'}: ${f.text}',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(46), // 18% over the surface
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Text(
              removed ? '−' : '+',
              style: text.bodyLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                f.text,
                style: f.isEmpty
                    ? text.bodyMedium?.copyWith(
                        color: AppColors.darkOnSurfaceMuted,
                        fontStyle: FontStyle.italic,
                      )
                    : text.bodyMedium?.copyWith(
                        decoration: removed ? TextDecoration.lineThrough : null,
                      ),
              ),
            ),
            if (f.isLong)
              TextButton(
                onPressed: () => showValueSheet(context, r.label, f.raw),
                child: const Text('View'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 600 && !created;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (wide)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'BEFORE',
                        style: text.labelSmall?.copyWith(
                          color: AppColors.progressDanger,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        'AFTER',
                        style: text.labelSmall?.copyWith(
                          color: AppColors.success,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            for (final r in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            r.label,
                            style: text.labelLarge?.copyWith(
                              color: AppColors.darkOnSurfaceMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (r.delta != null)
                          Pill(r.delta!, AppColors.stepCurrentLabel),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _line(context, r, r.before!, removed: true),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: _line(context, r, r.after, removed: false),
                          ),
                        ],
                      )
                    else ...[
                      if (r.before != null) ...[
                        _line(context, r, r.before!, removed: true),
                        const SizedBox(height: 6),
                      ],
                      _line(context, r, r.after, removed: false),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
