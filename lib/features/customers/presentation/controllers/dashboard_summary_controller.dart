import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/customers/data/customer_providers.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';

@immutable
class DashboardSummaryState {
  final DashboardSummary? summary;
  final bool isLoading;
  const DashboardSummaryState({this.summary, this.isLoading = true});
}

/// Today's target / collected / pending card on the Field tab.
final dashboardSummaryProvider =
    NotifierProvider.autoDispose<
      DashboardSummaryController,
      DashboardSummaryState
    >(DashboardSummaryController.new);

class DashboardSummaryController extends Notifier<DashboardSummaryState> {
  @override
  DashboardSummaryState build() => const DashboardSummaryState();

  /// A failure keeps the last summary; [onError] gets the message.
  Future<void> load({
    bool showSkeleton = true,
    void Function(String message)? onError,
  }) async {
    if (showSkeleton && !state.isLoading) {
      state = DashboardSummaryState(summary: state.summary);
    }
    try {
      final data = await ref
          .read(customerRepositoryProvider)
          .dashboardSummary();
      if (!ref.mounted) return;
      state = DashboardSummaryState(summary: data, isLoading: false);
    } on ApiException catch (e) {
      if (!ref.mounted) return;
      onError?.call(e.message);
      state = DashboardSummaryState(summary: state.summary, isLoading: false);
    }
  }
}
