/// Where a loan is in its life. Derived from the API status string.
enum LoanStage { active, overdue, paidOff, closed, defaulted, unknown }

LoanStage loanStageOf(String status) => switch (status.trim().toUpperCase()) {
  'ACTIVE' => LoanStage.active,
  'OVERDUE' => LoanStage.overdue,
  'PAID_OFF' => LoanStage.paidOff,
  'CLOSED' => LoanStage.closed,
  'DEFAULTED' => LoanStage.defaulted,
  _ => LoanStage.unknown,
};
