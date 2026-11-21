import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/app/router/app_router.dart';
import 'package:micro_lending_app/shared/session/session_controller.dart';

/// The app's single router. Re-runs its redirect whenever the sign-in status
/// changes, so logging in or out moves the user to the right place.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider.select((s) => s.status), (_, _) {
    refresh.value++;
  });

  final router = AppRouter.create(
    refreshListenable: refresh,
    redirect: (_, state) => AppRouter.redirectFor(
      ref.read(sessionProvider).status,
      state.matchedLocation,
    ),
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
