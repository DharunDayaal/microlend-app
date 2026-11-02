import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:micro_lending_app/routes/app_router.dart';
import 'package:micro_lending_app/routes/auth_notifier.dart';
import 'package:micro_lending_app/utils/device/device_utils.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';
import 'package:micro_lending_app/utils/local_storage/token_storage.dart';
import 'package:micro_lending_app/utils/network/api_client.dart';
import 'package:micro_lending_app/utils/session/current_user.dart';
import 'package:micro_lending_app/utils/theme/theme.dart';

Future<void> main() async {
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

  await CurrentUser.instance.init();
  await AuthNotifier.instance.init();

  // Tokens but no saved profile: an install from before profiles were saved,
  // or cleared storage. Without the profile there is no role and no defaults,
  // so sign in again.
  if (AuthNotifier.instance.isLoggedIn && !CurrentUser.instance.isSignedIn) {
    await TokenStorage.instance.clear();
    AuthNotifier.instance.signedOut();
  }

  // When the refresh token is rejected, move the user to login. This also
  // clears the saved profile (signedOut does it) and the router's redirect
  // opens the login screen.
  ApiClient.instance.onSessionExpired = AuthNotifier.instance.signedOut;

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}