import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/utils/formatters/currency_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/date_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/features/loans/data/payment_outbox.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';

/// Payments the server rejected while syncing: what, why, and Remove.
Future<void> showSyncReviewSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (_) => const SyncReviewSheet(),
    );

class SyncReviewSheet extends ConsumerWidget {
  const SyncReviewSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final failed = ref.watch(paymentOutboxProvider).failed;

    return Padding(
      padding: const EdgeInsets.all(AppSizes.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.syncFailedTitle, style: text.headlineSmall),
          AppGap.h4,
          Text(
            l.syncFailedHelp,
            style: text.bodySmall?.copyWith(
              color: AppColors.darkOnSurfaceMuted,
            ),
          ),
          AppGap.h12,
          if (failed.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
              child: Text(l.netGood, style: text.bodyMedium),
            ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: failed.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final p = failed[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.progressDanger,
                  ),
                  title: Text(
                    '${TextFormatter.dummyId(p.loanId, '#LN')} • '
                    '${l.syncItemLine(CurrencyFormatter.format(p.amount), p.weekNumber, DateFormatter.dateTime(p.collectedAt))}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    p.failure ?? '',
                    style: text.bodySmall?.copyWith(
                      color: AppColors.progressDanger,
                    ),
                  ),
                  trailing: TextButton(
                    onPressed: () =>
                        ref.read(paymentOutboxProvider.notifier).dismiss(p.key),
                    child: Text(l.syncRemove),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
