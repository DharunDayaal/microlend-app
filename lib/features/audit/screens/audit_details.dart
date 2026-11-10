import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_button.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/common/widgets/state_views.dart';
import 'package:micro_lending_app/data/models/audit_model.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/data/services/audit_service.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_common.dart';
import 'package:micro_lending_app/features/audit/domain/audit_catalog.dart';
import 'package:micro_lending_app/features/audit/domain/audit_diff.dart';
import 'package:micro_lending_app/features/audit/domain/audit_time.dart';
import 'package:micro_lending_app/features/audit/widgets/audit_widgets.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_widgets.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';

class AuditDetailScreen extends StatefulWidget {
  final String id;
  final AuditLog? initial; // handed over by the list, so it opens instantly
  const AuditDetailScreen({super.key, required this.id, this.initial});

  @override
  State<AuditDetailScreen> createState() => _AuditDetailScreenState();
}

class _AuditDetailScreenState extends State<AuditDetailScreen> {
  AuditLog? _log;
  bool _loading = false;
  String? _error;
  AuditErrorKind? _kind;
  bool _raw = false;

  @override
  void initState() {
    super.initState();
    _log = widget.initial;
    if (_log == null) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _kind = null;
    });
    try {
      final l = await AuditService.get(widget.id);
      if (mounted) setState(() => _log = l);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _kind = classifyAudit(e);
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openEntity(AuditLog l) {
    final id = l.entityId;
    if (id == null) return;
    switch ((l.entityType ?? '').toUpperCase()) {
      case 'LOAN':
        context.push('${AppRoutes.loansList}/$id');
      case 'CUSTOMER':
        context.push(AppRoutes.customerDetail(id));
      default:
        context.push(
          AppRoutes.auditFor(entityType: l.entityType, entityId: id),
        );
    }
  }

  bool _canOpen(AuditLog l) {
    final t = (l.entityType ?? '').toUpperCase();
    return l.entityId != null && (t == 'LOAN' || t == 'CUSTOMER');
  }

  @override
  Widget build(BuildContext context) {
    if (!CurrentUser.instance.hasRole(UserRole.admin)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Audit log')),
        body: const Center(
          child: Text("You don't have access to the audit log."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Audit entry'),
      ),
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    final log = _log;

    if (log == null) {
      if (_loading) {
        return const Padding(
          padding: EdgeInsets.all(AppSizes.lg),
          child: AppShimmer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: double.infinity, height: 110, radius: 20),
                SizedBox(height: AppSizes.md),
                SkeletonBox(width: double.infinity, height: 160, radius: 20),
                SizedBox(height: AppSizes.md),
                SkeletonBox(width: double.infinity, height: 200, radius: 20),
              ],
            ),
          ),
        );
      }
      if (_kind == AuditErrorKind.notFound) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('This record is no longer available.'),
                AppGap.h16,
                AppButton(
                  label: 'Back',
                  outlined: true,
                  fitContent: true,
                  radius: AppSizes.md,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        );
      }
      if (_kind == AuditErrorKind.forbidden) {
        return const Center(
          child: Text("You don't have access to the audit log."),
        );
      }
      return ErrorView(
        message: _error ?? 'Could not load this entry.',
        onRetry: _load,
      );
    }

    final text = Theme.of(context).textTheme;
    final m = moduleStyle(log.module);
    final color = m.color(context);
    final attention = needsAttention(log);
    final rows = buildDiff(log);
    final created = isCreated(log);
    final meta = metaDetails(log);
    final isSuper = CurrentUser.instance.isSuperAdmin;
    final a = log.actor;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.lg),
      children: [
        // ----- header -----
        GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: log.id));
            AppSnackbar.info(context, 'Log id copied');
          },
          child: Material(
            color: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.darkBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: color),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: color.withAlpha(31),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(m.icon, size: 18, color: color),
                              ),
                              AppGap.w8,
                              Text(
                                m.label.toUpperCase(),
                                style: text.labelMedium?.copyWith(
                                  color: color,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const Spacer(),
                              if (attention)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: AppColors.progressDanger,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Attention',
                                      style: text.labelMedium?.copyWith(
                                        color: AppColors.progressDanger,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          AppGap.h12,
                          Text(
                            actionLabel(log.action),
                            style: text.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            istFull(log.createdAt),
                            style: text.labelLarge?.copyWith(
                              color: AppColors.darkOnSurfaceMuted,
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
        AppGap.h16,

        // ----- who and what -----
        AnalyticsFrame(
          child: Column(
            children: [
              InfoRow(
                icon: a?.isSystem == true
                    ? Icons.settings_rounded
                    : Icons.person_outline,
                label: 'Who',
                value: actorText(log),
                trailing: a?.id == null
                    ? null
                    : const Icon(Icons.chevron_right_rounded),
              ),
              if (subjectText(log).isNotEmpty) ...[
                const Divider(height: 1, color: AppColors.darkBorder),
                InkWell(
                  onTap: _canOpen(log) ? () => _openEntity(log) : null,
                  child: InfoRow(
                    icon: Icons.label_outline,
                    label: 'On',
                    value: subjectText(log),
                    trailing: _canOpen(log)
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Open',
                                style: text.labelMedium?.copyWith(
                                  color: AppColors.stepCurrentLabel,
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          )
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),
        AppGap.h12,
        Row(
          children: [
            if (a?.id != null)
              Expanded(
                child: AppButton(
                  label: 'More from this actor',
                  outlined: true,
                  radius: AppSizes.md,
                  height: 44,
                  onPressed: () => context.push(
                    AppRoutes.auditFor(actorId: a!.id, label: a.name),
                  ),
                ),
              ),
            if (a?.id != null && log.entityId != null) AppGap.w12,
            if (log.entityId != null)
              Expanded(
                child: AppButton(
                  label: 'More on this record',
                  outlined: true,
                  radius: AppSizes.md,
                  height: 44,
                  onPressed: () => context.push(
                    AppRoutes.auditFor(
                      entityType: log.entityType,
                      entityId: log.entityId,
                    ),
                  ),
                ),
              ),
          ],
        ),
        AppGap.h16,

        // ----- changes or raw -----
        if (isSuper) ...[
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: false, label: Text('Changes')),
              ButtonSegment(value: true, label: Text('Raw JSON')),
            ],
            selected: {_raw},
            onSelectionChanged: (v) => setState(() => _raw = v.first),
          ),
          AppGap.h12,
        ],
        if (_raw && isSuper)
          AnalyticsFrame(
            title: 'Raw JSON',
            trailing: IconButton(
              tooltip: 'Copy',
              icon: const Icon(Icons.copy_rounded, size: 18),
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(
                    text: const JsonEncoder.withIndent('  ').convert(log.raw),
                  ),
                );
                AppSnackbar.info(context, 'JSON copied');
              },
            ),
            child: SelectableText(
              const JsonEncoder.withIndent('  ').convert(log.raw),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          )
        else if (rows.isNotEmpty)
          AnalyticsFrame(
            title: created ? 'Created with' : 'Changes (${rows.length})',
            child: DiffView(rows: rows, created: created),
          )
        else
          AnalyticsFrame(
            title: 'Details',
            child: meta.isEmpty
                ? const EmptyNote(
                    'No field changes were recorded for this entry.',
                  )
                : Column(
                    children: [
                      for (final (label, value) in meta)
                        InfoRow(
                          icon: Icons.notes_rounded,
                          label: label,
                          value: value,
                        ),
                    ],
                  ),
          ),
        AppGap.h12,

        // ----- request details (collapsed) -----
        AnalyticsFrame(
          padding: EdgeInsets.zero,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                'Request details',
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                0,
                AppSizes.md,
                AppSizes.md,
              ),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv('IP', '${log.meta['ip'] ?? '-'}'),
                _kv('Device', '${log.meta['user_agent'] ?? '-'}'),
                _kv('Request', '${log.meta['request_id'] ?? '-'}'),
                _kv('Log id', log.id),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSizes.bottomClearance),
      ],
    );
  }

  Widget _kv(String k, String v) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              k,
              style: text.labelMedium?.copyWith(
                color: AppColors.darkOnSurfaceMuted,
              ),
            ),
          ),
          Expanded(child: SelectableText(v, style: text.labelMedium)),
        ],
      ),
    );
  }
}
