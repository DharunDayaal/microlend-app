import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:micro_lending_app/app/app.dart';
import 'package:micro_lending_app/app/app_overrides.dart';
import 'package:micro_lending_app/core/device/device_utils.dart';
import 'package:micro_lending_app/core/logging/app_logger.dart';
import 'package:micro_lending_app/core/network/api_client.dart';
import 'package:micro_lending_app/features/profile/data/profile_providers.dart';
import 'package:micro_lending_app/l10n/locale_controller.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

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
