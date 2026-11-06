class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = "https://microlending-backend.vercel.app/api";

  static const String register = '/auth/register';
  static const String loginWithEmail = '/auth/login/email';
  static const String loginWithPhone = '/auth/login/phone';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String sendOtp = '/auth/otp/request';
  static const String verifyOtp = '/auth/otp/verify';
  static const String resetPassword = '/auth/password/reset';

  static const String getSummary = '/users/today-summary';
  static const String getCustomersByWeekday = '/users/weekday';
  static const String addCustomer = '/users/create';
  static String getCustomerDetails(String customerId) => '/users/$customerId';
  static String getCustomerLoans(String customerId) =>
      '/users/loans/$customerId';
  static String getCustomerReferrals(String customerId) =>
      '/users/referrals/$customerId';

  static const String issueLoan = '/loans/issue';
  static String getLoanDetails(String loanId) => '/loans/details/$loanId';
  static String collectPayment(String loanId) =>
      '/loans/collect/payment/$loanId';
  static const String getLoans = '/loans/list';
  static const String collectionsDue = '/loans/collections/due';
  static String getPayments(String loanId) => '/loans/payments/$loanId';
  static String loanStatus(String loanId) => '/loans/update/status/$loanId';

  static const String me = '/me';
  static const String mePhone = '/me/phone';
  static const String mePassword = '/me/password';
  static const String meSessions = '/me/sessions';
  static String meSession(String id) => '/me/sessions/$id';
  static const String meStats = '/me/stats';
  static const String meDefaults = '/me/defaults';
  static const String meTeam = '/me/team';
  static const String admins = '/admins';
  static String adminVerification(String id) => '/admins/$id/verification';
  static String adminActive(String id) => '/admins/$id/active';
  static const String settingsLimits = '/settings/limits';

  static String analytics(String level, String tail) =>
      '/analytics/$level/$tail';
}
