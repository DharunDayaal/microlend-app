// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Choose the app language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTamil => 'தமிழ்';

  @override
  String get deviceLanguageNotice =>
      'Your phone\'s preferred language is Tamil, so the app opened in Tamil. You can change this with the language button at the top of the home screen.';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Retry';

  @override
  String daysLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days late',
      one: '1 day late',
    );
    return '$_temp0';
  }

  @override
  String commonWeekN(int week) {
    return 'Week $week';
  }

  @override
  String payWeekAlreadyPaid(int week) {
    return 'Week $week is already paid in full';
  }

  @override
  String get payDueToday => 'Due today';

  @override
  String get payScheduledAhead => 'Scheduled ahead';

  @override
  String get payPartialOnFile => 'Partial payment on file';

  @override
  String get payOverdueNotCollected => 'Overdue — not yet collected';

  @override
  String payWeekDate(int week, String date) {
    return 'Week $week • $date';
  }

  @override
  String payStillOwedForWeek(String amount, int week) {
    return '$amount still owed for Week $week';
  }

  @override
  String payWeekWasDue(int week, String date) {
    return 'Week $week was due $date';
  }

  @override
  String get payEnterValidAmount => 'Enter a valid payment amount';

  @override
  String get payCash => 'Cash';

  @override
  String get payUpi => 'UPI';

  @override
  String get payCollectPayment => 'Collect Payment';

  @override
  String payWeekOfTotal(int week, int total) {
    return 'Week $week of $total';
  }

  @override
  String get payAmountToCollect => 'AMOUNT TO COLLECT';

  @override
  String payUpToCollectable(String amount) {
    return 'Up to $amount collectable on this loan';
  }

  @override
  String payClearWeek(int week) {
    return 'Clear Week $week';
  }

  @override
  String get payTwoWeeks => 'Pay 2 Weeks';

  @override
  String paySettleFullLoan(String amount) {
    return 'Settle full loan — $amount';
  }

  @override
  String get payThisWeek => 'This week';

  @override
  String get payEntireLoan => 'Entire loan';

  @override
  String get payCleared => 'Cleared ✓';

  @override
  String payConfirmClose(String amount) {
    return 'CONFIRM & CLOSE LOAN — $amount';
  }

  @override
  String payConfirmRecord(String amount) {
    return 'CONFIRM & RECORD $amount';
  }

  @override
  String otpEnterComplete(int length) {
    return 'Enter the complete $length-digit code';
  }

  @override
  String get otpNewCodeSent => 'A new code has been sent.';

  @override
  String get otpVerifyPhone => 'Verify phone number';

  @override
  String otpEnterCodeSentTo(int length, String phone) {
    return 'Enter the $length-digit code sent to $phone.';
  }

  @override
  String otpResendIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get otpResend => 'Resend OTP';

  @override
  String get commonContinue => 'Continue';

  @override
  String get statusPaid => 'PAID';

  @override
  String get statusPartial => 'PARTIAL';

  @override
  String get statusUnpaid => 'UNPAID';

  @override
  String get statusScheduled => 'SCHEDULED';

  @override
  String get statusUpcoming => 'UPCOMING';

  @override
  String get statusOverdue => 'OVERDUE';

  @override
  String trackDueOn(String date) {
    return 'Due $date';
  }

  @override
  String get trackPaidInFull => 'Paid in full';

  @override
  String trackDueToClear(String amount) {
    return '$amount Due to clear';
  }

  @override
  String get trackNotCollected => 'Not collected';

  @override
  String trackPending(String amount) {
    return '$amount pending';
  }

  @override
  String get trackUpcoming => 'Upcoming';

  @override
  String trackPastTerm(int weeks) {
    return 'Past $weeks-week term';
  }

  @override
  String trackOverdueAmount(String amount) {
    return '$amount overdue';
  }

  @override
  String trackWeekShort(String week) {
    return 'Wk $week';
  }

  @override
  String trackCollectAmount(String amount) {
    return 'Collect $amount';
  }

  @override
  String get referralSelectTitle => 'Select Referring Borrower';

  @override
  String get commonSearchNamePhone => 'Search by name or phone';

  @override
  String get referralNoneFound => 'No referrers found';

  @override
  String get payPastTerm => 'PAST TERM';

  @override
  String get payAmountPaid => 'AMOUNT PAID';

  @override
  String get payWeekCleared => 'WEEK CLEARED';

  @override
  String payWeekProgress(int week) {
    return 'Week $week progress';
  }

  @override
  String payWeekFullyCollected(int week, String amount) {
    return 'Week $week fully collected ($amount)';
  }

  @override
  String payCollectedOfLeft(String collected, String target, String left) {
    return '$collected of $target collected • $left left';
  }

  @override
  String get payIdCopied => 'Payment ID copied';

  @override
  String get commonCall => 'Call';

  @override
  String get commonUnableOpenDialer => 'Unable to open dialer';

  @override
  String stepDecrease(String label) {
    return 'Decrease $label';
  }

  @override
  String stepIncrease(String label) {
    return 'Increase $label';
  }

  @override
  String get recoveryOverallTarget => 'Overall Recovery Target';

  @override
  String recoveryPercentCompleted(String percent) {
    return '$percent% Completed';
  }

  @override
  String get recoveryOverall => 'Overall recovery';

  @override
  String recoveryOverdueLine(String percent, String amount) {
    return '$percent% overdue • $amount';
  }

  @override
  String ringPercentCollected(int percent) {
    return '$percent percent collected';
  }

  @override
  String get securityRating => 'Security rating';

  @override
  String get securityWeak => 'Weak';

  @override
  String get securityFair => 'Fair';

  @override
  String get securityGood => 'Good';

  @override
  String get securityStrong => 'Strong';

  @override
  String securityLevelOf(int level, int total) {
    return '$level of $total';
  }

  @override
  String placeholderComingSoon(String title) {
    return '$title: coming soon';
  }

  @override
  String get commonRequired => '*Required';

  @override
  String get appName => 'Thavanai';

  @override
  String get authSelectLoginMethod => 'Select Login Method';

  @override
  String get authWelcomeBack => 'Welcome back';

  @override
  String get authSelectMethodSubtitle =>
      'Select your preferred sign in method to access you field ledger and daily collections.';

  @override
  String get authEmailPassword => 'Email & Password';

  @override
  String get authEmailPasswordSubtitle =>
      'Sign in using your registered email address...';

  @override
  String get authPhoneOtp => 'Phone OTP verification';

  @override
  String get authPhoneOtpSubtitle =>
      'Instant login via 6-digit OTP verification directly to the registered mobile number';

  @override
  String get commonOr => 'OR';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authRegisterHere => 'Register here';

  @override
  String get authEmailLogin => 'Email Login';

  @override
  String get authSignInToAccess => 'Sign in to access your account.';

  @override
  String get authEmailAddress => 'Email Address';

  @override
  String get authEnterEmailHint => 'Enter your email...';

  @override
  String get authPassword => 'Password';

  @override
  String get authEnterPasswordHint => 'Enter your password...';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authSignIn => 'SIGN IN';

  @override
  String get authOrQuickSwitch => 'OR QUICK SWITCH';

  @override
  String get authLoginWithPhone => 'Log in with phone number';

  @override
  String get authNoAccountInline => 'Don\'t have an account? ';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authNewCodeSent => 'A new verification code has been sent.';

  @override
  String get authEnterComplete6 => 'Please enter the complete 6-digit code';

  @override
  String get authVerifyContinue => 'Verify & continue';

  @override
  String get authSendOtp => 'Send OTP';

  @override
  String get authOtpLogin => 'OTP Login';

  @override
  String get authLoginWithOtp => 'Login with OTP';

  @override
  String get authOtpSubtitle =>
      'Enter 6 digit verification code sent via secure SMS to your registered mobile.';

  @override
  String get authLoginWithEmail => 'Log in with email';

  @override
  String get authRegisteredNumber => 'Registered number';

  @override
  String get authPhoneNumber => 'Phone Number';

  @override
  String get authEnterPhoneHint => 'Enter your phone number...';

  @override
  String get approvalVerificationRequired =>
      'Account verification is required to proceed further';

  @override
  String get approvalPendingTitle => 'Approval Pending';

  @override
  String get approvalUnderReviewBadge =>
      'APPLICATION UNDER REVIEW • PENDING ADMIN APPROVAL';

  @override
  String get approvalInProgress => 'Approval in Progress';

  @override
  String get approvalSubmittedBody =>
      'Your profile and lending parameters have been submitted. An administrator will review and approve your account soon.';

  @override
  String get approvalWhatNext => 'What to expect next';

  @override
  String get approvalWhatNextBody =>
      'Your profile is currently under review by the administrator. You will be notified once your account has been approved and activated.';

  @override
  String get approvalReviewTimeframe => 'REVIEW TIMEFRAME';

  @override
  String get approvalTypicalTime => 'Typical review time: 24-48 business hours';

  @override
  String get resetTitle => 'Password Reset';

  @override
  String get resetHeading => 'Reset your password';

  @override
  String get resetSubtitle =>
      'Verify your registered email or phone number to create a secure new password for your account.';

  @override
  String get resetRememberPassword => 'Remember your Password? ';

  @override
  String get resetBackToLogin => 'Back to login';

  @override
  String get resetRegisteredEmail => 'Registered email address';

  @override
  String get resetRegisteredPhone => 'Registered phone number';

  @override
  String get resetEnterEmail => 'Enter your email address';

  @override
  String get resetEnterPhone => 'Enter your phone number';

  @override
  String get resetNewPassword => 'New Password';

  @override
  String get resetNewPasswordHint => 'Enter your strong new password';

  @override
  String get resetConfirmPassword => 'Confirm New Password';

  @override
  String get resetConfirmHint => 'Re-type your password to confirm';

  @override
  String get resetPasswordsMustMatch => 'Passwords must match exactly';

  @override
  String get resetUpdatePassword => 'Update Password';

  @override
  String get resetGetCode => 'Get Verification Code';

  @override
  String get regTitle => 'Registration';

  @override
  String get regBackToStep1 => 'Back to step 1';

  @override
  String regStepN(int step) {
    return 'Step $step';
  }

  @override
  String get regPersonalDetails => 'Personal Details';

  @override
  String get regLendingTerms => 'Lending Terms';

  @override
  String get commonDone => 'Done';

  @override
  String get regStep1Subtitle =>
      'Step 1 of 2: Personal Details. Enter your information to create your account.';

  @override
  String get regFullName => 'Full name';

  @override
  String get regEnterName => 'Enter your name';

  @override
  String get regEnterMobile => 'Enter your mobile number';

  @override
  String get regCreatePassword => 'Create Password';

  @override
  String get regEnterPassword => 'Enter your password';

  @override
  String get regSecurityRating => 'Security Rating';

  @override
  String get regStrengthLow => 'Low';

  @override
  String get regStrengthMedium => 'Medium';

  @override
  String get regStrengthHigh => 'High';

  @override
  String get regStrengthExcellent => 'Excellent';

  @override
  String get regLendingSubtitle =>
      'Final step - set your standard lending parameters. These defaults will pre-populate your loan origination calculator.';

  @override
  String get regVerifiedProfile => 'VERIFIED PROFILE';

  @override
  String get regFieldUser => 'Field user';

  @override
  String get termsDefaultInterest => 'Default Interest Rate';

  @override
  String get termsFlatRate => 'Flat Rate';

  @override
  String get termsEnterInterest => 'Enter your interest rate';

  @override
  String get termsInterestFooter =>
      'Applied flat across the full loan cycle duration.';

  @override
  String get termsInterestRate => 'Interest rate';

  @override
  String get termsUpfrontFee => 'Upfront Processing Fee';

  @override
  String get termsAtDisbursement => 'At Disbursement';

  @override
  String get termsEnterUpfront => 'Enter your upfront fee';

  @override
  String get termsUpfrontFooter =>
      'Deducted immediately from cash handover upon spot disbursement.';

  @override
  String get termsUpfrontFeeShort => 'Upfront fee';

  @override
  String get termsTotalDurationMonths => 'Total Duration (Months)';

  @override
  String get termsWeeklySchedule => 'Weekly Schedule';

  @override
  String termsMonthsShort(String value) {
    return '$value MO';
  }

  @override
  String get termsMonths => 'Months';

  @override
  String get regBaselinePreview => 'Standard Baseline\nPreview';

  @override
  String regLoanModel(String amount) {
    return '$amount \nLoan Model';
  }

  @override
  String get regNetHandover => 'NET HANDOVER CASH';

  @override
  String regDeductedFee(String amount) {
    return 'Deducted fee: -$amount\n';
  }

  @override
  String get regTotalRepayable => 'TOTAL REPAYABLE';

  @override
  String regIncludesInterest(String amount, String percent) {
    return 'Includes $amount ($percent)';
  }

  @override
  String get regWeeklyCollection => 'WEEKLY COLLECTION AMOUNT';

  @override
  String get regFixedEveryMonday => 'Fixed installment every\nMonday';

  @override
  String get regPerWeek => 'per week\n';

  @override
  String regWeeksParen(int weeks) {
    return '($weeks) weeks';
  }

  @override
  String get regInstallmentSchedule => 'Installment Schedule';

  @override
  String get regPrincipalFlat => 'Principal + Flat Int.';

  @override
  String get commonStatus => 'Status';

  @override
  String regWeekHash(String week) {
    return 'Week #$week';
  }

  @override
  String regAdditionalCycles(int count) {
    return '+ $count additonal Weekly cycles to maturity';
  }

  @override
  String get regHaveAccount => 'Already have an account? ';

  @override
  String get regSignIn => 'Sign In';

  @override
  String get regDraftCached => 'Draft cached locally';

  @override
  String regStepOf(int step, int total) {
    return 'STEP $step of $total';
  }

  @override
  String get regVerifyPhone => 'Verify Phone Number';

  @override
  String get regRegister => 'Register';

  @override
  String get termsCalculateTerm => 'Calculate Term:';

  @override
  String termsWeeksCount(int weeks) {
    return '$weeks Weeks ';
  }

  @override
  String termsDaysParen(int days) {
    return '($days Days)';
  }

  @override
  String get termsAutoCalculated => 'Auto calculated: ';

  @override
  String get termsEnterMonths => 'enter the number of months';

  @override
  String termsMonthsCount(String months) {
    return '$months months ';
  }

  @override
  String get termsTimesFourWeeks => 'x 4 weeks = ';

  @override
  String termsWeeklyCollections(int weeks) {
    return '$weeks weekly collections';
  }

  @override
  String get tabField => 'Field';

  @override
  String get tabLoans => 'Loans';

  @override
  String get tabBorrowers => 'Borrowers';

  @override
  String get tabReports => 'Reports';

  @override
  String get menuMyProfile => 'My profile';

  @override
  String get menuMyProfileSub => 'Name, phone, email and loan defaults';

  @override
  String get menuAddBorrower => 'Add borrower';

  @override
  String get menuAddBorrowerSub => 'Register a new customer';

  @override
  String get menuManageUsers => 'Manage users';

  @override
  String get menuManageUsersSub => 'Add team members and set roles';

  @override
  String get menuAnalytics => 'Advanced analytics';

  @override
  String get menuAnalyticsSub => 'Recovery, overdue trends and collections';

  @override
  String get menuAllAdmins => 'All admins';

  @override
  String get menuAllAdminsSub => 'Approve and manage admin accounts';

  @override
  String get menuAuditLog => 'Audit log';

  @override
  String get menuAuditLogSub => 'Who changed what, and when';

  @override
  String get menuDownloads => 'Downloads';

  @override
  String get menuDownloadsSub => 'Sheets and reports you have exported';

  @override
  String get greetMorning => 'Good morning';

  @override
  String get greetAfternoon => 'Good afternoon';

  @override
  String get greetEvening => 'Good evening';

  @override
  String get menuOpenProfile => 'Open profile menu';

  @override
  String get menuSignedOut => 'Signed out';

  @override
  String get menuLogOut => 'Log out';

  @override
  String get menuLogOutSub => 'You will need to sign in again.';

  @override
  String get menuLogOutConfirm => 'Log out?';

  @override
  String get errorPageNotFound => '404! Page not found.';

  @override
  String get roleUser => 'User';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleSuperAdmin => 'Super Admin';

  @override
  String get manualStatusClosed => 'Closed';

  @override
  String get manualStatusDefaulted => 'Defaulted';

  @override
  String get manualStatusReopen => 'Active (reopen)';

  @override
  String get manualStatusClosedDesc =>
      'Ends the loan. Nothing more can be collected on it.';

  @override
  String get manualStatusDefaultedDesc =>
      'The borrower will not repay. The loan is written off as a default.';

  @override
  String get manualStatusReopenDesc =>
      'Reopens the loan so collections can resume. It shows as overdue again if weeks are already past due.';

  @override
  String get exportWeekdaySheet => 'Collection sheet';

  @override
  String get exportWeekdaySheetBlurb =>
      'One block per customer for a weekday: loan details and what was paid each week (W1 - 300, W2 - 400).';

  @override
  String get exportDueThisWeek => 'Route sheet';

  @override
  String get exportDueThisWeekBlurb =>
      'Weekly instalments falling due, by day, with amount due, paid and balance.';

  @override
  String get exportCustomerList => 'Customer list';

  @override
  String get exportCustomerListBlurb =>
      'Customers with phone, area, payment day, active loans and outstanding.';

  @override
  String get exportOverdue => 'Overdue loans';

  @override
  String get exportOverdueBlurb =>
      'Overdue and defaulted loans with days late and the overdue amount.';

  @override
  String get exportCollections => 'Collections';

  @override
  String get exportCollectionsBlurb => 'Every payment taken in a date range.';

  @override
  String get exportLoansRegister => 'Loans register';

  @override
  String get exportLoansRegisterBlurb =>
      'Every loan with its money columns. Filter by status and issue date.';

  @override
  String get exportClosedLoans => 'Closed loans';

  @override
  String get exportClosedLoansBlurb =>
      'Loans closed, paid off or defaulted in a range, with collected and shortfall.';

  @override
  String get exportNewCustomers => 'New customers';

  @override
  String get exportNewCustomersBlurb =>
      'Customers added in a range, with referrer and who added them.';

  @override
  String get exportAuditLog => 'Audit log';

  @override
  String get exportAuditLogBlurb =>
      'Who changed what, with old and new values.';

  @override
  String get exportEmployeePerformance => 'Employee performance';

  @override
  String get exportEmployeePerformanceBlurb =>
      'Per employee: collected, target, rates, overdue, new customers and loans.';

  @override
  String get exportTeamSummary => 'Team summary';

  @override
  String get exportTeamSummaryBlurb => 'One row per admin.';

  @override
  String get dayMonShort => 'MON';

  @override
  String get dayTueShort => 'TUE';

  @override
  String get dayWedShort => 'WED';

  @override
  String get dayThuShort => 'THR';

  @override
  String get dayFriShort => 'FRI';

  @override
  String get daySatShort => 'SAT';

  @override
  String get daySunShort => 'SUN';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get custFillHighlighted => 'Please fill the highlighted fields.';

  @override
  String get custOtpSendFailed =>
      'Couldn\'t send the verification code. Try again.';

  @override
  String custOtpSentTo(String phone) {
    return 'Verification code sent to $phone.';
  }

  @override
  String get custVerifyToAdd => 'Verify the phone number to add this borrower.';

  @override
  String get custPhoneVerified => 'Phone number verified.';

  @override
  String custAddedSuccess(String name) {
    return '$name was added successfully.';
  }

  @override
  String get custAddFailed => 'Couldn\'t add the borrower. Please try again.';

  @override
  String get commonSomethingWrong => 'Something went wrong. Please try again.';

  @override
  String get custSaveAdd => 'Save & Add Borrower';

  @override
  String get custCancelDiscard => 'Cancel & Discard';

  @override
  String get custIdentityCredentials => 'Identity Credentials';

  @override
  String get custRequiredBadge => 'Required';

  @override
  String get custFullName => 'Full Name';

  @override
  String get custEnterFullName => 'Enter full name';

  @override
  String get custMobileNumber => 'Mobile number';

  @override
  String get custEnterMobile => 'Enter mobile number';

  @override
  String get custPreferredDayBatch => 'Preferred Day Batch';

  @override
  String get custAssignedRoute => 'Assigned to weekly field collection route';

  @override
  String custDayBatch(String day) {
    return '$day Batch';
  }

  @override
  String get custAddressLocation => 'Address & Location';

  @override
  String get custVerification => 'Verification';

  @override
  String get custStreet => 'Street Name / House No.';

  @override
  String get custStreetHint => 'Street name or number';

  @override
  String get custCity => 'City / Town';

  @override
  String get custEnterCity => 'Enter city';

  @override
  String get custDistrict => 'District';

  @override
  String get custEnterDistrict => 'Enter district';

  @override
  String get custReferredBy => 'Referred By Borrower';

  @override
  String get custOptional => 'Optional';

  @override
  String get custSelectReferrer => 'Select Referrer Borrower';

  @override
  String custReferrerIdLine(String id) {
    return 'ID $id • 2 Fully Repaid Loans';
  }

  @override
  String get custChange => 'Change';

  @override
  String get custAddBorrower => 'Add Borrower';

  @override
  String get custSearchHint => 'Search borrower, street, city, district...';

  @override
  String get custNoneScheduled => 'No customers scheduled';

  @override
  String get commonTapToRetry => 'Tap to retry';

  @override
  String get custNoMore => 'No more customers';

  @override
  String get custTodaysTarget => 'TODAY\'S TARGET ROUTE';

  @override
  String get custDueSuffix => ' due';

  @override
  String get custCollected => 'Collected';

  @override
  String get custPending => 'Pending';

  @override
  String custBorrowersCount(int count) {
    return '$count Borrowers';
  }

  @override
  String get commonNA => 'N/A';

  @override
  String get commonBack => 'Back';

  @override
  String get commonHistory => 'History';

  @override
  String custRegOn(String date) {
    return '• Reg: $date';
  }

  @override
  String custCycleEligible(String count) {
    return 'Cycle $count Eligible';
  }

  @override
  String get custAssignedRouteLabel => 'Assigned Route';

  @override
  String custDayRoute(String day) {
    return '$day Route';
  }

  @override
  String get custCallBorrower => 'Call Borrower';

  @override
  String get custCloseActiveFirst =>
      'Close the current active loan before issuing a new one.';

  @override
  String get issueStepBorrower => 'Borrower';

  @override
  String get issueStepProfile => 'Profile';

  @override
  String get issueStepSelected => 'Selected';

  @override
  String get issueStepTerms => 'Terms';

  @override
  String get issueStepCalculator => 'Calculator';

  @override
  String get issueStepConfirmed => 'Confirmed';

  @override
  String get issueStepDisburse => 'Disburse';

  @override
  String get issueStepConfirmation => 'Confirmation';

  @override
  String get issueTitleBorrower => 'Borrower Profile & History';

  @override
  String get issueTitleTerms => 'Loan Terms & Calculator';

  @override
  String get issueTitleDisburse => 'Review & Disburse';

  @override
  String get issueSwitchBorrowers => 'Switch Borrowers';

  @override
  String issueAlreadyHasOverdue(String name, String id) {
    return '$name already has an overdue loan ($id). Close it before issuing a new one.';
  }

  @override
  String issueAlreadyHasActive(String name, String id) {
    return '$name already has an active loan ($id). Close it before issuing a new one.';
  }

  @override
  String get issueConfirmTitle => 'Issue loan & disburse?';

  @override
  String get issuePayoutCash => 'cash';

  @override
  String get issuePayoutBank => 'bank transfer';

  @override
  String issueConfirmBody(
    String net,
    String payout,
    String name,
    String total,
    int weeks,
    String weekly,
  ) {
    return 'Hand over $net ($payout) to $name.\n\nRepayable: $total over $weeks weeks, $weekly a week.\n\nThis cannot be undone.';
  }

  @override
  String get issueLoanAction => 'Issue loan';

  @override
  String get issueReviewAgain => 'Review again';

  @override
  String issueLoanIssued(String id, String name) {
    return 'Loan $id issued to $name.';
  }

  @override
  String get issueNoServerAnswer =>
      'No answer from the server. Check the borrower’s loans before trying again, in case the loan was already issued.';

  @override
  String get issueNewLoan => 'Issue New Loan';

  @override
  String issueStepOfTitle(int step, int total, String title) {
    return 'Step $step of $total: $title';
  }

  @override
  String get issueLoadBorrowerFailed => 'Could not load the borrower.';

  @override
  String get issueChooseBorrower => 'Choose a borrower first.';

  @override
  String get issueContinueTerms => 'Continue to terms';

  @override
  String get issueNextStep => 'Next Step';

  @override
  String get facilityPaymentOverdue => 'Payment overdue';

  @override
  String get facilityAllPaid => 'All installments paid';

  @override
  String get facilityTitle => 'Active Facility';

  @override
  String get facilityRemaining => 'Remaining Balance';

  @override
  String facilityOfTotal(String amount) {
    return 'of $amount Total';
  }

  @override
  String get facilityNextInstallment => 'Next Installment';

  @override
  String facilityRepaidPercent(int percent) {
    return 'Repaid: $percent%';
  }

  @override
  String facilityPaidAmount(String amount) {
    return '$amount Paid';
  }

  @override
  String get facilityViewTracks => 'View Tracks';

  @override
  String get facilityViewPayments => 'View payments';

  @override
  String get addressNoStreet => 'No street on file';

  @override
  String get creditNewBorrower => 'NEW BORROWER';

  @override
  String get creditAtRisk => 'AT RISK';

  @override
  String get creditGoodStanding => 'GOOD STANDING';

  @override
  String get creditFair => 'FAIR';

  @override
  String get creditTitle => 'Field Credit History';

  @override
  String get creditOnTime => 'ON-TIME';

  @override
  String creditRatio(int ratio) {
    return '$ratio% Ratio';
  }

  @override
  String get creditDelayed => 'DELAYED';

  @override
  String get creditRepaidLate => 'Repaid late';

  @override
  String get creditDefault => 'DEFAULT';

  @override
  String get creditCleanSheet => 'Clean Sheet';

  @override
  String get creditNeedsReview => 'Needs review';

  @override
  String get creditCompletedCycles => 'COMPLETED CYCLES';

  @override
  String get creditNoCycles => 'No completed cycles yet';

  @override
  String get creditDelayRepaid => 'DELAY REPAID';

  @override
  String get statusClosed => 'CLOSED';

  @override
  String creditCycleLine(int cycle, String id) {
    return 'Cycle #$cycle • $id';
  }

  @override
  String creditClosedLine(String date, String amount) {
    return 'Closed $date • $amount';
  }

  @override
  String get issueBarOnePerBorrower => 'One active loan per borrower';

  @override
  String issueBarCycle(int cycle) {
    return 'Cycle $cycle';
  }

  @override
  String get issueBarIssueLoan => 'ISSUE LOAN';

  @override
  String issueBarIssueLoanTo(String name) {
    return 'ISSUE LOAN TO $name';
  }

  @override
  String get issueBarHint =>
      'Check credit limits & calculate custom repayment schedule';

  @override
  String get socialTitle => 'Social Network & Guarantees';

  @override
  String get socialReferredBy => 'Referred By Guarantor';

  @override
  String get socialBorrowersReferred => 'Borrowers Referred';

  @override
  String profileCycleN(int cycle) {
    return 'Cycle $cycle';
  }

  @override
  String profileSince(String date) {
    return 'Since $date';
  }

  @override
  String get profileSwitchBorrower => 'Switch borrower';

  @override
  String get profileNotSet => 'Not set';

  @override
  String profileEveryDay(String day) {
    return 'Every $day';
  }

  @override
  String get profileCollectionRoute => 'Collection route';

  @override
  String get profileCollectionDay => 'Collection day';

  @override
  String get profileStreet => 'Street';

  @override
  String get profileTownDistrict => 'Town & district';

  @override
  String get profileCreditHistory => 'Credit history';

  @override
  String get profileFirstLoan =>
      'First loan for this borrower. There is no repayment history yet.';

  @override
  String profileOnTimeAcross(int percent, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total loans',
      one: '1 loan',
    );
    return '$percent% repaid on time across $_temp0';
  }

  @override
  String get profileReferralNetwork => 'Referral network';

  @override
  String get profileReferredBy => 'Referred by';

  @override
  String get profileSource => 'Source';

  @override
  String get profileDirectWalkIn => 'Direct walk-in';

  @override
  String get profileReferred => 'REFERRED';

  @override
  String get profileActive => 'ACTIVE';

  @override
  String get profilePaired => 'PAIRED';

  @override
  String get disburseReady => 'READY FOR DISBURSAL';

  @override
  String get disburseCheckTerms => 'CHECK TERMS';

  @override
  String get disburseSanctioned => 'Sanctioned Principal';

  @override
  String disburseUpfrontFeePct(String percent) {
    return 'Upfront Fee ($percent)';
  }

  @override
  String get disburseNetCash => 'NET CASH HANDOVER';

  @override
  String get disburseImmediate => 'Immediate physical disbursal';

  @override
  String get disburseTotalRepayable => 'TOTAL REPAYABLE';

  @override
  String disburseWeeksShort(int weeks) {
    return '$weeks wks';
  }

  @override
  String get disburseWeeklyCadence => 'WEEKLY CADENCE';

  @override
  String get disbursePayoutMode => 'Payout Mode';

  @override
  String get disburseSelectChannel => 'Select 1 channel';

  @override
  String get disburseCashInHand => 'Cash in hand';

  @override
  String disburseCashSubtitle(String amount) {
    return 'Agent hands over $amount in currency notes from the collection pouch.';
  }

  @override
  String get disburseFieldStandard => 'FIELD STANDARD';

  @override
  String get disburseBankTitle => 'Instant UPI / IMPS Bank Transfer';

  @override
  String get disburseBankAvailable =>
      'Disburse to the verified account on file.';

  @override
  String get disburseBankUnavailable =>
      'No verified bank account on file for this borrower.';

  @override
  String get disburseModeCash => 'Cash';

  @override
  String get disburseModeBank => 'Bank transfer';

  @override
  String get disburseNetPhysical => 'NET PHYSICAL HANDOVER';

  @override
  String disburseIssueButton(String amount) {
    return 'ISSUE LOAN & DISBURSE $amount';
  }

  @override
  String get disburseRecorded => 'Disbursal is recorded to the field ledger';

  @override
  String termsUsingDefaults(String fee, String interest, String months) {
    return 'Using your saved defaults ($fee fee, $interest interest, $months months)';
  }

  @override
  String get termsChangedDefaults => 'You changed the saved defaults';

  @override
  String get commonReset => 'Reset';

  @override
  String get termsPrincipal => 'Sanctioned principal amount';

  @override
  String get termsRepaymentMonths => 'Repayment term (months)';

  @override
  String get termsWeeklyMeetings => 'Weekly center meetings';

  @override
  String termsCalculatedWeeks(int weeks) {
    return 'Calculated: $weeks Weeks (4 wks / month cadence)';
  }

  @override
  String get termsAutoComputed => 'Auto-computed';

  @override
  String termsMonthChip(String months, int weeks) {
    return '$months Mo ($weeks Wks)';
  }

  @override
  String get termsUpfrontFeeLower => 'Upfront fee';

  @override
  String get termsProcessingRisk => 'Processing & risk cover';

  @override
  String get termsFlatOnPrincipal => 'Flat on principal, once';

  @override
  String termsDisbursedToday(String date) {
    return 'Disbursed: Today, $date';
  }

  @override
  String termsFirstDue(String date) {
    return '1st Due: $date';
  }

  @override
  String get termsBreakdown => 'Disbursement Breakdown';

  @override
  String get termsGrossPrincipal => 'Gross Sanctioned Principal';

  @override
  String termsProcessingRiskPct(String percent) {
    return 'Processing & Risk Cover ($percent)';
  }

  @override
  String get termsPhysicalDisbursement => 'PHYSICAL DISBURSEMENT';

  @override
  String termsFlatInterestAdded(String percent) {
    return 'Flat Interest Added ($percent)';
  }

  @override
  String get termsTotalRepayablePI => 'Total Repayable (Principal + Int)';

  @override
  String termsWeeklyInstallmentWeeks(int weeks) {
    return 'Weekly Installment ($weeks Weeks)';
  }

  @override
  String get termsWeeklyCollection => 'Weekly collection';

  @override
  String termsEveryDayCollection(String day) {
    return 'Every $day collection';
  }

  @override
  String get termsPerWeekShort => ' / wk';

  @override
  String get termsMilestonePreview => 'Schedule milestone preview';

  @override
  String termsTotalWeeks(int weeks) {
    return '$weeks Total Weeks';
  }

  @override
  String get termsHideAmortization => 'Hide amortization';

  @override
  String termsViewAmortization(int weeks) {
    return 'View detailed $weeks-week amortization';
  }

  @override
  String get termsPreviewOnly =>
      'Preview only. The final schedule is calculated when the loan is issued.';

  @override
  String termsWeekDate(int week, String date) {
    return 'Wk #$week ($date)';
  }

  @override
  String get termsFinalSettlement => 'Final Settlement';

  @override
  String get termsColWeek => 'WEEK';

  @override
  String get termsColDue => 'DUE';

  @override
  String get termsColInstallment => 'INSTALLMENT';

  @override
  String get termsColBalance => 'BALANCE';

  @override
  String termsDayRoute(String day) {
    return ' • $day Route';
  }

  @override
  String get commonDecrease => 'Decrease';

  @override
  String get commonIncrease => 'Increase';

  @override
  String get loanStageActive => 'ACTIVE';

  @override
  String get loanStagePaidOff => 'PAID OFF';

  @override
  String get loanStageDefaulted => 'DEFAULTED';

  @override
  String get loanStageUnknown => 'UNKNOWN';

  @override
  String get loanReopenBlockedOther =>
      'This borrower already has another active or overdue loan.';

  @override
  String get loanReopenCheckFailed =>
      'Could not check the borrower’s other loans. Refresh and try again.';

  @override
  String get loanStatusUpdated => 'Loan status updated.';

  @override
  String get loanPaymentRecorded => 'Payment recorded.';

  @override
  String loanTitleId(String id) {
    return 'Loan $id';
  }

  @override
  String get loanMenuTracks => 'Repayment tracks';

  @override
  String get loanMenuPayments => 'Payment history';

  @override
  String get loanMenuCall => 'Call borrower';

  @override
  String get loanMenuChangeStatus => 'Change status';

  @override
  String get loanLoadFailed => 'Could not load this loan.';

  @override
  String get loanRepaymentSchedule => 'Repayment schedule';

  @override
  String loanViewAllWeeks(int count) {
    return 'View all $count weeks';
  }

  @override
  String loanMoreOverdueWeeks(int count) {
    return '$count more overdue weeks';
  }

  @override
  String loanCollectOverdue(String amount) {
    return 'Collect overdue • $amount';
  }

  @override
  String get loanRecordPayment => 'Record payment';

  @override
  String get loanIssueNew => 'Issue new loan';

  @override
  String get loanViewPaymentHistory => 'View payment history';

  @override
  String get loanPayments => 'Payments';

  @override
  String get loanLoadDetailsFailed => 'Could not load the loan details.';

  @override
  String get loanTotalCollected => 'TOTAL COLLECTED';

  @override
  String get loanOutstanding => 'OUTSTANDING';

  @override
  String loanTarget(String amount) {
    return 'Target: $amount';
  }

  @override
  String loanPercentCleared(int percent) {
    return '$percent% Cleared';
  }

  @override
  String get loanTotalPaid => 'TOTAL PAID';

  @override
  String get loanCoverage => 'COVERAGE';

  @override
  String loanWeeksCount(int weeks) {
    return '$weeks Weeks';
  }

  @override
  String get loanLastLog => 'LAST LOG';

  @override
  String get loanNoPayments => 'No payments found';

  @override
  String get loanLoadingOlder => 'Loading older payments...';

  @override
  String get loanNoMorePayments => 'No more payments';

  @override
  String get trackerPaymentSuccess => 'Payment Successfull';

  @override
  String get trackerOnlyOpenLoans =>
      'Only active or overdue loans take payments.';

  @override
  String get trackerAllWeeksHavePayment =>
      'Every week already has a payment. Use Collect on a partial week.';

  @override
  String get trackerRecordWeekly => '+ Record Weekly Payment';

  @override
  String trackerCycle(int cycle) {
    return 'CYCLE $cycle';
  }

  @override
  String get trackerActiveLoan => 'Active Loan';

  @override
  String get trackerWeeklyTarget => 'Weekly Target';

  @override
  String get trackerPrincipal => 'Principal';

  @override
  String get trackerTotalDue => 'Total Due';

  @override
  String get trackerTenure => 'Tenure';

  @override
  String get trackerCollected => 'COLLECTED';

  @override
  String trackerWeeksLeft(int weeks) {
    return '$weeks weeks left';
  }

  @override
  String get trackerNextDue => 'NEXT DUE';

  @override
  String get trackerAllPaid => 'ALL PAID';

  @override
  String get trackerLoanCompleted => 'Loan completed';

  @override
  String trackerWeekShortDate(int week, String date) {
    return 'W$week • $date';
  }

  @override
  String trackerDaysLate(int week, int days) {
    return 'W$week • ${days}d late';
  }

  @override
  String get trackerDueToday => 'DUE TODAY';

  @override
  String get trackerDueTomorrow => 'DUE TOMORROW';

  @override
  String get trackerWeeklyTracks => 'Weekly Repayment Tracks';

  @override
  String trackerInstallmentsPlanned(int count) {
    return '$count Total Installments Planned';
  }

  @override
  String get trackerLedger => 'Ledger';

  @override
  String get loansFilterAll => 'All';

  @override
  String get loansFilterActive => 'Active';

  @override
  String get loansFilterOverdue => 'Overdue';

  @override
  String get loansFilterPaidOff => 'Paid off';

  @override
  String get loansFilterDefaulted => 'Defaulted';

  @override
  String get loansFilterClosed => 'Closed';

  @override
  String get loansSearchHint => 'Search loan by name and phone number...';

  @override
  String get loansNoneFound => 'No loans found';

  @override
  String get loansNoMore => 'No more loans';

  @override
  String loansCallPhone(String phone) {
    return 'call $phone';
  }

  @override
  String get loansSettled => 'Settled';

  @override
  String loansPerWeek(String amount) {
    return '$amount/wk';
  }

  @override
  String get loansTotalPayable => 'Total Payable';

  @override
  String get loansCollected => 'Collected';

  @override
  String get loansRemaining => 'Remaining';

  @override
  String loansDisbursed(String amount) {
    return 'Disbursed: $amount';
  }

  @override
  String get loansViewLedger => 'View Ledger';

  @override
  String get statusFooterClosed => 'This cannot be undone.';

  @override
  String get statusFooterDefaulted => 'An admin can reopen it later if needed.';

  @override
  String get statusFooterReopen =>
      'You can mark it defaulted or closed again later.';

  @override
  String statusReopenMessage(String who, String amount, String footer) {
    return '$who\n\n$amount becomes collectable again. If a week is already past due, the loan shows as overdue automatically.\n\n$footer';
  }

  @override
  String statusWriteOffLine(String amount) {
    return '$amount is still unpaid and will be written off.\n\n';
  }

  @override
  String get statusReopenTitle => 'Reopen this loan?';

  @override
  String statusMarkAsTitle(String status) {
    return 'Mark loan as $status?';
  }

  @override
  String get statusReopenLoan => 'Reopen loan';

  @override
  String statusMarkAs(String status) {
    return 'Mark $status';
  }

  @override
  String get statusGoBack => 'Go back';

  @override
  String get statusNoServerAnswer =>
      'No answer from the server. Refresh the loan before trying again, in case the status was already changed.';

  @override
  String get statusSheetTitle => 'Change loan status';

  @override
  String get statusAutoNote =>
      'Overdue and Paid off are set automatically from payments, so they cannot be chosen here.';

  @override
  String get statusClosedCannotChange =>
      'This loan is closed and cannot be changed.';

  @override
  String get statusNoPermission =>
      'You do not have permission to change this loan’s status.';

  @override
  String get statusMoveTo => 'MOVE TO';

  @override
  String get statusReopenWarning =>
      'Collections resume on this loan. If a week is already past due, it will show as overdue automatically.';

  @override
  String statusDefaultWarning(String amount) {
    return '$amount is still unpaid. Marking the loan as defaulted writes it off.';
  }

  @override
  String statusCloseWarning(String amount) {
    return '$amount is still unpaid. Closing the loan writes it off.';
  }

  @override
  String get statusUpdate => 'Update status';

  @override
  String get statusCurrentStatus => 'CURRENT STATUS';

  @override
  String get statusCurrent => 'CURRENT';

  @override
  String bannerOverdueTitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'Overdue • $_temp0 late';
  }

  @override
  String bannerOverdueBody(String amount, int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks',
      one: '1 week',
    );
    return '$amount across $_temp0 is past due.';
  }

  @override
  String bannerTermEnded(int weeks) {
    return ' The $weeks-week term has ended.';
  }

  @override
  String get bannerFullyRepaid => 'Fully repaid';

  @override
  String bannerPaidOffBody(int weeks, String amount) {
    return 'All $weeks weekly installments are collected. $amount received in total.';
  }

  @override
  String get bannerLoanClosed => 'Loan closed';

  @override
  String bannerClosedOn(String date) {
    return 'Closed on $date.';
  }

  @override
  String bannerLeftUnpaid(String amount) {
    return '$amount was left unpaid.';
  }

  @override
  String get bannerThisLoanClosed => 'This loan is closed.';

  @override
  String get bannerMarkedDefaulted => 'Marked as defaulted';

  @override
  String bannerStillOutstanding(String amount) {
    return '$amount is still outstanding.';
  }

  @override
  String sectionDayRoute(String day) {
    return '$day route';
  }

  @override
  String balanceWeeksPastDue(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks weeks',
      one: '1 week',
    );
    return '$_temp0 past due';
  }

  @override
  String get balanceNextInstallment => 'NEXT INSTALLMENT';

  @override
  String get balanceNothingScheduled => 'Nothing scheduled';

  @override
  String get balanceSettled => 'SETTLED';

  @override
  String get balanceNoBalance => 'No balance left';

  @override
  String get balanceUnpaidAtClose => 'UNPAID AT CLOSE';

  @override
  String get balanceRepaymentProgress => 'Loan repayment progress';

  @override
  String balanceRepaidPercent(String percent) {
    return '$percent% repaid';
  }

  @override
  String balanceWeeksPaid(int paid, int total) {
    return '$paid of $total weeks paid';
  }

  @override
  String get recentNoPayments => 'No payments recorded yet.';

  @override
  String get recentPayments => 'Recent payments';

  @override
  String get commonViewAll => 'View all';

  @override
  String get contractPrincipal => 'Sanctioned principal';

  @override
  String contractUpfrontFee(String percent) {
    return 'Upfront fee ($percent%)';
  }

  @override
  String get contractNetDisbursed => 'Net disbursed';

  @override
  String get contractFlatInterest => 'Flat interest';

  @override
  String get contractTotalRepayable => 'Total repayable';

  @override
  String get contractWeeklyInstallment => 'Weekly installment';

  @override
  String get contractTerm => 'Term';

  @override
  String contractTermValue(int weeks, String months) {
    return '$weeks weeks ($months months)';
  }

  @override
  String get contractDisbursedOn => 'Disbursed on';

  @override
  String get contractMaturesOn => 'Matures on';

  @override
  String get contractClosedOn => 'Closed on';

  @override
  String get contractDetails => 'Contract details';

  @override
  String get borrowersTotal => 'Total';

  @override
  String get borrowersActive => 'Active';

  @override
  String get borrowersDues => 'dues';

  @override
  String get borrowersReferrals => 'Referrals';

  @override
  String get borrowersNet => 'net';

  @override
  String get borrowersActiveLoan => 'Active Loan';

  @override
  String get borrowersOverdueLoan => 'Overdue Loan';

  @override
  String get borrowersNoActiveLoans => 'No Active Loans';

  @override
  String get borrowersCollectPayment => 'Collect payment';

  @override
  String get tracksNoneFound => 'No tracks found';

  @override
  String get tracksTitle => 'Repayment Tracks';

  @override
  String tracksWeeksShort(int weeks) {
    return '$weeks Wks';
  }

  @override
  String tracksSubtitle(String name, String id) {
    return '$name • Active Facility $id';
  }

  @override
  String get tracksCompleted => 'COMPLETED';

  @override
  String tracksPaidCount(int count) {
    return '$count Paid';
  }

  @override
  String tracksTrackCount(int count) {
    return '$count Track';
  }

  @override
  String get tracksFacilityBal => 'FACILITY BAL';

  @override
  String get rangeToday => 'Today';

  @override
  String get rangeLast7 => 'Last 7 days';

  @override
  String get rangeLast30 => 'Last 30 days';

  @override
  String get rangeLast90 => 'Last 90 days';

  @override
  String get rangeThisMonth => 'This month';

  @override
  String get rangeLastMonth => 'Last month';

  @override
  String get rangeCustom => 'Custom';

  @override
  String get agoJustNow => 'just now';

  @override
  String agoMinutes(int m) {
    return '$m min ago';
  }

  @override
  String agoHours(int h) {
    return '$h h ago';
  }

  @override
  String agoDays(int d) {
    return '$d d ago';
  }

  @override
  String get offlineNoData => 'You are offline.';

  @override
  String offlineShowingFrom(String ago) {
    return 'You are offline. Showing numbers from $ago.';
  }

  @override
  String updatedPullRefresh(String ago) {
    return 'Updated $ago. Pull down to refresh.';
  }

  @override
  String get pullToRefresh => 'Pull down to refresh.';

  @override
  String get anTabPulse => 'Pulse';

  @override
  String get anTabCollections => 'Collections';

  @override
  String get anTabPortfolio => 'Portfolio';

  @override
  String get anTabCustomers => 'Customers';

  @override
  String get anTabTeam => 'Team';

  @override
  String get anTabForecast => 'Forecast';

  @override
  String get anTabAdmins => 'Admins';

  @override
  String get anTabMoney => 'Money';

  @override
  String get anTabRisk => 'Risk';

  @override
  String get anTabGeography => 'Geography';

  @override
  String get anTabPeople => 'People';

  @override
  String get anNoAccess => 'You don\'t have access to this view.';

  @override
  String get anSegAnalytics => 'Analytics';

  @override
  String get anSegPlatform => 'Platform';

  @override
  String get dueListTitle => 'Due list';

  @override
  String dueNoneScheduled(String day) {
    return 'No loans are scheduled for $day.';
  }

  @override
  String dueNoMatch(String query) {
    return 'No loans match \"$query\".';
  }

  @override
  String get dueCollectedVsTarget => 'Collected against target for the day';

  @override
  String dueCollectedOfTarget(String collected, String target) {
    return '$collected collected of $target target';
  }

  @override
  String dueScheduledFor(String day) {
    return 'Loans scheduled for $day';
  }

  @override
  String dueSummaryLine(int customers, int active, int overdue) {
    return '$customers customers • $active active • $overdue overdue';
  }

  @override
  String dueListNote(String day) {
    return 'The list shows loans scheduled for $day as they stand now, not who paid on this date.';
  }

  @override
  String get commonUnknown => 'Unknown';

  @override
  String dueOutstanding(String amount) {
    return 'Outstanding $amount';
  }

  @override
  String get dueLabel => 'due';

  @override
  String get dueOnSchedule => 'ON SCHEDULE';

  @override
  String anViewing(String name) {
    return 'Viewing: $name';
  }

  @override
  String get commonClear => 'Clear';

  @override
  String get anAllAdmins => 'All admins';

  @override
  String get anAllEmployees => 'All employees';

  @override
  String anMaxRange(int days) {
    return 'Pick a range of at most $days days.';
  }

  @override
  String get anDateRange => 'Date range';

  @override
  String get commonApply => 'Apply';

  @override
  String get anChooseAdmin => 'Choose an admin';

  @override
  String get anChooseEmployee => 'Choose an employee';

  @override
  String get commonSearch => 'Search';

  @override
  String get anNobodyMatches => 'Nobody matches.';

  @override
  String get anTakingLonger => 'Taking longer than usual.';

  @override
  String get anCardLoadFailed => 'Could not load this card.';

  @override
  String anDeltaPts(String value) {
    return '$value pts';
  }

  @override
  String get anNoChange => 'No change';

  @override
  String anDeltaNew(String value) {
    return '$value (new)';
  }

  @override
  String get commonLoading => 'Loading...';

  @override
  String anShowMore(int left) {
    return 'Show more ($left left)';
  }

  @override
  String get dayMonAbbr => 'Mon';

  @override
  String get dayTueAbbr => 'Tue';

  @override
  String get dayWedAbbr => 'Wed';

  @override
  String get dayThuAbbr => 'Thu';

  @override
  String get dayFriAbbr => 'Fri';

  @override
  String get daySatAbbr => 'Sat';

  @override
  String get daySunAbbr => 'Sun';

  @override
  String get anInsights => 'Insights';

  @override
  String get anInsightsEmpty =>
      'Insights appear once your customers have loans.';

  @override
  String get anShowLess => 'Show less';

  @override
  String anSeeAll(int count) {
    return 'See all $count';
  }

  @override
  String get anCollectionsVsTarget => 'Collections vs target';

  @override
  String get anGroupDayShort => 'D';

  @override
  String get anGroupWeekShort => 'W';

  @override
  String get anGroupMonthShort => 'M';

  @override
  String get anNoCollectionsPeriod =>
      'No collections in this period. Try a longer range.';

  @override
  String anTrendSemantics(String amount) {
    return 'Collections trend, total $amount';
  }

  @override
  String anBestDay(String label, String amount) {
    return 'Best day: $label $amount';
  }

  @override
  String anBestWeek(String label, String amount) {
    return 'Best week: $label $amount';
  }

  @override
  String anBestMonth(String label, String amount) {
    return 'Best month: $label $amount';
  }

  @override
  String anOfTarget(String amount) {
    return ' of $amount';
  }

  @override
  String get anOutstandingByAge => 'Outstanding by age';

  @override
  String get anNothingOutstanding => 'Nothing outstanding right now.';

  @override
  String anAgingSemantics(String amount) {
    return 'Aging, total outstanding $amount';
  }

  @override
  String anLoansAmount(int count, String amount) {
    return '$count loans • $amount';
  }

  @override
  String get anPortfolioHealth => 'Portfolio health';

  @override
  String get anNoLoansYet => 'No loans yet.';

  @override
  String anStatusSemantics(int total) {
    return 'Loan status, $total loans';
  }

  @override
  String get anLoansWord => 'loans';

  @override
  String get anCollectionCalendar => 'Collection calendar';

  @override
  String get anPrevMonth => 'Previous month';

  @override
  String get anNextMonth => 'Next month';

  @override
  String anCollectedOf(String collected, String target) {
    return '$collected of $target';
  }

  @override
  String anTargetAmount(String amount) {
    return 'Target $amount';
  }

  @override
  String anPaidAmount(String amount) {
    return 'Paid $amount';
  }

  @override
  String get anOpenDueList => 'Open due list';

  @override
  String get anTapDay => 'Tap a day for its target and collection.';

  @override
  String get anDayUpcoming => 'upcoming';

  @override
  String get anDayNothingDue => 'nothing due';

  @override
  String get anByWeekday => 'By weekday';

  @override
  String get anWeekdaySemantics => 'Target against collected for each weekday';

  @override
  String get anTarget => 'Target';

  @override
  String get anCollected => 'Collected';

  @override
  String get anCustomersUnderDay => 'Customers under each day';

  @override
  String get anRepaymentByMonth => 'Repayment by issue month';

  @override
  String get anRepaid => 'Repaid';

  @override
  String get anOnTrack => 'On track';

  @override
  String get anCohortsEmpty =>
      'Cohorts appear once loans have been issued for a few weeks.';

  @override
  String get anCohortSemantics => 'Repayment curves for each issue month';

  @override
  String get anWeeksSinceIssue => 'Weeks since issue';

  @override
  String anWeekPercent(int week, String percent) {
    return 'Week $week: $percent%';
  }

  @override
  String anCohortSummary(String month, int loans, String amount) {
    return '$month: $loans loans • $amount';
  }

  @override
  String anPercentDefaulted(String percent) {
    return ' • $percent% defaulted';
  }

  @override
  String get anCohortTooEarly => 'Too early to read this cohort.';

  @override
  String anCohortRepaid(String month, String percent, int weeks) {
    return 'Loans issued in $month have repaid $percent% of what they owe after $weeks weeks';
  }

  @override
  String anCohortOnTrack(String percent) {
    return '; the schedule says $percent%, so they are on track.';
  }

  @override
  String anCohortBehind(String percent) {
    return '; the schedule says $percent%, so they are behind.';
  }

  @override
  String get anNoDataPeriod => 'No data in this period. Try a longer range.';

  @override
  String anAdminN(int n) {
    return 'Admin $n';
  }

  @override
  String get anOthers => 'Others';

  @override
  String anComparedPrevious(int days) {
    return 'Compared with the previous $days days';
  }

  @override
  String get anLoansRightNow => 'loans right now';

  @override
  String anPar(String percent) {
    return 'PAR $percent%';
  }

  @override
  String get anToday => 'TODAY';

  @override
  String get anThisWeek => 'THIS WEEK';

  @override
  String get anThisMonth => 'THIS MONTH';

  @override
  String get anPaymentBehaviour => 'Payment behaviour';

  @override
  String get anNoPaymentsPeriod =>
      'No payments in this period. Try a longer range.';

  @override
  String get anOnTimeUpper => 'ON TIME';

  @override
  String get anLate => 'LATE';

  @override
  String get anAvgDaysLate => 'AVG DAYS LATE';

  @override
  String get anWorst => 'WORST';

  @override
  String anDaysShort(int days) {
    return '${days}d';
  }

  @override
  String anWeeklyInstalmentsDue(int count) {
    return 'Weekly instalments ($count due)';
  }

  @override
  String anPaidPct(String percent) {
    return 'Paid $percent%';
  }

  @override
  String anPartialPct(String percent) {
    return 'Partial $percent%';
  }

  @override
  String anUnpaidPct(String percent) {
    return 'Unpaid $percent%';
  }

  @override
  String anOverpaidPct(String percent) {
    return 'Overpaid $percent%';
  }

  @override
  String get anDisbursements => 'Disbursements';

  @override
  String anLoansCount(int count) {
    return '$count loans';
  }

  @override
  String get anDisbursed => 'Disbursed';

  @override
  String get anEarnings => 'Earnings';

  @override
  String get anTotal => 'TOTAL';

  @override
  String get anFeesUpper => 'FEES';

  @override
  String get anInterestUpper => 'INTEREST';

  @override
  String get anExpected => 'EXPECTED';

  @override
  String get anFees => 'Fees';

  @override
  String get anInterest => 'Interest';

  @override
  String get anInterestEarned => 'Interest earned';

  @override
  String get anPlatformEarnings => 'Platform earnings';

  @override
  String anMaturingIn(int days) {
    return 'Maturing in $days days';
  }

  @override
  String anNoneMaturing(int days) {
    return 'No loans mature in the next $days days.';
  }

  @override
  String anWeeklyAmount(String amount) {
    return 'Weekly $amount';
  }

  @override
  String anDaysLeft(int days) {
    return '${days}d left';
  }

  @override
  String get anCustomersAtRisk => 'Customers at risk';

  @override
  String get anNoneAtRisk => 'No customers at risk right now.';

  @override
  String anRiskLine(int days, int weeks) {
    return '$days days late • $weeks missed weeks';
  }

  @override
  String get anReferrerAtRisk => ' • referrer at risk';

  @override
  String anRiskScore(String score) {
    return 'Risk $score';
  }

  @override
  String get anRepeatBorrowers => 'Repeat borrowers';

  @override
  String get anRepeatRate => 'REPEAT RATE';

  @override
  String get anRetention => 'RETENTION';

  @override
  String get anAvgLoans => 'AVG LOANS';

  @override
  String anLoanCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count loans',
      one: '1 loan',
    );
    return '$_temp0';
  }

  @override
  String get anCustomers => 'Customers';

  @override
  String get anTopReferrers => 'Top referrers';

  @override
  String get anNoReferrals => 'No referrals yet.';

  @override
  String anConverted(String percent) {
    return '$percent% converted';
  }

  @override
  String anReferredConverted(int referred, int converted) {
    return 'Referred $referred • converted $converted';
  }

  @override
  String anAtRiskCount(int count) {
    return ' • $count at risk';
  }

  @override
  String get anGeography => 'Geography';

  @override
  String get anOutstandingByArea => 'Outstanding by area';

  @override
  String get anDistrict => 'District';

  @override
  String get anCity => 'City';

  @override
  String get anNoBorrowersScope => 'No borrowers in this scope yet.';

  @override
  String anBorrowersPar(int count, String percent) {
    return '$count borrowers • PAR $percent%';
  }

  @override
  String get anEmployeeLeaderboard => 'Employee leaderboard';

  @override
  String get anTeamLeaderboard => 'Team leaderboard';

  @override
  String get anNoEmployees => 'No employees to show yet.';

  @override
  String anParOverdue(String percent, int overdue) {
    return 'PAR $percent% • $overdue overdue';
  }

  @override
  String get anEmployee => 'Employee';

  @override
  String get anPAR => 'PAR';

  @override
  String get anNoRisky => 'No risky customers.';

  @override
  String get anCashflowForecast => 'Cash-flow forecast';

  @override
  String anExpectedNextWeeks(int weeks) {
    return 'Expected next $weeks weeks';
  }

  @override
  String anPlusArrears(String amount) {
    return 'Plus $amount overdue and due now';
  }

  @override
  String get anDue => 'Due';

  @override
  String get anCurrentWeekHighlighted => ' The current week is highlighted.';

  @override
  String get anPlatformAtGlance => 'Platform at a glance';

  @override
  String get anCollectedMonth => 'COLLECTED (MONTH)';

  @override
  String get anAdminsUpper => 'ADMINS';

  @override
  String get anEmployeesUpper => 'EMPLOYEES';

  @override
  String get anEarned => 'EARNED';

  @override
  String get anNoAdmins => 'No admins yet.';

  @override
  String anAdminRowLine(int employees, String percent, int overdue) {
    return '$employees employees • PAR $percent% • $overdue overdue';
  }

  @override
  String get anDisbursedByAdmin => 'Disbursed by admin';

  @override
  String get anDisbursedByAdminMonthly => 'Disbursed by admin (monthly)';

  @override
  String get anSplitByAdmin => 'Split by admin';

  @override
  String get anPlatformCollections => 'Platform collections';

  @override
  String get anAccounts => 'Accounts';

  @override
  String anActiveInactive(String active, String inactive) {
    return '$active active • $inactive inactive';
  }

  @override
  String anPendingCount(String count) {
    return '$count pending';
  }

  @override
  String get anEmployeesPerAdmin => 'EMPLOYEES PER ADMIN';

  @override
  String get anPlatformOutstandingByAge => 'Platform outstanding by age';

  @override
  String get anRiskConcentration => 'Risk concentration';

  @override
  String get anOutstandingByAdmin => 'Outstanding by admin';

  @override
  String anShareOfBook(String percent) {
    return '$percent% of book';
  }

  @override
  String get anLargestExposures => 'Largest exposures';

  @override
  String get anNoExposures => 'No exposures to show.';

  @override
  String anExposureLine(String days, String percent) {
    return '$days days late • $percent% of book';
  }

  @override
  String get repAdvancedSemantics =>
      'Advanced analytics. Trends, cohorts and team performance.';

  @override
  String get repAdvancedSub => 'Trends, cohorts and team performance';

  @override
  String get repAsOfToday => 'As of today';

  @override
  String get repCashOutstanding => 'Cash outstanding';

  @override
  String get repNoLoansInBook => 'No loans in the book yet.';

  @override
  String repOutstandingSemantics(String amount, int percent) {
    return 'Outstanding receivable $amount, $percent percent of the payable amount collected';
  }

  @override
  String get repOutstandingReceivable => 'Outstanding receivable';

  @override
  String repPayableCollected(int percent) {
    return '$percent% of payable collected';
  }

  @override
  String get repDisbursed => 'Disbursed';

  @override
  String get repPayable => 'Payable';

  @override
  String get repCollected => 'Collected';

  @override
  String repLoansInBook(int count) {
    return '$count loans in the book';
  }

  @override
  String get repEarningsEmpty => 'Earnings appear once loans are issued.';

  @override
  String repTotalEarnedSemantics(String amount) {
    return 'Total earned $amount';
  }

  @override
  String get repTotalEarned => 'Total earned';

  @override
  String get repExpectedInterest => 'Expected interest';

  @override
  String get repInterestNote =>
      'Interest counts only what was collected above the principal, so it trails the expected figure until loans are repaid.';

  @override
  String repOverdueSemantics(String name, String amount, int days) {
    return '$name, $amount outstanding, $days days late';
  }

  @override
  String repAmountOutstanding(String amount) {
    return '$amount outstanding';
  }

  @override
  String get repOverdueLoans => 'Overdue loans';

  @override
  String get repNoOverdue => 'No overdue loans. Everything is on schedule.';

  @override
  String get repSeeAll => 'See all';

  @override
  String get repNoOverdueShort => 'No overdue loans.';

  @override
  String get auditNoAccess => 'You don\'t have access to the audit log.';

  @override
  String get auditEntry => 'Audit entry';

  @override
  String get auditRecordGone => 'This record is no longer available.';

  @override
  String get auditLoadEntryFailed => 'Could not load this entry.';

  @override
  String get auditLogIdCopied => 'Log id copied';

  @override
  String get auditAttention => 'Attention';

  @override
  String get auditWho => 'Who';

  @override
  String get auditOn => 'On';

  @override
  String get auditOpen => 'Open';

  @override
  String get auditMoreFromActor => 'More from this actor';

  @override
  String get auditMoreOnRecord => 'More on this record';

  @override
  String get auditChanges => 'Changes';

  @override
  String get auditRawJson => 'Raw JSON';

  @override
  String get commonCopy => 'Copy';

  @override
  String get auditJsonCopied => 'JSON copied';

  @override
  String get auditCreatedWith => 'Created with';

  @override
  String auditChangesCount(int count) {
    return 'Changes ($count)';
  }

  @override
  String get auditDetails => 'Details';

  @override
  String get auditNoFieldChanges =>
      'No field changes were recorded for this entry.';

  @override
  String get auditRequestDetails => 'Request details';

  @override
  String get auditIp => 'IP';

  @override
  String get auditDevice => 'Device';

  @override
  String get auditRequest => 'Request';

  @override
  String get auditLogId => 'Log id';

  @override
  String get auditTeam => 'Team';

  @override
  String auditFiltersApplied(int count) {
    return '$count filters applied';
  }

  @override
  String get auditFilters => 'Filters';

  @override
  String get auditAllTeams => 'All teams';

  @override
  String auditAbout(String name) {
    return 'About: $name';
  }

  @override
  String get auditThisUser => 'this user';

  @override
  String auditBy(String name) {
    return 'By: $name';
  }

  @override
  String get auditThisPerson => 'this person';

  @override
  String get auditClearAll => 'Clear all';

  @override
  String get auditNothingMatches => 'Nothing matches these filters';

  @override
  String get auditNoActivity => 'No activity yet';

  @override
  String get auditTryWider => 'Try a wider date range or fewer filters.';

  @override
  String get auditChangesAppear => 'Changes made in the app will appear here.';

  @override
  String get auditClearFilters => 'Clear filters';

  @override
  String auditEntriesCount(int shown, int total) {
    return '$shown of $total entries';
  }

  @override
  String get auditWhoDidIt => 'Who did it';

  @override
  String get auditWhoAffected => 'Who it affected';

  @override
  String get auditAnyone => 'Anyone';

  @override
  String get auditModule => 'MODULE';

  @override
  String get auditActions => 'ACTIONS';

  @override
  String get auditNoActionsScope =>
      'No actions have been recorded in your scope yet.';

  @override
  String get auditSelected => 'Selected';

  @override
  String get auditApplyFilters => 'Apply filters';

  @override
  String auditMe(String name) {
    return '$name (me)';
  }

  @override
  String get auditAll => 'All';

  @override
  String auditModuleSemantics(String label) {
    return '$label module';
  }

  @override
  String get auditNeedsAttention => 'Needs attention. ';

  @override
  String get auditBefore => 'Before';

  @override
  String get auditAfter => 'After';

  @override
  String get auditView => 'View';

  @override
  String get auditBeforeUpper => 'BEFORE';

  @override
  String get auditAfterUpper => 'AFTER';

  @override
  String get expCouldNotOpen => 'Could not open the file.';

  @override
  String get expAlreadyInProgress => 'That export is already in progress.';

  @override
  String get expStarted => 'Export started.';

  @override
  String get expNoDownloads =>
      'No downloads yet. Reports you export appear here for 24 hours.';

  @override
  String get expExpired => 'EXPIRED';

  @override
  String get expQueued => 'QUEUED';

  @override
  String get expBuilding => 'BUILDING';

  @override
  String get expReady => 'READY';

  @override
  String get expFailed => 'FAILED';

  @override
  String get expPreparing => 'Preparing...';

  @override
  String expRowsProgress(int done, int total) {
    return '$done of $total rows';
  }

  @override
  String get expOpen => 'Open';

  @override
  String get expShare => 'Share';

  @override
  String expUntil(String time) {
    return 'Until $time';
  }

  @override
  String get expCreateAgain => 'Create again';

  @override
  String get expExport => 'Export';

  @override
  String expDownloadsBuilding(int count) {
    return 'Downloads ($count building)';
  }

  @override
  String get expThisWeek => 'This week';

  @override
  String get expNext7 => 'Next 7 days';

  @override
  String expPickAtMost(int days) {
    return 'Pick at most $days days.';
  }

  @override
  String get expCustomersAddedBy => 'Customers added by';

  @override
  String get expChooseWeekday => 'Choose a weekday.';

  @override
  String get expChooseRange => 'Choose a date range.';

  @override
  String get expStartBeforeEnd =>
      'The start date must be on or before the end date.';

  @override
  String get expNoServerAnswer =>
      'No answer from the server. Open Downloads to see whether it was created, then try again.';

  @override
  String get expScopeSuper => 'Covers every team unless you pick one.';

  @override
  String get expScopeAdmin => 'Covers your team only.';

  @override
  String get expScopeUser => 'Covers only the customers you created.';

  @override
  String get expHintXlsx => 'Best for Excel. Up to 100,000 rows.';

  @override
  String get expHintCsv =>
      'Plain text that opens anywhere. Up to 300,000 rows.';

  @override
  String get expHintPdfWeekday =>
      'One block per customer, ready to print for the route. Up to 1,000 loans.';

  @override
  String get expHintPdfAudit =>
      'For printing. Up to 1,000 rows, and long values are shortened. Use Excel or CSV for full values.';

  @override
  String get expHintPdf => 'For printing. Up to 1,000 rows.';

  @override
  String get expGone => 'This export is no longer available.';

  @override
  String get expStartAgain => 'Start again';

  @override
  String get expFormat => 'Format';

  @override
  String get expWeekday => 'Weekday';

  @override
  String get expPaymentDay => 'Payment day';

  @override
  String get expOptional => 'Optional';

  @override
  String get expAny => 'Any';

  @override
  String expUpToDays(int days) {
    return 'Up to $days days';
  }

  @override
  String get expAllTime => 'All time';

  @override
  String get expIssuedBetween => 'Issued between';

  @override
  String get expAnyDate => 'Any date';

  @override
  String get expPickDates => 'Pick dates';

  @override
  String get expScope => 'Scope';

  @override
  String expAuditNote(String note) {
    return 'Also uses the audit screen filters: $note.';
  }

  @override
  String get expSwitchCsv => 'Switch to CSV';

  @override
  String get expSwitchExcel => 'Switch to Excel';

  @override
  String expCreateFormat(String format) {
    return 'Create $format';
  }

  @override
  String get expWaiting => 'Waiting in line...';

  @override
  String get expBuildingFile => 'Building your file...';

  @override
  String get expCountingRows => 'Counting rows...';

  @override
  String get expAlreadyInProgressSuffix => ' • already in progress';

  @override
  String get expReadyLabel => 'Ready';

  @override
  String get expDownloading => 'Downloading...';

  @override
  String get expBuildFailed => 'Could not build the file';

  @override
  String get expTryAgain => 'Try again';

  @override
  String get expFileExpired => 'This file has expired.';

  @override
  String get expKeptExpired =>
      'Files are kept for 24 hours. Create it again to get a new one.';

  @override
  String get expCanClose =>
      'You can close this. It keeps building and appears in Downloads.';

  @override
  String get expKept24 => 'Files are kept for 24 hours.';

  @override
  String get empWorksUnder => 'Works under';

  @override
  String get empNoActiveAdmins => 'There are no active admins.';

  @override
  String empEmployeesCount(int count) {
    return '$count employees';
  }

  @override
  String get empEnterNumber => 'Enter a number';

  @override
  String empRangeError(String label, String min, String max) {
    return '$label must be $min to $max';
  }

  @override
  String get empOneDecimal => 'One decimal place at most';

  @override
  String get empFee => 'Fee';

  @override
  String get empInterest => 'Interest';

  @override
  String get empTerm => 'Term';

  @override
  String get empNameTooShort => 'Name needs at least 2 characters';

  @override
  String get empNameChars => 'Use letters, spaces and . \' - only';

  @override
  String get empInvalidMobile => 'Enter a valid mobile number';

  @override
  String get empInvalidEmail => 'Enter a valid email';

  @override
  String get empChooseAdmin => 'Choose the admin this employee works under.';

  @override
  String get empFixDefaults => 'Fix the loan defaults first.';

  @override
  String empAdded(String name) {
    return '$name was added. If they cannot sign in yet, approve them under Pending.';
  }

  @override
  String get empNoServerAnswer =>
      'No answer from the server. Check Manage users before trying again, in case the account was already created.';

  @override
  String get empAddEmployee => 'Add employee';

  @override
  String get empDiscardTitle => 'Discard this employee?';

  @override
  String get empDiscardMessage => 'You have details that are not saved.';

  @override
  String get empDiscard => 'Discard';

  @override
  String get empKeepEditing => 'Keep editing';

  @override
  String get empCreate => 'Create employee';

  @override
  String get empAdmin => 'Admin';

  @override
  String get empChooseAnAdmin => 'Choose an admin';

  @override
  String get empAccount => 'Account';

  @override
  String get empFullName => 'Full name';

  @override
  String get empPhoneNumber => 'Phone number';

  @override
  String get empPhoneHelper => 'They sign in with this number.';

  @override
  String get empEmailOptional => 'Email (optional)';

  @override
  String get empPassword => 'Password';

  @override
  String get empGenerate => 'Generate';

  @override
  String get empMin8 => 'Use at least 8 characters';

  @override
  String get empHide => 'Hide';

  @override
  String get empShow => 'Show';

  @override
  String get empPasswordsMismatch => 'Passwords do not match';

  @override
  String get empConfirmPassword => 'Confirm password';

  @override
  String get empSharePassword =>
      'Share this password with them. They can change it later from their profile.';

  @override
  String get empLoanDefaults => 'Loan defaults';

  @override
  String get empCustomise => 'Customise for this employee';

  @override
  String get empOnlyThisEmployee => 'These values are only for this employee.';

  @override
  String empUsesAdminDefaults(
    String admin,
    String fee,
    String interest,
    String months,
  ) {
    return 'Uses $admin defaults: fee $fee%, interest $interest%, $months months. Later changes apply to them too.';
  }

  @override
  String empUsesYourDefaults(String fee, String interest, String months) {
    return 'Uses your defaults: fee $fee%, interest $interest%, $months months. Later changes apply to them too.';
  }

  @override
  String get empTheAdmin => 'the admin';

  @override
  String get empUpfrontFee => 'Upfront fee';

  @override
  String get empMonthsSuffix => 'months';

  @override
  String get empResetInherited => 'Reset to inherited values';

  @override
  String empExample(
    String loan,
    String fee,
    String handed,
    String total,
    String weekly,
    int weeks,
  ) {
    return 'On a $loan loan: fee $fee, $handed handed over, $total repayable, $weekly a week for $weeks weeks.';
  }

  @override
  String manApproved(String name) {
    return '$name approved.';
  }

  @override
  String manApprovedCanSignIn(String name) {
    return '$name approved. They can sign in now.';
  }

  @override
  String manRejectTitle(String name) {
    return 'Reject $name?';
  }

  @override
  String get manRejectMessage =>
      'The account is deactivated and cannot sign in. It is never deleted.';

  @override
  String get manReject => 'Reject';

  @override
  String manRejected(String name) {
    return '$name rejected.';
  }

  @override
  String manDeactivateTitle(String name) {
    return 'Deactivate $name?';
  }

  @override
  String get manDeactivateAdminMsg =>
      'They are signed out once their access token expires. Their employees are not changed.';

  @override
  String get manDeactivateUserMsg =>
      'They are signed out once their access token expires. Their customers and loans stay as they are.';

  @override
  String get manDeactivate => 'Deactivate';

  @override
  String manDeactivated(String name) {
    return '$name deactivated.';
  }

  @override
  String manReactivatedPending(String name) {
    return '$name reactivated. They are waiting for approval again.';
  }

  @override
  String manReactivated(String name) {
    return '$name reactivated.';
  }

  @override
  String get manCountsFailed => 'Could not load the counts.';

  @override
  String get manPending => 'PENDING';

  @override
  String get manAwaitingApproval => 'awaiting approval';

  @override
  String get manTeams => 'TEAMS';

  @override
  String get manApprovedAdmins => 'approved admins';

  @override
  String get manEmployees => 'EMPLOYEES';

  @override
  String get manAcrossAllTeams => 'across all teams';

  @override
  String get manAcrossTeams => 'across teams';

  @override
  String get manActive => 'ACTIVE';

  @override
  String get manCanSignIn => 'can sign in';

  @override
  String get manInactive => 'INACTIVE';

  @override
  String get manDeactivatedLower => 'deactivated';

  @override
  String get manManageAdmins => 'Manage admins';

  @override
  String get manSearchHint => 'Search by name, phone or email';

  @override
  String get manNoAdminsPending => 'No admins are waiting for approval.';

  @override
  String get manNoActiveAdmins => 'No active admins yet.';

  @override
  String get manNoInactiveAdmins => 'No inactive admins.';

  @override
  String get manFilterByAdmin => 'Filter by admin';

  @override
  String get manNoEmployeesPending => 'No employees are waiting for approval.';

  @override
  String get manNoActiveEmployees => 'No active employees yet.';

  @override
  String get manNoInactiveEmployees => 'No inactive employees.';

  @override
  String get accPhone => 'Phone';

  @override
  String get accEmail => 'Email';

  @override
  String get accNotAdded => 'Not added';

  @override
  String get accJoined => 'Joined';

  @override
  String get accLoanDefaultsOwn => 'Loan defaults (own)';

  @override
  String accDefaultsLine(String fee, String interest, String months) {
    return 'Fee $fee% • Interest $interest% • $months months';
  }

  @override
  String accTeamCount(int count) {
    return 'Team ($count)';
  }

  @override
  String accPendingCount(int count) {
    return '$count pending';
  }

  @override
  String get accNoEmployees => 'No employees under this admin yet.';

  @override
  String accCustomersCount(int count) {
    return '$count customers';
  }

  @override
  String get accOpenManageUsers =>
      'Open Manage users to approve or deactivate employees.';

  @override
  String get accActivity => 'Activity';

  @override
  String get accCustomers => 'CUSTOMERS';

  @override
  String get accCreated => 'created';

  @override
  String get accActiveLoans => 'ACTIVE LOANS';

  @override
  String get accActiveAndOverdue => 'active and overdue';

  @override
  String get accViewPerformance => 'View performance';

  @override
  String get manTabPending => 'Pending';

  @override
  String get manTabActive => 'Active';

  @override
  String get manTabInactive => 'Inactive';

  @override
  String get manOwnDefaults => 'Own defaults';

  @override
  String get manAdminDefaults => 'Admin defaults';

  @override
  String manDefaultsShort(String fee, String interest, String months) {
    return 'Fee $fee% • Int $interest% • $months mo';
  }

  @override
  String manJoinedOn(String date) {
    return 'Joined $date';
  }

  @override
  String get manApprove => 'Approve';

  @override
  String get manDetails => 'Details';

  @override
  String get manReactivate => 'Reactivate';

  @override
  String manNobodyMatches(String query) {
    return 'Nobody matches \"$query\".';
  }

  @override
  String get manThatIsEveryone => 'That is everyone';

  @override
  String get profPhoneUpdated => 'Phone number updated.';

  @override
  String get profPasswordChanged => 'Password changed.';

  @override
  String get profSignOutDevice => 'Sign out this device?';

  @override
  String profSignedInOn(String date) {
    return 'Signed in on $date.';
  }

  @override
  String get profSignOut => 'Sign out';

  @override
  String get profSignOutAllTitle => 'Sign out of all devices?';

  @override
  String get profSignOutAllMsg =>
      'This device is signed out too, and you will need to log in again.';

  @override
  String get profSignOutAll => 'Sign out all';

  @override
  String profApproveTitle(String name) {
    return 'Approve $name?';
  }

  @override
  String get profApproveMsg =>
      'They will be able to sign in and manage a team.';

  @override
  String get profRejectMsg =>
      'The account will be deactivated. It is never deleted.';

  @override
  String get profAdminApproved => 'Admin approved.';

  @override
  String get profAdminRejected => 'Admin rejected.';

  @override
  String get profLimitsUpdated => 'Limits updated.';

  @override
  String get profDiscardChanges => 'Discard changes?';

  @override
  String get profUnsavedEdits => 'You have edits that are not saved.';

  @override
  String get profLoadFailed => 'Could not load your profile.';

  @override
  String get profHidePasswords => 'Hide passwords';

  @override
  String get profShowPasswords => 'Show passwords';

  @override
  String get profChangePassword => 'Change password';

  @override
  String get profOtherDevicesSignedOut =>
      'Your other devices will be signed out.';

  @override
  String get profEnterCurrent => 'Enter your current password';

  @override
  String get profCurrentPassword => 'Current password';

  @override
  String get profDifferentPassword => 'Choose a different password';

  @override
  String get profNewPassword => 'New password';

  @override
  String get profConfirmNewPassword => 'Confirm new password';

  @override
  String get profUpdatePassword => 'Update password';

  @override
  String get profSamePhone => 'That is already your phone number';

  @override
  String get profSendCodeFailed => 'Could not send the code. Try again.';

  @override
  String get profEnterCode => 'Enter the 6-digit code';

  @override
  String get profSomethingWrong => 'Something went wrong. Try again.';

  @override
  String get profChangePhone => 'Change phone number';

  @override
  String get profWillSendCode => 'We will send a code to the new number.';

  @override
  String profCodeSentTo(String phone) {
    return 'Code sent to $phone';
  }

  @override
  String get profNewPhone => 'New phone number';

  @override
  String get profSixDigitCode => '6-digit code';

  @override
  String get profSendCode => 'Send code';

  @override
  String get profVerifyUpdate => 'Verify and update';

  @override
  String get profUseAnother => 'Use another number';

  @override
  String profResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get profResendCode => 'Resend code';

  @override
  String get profMinPrincipal => 'Minimum principal (₹)';

  @override
  String get profMaxPrincipal => 'Maximum principal (₹)';

  @override
  String get profMinTerm => 'Minimum term (months)';

  @override
  String get profMaxTerm => 'Maximum term (months)';

  @override
  String get profMaxFee => 'Maximum upfront fee (%)';

  @override
  String get profMaxInterest => 'Maximum interest (%)';

  @override
  String get profMinPrincipalExceeds =>
      'Minimum principal cannot exceed maximum principal';

  @override
  String get profMinTermExceeds => 'Minimum term cannot exceed maximum term';

  @override
  String get profChangeOneLimit => 'Change at least one limit';

  @override
  String get profLoanLimits => 'Loan limits';

  @override
  String get profLimitsNote =>
      'Existing admin defaults are not rewritten. A tighter limit applies the next time defaults are saved.';

  @override
  String get profPositiveNumber => 'Enter a positive number';

  @override
  String profMustBeOrLess(String max) {
    return 'Must be $max or less';
  }

  @override
  String get profSaveLimits => 'Save limits';

  @override
  String get pcAwaitingApproval => 'AWAITING APPROVAL';

  @override
  String get pcVerified => 'VERIFIED';

  @override
  String pcMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get pcProfileUpdated => 'Profile updated.';

  @override
  String get pcContact => 'Contact';

  @override
  String get pcEditNameEmail => 'Edit name and email';

  @override
  String get pcName => 'Name';

  @override
  String get pcMyNumbers => 'My numbers';

  @override
  String get pcMe => 'Me';

  @override
  String get pcMyTeam => 'My team';

  @override
  String get pcEveryone => 'Everyone';

  @override
  String get pcNumbersFailed => 'Could not load the numbers.';

  @override
  String get pcCollectedVsTarget => 'Collected against target';

  @override
  String pcOfTarget(String amount) {
    return 'of $amount target';
  }

  @override
  String get pcCustomersPaid => 'CUSTOMERS PAID';

  @override
  String get pcInThisPeriod => 'in this period';

  @override
  String get pcPaymentsByDue => 'payments by due date';

  @override
  String get pcDefaultsUpdated => 'Loan defaults updated.';

  @override
  String get pcEditDefaults => 'Edit loan defaults';

  @override
  String get pcUpfrontFeeUpper => 'UPFRONT FEE';

  @override
  String get pcOnPrincipal => 'on principal';

  @override
  String get pcInterestUpper => 'INTEREST';

  @override
  String get pcFlatOnce => 'flat, once';

  @override
  String get pcTermUpper => 'TERM';

  @override
  String pcMonthsShort(String months) {
    return '$months mo';
  }

  @override
  String pcWeeks(int weeks) {
    return '$weeks weeks';
  }

  @override
  String get pcSetByAdmin =>
      'Set by your admin. Only new loans use these values.';

  @override
  String get pcAppliesNewOnly =>
      'Applies to new loans only, never existing ones. Employees who inherit these values pick them up at once.';

  @override
  String get pcOnlyAdminsChange =>
      'Only admins can change these. Only new loans use them.';

  @override
  String get pcSecurity => 'Security';

  @override
  String get pcChangeYourPassword => 'Change your password';

  @override
  String get pcSignedInDevices => 'SIGNED-IN DEVICES';

  @override
  String get pcSessionsFailed => 'Could not load your sessions.';

  @override
  String get pcNoSessions => 'No active sessions.';

  @override
  String pcExpires(String date) {
    return 'Expires $date';
  }

  @override
  String get pcDeviceNamesNote =>
      'Device names are not recorded, so the current device is not marked.';

  @override
  String get pcSignOutAllDevices => 'Sign out of all devices';

  @override
  String get pcTeamFailed => 'Could not load the team.';

  @override
  String get pcNoApprovedTeams => 'No approved teams yet.';

  @override
  String pcMembersCount(int count) {
    return '$count members';
  }

  @override
  String pcPendingSuffix(int count) {
    return ' • $count pending';
  }

  @override
  String get pcNoTeamMembers => 'No team members yet.';

  @override
  String pcMoreInManage(int count) {
    return '+$count more in Manage users';
  }

  @override
  String get pcSystem => 'System';

  @override
  String pcWaiting(int count) {
    return '$count waiting';
  }

  @override
  String get pcAdminApprovals => 'ADMIN APPROVALS';

  @override
  String get pcApprovalQueueFailed => 'Could not load the approval queue.';

  @override
  String pcRejectName(String name) {
    return 'Reject $name';
  }

  @override
  String pcApproveName(String name) {
    return 'Approve $name';
  }

  @override
  String get pcLoanLimitsUpper => 'LOAN LIMITS';

  @override
  String pcLimitsSummary(
    String minP,
    String maxP,
    String minM,
    String maxM,
    String fee,
    String interest,
  ) {
    return 'Principal $minP to $maxP\nTerm $minM to $maxM months\nFee up to $fee% • Interest up to $interest%';
  }

  @override
  String get pcEditLimits => 'Edit loan limits';

  @override
  String get pcApp => 'App';

  @override
  String get pcVersion => 'Version';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get profNoAnswerReloaded =>
      'No answer from the server. Your profile was reloaded; check it and save again if needed.';

  @override
  String get profNoApprovedTeam => 'There is no approved team to show yet.';

  @override
  String get expDownloadExpired => 'This file has expired. Create it again.';

  @override
  String get expDownloadNotReady => 'The file is not ready yet.';

  @override
  String get expDownloadFailed =>
      'The download did not finish. Check your connection and try again.';

  @override
  String get expDownloadEmpty => 'The downloaded file is empty. Try again.';

  @override
  String valRequired(String field) {
    return '$field is required';
  }

  @override
  String get valThisField => 'This field';

  @override
  String get valValue => 'Value';

  @override
  String get valFieldCity => 'City';

  @override
  String get valFieldConfirmPassword => 'Confirm Password';

  @override
  String get valNameRequired => 'Name is required';

  @override
  String get valNameShort => 'Name is too short';

  @override
  String get valNameChars =>
      'Name can only contain letters, spaces, and certain punctuation';

  @override
  String get valPhoneRequired => 'Phone number is required';

  @override
  String get valPhoneInvalid => 'Enter a valid 10-digit mobile number';

  @override
  String get valOtpRequired => 'OTP is required';

  @override
  String valOtpLength(int length) {
    return 'Enter the $length-digit OTP';
  }

  @override
  String get valEmailRequired => 'Email is required';

  @override
  String get valEmailInvalid => 'Enter a valid email';

  @override
  String get valPasswordRequired => 'Password is required';

  @override
  String valPasswordMissing(String items) {
    return 'Missing: $items';
  }

  @override
  String valMinChars(int count) {
    return '$count+ chars';
  }

  @override
  String get valUppercase => 'uppercase';

  @override
  String get valNumber => 'number';

  @override
  String get valSpecialChar => 'special char';

  @override
  String get valConfirmPassword => 'Confirm your password';

  @override
  String get valPasswordsMismatch => 'Passwords do not match';

  @override
  String get valAmountRequired => 'Amount is required';

  @override
  String get valAmountPositive => 'Enter an amount greater than 0';

  @override
  String valAmountMin(String amount) {
    return 'Minimum is $amount';
  }

  @override
  String valAmountMax(String amount) {
    return 'Maximum is $amount';
  }

  @override
  String get valPercentRequired => 'Percentage is required';

  @override
  String get valNumberInvalid => 'Enter a valid number';

  @override
  String valPercentRange(int max) {
    return 'Enter a value between 0 and $max';
  }

  @override
  String get valPositiveNumber => 'Enter a valid number greater than 0';

  @override
  String get audModAuth => 'Auth';

  @override
  String get audModProfile => 'Profile';

  @override
  String get audModAdmin => 'Admin';

  @override
  String get audModEmployee => 'Employee';

  @override
  String get audModCustomer => 'Customer';

  @override
  String get audModLoan => 'Loan';

  @override
  String get audModPayment => 'Payment';

  @override
  String get audModSettings => 'Settings';

  @override
  String get audModSystem => 'System';

  @override
  String get audModOther => 'Other';

  @override
  String get audActAdminRegistered => 'Admin registered';

  @override
  String get audActLoginFailed => 'Login failed';

  @override
  String get audActLoginBlocked => 'Login blocked';

  @override
  String get audActPasswordReset => 'Password reset';

  @override
  String get audActSessionsRevoked => 'Sessions signed out';

  @override
  String get audActProfileUpdated => 'Profile updated';

  @override
  String get audActPhoneChanged => 'Phone number changed';

  @override
  String get audActPasswordChanged => 'Password changed';

  @override
  String get audActLoanDefaultsUpdated => 'Loan defaults updated';

  @override
  String get audActAdminVerificationChanged => 'Admin approval changed';

  @override
  String get audActAdminActiveChanged => 'Admin activated or deactivated';

  @override
  String get audActAdminDefaultsChanged => 'Admin defaults changed';

  @override
  String get audActEmployeeCreated => 'Employee created';

  @override
  String get audActEmployeeVerificationChanged => 'Employee approval changed';

  @override
  String get audActEmployeeActiveChanged => 'Employee activated or deactivated';

  @override
  String get audActEmployeeReassigned => 'Employee moved to another admin';

  @override
  String get audActEmployeeDefaultsUpdated => 'Employee defaults updated';

  @override
  String get audActEmployeeProfileEdited => 'Employee profile edited';

  @override
  String get audActCustomerCreated => 'Customer created';

  @override
  String get audActCustomerUpdated => 'Customer updated';

  @override
  String get audActCustomerDeleted => 'Customer deleted';

  @override
  String get audActCustomerReassigned => 'Customer reassigned';

  @override
  String get audActReferrerChanged => 'Referrer changed';

  @override
  String get audActLoanCreated => 'Loan created';

  @override
  String get audActLoanStatusChanged => 'Loan status changed';

  @override
  String get audActLoanTermsEdited => 'Loan terms edited';

  @override
  String get audActLoanClosed => 'Loan closed';

  @override
  String get audActLoanWrittenOff => 'Loan written off';

  @override
  String get audActLoanDeleted => 'Loan deleted';

  @override
  String get audActPaymentRecorded => 'Payment recorded';

  @override
  String get audActPaymentEdited => 'Payment edited';

  @override
  String get audActPaymentReversed => 'Payment reversed';

  @override
  String get audActWeekStatusChanged => 'Week status changed';

  @override
  String get audActBackdatedPayment => 'Backdated payment';

  @override
  String get audActLoanLimitsUpdated => 'Loan limits updated';

  @override
  String get audActSettingsChanged => 'Settings changed';

  @override
  String get audActDataExported => 'Data exported';

  @override
  String get audActBulkImport => 'Bulk import';

  @override
  String get audEntUser => 'User';

  @override
  String get audEntWeek => 'Week';

  @override
  String get audEntSetting => 'Setting';

  @override
  String get audFieldStatus => 'Status';

  @override
  String get audFieldName => 'Name';

  @override
  String get audFieldPhone => 'Phone';

  @override
  String get audFieldEmail => 'Email';

  @override
  String get audFieldApproval => 'Approval';

  @override
  String get audFieldActive => 'Active';

  @override
  String get audFieldDefaultUpfrontFee => 'Default upfront fee';

  @override
  String get audFieldDefaultInterest => 'Default interest';

  @override
  String get audFieldDefaultTerm => 'Default term';

  @override
  String get audFieldDefaultTermWeeks => 'Default term (weeks)';

  @override
  String get audFieldPrincipal => 'Principal';

  @override
  String get audFieldTotalPayable => 'Total payable';

  @override
  String get audFieldWeeklyInstallment => 'Weekly installment';

  @override
  String get audFieldUpfrontFee => 'Upfront fee';

  @override
  String get audFieldMinPrincipal => 'Minimum principal';

  @override
  String get audFieldMaxPrincipal => 'Maximum principal';

  @override
  String get audFieldMinTerm => 'Minimum term';

  @override
  String get audFieldMaxTerm => 'Maximum term';

  @override
  String get audFieldMaxFee => 'Maximum fee';

  @override
  String get audFieldMaxInterest => 'Maximum interest';

  @override
  String get audFieldAmountPaid => 'Amount paid';

  @override
  String get audFieldCustomerName => 'Customer name';

  @override
  String get audFieldCollectionDay => 'Collection day';

  @override
  String get audFieldReason => 'Reason';

  @override
  String get audFieldSource => 'Source';

  @override
  String get audValEmpty => 'empty';

  @override
  String get audValVerified => 'Verified';

  @override
  String get audValNotVerified => 'Not verified';

  @override
  String get audValInactive => 'Inactive';

  @override
  String get audValYes => 'Yes';

  @override
  String get audValNo => 'No';

  @override
  String audValMonths(String n) {
    return '$n months';
  }

  @override
  String audValWeeks(String n) {
    return '$n weeks';
  }

  @override
  String audMoreCount(int count) {
    return '+$count more';
  }

  @override
  String get audYesterday => 'Yesterday';

  @override
  String get trackerNothingLeft => 'Nothing left to collect on this loan.';

  @override
  String payPastTermOverdue(int weeks) {
    return 'Overdue — past the $weeks-week term';
  }

  @override
  String get payHistory => 'Payment history';

  @override
  String payCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments',
      one: '1 payment',
    );
    return '$_temp0';
  }

  @override
  String payOfTotal(String amount) {
    return 'of $amount';
  }

  @override
  String get payWeeksPaid => 'WEEKS PAID';

  @override
  String payWeeksPaidValue(int paid, int total) {
    return '$paid of $total';
  }

  @override
  String get payLastPaid => 'LAST PAID';

  @override
  String get payWeekClearedShort => 'Week cleared';

  @override
  String payLeftForWeek(String amount) {
    return '$amount left for this week';
  }

  @override
  String get payDetails => 'Payment details';

  @override
  String get payPaidOn => 'Paid on';

  @override
  String get payCollectedBy => 'Collected by';

  @override
  String get payReference => 'Payment reference';

  @override
  String get payWeekRecord => 'Week record';

  @override
  String get payOpenDetails => 'Open payment details';

  @override
  String get trackerClosedPaidOff => 'Loan paid off';

  @override
  String trackerClosedStatus(String status) {
    return 'Loan status: $status';
  }

  @override
  String get trackerClosedNoPayments =>
      'No more payments can be recorded on this loan.';

  @override
  String get expStorageDenied =>
      'Allow storage access to save files to Lending Docs.';

  @override
  String expSavedTo(String folder) {
    return 'Saved to $folder';
  }
}
