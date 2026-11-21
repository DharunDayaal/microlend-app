import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/l10n/l10n_ext.dart';
import 'package:micro_lending_app/l10n/l10n_labels.dart';
import 'package:micro_lending_app/shared/design_system/styles/spacing_style.dart';
import 'package:micro_lending_app/shared/widgets/app_button.dart';
import 'package:micro_lending_app/shared/widgets/app_icon_button.dart';
import 'package:micro_lending_app/shared/widgets/app_name_card.dart';
import 'package:micro_lending_app/shared/widgets/app_skeleton.dart';
import 'package:micro_lending_app/shared/widgets/app_status_chip.dart';
import 'package:micro_lending_app/shared/widgets/call_icon_button.dart';
import 'package:micro_lending_app/features/loans/presentation/widgets/payment_sheet.dart';
import 'package:micro_lending_app/shared/widgets/state_views.dart';
import 'package:micro_lending_app/features/loans/domain/entities/collections_due.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';
import 'package:micro_lending_app/features/borrowers/presentation/controllers/borrowers_controller.dart';
import 'package:micro_lending_app/shared/pagination/paged_state.dart';
import 'package:micro_lending_app/features/borrowers/presentation/widgets/tracks_modal.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/design_system/constants/alphas.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';
import 'package:micro_lending_app/shared/design_system/constants/sizes.dart';
import 'package:micro_lending_app/core/utils/formatters/phone_formatter.dart';
import 'package:micro_lending_app/core/utils/formatters/text_formatter.dart';
import 'package:micro_lending_app/features/loans/domain/loan_helper.dart';

enum BorrowerLoanState { active, overdue, none }

class BorrowerScreen extends ConsumerStatefulWidget {
  const BorrowerScreen({super.key});

  @override
  ConsumerState<BorrowerScreen> createState() => _BorrowerScreenState();
}

class _BorrowerScreenState extends ConsumerState<BorrowerScreen> {
  static const _loadMoreTrigger = 300.0;

  final _scrollController = ScrollController();

  // ---------- state lives in BorrowersController ----------

  BorrowersController get _ctrl => ref.read(borrowersProvider.notifier);
  PagedState<LoanModel> get _p => ref.read(borrowersProvider);

  List<LoanModel> get _items => _p.items;
  Summary? get _summary => ref.read(borrowersSummaryProvider);
  bool get _isLoading => _p.isLoading;
  bool get _isLoadingMore => _p.isLoadingMore;
  bool get _hasNext => _p.hasNext;
  String? get _listError => _p.error;
  String? get _loadMoreError => _p.loadMoreError;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreTrigger) {
      _ctrl.loadMore();
    }
  }

  Future<void> _listCollectionDueLoans({bool showSkeleton = true}) =>
      _ctrl.refresh(showSkeleton: showSkeleton);

  void _retryLoadMore() => _ctrl.retryLoadMore();

  @override
  Widget build(BuildContext context) {
    ref.watch(borrowersProvider);
    ref.watch(borrowersSummaryProvider);
    final textTheme = Theme.of(context).textTheme;
    final pad = AppSpacing.screen(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () => _listCollectionDueLoans(showSkeleton: false),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: _summaryRow(textTheme),
              ),
              Expanded(child: _borrowerList(pad)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(TextTheme textTheme) {
    if (_isLoading) {
      return const Row(
        spacing: AppSizes.md,
        children: [
          Expanded(child: _StatCardSkeleton()),
          Expanded(child: _StatCardSkeleton()),
          Expanded(child: _StatCardSkeleton()),
        ],
      );
    }

    return Row(
      spacing: AppSizes.md,
      children: [
        Expanded(
          child: _StatCard(
            title: context.l10n.borrowersTotal,
            icon: Icons.group,
            value: '${_summary?.totalCustomers ?? 0}',
          ),
        ),
        Expanded(
          child: _StatCard(
            title: context.l10n.borrowersActive,
            icon: Icons.verified_outlined,
            value: '${_summary?.totalActiveLoans ?? 0}',
            subText: context.l10n.borrowersDues,
          ),
        ),
        Expanded(
          child: _StatCard(
            title: context.l10n.borrowersReferrals,
            icon: Icons.hub_outlined,
            value: '${_summary?.totalReferredCustomers ?? 0}',
            subText: context.l10n.borrowersNet,
          ),
        ),
      ],
    );
  }

  Widget _borrowerList(EdgeInsets pad) {
    final padding = EdgeInsets.fromLTRB(
      pad.left,
      AppSizes.md,
      pad.right,
      AppSizes.bottomClearance,
    );
    const physics = AlwaysScrollableScrollPhysics();
    if (_isLoading) {
      return ListView(
        physics: physics,
        padding: padding,
        children: const [_BorrowerLoanListSkeleton()],
      );
    }

    if (_listError != null) {
      return ListView(
        physics: physics,
        padding: padding,
        children: [
          ErrorView(
            message: _listError!,
            onRetry: () => _listCollectionDueLoans(),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        physics: physics,
        padding: padding,
        children: [
          EmptyView(
            icon: Icons.receipt_long_outlined,
            message: context.l10n.loansNoneFound,
          ),
        ],
      );
    }

    return ListView.separated(
      controller: _scrollController,
      physics: physics,
      padding: padding,
      itemCount: _items.length + 1,
      separatorBuilder: (_, _) => AppGap.h12,
      itemBuilder: (_, i) => i == _items.length
          ? _listFooter()
          : BorrowerTile(
              borrowerLoan: _items[i],
              onTrackUpdated: _ctrl.applyPayment,
            ),
    );
  }

  Widget _listFooter() {
    if (_isLoadingMore) return const _BorrowerLoanListSkeleton(count: 1);

    if (_loadMoreError != null) {
      return Column(
        children: [
          Text(_loadMoreError!, textAlign: TextAlign.center),
          TextButton(
            onPressed: _retryLoadMore,
            child: Text(context.l10n.commonTapToRetry),
          ),
        ],
      );
    }

    if (!_hasNext) {
      return Center(
        child: Text(
          context.l10n.loansNoMore,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

const double _titleRowHeight = 20;
const double _valueRowHeight = 28;

class _CardShell extends StatelessWidget {
  final Widget child;
  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkRim.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String? subText;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.value,
    this.subText,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: _titleRowHeight,
            child: Row(
              children: [
                Icon(icon, size: AppSizes.lg),
                const SizedBox(width: AppSizes.sm - 2),
                Expanded(
                  child: Text(
                    title,
                    style: text.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          SizedBox(
            height: _valueRowHeight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(value, style: text.headlineMedium),
                  if (subText != null && subText!.isNotEmpty) ...[
                    const SizedBox(width: AppSizes.sm),
                    Text(subText!, style: text.labelMedium),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: AppShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(
              height: _titleRowHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SkeletonBox(width: 64, height: 12, radius: 4),
              ),
            ),
            SizedBox(height: AppSizes.xs),
            SizedBox(
              height: _valueRowHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SkeletonBox(width: 40, height: 22, radius: 4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BorrowerTile extends StatelessWidget {
  final LoanModel borrowerLoan;
  final ValueChanged<PaymentResultModel> onTrackUpdated;

  const BorrowerTile({
    super.key,
    required this.borrowerLoan,
    required this.onTrackUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final (stateLabel, stateColor) = switch (borrowerLoan.status
        .toLowerCase()) {
      'active' => (
        context.l10n.borrowersActiveLoan,
        AppColors.stepCurrentLabel,
      ),
      'overdue' => (
        context.l10n.borrowersOverdueLoan,
        AppColors.progressDanger,
      ),
      _ => (context.l10n.borrowersNoActiveLoans, AppColors.success),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.darkSurface.withAlpha(AppAlphas.badgeFill),
      child: InkWell(
        onTap: () => context.push(AppRoutes.loanDetail(borrowerLoan.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppNameCard(
                    name: borrowerLoan.customerName ?? '',
                    width: 48,
                    height: 48,
                  ),
                  AppGap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                borrowerLoan.customerName ?? '',
                                style: text.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            AppGap.w8,
                            AppChip(
                              label: TextFormatter.dummyId(
                                borrowerLoan.customerId,
                                "#USR",
                              ),
                              backgroundColor: AppColors.darkPrimary.withAlpha(
                                AppAlphas.badgeFill,
                              ),
                              foregroundColor: AppColors.stepCurrentLabel,
                              borderColor: Colors.transparent,
                              radius: AppSizes.radiusSm,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.sm,
                                vertical: 2,
                              ),
                              textStyle: text.labelSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          PhoneFormatter.display(
                            borrowerLoan.phoneNumber ?? '',
                          ),
                          style: text.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  AppGap.w8,
                  CallIconButton(phone: borrowerLoan.phoneNumber ?? ''),
                  AppGap.w8,
                  AppIconButton(
                    icon: Icons.chevron_right_rounded,
                    color: AppColors.darkOnSurface,
                    backgroundColor: AppColors.darkBorder.withAlpha(
                      AppAlphas.badgeFill,
                    ),
                    onPressed: () =>
                        context.push(AppRoutes.loanDetail(borrowerLoan.id)),
                  ),
                ],
              ),
              AppGap.h12,
              const Divider(height: 2),
              AppGap.h8,
              Row(
                children: [
                  Flexible(
                    child: _IconTag(
                      icon: Icons.calendar_month_outlined,
                      label: context.l10n.custDayBatch(
                        weekdayLabel(context, borrowerLoan.preferredPaymentDay),
                      ),
                      color: AppColors.darkOnSurface,
                      background: AppColors.darkBorder,
                    ),
                  ),
                  AppGap.w8,
                  Flexible(
                    child: _DotTag(label: stateLabel, color: stateColor),
                  ),
                ],
              ),
              AppGap.h12,
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: context.l10n.facilityViewTracks,
                      onPressed: () => TracksModal.show(
                        context,
                        customerId: borrowerLoan.customerId,
                        customerName: borrowerLoan.customerName ?? '',
                        loanId: borrowerLoan.id,
                        totalWeeks: borrowerLoan.totalWeeks,
                        remainingBalance: borrowerLoan.outstandingAmount,
                        loanTracks: borrowerLoan.tracks,
                        issuedAt: borrowerLoan.issuedAt,
                        isOverdueLoan:
                            borrowerLoan.isOverdue ||
                            borrowerLoan.status.toUpperCase() == 'OVERDUE',
                        weeklyAmount: borrowerLoan.weeklyPayableAmount,
                      ),
                      backgroundColor: AppColors.darkRim,
                      prefixIcon: Icons.history,
                      radius: AppSizes.radiusLg,
                    ),
                  ),
                  AppGap.w12,
                  Expanded(
                    child: AppButton(
                      label: context.l10n.borrowersCollectPayment,
                      onPressed: () async {
                        final payment = await PaymentSheet.show(
                          context,
                          customerId: borrowerLoan.customerId,
                          customerName: borrowerLoan.customerName ?? '',
                          weekNumber: LoanHelper.nextCollectableWeek(
                            borrowerLoan.tracks,
                          ),
                          totalWeeks: borrowerLoan.totalWeeks,
                          targetAmount: borrowerLoan.weeklyPayableAmount,
                          loanId: borrowerLoan.id,
                          loanOutstandingAmount: borrowerLoan.outstandingAmount,
                          issuedAt: borrowerLoan.issuedAt,
                        );
                        if (payment != null) onTrackUpdated(payment);
                      },
                      prefixIcon: Icons.layers,
                      radius: AppSizes.radiusLg,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  const _IconTag({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + 2,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: background.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: AppColors.warning),
          const SizedBox(width: AppSizes.xs + 2),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotTag extends StatelessWidget {
  final String label;
  final Color color;
  const _DotTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm + 2,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(AppAlphas.badgeFill),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withAlpha(AppAlphas.borderTint)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSizes.xs + 2),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _BorrowerLoanListSkeleton extends StatelessWidget {
  final int count;
  const _BorrowerLoanListSkeleton({this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: AppSizes.md,
      children: List.generate(count, (_) => const _BorrowerTileSkeleton()),
    );
  }
}

class _BorrowerTileSkeleton extends StatelessWidget {
  const _BorrowerTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: AppColors.darkSurface.withAlpha(AppAlphas.badgeFill),
      child: InkWell(
        child: AppShimmer(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SkeletonBox(
                      width: 48,
                      height: 48,
                      radius: AppSizes.radiusLg,
                    ),
                    AppGap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SkeletonBox(width: 100, height: 16),
                              AppGap.w8,
                              const SkeletonBox(
                                width: 60,
                                height: 14,
                                radius: AppSizes.radiusSm,
                              ),
                            ],
                          ),
                          AppGap.h8,
                          const SkeletonBox(width: 110, height: 12),
                        ],
                      ),
                    ),
                    AppGap.w8,
                    const SkeletonBox(
                      width: 36,
                      height: 36,
                      radius: AppSizes.radiusMd,
                    ),
                    AppGap.w8,
                    const SkeletonBox(
                      width: 36,
                      height: 36,
                      radius: AppSizes.radiusMd,
                    ),
                  ],
                ),
                AppGap.h12,
                Row(
                  children: [
                    const SkeletonBox(
                      width: 110,
                      height: 24,
                      radius: AppSizes.radiusSm,
                    ),
                    AppGap.w8,
                    const SkeletonBox(
                      width: 90,
                      height: 24,
                      radius: AppSizes.radiusSm,
                    ),
                  ],
                ),
                AppGap.h16,
                Row(
                  children: [
                    Expanded(
                      child: const SkeletonBox(
                        height: 40,
                        radius: AppSizes.radiusMd,
                      ),
                    ),
                    AppGap.w12,
                    Expanded(
                      child: const SkeletonBox(
                        height: 40,
                        radius: AppSizes.radiusMd,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
