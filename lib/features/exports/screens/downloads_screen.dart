import 'package:flutter/material.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/common/styles/spacing_style.dart';
import 'package:micro_lending_app/common/widgets/app_icon_button.dart';
import 'package:micro_lending_app/common/widgets/app_skeleton.dart';
import 'package:micro_lending_app/common/widgets/state_views.dart';
import 'package:micro_lending_app/data/models/export_model.dart';
import 'package:micro_lending_app/features/analytics/widgets/analytics_common.dart';
import 'package:micro_lending_app/features/audit/domain/audit_time.dart';
import 'package:micro_lending_app/features/exports/exports_tracker.dart';
import 'package:micro_lending_app/features/profile/widgets/profile_widgets.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';
import 'package:micro_lending_app/utils/constants/sizes.dart';
import 'package:micro_lending_app/utils/helpers/snackbar_helper.dart';
import 'package:micro_lending_app/utils/network/api_exception.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  final _t = ExportsTracker.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _t.refreshList(); // also restarts polling for anything still building
      }
    });
  }

  Future<void> _use(ExportJob j, {required bool share}) async {
    try {
      await _t.use(j, share: share);
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } catch (_) {
      if (mounted) AppSnackbar.error(context, context.l10n.expCouldNotOpen);
    }
  }

  Future<void> _again(ExportJob j) async {
    final kind = j.kind;
    if (kind == null) return;
    try {
      final c = await _t.start(
        type: kind,
        format: j.format,
        filters: j.filters,
      );
      if (mounted) {
        AppSnackbar.info(
          context,
          c.alreadyRunning
              ? context.l10n.expAlreadyInProgress
              : context.l10n.expStarted,
        );
      }
    } on ApiException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppIconButton(
          icon: Icons.arrow_back_ios,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(context.l10n.menuDownloads),
      ),
      body: SafeArea(
        child: ListenableBuilder(listenable: _t, builder: (_, _) => _body()),
      ),
    );
  }

  Widget _body() {
    final pad = EdgeInsets.fromLTRB(
      AppSizes.lg,
      AppSizes.md,
      AppSizes.lg,
      AppSizes.bottomClearance,
    );
    const physics = AlwaysScrollableScrollPhysics();
    final jobs = _t.jobs;

    if (!_t.listLoaded && _t.listLoading && jobs.isEmpty) {
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: pad,
        itemCount: 4,
        separatorBuilder: (_, _) => AppGap.h12,
        itemBuilder: (_, _) => const _TileSkeleton(),
      );
    }
    if (_t.listError != null && jobs.isEmpty) {
      return ListView(
        physics: physics,
        padding: pad,
        children: [
          ErrorView(message: _t.listError!, onRetry: () => _t.refreshList()),
        ],
      );
    }
    if (jobs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _t.refreshList,
        child: ListView(
          physics: physics,
          padding: pad,
          children: [
            EmptyView(
              icon: Icons.download_done_rounded,
              message: context.l10n.expNoDownloads,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _t.refreshList,
      child: ListView.separated(
        physics: physics,
        padding: pad,
        itemCount: jobs.length,
        separatorBuilder: (_, _) => AppGap.h12,
        itemBuilder: (_, i) {
          final j = jobs[i];
          return _JobTile(
            job: j,
            downloading: _t.downloading.containsKey(j.id),
            progress: _t.downloading[j.id],
            onOpen: () => _use(j, share: false),
            onShare: () => _use(j, share: true),
            onAgain: () => _again(j),
          );
        },
      ),
    );
  }
}

(String, Color) _look(BuildContext context, ExportJob j) {
  final l = context.l10n;
  if (j.isExpired) return (l.expExpired, AppColors.darkOnSurfaceMuted);
  return switch (j.status) {
    ExportStatus.queued => (l.expQueued, AppColors.warning),
    ExportStatus.running => (l.expBuilding, AppColors.stepCurrentLabel),
    ExportStatus.done => (l.expReady, AppColors.success),
    ExportStatus.failed => (l.expFailed, AppColors.progressDanger),
    ExportStatus.expired => (l.expExpired, AppColors.darkOnSurfaceMuted),
  };
}

Color _formatColor(ExportFormat f) => switch (f) {
  ExportFormat.xlsx => AppColors.success,
  ExportFormat.csv => AppColors.stepCurrentLabel,
  ExportFormat.pdf => AppColors.progressDanger,
};

class _JobTile extends StatelessWidget {
  final ExportJob job;
  final bool downloading;
  final double? progress;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final VoidCallback onAgain;

  const _JobTile({
    required this.job,
    required this.downloading,
    required this.progress,
    required this.onOpen,
    required this.onShare,
    required this.onAgain,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final muted = text.labelMedium?.copyWith(
      color: AppColors.darkOnSurfaceMuted,
    );
    final (label, color) = _look(context, job);
    final fc = _formatColor(job.format);

    return ProfileFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: fc.withAlpha(36),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(job.format.icon, color: fc),
              ),
              AppGap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.l10nTitle(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      job.filterSummary,
                      maxLines: 2,
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
          AppGap.h8,
          Text(
            [
              if (job.createdAt != null) istShort(job.createdAt!),
              job.format.label,
              if (job.fileSize != null) fmtBytes(job.fileSize),
            ].join(' • '),
            style: muted,
          ),
          if (job.isActive) ...[
            AppGap.h8,
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: job.status == ExportStatus.queued ? null : job.progress,
                minHeight: 6,
                backgroundColor: AppColors.darkBorder,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              job.totalRows == null
                  ? context.l10n.expPreparing
                  : context.l10n.expRowsProgress(
                      job.processedRows,
                      job.totalRows!,
                    ),
              style: muted,
            ),
          ],
          if (job.status == ExportStatus.failed && job.error != null) ...[
            const SizedBox(height: 6),
            Text(
              job.error!,
              style: text.labelMedium?.copyWith(
                color: AppColors.progressDanger,
              ),
            ),
          ],
          if (job.isReady) ...[
            AppGap.h8,
            if (downloading)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.darkBorder,
                ),
              )
            else
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onOpen,
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(context.l10n.expOpen),
                  ),
                  TextButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    label: Text(context.l10n.expShare),
                  ),
                  const Spacer(),
                  if (job.expiresAt != null)
                    Flexible(
                      child: Text(
                        context.l10n.expUntil(istTime(job.expiresAt!)),
                        style: muted,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
          ],
          if ((job.status == ExportStatus.failed || job.isExpired) &&
              job.kind != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAgain,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(context.l10n.expCreateAgain),
              ),
            ),
        ],
      ),
    );
  }
}

class _TileSkeleton extends StatelessWidget {
  const _TileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const ProfileFrame(
      child: AppShimmer(
        child: Row(
          children: [
            SkeletonBox(width: 44, height: 44, radius: 14),
            SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 140, height: 14, radius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: 190, height: 10, radius: 4),
                  SizedBox(height: 8),
                  SkeletonBox(width: 110, height: 10, radius: 4),
                ],
              ),
            ),
            SizedBox(width: AppSizes.md),
            SkeletonBox(width: 60, height: 20, radius: 10),
          ],
        ),
      ),
    );
  }
}
