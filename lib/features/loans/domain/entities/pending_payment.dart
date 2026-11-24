import 'package:flutter/foundation.dart';

/// A payment saved on this phone that the server has not confirmed yet.
///
/// [key] is the `Idempotency-Key`: made once when the collector taps Save and
/// sent with every retry, so the server never records it twice.
@immutable
class PendingPayment {
  final String key;

  /// Who collected it. Only their own payments sync while they're signed in.
  final String collectorId;
  final String loanId;
  final int weekNumber;
  final double amount;

  /// This week's target when it was recorded (to show it before it syncs).
  final double weekTarget;

  /// When the money was collected (device time), sent as `collected_at`.
  final DateTime collectedAt;

  /// How many times sending it failed for network reasons.
  final int attempts;

  /// The server rejected it (4xx). It is kept for review and never retried.
  final String? failure;

  const PendingPayment({
    required this.key,
    required this.collectorId,
    required this.loanId,
    required this.weekNumber,
    required this.amount,
    required this.weekTarget,
    required this.collectedAt,
    this.attempts = 0,
    this.failure,
  });

  bool get isFailed => failure != null;

  PendingPayment copyWith({int? attempts, String? failure}) => PendingPayment(
    key: key,
    collectorId: collectorId,
    loanId: loanId,
    weekNumber: weekNumber,
    amount: amount,
    weekTarget: weekTarget,
    collectedAt: collectedAt,
    attempts: attempts ?? this.attempts,
    failure: failure ?? this.failure,
  );

  Map<String, dynamic> toJson() => {
    'key': key,
    'collector_id': collectorId,
    'loan_id': loanId,
    'week_number': weekNumber,
    'amount': amount,
    'week_target': weekTarget,
    'collected_at': collectedAt.toUtc().toIso8601String(),
    'attempts': attempts,
    if (failure != null) 'failure': failure,
  };

  factory PendingPayment.fromJson(Map<String, dynamic> json) => PendingPayment(
    key: json['key'] as String,
    collectorId: json['collector_id'] as String,
    loanId: json['loan_id'] as String,
    weekNumber: (json['week_number'] as num).toInt(),
    amount: (json['amount'] as num).toDouble(),
    weekTarget: (json['week_target'] as num).toDouble(),
    collectedAt: DateTime.parse(json['collected_at'] as String).toLocal(),
    attempts: (json['attempts'] as num? ?? 0).toInt(),
    failure: json['failure'] as String?,
  );
}
