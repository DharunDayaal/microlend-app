import 'package:flutter_test/flutter_test.dart';
import 'package:micro_lending_app/app/router/app_router.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/session/session_state.dart';

String? go(AuthStatus s, String to) => AppRouter.redirectFor(s, to);

void main() {
  group('AppRouter redirect rules', () {
    test('signed-out users are sent to the login chooser', () {
      expect(
        go(AuthStatus.signedOut, AppRoutes.customersList),
        AppRoutes.login,
      );
      expect(go(AuthStatus.signedOut, AppRoutes.loansList), AppRoutes.login);
    });

    test('signed-out users may stay on any public auth page', () {
      for (final page in [
        AppRoutes.login,
        AppRoutes.loginWithEmail,
        AppRoutes.loginWithPhone,
        AppRoutes.register,
        AppRoutes.forgetPassword,
      ]) {
        expect(go(AuthStatus.signedOut, page), isNull, reason: page);
      }
    });

    test('unapproved users are held on the pending page', () {
      expect(
        go(AuthStatus.pendingApproval, AppRoutes.customersList),
        AppRoutes.approvalPending,
      );
      expect(go(AuthStatus.pendingApproval, AppRoutes.approvalPending), isNull);
    });

    test('signed-in users are bounced from auth pages to home', () {
      expect(
        go(AuthStatus.signedIn, AppRoutes.loginWithEmail),
        AppRoutes.customersList,
      );
      expect(
        go(AuthStatus.signedIn, AppRoutes.approvalPending),
        AppRoutes.customersList,
      );
      expect(go(AuthStatus.signedIn, AppRoutes.loansList), isNull);
    });
  });
}
