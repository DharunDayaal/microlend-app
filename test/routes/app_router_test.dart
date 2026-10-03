import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/routes/app_router.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/routes/auth_notifier.dart';

class FakeBuildContext extends Fake implements BuildContext {}

void setMockAuthStatus(AuthStatus status) {
  AuthNotifier.instance.signedOut();
  if (status == AuthStatus.signedIn) AuthNotifier.instance.signedIn();
  if (status == AuthStatus.pendingApproval)
    AuthNotifier.instance.pendingApproval();
}

GoRouterState createMockState(String path) {
  final uri = Uri.parse(path);
  return GoRouterState(
    AppRouter.router.configuration,
    uri: uri,
    path: path,
    matchedLocation: path,
    fullPath: path,
    pathParameters: const {},
    pageKey: ValueKey(path),
  );
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('AppRouter Redirect Logic Security Gates', () {
    // Instantiate our dummy context to use across tests 👇
    final dummyContext = FakeBuildContext();

    test(
      'Logged out users targeting dashboard are redirected to email login',
      () {
        setMockAuthStatus(AuthStatus.signedOut);

        final state = createMockState(AppRoutes.customersList);

        // Pass the dummy context instead of trying to look up the unrendered Navigator
        final redirectResult = AppRouter.handleRedirect(dummyContext, state);
        expect(redirectResult, equals(AppRoutes.loginWithEmail));
      },
    );

    test('Logged out users targeting phone login or registration are allowed to stay', () {
      setMockAuthStatus(AuthStatus.signedOut);
      final state = createMockState(AppRoutes.register);

      final redirectResult = AppRouter.handleRedirect(dummyContext, state);
      expect(redirectResult, isNull);
    });

    test('Logged in but unapproved users are instantly forced to the pending waiting room', () {
      setMockAuthStatus(AuthStatus.pendingApproval);
      final state = createMockState(AppRoutes.customersList);

      final redirectResult = AppRouter.handleRedirect(dummyContext, state);
      expect(redirectResult, equals(AppRoutes.approvalPending));
    });

    test('Fully signed-in & approved users attempting to hit auth pages are bounced to home', () {
      setMockAuthStatus(AuthStatus.signedIn);
      final state = createMockState(AppRoutes.loginWithEmail);

      final redirectResult = AppRouter.handleRedirect(dummyContext, state);
      expect(redirectResult, equals(AppRoutes.customersList));
    });
  });
}
