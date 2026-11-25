import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/core/connectivity/connection_monitor.dart';
import 'package:micro_lending_app/core/connectivity/phone_network.dart';

const wifi = PhoneNetwork(connected: true, validated: true, transport: 'wifi');
const mobile = PhoneNetwork(
  connected: true,
  validated: true,
  transport: 'cellular',
  downKbps: 8000,
);

void main() {
  late StreamController<PhoneNetwork> phone;
  late Duration? health; // what /health does next; null = unreachable
  late int probes;

  ProviderContainer make({bool nativeMissing = false}) {
    phone = StreamController<PhoneNetwork>.broadcast();
    health = const Duration(milliseconds: 200);
    probes = 0;
    return ProviderContainer.test(
      overrides: [
        phoneNetworkProvider.overrideWithValue(
          nativeMissing ? Stream.error(Exception('no plugin')) : phone.stream,
        ),
        connectionProbeProvider.overrideWithValue(() async {
          probes++;
          return health;
        }),
      ],
    );
  }

  Future<void> send(PhoneNetwork n) async {
    phone.add(n);
    for (var i = 0; i < 10; i++) {
      await Future<void>.value();
    }
  }

  testWidgets('no checks at all while everything is fine', (tester) async {
    final c = make();
    c.read(connectionProvider.notifier).start();
    await send(wifi);
    await tester.pump(const Duration(minutes: 30));
    expect(probes, 0);
    expect(c.read(connectionProvider), ConnectionQuality.good);
  });

  testWidgets('offline the moment the phone loses its network; one check '
      'when it comes back', (tester) async {
    final c = make();
    c.read(connectionProvider.notifier).start();
    await send(wifi);

    await send(PhoneNetwork.disconnected);
    expect(c.read(connectionProvider), ConnectionQuality.offline);
    await tester.pump(const Duration(minutes: 5));
    expect(probes, 0); // nothing to try without a network

    await send(mobile);
    expect(probes, 1); // confirms our server answers
    expect(c.read(connectionProvider), ConnectionQuality.good);
  });

  testWidgets('moving from Wi-Fi to mobile data checks once', (tester) async {
    final c = make();
    c.read(connectionProvider.notifier).start();
    await send(wifi);
    await send(mobile);
    await send(mobile); // same network again: no new check
    expect(probes, 1);
    expect(c.read(connectionProvider), ConnectionQuality.good);
  });

  testWidgets('Wi-Fi that needs a login: offline, rechecked with growing '
      'waits', (tester) async {
    final c = make();
    c.read(connectionProvider.notifier).start();
    await send(wifi);

    health = null; // /health is not reached (login page)
    await send(
      const PhoneNetwork(connected: true, validated: false, transport: 'wifi'),
    );
    expect(probes, 1);
    expect(c.read(connectionProvider), ConnectionQuality.offline);

    // the same news repeated (Android re-sends details) adds no check
    await send(
      const PhoneNetwork(
        connected: true,
        validated: false,
        transport: 'wifi',
        downKbps: 9000,
      ),
    );
    expect(probes, 1);

    await tester.pump(const Duration(seconds: 10));
    expect(probes, 2);
    await tester.pump(const Duration(seconds: 20));
    expect(probes, 3);

    health = const Duration(milliseconds: 200); // logged in to the Wi-Fi
    await tester.pump(const Duration(seconds: 40));
    expect(probes, 4);
    expect(c.read(connectionProvider), ConnectionQuality.good);
    await tester.pump(const Duration(minutes: 10));
    expect(probes, 4); // fine again: no more checks
  });

  testWidgets('a working network that Android could not verify is trusted '
      'once /health answers', (tester) async {
    final c = make();
    c.read(connectionProvider.notifier).start();
    await send(
      const PhoneNetwork(connected: true, validated: false, transport: 'wifi'),
    );
    expect(c.read(connectionProvider), ConnectionQuality.good);
  });

  testWidgets("Android's slow-link estimate marks it weak; fast answers "
      "can't override it", (tester) async {
    final c = make();
    final m = c.read(connectionProvider.notifier)..start();
    await send(
      const PhoneNetwork(
        connected: true,
        validated: true,
        transport: 'cellular',
        downKbps: 120,
      ),
    );
    m.report(const Duration(milliseconds: 300), NetworkOutcome.reached);
    expect(c.read(connectionProvider), ConnectionQuality.weak);

    await send(mobile); // signal improved
    expect(c.read(connectionProvider), ConnectionQuality.good);
  });

  testWidgets('real requests still decide weak on a "good" network', (
    tester,
  ) async {
    final c = make();
    final m = c.read(connectionProvider.notifier)..start();
    await send(mobile);
    m.report(const Duration(seconds: 6), NetworkOutcome.reached);
    expect(c.read(connectionProvider), ConnectionQuality.weak);
  });

  testWidgets('without the native side it falls back to requests and '
      '/health retries', (tester) async {
    final c = make(nativeMissing: true);
    final m = c.read(connectionProvider.notifier)..start();
    await tester.pump();
    health = null;
    m.report(Duration.zero, NetworkOutcome.unreachable);
    expect(c.read(connectionProvider), ConnectionQuality.offline);

    health = const Duration(milliseconds: 200);
    await tester.pump(const Duration(seconds: 10));
    expect(probes, 1);
    expect(c.read(connectionProvider), ConnectionQuality.good);
  });

  testWidgets('back in the foreground: re-checked only if offline', (
    tester,
  ) async {
    final c = make();
    final m = c.read(connectionProvider.notifier)..start();
    await send(wifi);
    m.pause();
    m.start(); // resume while fine
    await tester.pump();
    expect(probes, 0);

    m.report(Duration.zero, NetworkOutcome.unreachable);
    m.pause();
    m.start(); // resume while offline
    await tester.pump();
    expect(probes, 1);
  });

  group('HealthProbe.isHealthy', () {
    test('only the server\'s own healthy answer counts', () {
      expect(HealthProbe.isHealthy(200, {'success': true}), true);
      expect(HealthProbe.isHealthy(200, '<html>Login to Wi-Fi</html>'), false);
      expect(HealthProbe.isHealthy(302, null), false);
      expect(HealthProbe.isHealthy(500, {'success': false}), false);
      expect(HealthProbe.isHealthy(200, {'success': false}), false);
    });
  });

  test('PhoneNetwork reads the native event', () {
    final n = PhoneNetwork.fromMap({
      'connected': true,
      'validated': false,
      'transport': 'cellular',
      'downKbps': 0, // Android: no estimate
    });
    expect(n.connected, true);
    expect(n.validated, false);
    expect(n.transport, 'cellular');
    expect(n.downKbps, isNull);
    expect(PhoneNetwork.fromMap({'connected': false}).connected, false);
  });
}
