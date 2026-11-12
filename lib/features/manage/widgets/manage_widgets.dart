import 'dart:async';

import 'package:flutter/material.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_name_card.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/common/widgets/state_views.dart';
import 'package:micro_lending_app/data/models/managed_account.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_common.dart';
import 'package:micro_lending_app/features/manage/controller/manage_controller.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_widgets.dart';
import 'package:micro_lending_app/utils/constants/alphas.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/formatters/date_formatter.dart';

(String, Color) statusLook(AccountStatus s) => switch (s) {
  AccountStatus.pending => ('PENDING', AppColors.warning),
  AccountStatus.active => ('ACTIVE', AppColors.success),
  AccountStatus.inactive => ('INACTIVE', AppColors.progressDanger),
};

String _num(double v) =>
    v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

// =============== tabs, search, stat strip ===============

class StatusTabs extends StatelessWidget {
  final String value;
  final int pendingBadge;
  final ValueChanged<String> onChanged;
  const StatusTabs({
    super.key,
    required this.value,
    required this.onChanged,
    this.pendingBadge = 0,
  });

  static const _items = [
    ('pending', 'Pending'),
    ('active', 'Active'),
    ('inactive', 'Inactive'),
  ];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          for (final (key, label) in _items)
            Expanded(
              child: Semantics(
                button: true,
                selected: value == key,
                label: label,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(key),
                  child: AnimatedContainer(
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 180),
                    constraints: const BoxConstraints(minHeight: 44),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: value == key
                          ? AppColors.stepCurrentLabel.withAlpha(40)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: text.labelLarge?.copyWith(
                            fontWeight: value == key
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: value == key
                                ? AppColors.stepCurrentLabel
                                : null,
                          ),
                        ),
                        if (key == 'pending' && pendingBadge > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              pendingBadge > 99 ? '99+' : '$pendingBadge',
                              style: text.labelSmall?.copyWith(
                                color: AppColors.darkBackground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ManageSearch extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const ManageSearch({super.key, required this.hint, required this.onChanged});

  @override
  State<ManageSearch> createState() => _ManageSearchState();
}

class _ManageSearchState extends State<ManageSearch> {
  final _c = TextEditingController();
  Timer? _t;

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  void _changed(String v) {
    setState(() {});
    _t?.cancel();
    _t = Timer(
      const Duration(milliseconds: 400),
      () => widget.onChanged(v.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _c,
      onChanged: _changed,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _c.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close),
                onPressed: () {
                  _c.clear();
                  _changed('');
                },
              ),
      ),
    );
  }
}

typedef StatItem = (String label, String value, String caption, Color color);

class StatStrip extends StatelessWidget {
  final List<StatItem> items;
  const StatStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppSizes.sm,
      children: [
        for (final (label, value, caption, color) in items)
          Expanded(
            child: MiniTile(
              label: label,
              value: value,
              caption: caption,
              color: color,
            ),
          ),
      ],
    );
  }
}

class StatStripSkeleton extends StatelessWidget {
  const StatStripSkeleton({super.key});

  Widget _tile() => Expanded(
    child: Container(
      height: 84,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withAlpha(AppAlphas.scrim),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: const AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 60, height: 10, radius: 4),
            SizedBox(height: 10),
            SkeletonBox(width: 40, height: 20, radius: 4),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) =>
      Row(spacing: AppSizes.sm, children: [_tile(), _tile(), _tile()]);
}

// =============== the card ===============

class AccountCard extends StatelessWidget {
  final ManagedAccount a;
  final bool isAdminAccount;
  final bool showAdminName;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDeactivate;
  final VoidCallback onReactivate;

  const AccountCard({
    super.key,
    required this.a,
    required this.isAdminAccount,
    required this.showAdminName,
    required this.busy,
    required this.onOpen,
    required this.onApprove,
    required this.onReject,
    required this.onDeactivate,
    required this.onReactivate,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (label, color) = statusLook(a.status);
    final muted = text.labelMedium?.copyWith(
      color: AppColors.darkOnSurfaceMuted,
    );

    return AnalyticsFrame(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppNameCard(name: a.displayName, width: 46, height: 46),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      a.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: muted,
                    ),
                  ],
                ),
              ),
              AppGap.w8,
              Pill(label, color),
            ],
          ),
          AppGap.h12,
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: [
              if (isAdminAccount)
                _Chip(Icons.groups_outlined, '${a.membersCount ?? 0} employees')
              else ...[
                _Chip(
                  Icons.people_alt_outlined,
                  '${a.customersCount ?? 0} customers',
                ),
                if (showAdminName && (a.adminName ?? '').isNotEmpty)
                  _Chip(Icons.admin_panel_settings_outlined, a.adminName!),
                if (a.hasOwnDefaults != null)
                  _Chip(
                    Icons.tune_rounded,
                    a.hasOwnDefaults! ? 'Own defaults' : 'Admin defaults',
                  ),
              ],
              if (isAdminAccount && a.fee != null)
                _Chip(
                  Icons.percent_rounded,
                  'Fee ${_num(a.fee!)}% • Int ${_num(a.interest ?? 0)}% • ${_num(a.months ?? 0)} mo',
                ),
              if (a.createdAt != null)
                _Chip(
                  Icons.event_outlined,
                  'Joined ${DateFormatter.date(a.createdAt)}',
                ),
            ],
          ),
          AppGap.h12,
          AccountActionBar(
            status: a.status,
            busy: busy,
            onApprove: onApprove,
            onReject: onReject,
            onDeactivate: onDeactivate,
            onReactivate: onReactivate,
            onDetails: onOpen,
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkBorder.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.darkOnSurfaceMuted),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// The buttons depend on the status. [onDetails] is null inside the detail sheet.
class AccountActionBar extends StatelessWidget {
  final AccountStatus status;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDeactivate;
  final VoidCallback onReactivate;
  final VoidCallback? onDetails;

  const AccountActionBar({
    super.key,
    required this.status,
    required this.busy,
    required this.onApprove,
    required this.onReject,
    required this.onDeactivate,
    required this.onReactivate,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    Widget danger(String label, IconData icon, VoidCallback f) => AppButton(
      label: label,
      outlined: true,
      prefixIcon: icon,
      radius: AppSizes.md,
      height: 44,
      foregroundColor: AppColors.progressDanger,
      onPressed: f,
    );

    switch (status) {
      case AccountStatus.pending:
        return Row(
          children: [
            Expanded(child: danger('Reject', Icons.close_rounded, onReject)),
            AppGap.w12,
            Expanded(
              child: AppButton(
                label: 'Approve',
                prefixIcon: Icons.check_rounded,
                radius: AppSizes.md,
                height: 44,
                onPressed: onApprove,
              ),
            ),
          ],
        );
      case AccountStatus.active:
        return Row(
          children: [
            if (onDetails != null) ...[
              Expanded(
                child: AppButton(
                  label: 'Details',
                  outlined: true,
                  prefixIcon: Icons.visibility_outlined,
                  radius: AppSizes.md,
                  height: 44,
                  onPressed: onDetails,
                ),
              ),
              AppGap.w12,
            ],
            Expanded(
              child: danger('Deactivate', Icons.block_rounded, onDeactivate),
            ),
          ],
        );
      case AccountStatus.inactive:
        return SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Reactivate',
            outlined: true,
            prefixIcon: Icons.restart_alt_rounded,
            radius: AppSizes.md,
            height: 44,
            onPressed: onReactivate,
          ),
        );
    }
  }
}

class AccountCardSkeleton extends StatelessWidget {
  const AccountCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnalyticsFrame(
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(width: 46, height: 46, radius: AppSizes.radiusLg),
                SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 130, height: 14, radius: 4),
                      SizedBox(height: 8),
                      SkeletonBox(width: 170, height: 10, radius: 4),
                    ],
                  ),
                ),
                SkeletonBox(width: 62, height: 20, radius: 10),
              ],
            ),
            SizedBox(height: AppSizes.md),
            Row(
              children: [
                SkeletonBox(width: 90, height: 24, radius: 8),
                SizedBox(width: AppSizes.sm),
                SkeletonBox(width: 110, height: 24, radius: 8),
              ],
            ),
            SizedBox(height: AppSizes.md),
            SkeletonBox(
              width: double.infinity,
              height: 44,
              radius: AppSizes.md,
            ),
          ],
        ),
      ),
    );
  }
}

// =============== the list ===============

class ManageListView extends StatefulWidget {
  final ManageController c;
  final Widget? header;
  final Widget Function(BuildContext context, ManagedAccount a) itemBuilder;
  final String Function(String status) emptyMessage;
  final Future<void> Function() onRefresh;

  const ManageListView({
    super.key,
    required this.c,
    required this.itemBuilder,
    required this.emptyMessage,
    required this.onRefresh,
    this.header,
  });

  @override
  State<ManageListView> createState() => _ManageListViewState();
}

class _ManageListViewState extends State<ManageListView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (!_scroll.hasClients) return;
      final p = _scroll.position;
      if (p.pixels >= p.maxScrollExtent - 300) widget.c.loadMore();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final pad = EdgeInsets.fromLTRB(
      AppSizes.lg,
      AppSizes.sm,
      AppSizes.lg,
      AppSizes.bottomClearance,
    );
    const physics = AlwaysScrollableScrollPhysics();

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListenableBuilder(
        listenable: widget.c,
        builder: (context, _) {
          final c = widget.c;
          final head = widget.header;

          if (c.loading) {
            return ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: pad,
              children: [
                ?head,
                if (head != null) AppGap.h16,
                const AccountCardSkeleton(),
                AppGap.h12,
                const AccountCardSkeleton(),
                AppGap.h12,
                const AccountCardSkeleton(),
              ],
            );
          }
          if (c.error != null) {
            return ListView(
              physics: physics,
              padding: pad,
              children: [
                ?head,
                if (head != null) AppGap.h16,
                ErrorView(message: c.error!, onRetry: () => c.load()),
              ],
            );
          }
          if (c.items.isEmpty) {
            return ListView(
              physics: physics,
              padding: pad,
              children: [
                ?head,
                if (head != null) AppGap.h16,
                EmptyView(
                  icon: Icons.groups_outlined,
                  message: c.search.isEmpty
                      ? widget.emptyMessage(c.status)
                      : 'Nobody matches "${c.search}".',
                ),
              ],
            );
          }

          final offset = head == null ? 0 : 1;
          return ListView.separated(
            controller: _scroll,
            physics: physics,
            padding: pad,
            itemCount:
                c.items.length + offset + 1, // the last item is the footer
            separatorBuilder: (_, _) => AppGap.h12,
            itemBuilder: (context, i) {
              if (head != null && i == 0) return head;
              final index = i - offset;
              if (index < c.items.length) {
                return widget.itemBuilder(context, c.items[index]);
              }

              if (c.loadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSizes.md),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                );
              }
              if (c.moreError != null) {
                return Column(
                  children: [
                    Text(c.moreError!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: c.retryMore,
                      child: const Text('Tap to retry'),
                    ),
                  ],
                );
              }
              return c.hasNext
                  ? const SizedBox.shrink()
                  : Center(
                      child: Text('That is everyone', style: text.bodySmall),
                    );
            },
          );
        },
      ),
    );
  }
}
