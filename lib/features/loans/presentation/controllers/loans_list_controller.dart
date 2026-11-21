import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/shared/pagination/paged_notifier.dart';
import 'package:micro_lending_app/shared/pagination/paged_state.dart';

/// The Loans tab list. Lives as long as the Loans screen.
final loansListProvider =
    NotifierProvider.autoDispose<LoansListController, PagedState<LoanModel>>(
      LoansListController.new,
    );

class LoansListController extends PagedNotifier<LoanModel> {
  String _search = '';
  String _status = '';

  /// Reloads page 1 for a new search text or status filter.
  Future<void> load({
    required String search,
    required String status,
    bool showSkeleton = true,
  }) {
    _search = search;
    _status = status;
    return refresh(showSkeleton: showSkeleton);
  }

  @override
  Future<PagedResult<LoanModel>> fetchPage(int page, int limit) => ref
      .read(loanRepositoryProvider)
      .listLoans(page: page, limit: limit, search: _search, status: _status);

  @override
  Object idOf(LoanModel item) => item.id;
}
