import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:micro_lending_app/routes/app_router.dart';
import 'package:micro_lending_app/utils/device/device_utils.dart';
import 'package:micro_lending_app/utils/loggers/app_logger.dart';
import 'package:micro_lending_app/utils/network/api_client.dart';
import 'package:micro_lending_app/utils/theme/theme.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
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

  ApiClient.instance.onSessionExpired = () {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login/email',
      (route) => false,
    );
  };

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
