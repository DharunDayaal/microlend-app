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
  static const String collectPayment = '/loans/collect';
}
