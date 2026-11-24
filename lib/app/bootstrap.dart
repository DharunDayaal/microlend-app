import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/app/app.dart';
import 'package:micro_lending_app/app/app_overrides.dart';
import 'package:micro_lending_app/core/device/device_utils.dart';
import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:micro_lending_app/core/connectivity/connection_monitor.dart';
import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/core/network/response_cache.dart';
import 'package:micro_lending_app/features/loans/data/payment_outbox.dart';
import 'package:micro_lending_app/shared/session/session_state.dart';
import 'package:micro_lending_app/features/profile/data/profile_providers.dart';
import 'package:micro_lending_app/l10n/locale_controller.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

/// Keeps the lifecycle listener alive for the whole app run.
AppLifecycleListener? _lifecycle;

/// Offline-first wiring: connection quality from every request, the saved
/// copy of GET answers, and the payment queue that syncs on its own.
void _startOffline(ProviderContainer container) {
  final api = ApiClient.instance;
  final monitor = container.read(connectionProvider.notifier);

  api.onResult = (elapsed, error) {
    if (error == null || error.statusCode != null) {
      monitor.report(elapsed, NetworkOutcome.reached); // the server answered
    } else if (error.code == 'TIMEOUT') {
      monitor.report(elapsed, NetworkOutcome.timedOut);
    } else if (error.code == 'NO_INTERNET') {
      monitor.report(elapsed, NetworkOutcome.unreachable);
    }
  };

  final cache = FileResponseCache();
  api.cache = cache;
  // nothing from this account may stay on the phone after logout
  container.listen(sessionProvider.select((s) => s.status), (_, status) {
    if (status == AuthStatus.signedOut) unawaited(cache.clear());
  });

  container.read(paymentOutboxProvider); // loads saved payments, syncs them
  monitor.start();

  _lifecycle?.dispose(); // only one listener, even after a hot restart
  _lifecycle = AppLifecycleListener(
    onResume: () {
      monitor.start(); // checks straight away
      unawaited(container.read(paymentOutboxProvider.notifier).syncNow());
    },
    onPause: monitor.pause,
  );
}

/// Everything that must happen before the first frame: error hooks, saved
/// session, locale. Then the app starts with the shared [ProviderContainer].
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  DeviceUtils.lockPortrait();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error(
      details.exceptionAsString(),
      tag: 'Flutter',
      error: details.exception,
      stack: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error(
      'Uncaught error',
      tag: 'Platform',
      error: error,
      stack: stack,
    );
    return true;
  };

  // One container for the whole app; startup code below reads it directly.
  final container = ProviderContainer(overrides: appOverrides);

  final session = container.read(sessionProvider.notifier);
  await session.restore();

  // When the refresh token is rejected, move the user to login. This also
  // clears the saved profile (signedOut does it) and the router's redirect
  // opens the login screen.
  ApiClient.instance.onSessionExpired = session.signedOut;

  _startOffline(container);

  // call /api/me on every start.
  if (container.read(sessionProvider).isLoggedIn) {
    unawaited(refreshSessionProfile(container));
  }
  await container.read(localeProvider.notifier).init();
  runApp(UncontrolledProviderScope(container: container, child: const App()));
  WidgetsBinding.instance.addPostFrameCallback(
    (_) => showDeviceLanguageNotice(container),
  );
}
