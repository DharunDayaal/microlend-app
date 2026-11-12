class AppRoutes {
  AppRoutes._();

  static const String login = "/login";
  static const String loginWithEmail = "/login/email";
  static const String loginWithPhone = "/login/phone";
  static const String register = "/register";
  static const String approvalPending = "/approval-pending";
  static const String forgetPassword = "/reset-password";

  static const String customersList = "/customers"; // starting screen
  static const String addCustomer = "/customers/add";
  static String customerDetail(String id) => "/customers/$id";

  static const String loansList = "/loans";
  static String loanDetail(String id) => "/loans/$id";
  static String issueLoan(String customerId) => "/loans/issue/$customerId";
  static String loanTrack(String id) => "/loans/$id/tracks";
  static String loanPayment(String id) => "/loans/$id/payments";

  static String borrowersList = "/borrowers";

  static const String reports = "/reports";

  static const String profile = "/profile";
  static const analytics = "/analytics";

  static const String analyticsDue = '/analytics/due';

  static String analyticsDueFor(
    DateTime date, {
    double? target,
    double? collected,
    String? adminId,
  }) {
    final d =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return Uri(
      path: analyticsDue,
      queryParameters: {
        'date': d,
        if (target != null) 'target': '$target',
        if (collected != null) 'collected': '$collected',
        'admin_id': ?adminId,
      },
    ).toString();
  }

  static const String createEmployee = '/manage/users/new';
  static const String manageAdmins = '/manage/admins';
  static const String manageUsers = '/manage/users';

  static const String audit = '/audit';
  static String auditDetail(String id) => '/audit/$id';

  /// The audit list pre-filtered from a History button.
  static String auditFor({
    String? entityType,
    String? entityId,
    String? targetId,
    String? actorId,
    String? label,
  }) => Uri(
    path: audit,
    queryParameters: {
      'entity_type': ?entityType,
      'entity_id': ?entityId,
      'target_id': ?targetId,
      'actor_id': ?actorId,
      'label': ?label,
    },
  ).toString();
}
