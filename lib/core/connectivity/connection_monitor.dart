import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/network/api_endpoints.dart';

/// How well the app can reach the server right now.
enum ConnectionQuality { good, weak, offline }

/// What one request (or probe) told us about the network.
enum NetworkOutcome {
  /// The server answered (any status code).
  reached,

  /// No answer in time: the network is there but slow.
  timedOut,

  /// No connection at all.
  unreachable,
}

/// One call to the health route: how long it took, or null when the server
/// can't be reached. A timeout returns [HealthProbe.timeout].
typedef ConnectionProbe = Future<Duration?> Function();

/// Override in tests with a fake probe.
final connectionProbeProvider = Provider<ConnectionProbe>(
  (ref) => HealthProbe(ApiEndpoints.healthUrl).call,
);

final connectionProvider =
    NotifierProvider<ConnectionMonitor, ConnectionQuality>(
      ConnectionMonitor.new,
    );

/// Tracks [ConnectionQuality] from the app's own requests ([report], wired
/// to `ApiClient.onResult` in bootstrap) and from `GET /health` when the app
/// has been quiet for a while. Probing only runs after [start] and while the
/// app is in the foreground.
class ConnectionMonitor extends Notifier<ConnectionQuality> {
  /// `/health` answers in about 0.2 s on a good connection.
  static const weakProbe = Duration(milliseconds: 1500);

  /// API calls carry real data, so they get more room.
  static const weakRequest = Duration(milliseconds: 3000);

  /// Without other requests, check again after this long.
  static const probeWhenOffline = Duration(seconds: 10);
  static const probeWhenWeak = Duration(seconds: 30);
  static const probeWhenGood = Duration(minutes: 1);

  /// Smoothed "slowness" as a share of the weak limit (1.0 = at the limit),
  /// so probes and requests can be mixed. Recent answers count most.
  double? _load;
  Timer? _timer;
  bool _running = false;
  bool _probing = false;

  @override
  ConnectionQuality build() {
    ref.onDispose(() => _timer?.cancel());
    return ConnectionQuality.good; // until something says otherwise
  }

  /// Starts background checks (once the app is up, and on resume).
  void start() {
    _running = true;
    unawaited(checkNow());
  }

  /// Stops background checks (app in the background).
  void pause() {
    _running = false;
    _timer?.cancel();
  }

  /// Calls `/health` now, unless a check is already running.
  Future<void> checkNow() async {
    if (_probing) return;
    _probing = true;
    try {
      final took = await ref.read(connectionProbeProvider)();
      if (!ref.mounted) return;
      if (took == null) {
        report(Duration.zero, NetworkOutcome.unreachable, probe: true);
      } else if (took >= HealthProbe.timeout) {
        report(took, NetworkOutcome.timedOut, probe: true);
      } else {
        report(took, NetworkOutcome.reached, probe: true);
      }
    } finally {
      _probing = false;
    }
  }

  /// Feeds the result of a request ([probe] false) or a health check.
  /// [elapsed] matters only for [NetworkOutcome.reached].
  void report(Duration elapsed, NetworkOutcome outcome, {bool probe = false}) {
    switch (outcome) {
      case NetworkOutcome.reached:
        final limit = (probe ? weakProbe : weakRequest).inMilliseconds;
        final load = elapsed.inMilliseconds / limit;
        final avg = _load;
        // after being offline, the first answer starts a fresh average
        _load = avg == null || state == ConnectionQuality.offline
            ? load
            : avg * 0.6 + load * 0.4;
        state = _load! > 1 ? ConnectionQuality.weak : ConnectionQuality.good;
      case NetworkOutcome.timedOut:
        _load = 1.5; // a few quick answers are needed to show good again
        state = ConnectionQuality.weak;
      case NetworkOutcome.unreachable:
        state = ConnectionQuality.offline;
    }
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    if (!_running) return;
    final wait = switch (state) {
      ConnectionQuality.offline => probeWhenOffline,
      ConnectionQuality.weak => probeWhenWeak,
      ConnectionQuality.good => probeWhenGood,
    };
    _timer = Timer(wait, () => unawaited(checkNow()));
  }
}

/// `GET /health`. Any HTTP answer means the server is reachable. No token
/// is sent.
class HealthProbe {
  HealthProbe(this._url);

  static const timeout = Duration(seconds: 8);
  final String _url;
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      validateStatus: (_) => true,
    ),
  );

  Future<Duration?> call() async {
    final watch = Stopwatch()..start();
    try {
      await _dio.get<void>(_url);
      return watch.elapsed;
    } on DioException catch (e) {
      return switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout => timeout, // slow but there
        _ => null,
      };
    }
  }
}
