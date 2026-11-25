import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the phone itself says about its network. Sent by the native side
/// (Android: NetworkStreamHandler.kt, iOS: AppDelegate.swift) whenever it
/// changes; nothing is downloaded to find these out.
@immutable
class PhoneNetwork {
  /// Has a network that claims internet access.
  final bool connected;

  /// Android only: the phone checked that the internet really works (false
  /// on Wi-Fi that needs a login page). Null when unknown (iOS).
  final bool? validated;

  /// wifi, cellular, ethernet or other.
  final String transport;

  /// Android only: its own download speed estimate from the network type and
  /// signal. Null when unknown.
  final int? downKbps;

  const PhoneNetwork({
    required this.connected,
    this.validated,
    this.transport = 'other',
    this.downKbps,
  });

  static const disconnected = PhoneNetwork(connected: false);

  factory PhoneNetwork.fromMap(Map<Object?, Object?> m) => PhoneNetwork(
    connected: m['connected'] == true,
    validated: m['validated'] as bool?,
    transport: m['transport'] as String? ?? 'other',
    // Android reports 0 when it has no estimate
    downKbps: switch (m['downKbps']) {
      final int k when k > 0 => k,
      _ => null,
    },
  );

  @override
  String toString() =>
      'PhoneNetwork($transport, connected: $connected, '
      'validated: $validated, downKbps: $downKbps)';
}

/// The phone's network changes. Override in tests with a controller's
/// stream.
final phoneNetworkProvider = Provider<Stream<PhoneNetwork>>(
  (ref) =>
      const EventChannel('thavanai/network')
          .receiveBroadcastStream()
          .map((e) => PhoneNetwork.fromMap(e as Map<Object?, Object?>)),
);
