import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:micro_lending_app/features/audit/data/dtos/audit_dto.dart';
import 'package:micro_lending_app/features/analytics/presentation/screens/advanced_analytics_screen.dart';
import 'package:micro_lending_app/features/analytics/presentation/screens/due_list_screen.dart';
import 'package:micro_lending_app/features/audit/presentation/audit_filters.dart';
import 'package:micro_lending_app/features/audit/presentation/screens/audit_details.dart';
import 'package:micro_lending_app/features/audit/presentation/screens/audit_logs.dart';
import 'package:micro_lending_app/features/auth/presentation/screens/approval_pending.dart';
import 'package:micro_lending_app/features/auth/presentation/screens/login.dart';
import 'package:micro_lending_app/features/auth/presentation/screens/login_with_email.dart';
import 'package:micro_lending_app/features/auth/presentation/screens/login_with_phone.dart';
import 'package:micro_lending_app/features/auth/presentation/screens/register.dart';
import 'package:micro_lending_app/features/auth/presentation/screens/reset_password.dart';
import 'package:micro_lending_app/features/borrowers/presentation/screens/borrowers_screen.dart';
import 'package:micro_lending_app/features/customers/presentation/screens/add_customer.dart';
import 'package:micro_lending_app/features/customers/presentation/screens/customer_detail.dart';
import 'package:micro_lending_app/features/customers/presentation/screens/customer_screen.dart';
import 'package:micro_lending_app/features/customers/presentation/screens/issue_loan.dart';
import 'package:micro_lending_app/features/exports/presentation/screens/downloads_screen.dart';
import 'package:micro_lending_app/features/error/screens/error_screen.dart';
import 'package:micro_lending_app/features/home/home_shell.dart';
import 'package:micro_lending_app/features/loans/presentation/screens/loan_details.dart';
import 'package:micro_lending_app/features/loans/presentation/screens/loan_payments.dart';
import 'package:micro_lending_app/features/loans/presentation/screens/loan_tracker.dart';
import 'package:micro_lending_app/features/loans/presentation/screens/loans.dart';
import 'package:micro_lending_app/features/manage/presentation/screens/create_employee.dart';
import 'package:micro_lending_app/features/manage/presentation/screens/manage_admin.dart';
import 'package:micro_lending_app/features/manage/presentation/screens/manage_users.dart';
import 'package:micro_lending_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:micro_lending_app/features/reports/presentation/screens/reports.dart';
import 'package:micro_lending_app/app/router/app_routes.dart';
import 'package:micro_lending_app/shared/session/session_state.dart';

class AppRouter {
  AppRouter._();

  static final _rootKey = GlobalKey<NavigatorState>();

  /// Where a user with [status] may be at [location]. Null = stay.
  /// Pure, so the guard rules are easy to test.
  static String? redirectFor(AuthStatus status, String location) {
    final isPublicAuthRoute =
        location == AppRoutes.login ||
        location == AppRoutes.loginWithEmail ||
        location == AppRoutes.loginWithPhone ||
        location == AppRoutes.register ||
        location == AppRoutes.forgetPassword;

    final onPending = location == AppRoutes.approvalPending;

    return switch (status) {
      AuthStatus.signedOut => isPublicAuthRoute ? null : AppRoutes.login,
      AuthStatus.pendingApproval =>
        onPending ? null : AppRoutes.approvalPending,
      AuthStatus.signedIn =>
        (isPublicAuthRoute || onPending) ? AppRoutes.customersList : null,
    };
  }

  /// Builds the app's router. [routerProvider] supplies the session hooks.
  static GoRouter create({
    required GoRouterRedirect redirect,
    Listenable? refreshListenable,
  }) => GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.customersList,
    refreshListenable: refreshListenable,
    redirect: redirect,
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
      GoRoute(
        path: AppRoutes.profile,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.analytics,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const AdvancedAnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.createEmployee,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const CreateEmployeeScreen(),
      ),
      GoRoute(
        path: AppRoutes.manageAdmins,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ManageAdminsScreen(),
      ),
      GoRoute(
        path: AppRoutes.manageUsers,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ManageUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.analyticsDue,
        parentNavigatorKey: _rootKey,
        builder: (_, state) {
          final q = state.uri.queryParameters;
          return DueListScreen(
            date: DateTime.tryParse(q['date'] ?? '') ?? DateTime.now(),
            target: double.tryParse(q['target'] ?? ''),
            collected: double.tryParse(q['collected'] ?? ''),
            adminId: q['admin_id'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.audit,
        parentNavigatorKey: _rootKey,
        builder: (_, state) {
          final q = state.uri.queryParameters;
          final scoped =
              q.containsKey('entity_id') ||
              q.containsKey('target_id') ||
              q.containsKey('actor_id');
          return AuditListScreen(
            scope: scoped
                ? AuditScope(
                    entityType: q['entity_type'],
                    entityId: q['entity_id'],
                    targetId: q['target_id'],
                    actorId: q['actor_id'],
                    label: q['label'],
                  )
                : null,
          );
        },
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootKey,
            builder: (_, state) {
              final x = state.extra;
              return AuditDetailScreen(
                id: state.pathParameters['id']!,
                initial: x is Map
                    ? AuditLogDto.fromJson(Map<String, dynamic>.from(x))
                    : null,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.downloads,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const DownloadsScreen(),
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
                    path: "issue/:customerId",
                    parentNavigatorKey: _rootKey,
                    builder: (context, state) => IssueLoanScreen(
                      customerId: state.pathParameters['customerId']!,
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
