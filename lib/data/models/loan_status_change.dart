import 'package:flutter/material.dart';
import 'package:micro_lending_app/data/models/user_role_model.dart';
import 'package:micro_lending_app/features/loans/screens/loan_snapshot.dart';
import 'package:micro_lending_app/utils/constants/colors.dart';

/// The only statuses a person may set by hand. Overdue and paid-off are
/// worked out by the system, so they are never offered.
/// [active] is only a way to reopen a defaulted loan.
enum ManualLoanStatus {
  closed('CLOSED'),
  defaulted('DEFAULTED'),
  active('ACTIVE');

  final String apiValue;
  const ManualLoanStatus(this.apiValue);

  bool get isReopen => this == ManualLoanStatus.active;

  String get label => switch (this) {
    ManualLoanStatus.closed => 'Closed',
    ManualLoanStatus.defaulted => 'Defaulted',
    ManualLoanStatus.active => 'Active (reopen)',
  };

  IconData get icon => switch (this) {
    ManualLoanStatus.closed => Icons.lock_outline,
    ManualLoanStatus.defaulted => Icons.cancel_outlined,
    ManualLoanStatus.active => Icons.restart_alt_rounded,
  };

  Color get color => switch (this) {
    ManualLoanStatus.closed => AppColors.darkOnSurfaceMuted,
    ManualLoanStatus.defaulted => AppColors.progressDanger,
    ManualLoanStatus.active => AppColors.success,
  };

  String get description => switch (this) {
    ManualLoanStatus.closed =>
      'Ends the loan. Nothing more can be collected on it.',
    ManualLoanStatus.defaulted =>
      'The borrower will not repay. The loan is written off as a default.',
    ManualLoanStatus.active =>
      'Reopens the loan so collections can resume. It shows as overdue '
          'again if weeks are already past due.',
  };
}

/// Lowest role that may reopen a defaulted loan. SUPER_ADMIN ranks above
/// ADMIN, so it always passes. Change this one line to change who can.
const UserRole reopenMinimumRole = UserRole.admin;

/// Lowest role that may change a status at all.
const UserRole statusChangeMinimumRole = UserRole.admin;

/// The one place that says which moves are allowed. The server must enforce
/// the same rules, because this only controls what the screen offers.
List<ManualLoanStatus> allowedStatusChanges(LoanStage stage, UserRole role) {
  if (role.index < statusChangeMinimumRole.index) return const [];

  final canReopen = role.index >= reopenMinimumRole.index;

  switch (stage) {
    case LoanStage.active:
    case LoanStage.overdue:
      return const [ManualLoanStatus.closed, ManualLoanStatus.defaulted];
    case LoanStage.paidOff:
      return const [ManualLoanStatus.closed];
    case LoanStage.defaulted:
      return [if (canReopen) ManualLoanStatus.active, ManualLoanStatus.closed];
    case LoanStage.closed:
    case LoanStage.unknown:
      return const [];
  }
}
