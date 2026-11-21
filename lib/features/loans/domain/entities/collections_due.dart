import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';

/// Counts shown above the borrowers (collections due) list.
class Summary {
  final int totalCustomers;
  final int totalActiveLoans;
  final int totalOverdueLoans;
  final int totalReferredCustomers;

  const Summary({
    required this.totalCustomers,
    required this.totalActiveLoans,
    required this.totalOverdueLoans,
    required this.totalReferredCustomers,
  });

  Summary copyWith({
    int? totalCustomers,
    int? totalActiveLoans,
    int? totalOverdueLoans,
    int? totalReferredCustomers,
  }) {
    return Summary(
      totalCustomers: totalCustomers ?? this.totalCustomers,
      totalActiveLoans: totalActiveLoans ?? this.totalActiveLoans,
      totalOverdueLoans: totalOverdueLoans ?? this.totalOverdueLoans,
      totalReferredCustomers:
          totalReferredCustomers ?? this.totalReferredCustomers,
    );
  }
}

class CollectionsLoanDueModel {
  final PagedResult<LoanModel> result;
  final Summary summary;

  const CollectionsLoanDueModel({required this.result, required this.summary});
}
