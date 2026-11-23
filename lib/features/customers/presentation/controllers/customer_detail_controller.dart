import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/api_exception.dart';
import 'package:micro_lending_app/features/customers/data/customer_providers.dart';
import 'package:micro_lending_app/features/customers/domain/entities/customer.dart';
import 'package:micro_lending_app/features/loans/data/loan_providers.dart';
import 'package:micro_lending_app/features/loans/domain/entities/loan.dart';

/// The customer detail screen: profile, loans, the open loan, referrals.
@immutable
class CustomerDetailState {
  final CustomerDetails? details;
  final List<LoanItem> loans;

  /// Full details of the active or overdue loan, if there is one.
  final LoanModel? openLoan;
  final List<ReferralItem> referrals;
  final bool isLoading;

  const CustomerDetailState({
    this.details,
    this.loans = const [],
    this.openLoan,
    this.referrals = const [],
    this.isLoading = true,
  });

  /// Based on the loans list, not the details call: if details fail to load
  /// the customer still has an open loan, and issuing must stay blocked.
  bool get hasOpenLoan => loans.any((l) => _isOpen(l.status));

  static bool _isOpen(String status) {
    final s = status.toUpperCase();
    return s == 'ACTIVE' || s == 'OVERDUE';
  }

  static const _keep = Object();

  CustomerDetailState copyWith({
    Object? details = _keep,
    List<LoanItem>? loans,
    Object? openLoan = _keep,
    List<ReferralItem>? referrals,
    bool? isLoading,
  }) => CustomerDetailState(
    details: identical(details, _keep)
        ? this.details
        : details as CustomerDetails?,
    loans: loans ?? this.loans,
    openLoan: identical(openLoan, _keep)
        ? this.openLoan
        : openLoan as LoanModel?,
    referrals: referrals ?? this.referrals,
    isLoading: isLoading ?? this.isLoading,
  );
}

final customerDetailProvider = NotifierProvider.autoDispose
    .family<CustomerDetailController, CustomerDetailState, String>(
      CustomerDetailController.new,
    );

class CustomerDetailController extends Notifier<CustomerDetailState> {
  final String customerId;
  CustomerDetailController(this.customerId);

  int _requestId = 0;

  @override
  CustomerDetailState build() => const CustomerDetailState();

  bool _stale(int id) => !ref.mounted || id != _requestId;

  /// Loads every section in parallel. Each failure is reported through
  /// [onError] (the screen shows a snackbar); the rest still loads.
  Future<void> load({void Function(String message)? onError}) async {
    final id = ++_requestId;
    state = state.copyWith(isLoading: true);
    await Future.wait([
      _details(id, onError),
      _loans(id, onError),
      _referrals(id, onError),
    ]);
    if (!_stale(id)) state = state.copyWith(isLoading: false);
  }

  Future<void> _details(int id, void Function(String)? onError) async {
    try {
      final res = await ref
          .read(customerRepositoryProvider)
          .details(customerId);
      if (_stale(id)) return;
      if (res.success) state = state.copyWith(details: res);
    } on ApiException catch (e) {
      if (!_stale(id)) onError?.call(e.message);
    }
  }

  Future<void> _loans(int id, void Function(String)? onError) async {
    try {
      final loans = await ref
          .read(customerRepositoryProvider)
          .loans(customerId);
      if (_stale(id)) return;
      state = state.copyWith(loans: List.unmodifiable(loans));

      final current = loans
          .where((l) => CustomerDetailState._isOpen(l.status))
          .firstOrNull;
      if (current == null) {
        state = state.copyWith(openLoan: null);
        return;
      }

      final loan = await ref.read(loanRepositoryProvider).getLoan(current.id);
      if (_stale(id)) return;
      state = state.copyWith(openLoan: loan);
    } on ApiException catch (e) {
      if (!_stale(id)) onError?.call(e.message);
    }
  }

  Future<void> _referrals(int id, void Function(String)? onError) async {
    try {
      final referrals = await ref
          .read(customerRepositoryProvider)
          .referrals(customerId);
      if (_stale(id)) return;
      state = state.copyWith(referrals: List.unmodifiable(referrals));
    } on ApiException catch (e) {
      if (!_stale(id)) onError?.call(e.message);
    }
  }
}
