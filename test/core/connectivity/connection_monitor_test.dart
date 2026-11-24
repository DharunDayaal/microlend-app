import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/connectivity/connection_monitor.dart';

void main() {
  late Duration? probeAnswer;
  late int probes;
  late ProviderContainer c;

  setUp(() {
    probeAnswer = const Duration(milliseconds: 200);
    probes = 0;
    c = ProviderContainer.test(
      overrides: [
        connectionProbeProvider.overrideWithValue(() async {
          probes++;
          return probeAnswer;
        }),
      ],
    );
  });

  ConnectionQuality q() => c.read(connectionProvider);
  ConnectionMonitor m() => c.read(connectionProvider.notifier);
  Duration ms(int v) => Duration(milliseconds: v);

  test('starts as good and stays good with quick answers', () {
    expect(q(), ConnectionQuality.good);
    m().report(ms(400), NetworkOutcome.reached);
    m().report(ms(900), NetworkOutcome.reached);
    expect(q(), ConnectionQuality.good);
  });

  test('slow answers make it weak; quick ones bring it back', () {
    m().report(ms(5000), NetworkOutcome.reached);
    expect(q(), ConnectionQuality.weak);
    for (var i = 0; i < 6; i++) {
      m().report(ms(300), NetworkOutcome.reached);
    }
    expect(q(), ConnectionQuality.good);
  });

  test('one slow answer among quick ones is not enough for weak', () {
    m().report(ms(300), NetworkOutcome.reached);
    m().report(ms(300), NetworkOutcome.reached);
    m().report(ms(4000), NetworkOutcome.reached);
    expect(q(), ConnectionQuality.good);
  });

  test('a timeout is weak, no connection is offline', () {
    m().report(Duration.zero, NetworkOutcome.timedOut);
    expect(q(), ConnectionQuality.weak);
    m().report(Duration.zero, NetworkOutcome.unreachable);
    expect(q(), ConnectionQuality.offline);
  });

  test('the first answer after offline decides on its own', () {
    m().report(ms(5000), NetworkOutcome.reached); // weak history
    m().report(Duration.zero, NetworkOutcome.unreachable);
    m().report(ms(250), NetworkOutcome.reached);
    expect(q(), ConnectionQuality.good);
  });

  test('a health check is judged on its own, tighter limit', () async {
    probeAnswer = ms(2000); // fine for an API call, slow for /health
    await m().checkNow();
    expect(q(), ConnectionQuality.weak);

    probeAnswer = null; // unreachable
    await m().checkNow();
    expect(q(), ConnectionQuality.offline);

    probeAnswer = HealthProbe.timeout; // timed out
    await m().checkNow();
    expect(q(), ConnectionQuality.weak);
    expect(probes, 3);
  });

  test('no background checks until started', () async {
    m().report(Duration.zero, NetworkOutcome.unreachable);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(probes, 0);
  });
}
