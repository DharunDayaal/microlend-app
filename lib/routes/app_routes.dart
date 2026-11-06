class AppRoutes {
  AppRoutes._();

  static const login = "/login";
  static const loginWithEmail = "/login/email";
  static const loginWithPhone = "/login/phone";
  static const register = "/register";
  static const approvalPending = "/approval-pending";
  static const forgetPassword = "/reset-password";

  static const customersList = "/customers"; // starting screen
  static const addCustomer = "/customers/add";
  static String customerDetail(String id) => "/customers/$id";

  static const loansList = "/loans";
  static String loanDetail(String id) => "/loans/$id";
  static String issueLoan(String customerId) => "/loans/issue/$customerId";
  static String loanTrack(String id) => "/loans/$id/tracks";
  static String loanPayment(String id) => "/loans/$id/payments";

  static String borrowersList = "/borrowers";

  static const reports = "/reports";

  static const profile = "/profile";
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
        if (adminId != null) 'admin_id': adminId,
      },
    ).toString();
  }
}
