import 'package:flutter/material.dart';
import 'package:micro_lending_app/features/loans/domain/entities/manual_loan_status.dart';
import 'package:micro_lending_app/shared/design_system/constants/colors.dart';

/// Icon and colour for each manual status. Kept out of the domain enum so the
/// domain layer has no Flutter imports.
extension ManualLoanStatusLook on ManualLoanStatus {
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
}
