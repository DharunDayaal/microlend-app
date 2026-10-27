import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/features/auth/screens/approval_pending.dart';
import 'package:micro_lending_app/features/auth/screens/login.dart';
import 'package:micro_lending_app/features/auth/screens/login_with_email.dart';
import 'package:micro_lending_app/features/auth/screens/login_with_phone.dart';
import 'package:micro_lending_app/features/auth/screens/register.dart';
import 'package:micro_lending_app/features/auth/screens/reset_password.dart';
import 'package:micro_lending_app/features/borrowers/screeens/borrowers_screen.dart';
import 'package:micro_lending_app/features/customers/screens/add_customer.dart';
import 'package:micro_lending_app/features/customers/screens/customer_detail.dart';
import 'package:micro_lending_app/features/customers/screens/customer_screen.dart';
import 'package:micro_lending_app/features/customers/screens/issue_loan.dart';
import 'package:micro_lending_app/features/error/screens/error_screen.dart';
import 'package:micro_lending_app/features/home/home_shell.dart';
import 'package:micro_lending_app/features/loans/screens/loan_details.dart';
import 'package:micro_lending_app/features/loans/screens/loan_payments.dart';
import 'package:micro_lending_app/features/loans/screens/loan_tracker.dart';
import 'package:micro_lending_app/features/loans/screens/loans.dart';
import 'package:micro_lending_app/features/reports/reports.dart';
import 'package:micro_lending_app/routes/app_routes.dart';
import 'package:micro_lending_app/routes/auth_notifier.dart';

class AppRouter {
  AppRouter._();

  static final _rootKey = GlobalKey<NavigatorState>();

  static String? handleRedirect(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;

    final isPublicAuthRoute =
        loc == AppRoutes.login ||
        loc == AppRoutes.loginWithEmail ||
        loc == AppRoutes.loginWithPhone ||
        loc == AppRoutes.register ||
        loc == AppRoutes.forgetPassword;

    final onPending = loc == AppRoutes.approvalPending;

    return switch (AuthNotifier.instance.status) {
      AuthStatus.signedOut => isPublicAuthRoute ? null : AppRoutes.login,
      AuthStatus.pendingApproval =>
        onPending ? null : AppRoutes.approvalPending,
      AuthStatus.signedIn =>
        (isPublicAuthRoute || onPending) ? AppRoutes.customersList : null,
    };
  }

  static GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.customersList,
    refreshListenable: AuthNotifier.instance,
    redirect: handleRedirect,
    errorBuilder: (context, state) => ErrorScreen(),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: "email",
            builder: (context, state) => const LoginWithEmailScreen(),
          ),
          GoRoute(
            path: "phone",
            builder: (context, state) => const LoginWithPhoneScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.approvalPending,
        builder: (context, state) => const ApprovalPendingScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(shell: navigationShell),
        branches: [
          // Tab 1.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customersList,
                builder: (context, state) => const CustomerScreen(),
                routes: [
                  GoRoute(
                    path: "add",
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => AddCustomerScreen(),
                  ),
                  GoRoute(
                    path: ":id",
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => CustomerDetailScreen(
                      customerId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Tab 2.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.loansList,
                builder: (context, state) => LoansScreen(),
                routes: [
                  GoRoute(
                    path: "issue/:stepNo",
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => IssueLoanScreen(
                      stepNo: state.pathParameters['stepNo']!,
                    ),
                  ),
                  GoRoute(
                    path: ":id",
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) =>
                        LoanDetailsScreen(loanId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: "tracks",
                        parentNavigatorKey: _rootKey,
                        builder: (context, state) => LoanTrackerScreen(
                          loanId: state.pathParameters['id']!,
                        ),
                      ),
                      GoRoute(
                        path: "payments",
                        parentNavigatorKey: _rootKey,
                        builder: (context, state) => LoanPaymentsScreen(
                          loanId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Tab 3.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.borrowersList,
                builder: (context, state) => BorrowerScreen(),
              ),
            ],
          ),
          // Tab 4.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (context, state) => ReportsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
