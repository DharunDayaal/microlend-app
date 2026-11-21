import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/shared/pagination/paged_notifier.dart';
import 'package:micro_lending_app/shared/pagination/paged_state.dart';

/// Full payment history of one loan, paged.
final loanPaymentsProvider = NotifierProvider.autoDispose
    .family<LoanPaymentsController, PagedState<PaymentModel>, String>(
      LoanPaymentsController.new,
    );

class LoanPaymentsController extends PagedNotifier<PaymentModel> {
  final String loanId;
  LoanPaymentsController(this.loanId);

  @override
  Future<PagedResult<PaymentModel>> fetchPage(int page, int limit) => ref
      .read(loanRepositoryProvider)
      .listPayments(loanId: loanId, page: page, limit: limit);

  @override
  Object idOf(PaymentModel item) => item.id;
}
