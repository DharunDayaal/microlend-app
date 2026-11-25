import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/core/connectivity/phone_network.dart';
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

/// Works out [ConnectionQuality] from three signals:
///
/// 1. The phone's own network ([PhoneNetwork], after [start]): offline the
///    moment it drops, and a check the moment it comes back. On Android a
///    very slow link (its own estimate) counts as weak.
/// 2. The app's real requests ([report], wired to `ApiClient.onResult` in
///    bootstrap): how fast our server actually answers decides good or weak.
/// 3. `GET /health`, only as a fallback: to confirm the server answers when
///    the phone's network comes back, and to retry while requests fail but
///    the phone still says it's connected (server down, or Wi-Fi that needs
///    a login). Never while all is well.
class ConnectionMonitor extends Notifier<ConnectionQuality> {
  /// `/health` answers in about 0.2 s on a good connection.
  static const weakProbe = Duration(milliseconds: 1500);

  /// API calls carry real data, so they get more room.
  static const weakRequest = Duration(milliseconds: 3000);

  /// Android's speed estimate below this counts as weak (2G-like).
  static const slowLinkKbps = 300;

  /// Waits between /health retries while we can't reach the server but the
  /// phone says it's connected (the last one repeats).
  static const offlineRetries = [
    Duration(seconds: 10),
    Duration(seconds: 20),
    Duration(seconds: 40),
    Duration(minutes: 1),
    Duration(minutes: 2),
  ];

  /// Smoothed "slowness" as a share of the weak limit (1.0 = at the limit),
  /// so probes and requests can be mixed. Recent answers count most.
  double? _load;

  /// What requests and health checks say, before the phone's view.
  ConnectionQuality _measured = ConnectionQuality.good;

  /// Latest from the phone; null until it says something (or never, where
  /// the native side isn't there).
  PhoneNetwork? _phone;
  StreamSubscription<PhoneNetwork>? _events;
  Timer? _retry;
  int _retries = 0;
  bool _running = false;
  bool _probing = false;

  @override
  ConnectionQuality build() {
    ref.onDispose(() {
      _retry?.cancel();
      _events?.cancel();
    });
    return ConnectionQuality.good; // until something says otherwise
  }

  /// Starts listening to the phone's network (once the app is up) and, on
  /// resume, re-checks if we were offline.
  void start() {
    _running = true;
    _events ??= ref
        .read(phoneNetworkProvider)
        .listen(
          onPhoneNetwork,
          // no native side (tests, desktop): requests and /health only
          onError: (Object _) => _events = null,
          cancelOnError: true,
        );
    if (_measured == ConnectionQuality.offline) unawaited(checkNow());
  }

  /// App in the background: no retries.
  void pause() {
    _running = false;
    _retry?.cancel();
  }

  /// The phone's network changed.
  void onPhoneNetwork(PhoneNetwork now) {
    final before = _phone;
    _phone = now;
    if (!now.connected) {
      _retry?.cancel(); // nothing to try until it comes back
      _publish();
      return;
    }
    // came back, or moved between Wi-Fi and mobile data
    final cameBack =
        before != null &&
        (!before.connected || before.transport != now.transport);
    // Android newly says the internet doesn't really work (e.g. Wi-Fi with a
    // login page); repeats of the same news are ignored
    final lostInternet = now.validated == false && before?.validated != false;
    // first word from the phone while we already think we're offline
    final startedOffline =
        before == null && _measured == ConnectionQuality.offline;
    if (cameBack || lostInternet || startedOffline) {
      unawaited(checkNow()); // does our server really answer here?
    }
    _publish();
  }

  /// Calls `/health` now, unless a check is already running or the phone
  /// has no network.
  Future<void> checkNow() async {
    if (_probing || _phone?.connected == false) return;
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
        _load = avg == null || _measured == ConnectionQuality.offline
            ? load
            : avg * 0.6 + load * 0.4;
        _measured = _load! > 1
            ? ConnectionQuality.weak
            : ConnectionQuality.good;
        _retries = 0;
        _retry?.cancel();
      case NetworkOutcome.timedOut:
        _load = 1.5; // a few quick answers are needed to show good again
        _measured = ConnectionQuality.weak;
        _retries = 0;
        _retry?.cancel();
      case NetworkOutcome.unreachable:
        _measured = ConnectionQuality.offline;
        _scheduleRetry();
    }
    _publish();
  }

  /// The phone's view can only make things worse than measured: no network
  /// is offline, a very slow link is at best weak.
  void _publish() {
    final phone = _phone;
    var q = _measured;
    if (phone != null && !phone.connected) {
      q = ConnectionQuality.offline;
    } else if (q == ConnectionQuality.good &&
        (phone?.downKbps ?? slowLinkKbps) < slowLinkKbps) {
      q = ConnectionQuality.weak;
    }
    if (q != state) state = q;
  }

  /// Requests fail but the phone says it's connected: try /health again
  /// later, waiting longer each time.
  void _scheduleRetry() {
    _retry?.cancel();
    if (!_running || _phone?.connected == false) return;
    final wait = offlineRetries[_retries.clamp(0, offlineRetries.length - 1)];
    _retries++;
    _retry = Timer(wait, () => unawaited(checkNow()));
  }
}

/// `GET /health`. Only the server's own healthy answer counts as reached:
/// a Wi-Fi login page or an error page also answers HTTP, but our server
/// isn't usable then. No token is sent.
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
      followRedirects: false, // a login page usually redirects
    ),
  );

  /// `{"success": true, ...}` with status 200.
  static bool isHealthy(int? status, Object? body) =>
      status == 200 && body is Map && body['success'] == true;

  Future<Duration?> call() async {
    final watch = Stopwatch()..start();
    try {
      final res = await _dio.get<Object?>(_url);
      return isHealthy(res.statusCode, res.data) ? watch.elapsed : null;
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
