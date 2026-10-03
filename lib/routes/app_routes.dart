class AppRoutes {
  AppRoutes._();

  static const loginWithEmail = "/login/email";
  static const loginWithPhone = "/login/phone";
  static const register = "/register";
  static const approvalPending = "/approval-pending";

  static const customersList = "/customers"; // starting screen
  static const addCustomer = "/customers/add";
  static String customerDetail(String id) => "/customers/$id";

  static const loansList = "/loans";
  static String loanDetail(String id) => "/loans/$id";
  static String issueLoan(num stepNo) => "/loans/issue/$stepNo";
  static String loanTrack(String id) => "/loans/$id/tracks";
  static String loanPayment(String id) => "/loans/$id/payments";

  static const reports = "/reports";
}
