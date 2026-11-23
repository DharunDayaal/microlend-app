import 'package:micro_lending_app/core/pagination/paged_result.dart';
import 'package:micro_lending_app/features/loans/domain/entities/collections_due.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan_terms.dart';
import 'package:micro_lending_app/features/loans/domain/entities/manual_loan_status.dart';
import 'package:micro_lending_app/features/loans/domain/entities/payment_result.dart';

/// Everything the app can do with loans. Implementations throw
/// `ApiException` on failure (network, validation, auth).
abstract interface class LoanRepository {
  Future<LoanModel> getLoan(String loanId);

  Future<PagedResult<LoanModel>> listLoans({
    int page = 1,
    int limit = 20,
    String search = '',
    String status = '',
  });

  /// Loans whose collection day is [weekday], with summary counts.
  Future<CollectionsLoanDueModel> collectionsDue({
    required String weekday,
    int page = 1,
    int limit = 20,
    String search = '',
    String issuedAdmin = '',
  });

  Future<PagedResult<PaymentModel>> listPayments({
    required String loanId,
    int page = 1,
    int limit = 20,
  });

  /// Sends one payment. Retrying with the same [idempotencyKey] is safe:
  /// the server returns the saved payment (`replayed`) instead of a second.
  Future<PaymentResultModel> collectPayment({
    required String loanId,
    required int weekNumber,
    required double amount,
    required String idempotencyKey,
    required DateTime collectedAt,
  });

  Future<LoanModel> issueLoan({
    required String customerId,
    required LoanTerms terms,
    DateTime? issuedAt,
  });

  Future<void> changeStatus({
    required String loanId,
    required ManualLoanStatus status,
  });
}
