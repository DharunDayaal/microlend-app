import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta'),
  ];

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the app language'**
  String get languageSubtitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get languageTamil;

  /// No description provided for @deviceLanguageNotice.
  ///
  /// In en, this message translates to:
  /// **'Your phone\'s preferred language is Tamil, so the app opened in Tamil. You can change this under Language in your profile menu.'**
  String get deviceLanguageNotice;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @daysLate.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day late} other{{count} days late}}'**
  String daysLate(int count);

  /// No description provided for @commonWeekN.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String commonWeekN(int week);

  /// No description provided for @payWeekAlreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'Week {week} is already paid in full'**
  String payWeekAlreadyPaid(int week);

  /// No description provided for @payDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get payDueToday;

  /// No description provided for @payScheduledAhead.
  ///
  /// In en, this message translates to:
  /// **'Scheduled ahead'**
  String get payScheduledAhead;

  /// No description provided for @payPartialOnFile.
  ///
  /// In en, this message translates to:
  /// **'Partial payment on file'**
  String get payPartialOnFile;

  /// No description provided for @payOverdueNotCollected.
  ///
  /// In en, this message translates to:
  /// **'Overdue — not yet collected'**
  String get payOverdueNotCollected;

  /// No description provided for @payWeekDate.
  ///
  /// In en, this message translates to:
  /// **'Week {week} • {date}'**
  String payWeekDate(int week, String date);

  /// No description provided for @payStillOwedForWeek.
  ///
  /// In en, this message translates to:
  /// **'{amount} still owed for Week {week}'**
  String payStillOwedForWeek(String amount, int week);

  /// No description provided for @payWeekWasDue.
  ///
  /// In en, this message translates to:
  /// **'Week {week} was due {date}'**
  String payWeekWasDue(int week, String date);

  /// No description provided for @payEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid payment amount'**
  String get payEnterValidAmount;

  /// No description provided for @payCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get payCash;

  /// No description provided for @payUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get payUpi;

  /// No description provided for @payCollectPayment.
  ///
  /// In en, this message translates to:
  /// **'Collect Payment'**
  String get payCollectPayment;

  /// No description provided for @payWeekOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Week {week} of {total}'**
  String payWeekOfTotal(int week, int total);

  /// No description provided for @payAmountToCollect.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT TO COLLECT'**
  String get payAmountToCollect;

  /// No description provided for @payUpToCollectable.
  ///
  /// In en, this message translates to:
  /// **'Up to {amount} collectable on this loan'**
  String payUpToCollectable(String amount);

  /// No description provided for @payClearWeek.
  ///
  /// In en, this message translates to:
  /// **'Clear Week {week}'**
  String payClearWeek(int week);

  /// No description provided for @payTwoWeeks.
  ///
  /// In en, this message translates to:
  /// **'Pay 2 Weeks'**
  String get payTwoWeeks;

  /// No description provided for @paySettleFullLoan.
  ///
  /// In en, this message translates to:
  /// **'Settle full loan — {amount}'**
  String paySettleFullLoan(String amount);

  /// No description provided for @payThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get payThisWeek;

  /// No description provided for @payEntireLoan.
  ///
  /// In en, this message translates to:
  /// **'Entire loan'**
  String get payEntireLoan;

  /// No description provided for @payCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared ✓'**
  String get payCleared;

  /// No description provided for @payConfirmClose.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM & CLOSE LOAN — {amount}'**
  String payConfirmClose(String amount);

  /// No description provided for @payConfirmRecord.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM & RECORD {amount}'**
  String payConfirmRecord(String amount);

  /// No description provided for @otpEnterComplete.
  ///
  /// In en, this message translates to:
  /// **'Enter the complete {length}-digit code'**
  String otpEnterComplete(int length);

  /// No description provided for @otpNewCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent.'**
  String get otpNewCodeSent;

  /// No description provided for @otpVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify phone number'**
  String get otpVerifyPhone;

  /// No description provided for @otpEnterCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the {length}-digit code sent to {phone}.'**
  String otpEnterCodeSentTo(int length, String phone);

  /// No description provided for @otpResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String otpResendIn(int seconds);

  /// No description provided for @otpResend.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get otpResend;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get statusPaid;

  /// No description provided for @statusPartial.
  ///
  /// In en, this message translates to:
  /// **'PARTIAL'**
  String get statusPartial;

  /// No description provided for @statusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'UNPAID'**
  String get statusUnpaid;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULED'**
  String get statusScheduled;

  /// No description provided for @statusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get statusUpcoming;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get statusOverdue;

  /// No description provided for @trackDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String trackDueOn(String date);

  /// No description provided for @trackPaidInFull.
  ///
  /// In en, this message translates to:
  /// **'Paid in full'**
  String get trackPaidInFull;

  /// No description provided for @trackDueToClear.
  ///
  /// In en, this message translates to:
  /// **'{amount} Due to clear'**
  String trackDueToClear(String amount);

  /// No description provided for @trackNotCollected.
  ///
  /// In en, this message translates to:
  /// **'Not collected'**
  String get trackNotCollected;

  /// No description provided for @trackPending.
  ///
  /// In en, this message translates to:
  /// **'{amount} pending'**
  String trackPending(String amount);

  /// No description provided for @trackUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get trackUpcoming;

  /// No description provided for @trackPastTerm.
  ///
  /// In en, this message translates to:
  /// **'Past {weeks}-week term'**
  String trackPastTerm(int weeks);

  /// No description provided for @trackOverdueAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} overdue'**
  String trackOverdueAmount(String amount);

  /// No description provided for @trackWeekShort.
  ///
  /// In en, this message translates to:
  /// **'Wk {week}'**
  String trackWeekShort(String week);

  /// No description provided for @trackCollectAmount.
  ///
  /// In en, this message translates to:
  /// **'Collect {amount}'**
  String trackCollectAmount(String amount);

  /// No description provided for @referralSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Referring Borrower'**
  String get referralSelectTitle;

  /// No description provided for @commonSearchNamePhone.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone'**
  String get commonSearchNamePhone;

  /// No description provided for @referralNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No referrers found'**
  String get referralNoneFound;

  /// No description provided for @payPastTerm.
  ///
  /// In en, this message translates to:
  /// **'PAST TERM'**
  String get payPastTerm;

  /// No description provided for @payAmountPaid.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT PAID'**
  String get payAmountPaid;

  /// No description provided for @payWeekCleared.
  ///
  /// In en, this message translates to:
  /// **'WEEK CLEARED'**
  String get payWeekCleared;

  /// No description provided for @payWeekProgress.
  ///
  /// In en, this message translates to:
  /// **'Week {week} progress'**
  String payWeekProgress(int week);

  /// No description provided for @payWeekFullyCollected.
  ///
  /// In en, this message translates to:
  /// **'Week {week} fully collected ({amount})'**
  String payWeekFullyCollected(int week, String amount);

  /// No description provided for @payCollectedOfLeft.
  ///
  /// In en, this message translates to:
  /// **'{collected} of {target} collected • {left} left'**
  String payCollectedOfLeft(String collected, String target, String left);

  /// No description provided for @payIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Payment ID copied'**
  String get payIdCopied;

  /// No description provided for @commonCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get commonCall;

  /// No description provided for @commonUnableOpenDialer.
  ///
  /// In en, this message translates to:
  /// **'Unable to open dialer'**
  String get commonUnableOpenDialer;

  /// No description provided for @stepDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease {label}'**
  String stepDecrease(String label);

  /// No description provided for @stepIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase {label}'**
  String stepIncrease(String label);

  /// No description provided for @recoveryOverallTarget.
  ///
  /// In en, this message translates to:
  /// **'Overall Recovery Target'**
  String get recoveryOverallTarget;

  /// No description provided for @recoveryPercentCompleted.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Completed'**
  String recoveryPercentCompleted(String percent);

  /// No description provided for @recoveryOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall recovery'**
  String get recoveryOverall;

  /// No description provided for @recoveryOverdueLine.
  ///
  /// In en, this message translates to:
  /// **'{percent}% overdue • {amount}'**
  String recoveryOverdueLine(String percent, String amount);

  /// No description provided for @ringPercentCollected.
  ///
  /// In en, this message translates to:
  /// **'{percent} percent collected'**
  String ringPercentCollected(int percent);

  /// No description provided for @securityRating.
  ///
  /// In en, this message translates to:
  /// **'Security rating'**
  String get securityRating;

  /// No description provided for @securityWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get securityWeak;

  /// No description provided for @securityFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get securityFair;

  /// No description provided for @securityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get securityGood;

  /// No description provided for @securityStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get securityStrong;

  /// No description provided for @securityLevelOf.
  ///
  /// In en, this message translates to:
  /// **'{level} of {total}'**
  String securityLevelOf(int level, int total);

  /// No description provided for @placeholderComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{title}: coming soon'**
  String placeholderComingSoon(String title);

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'*Required'**
  String get commonRequired;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Thavanai'**
  String get appName;

  /// No description provided for @authSelectLoginMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Login Method'**
  String get authSelectLoginMethod;

  /// No description provided for @authWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authWelcomeBack;

  /// No description provided for @authSelectMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred sign in method to access you field ledger and daily collections.'**
  String get authSelectMethodSubtitle;

  /// No description provided for @authEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Email & Password'**
  String get authEmailPassword;

  /// No description provided for @authEmailPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in using your registered email address...'**
  String get authEmailPasswordSubtitle;

  /// No description provided for @authPhoneOtp.
  ///
  /// In en, this message translates to:
  /// **'Phone OTP verification'**
  String get authPhoneOtp;

  /// No description provided for @authPhoneOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Instant login via 6-digit OTP verification directly to the registered mobile number'**
  String get authPhoneOtpSubtitle;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get commonOr;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get authNoAccount;

  /// No description provided for @authRegisterHere.
  ///
  /// In en, this message translates to:
  /// **'Register here'**
  String get authRegisterHere;

  /// No description provided for @authEmailLogin.
  ///
  /// In en, this message translates to:
  /// **'Email Login'**
  String get authEmailLogin;

  /// No description provided for @authSignInToAccess.
  ///
  /// In en, this message translates to:
  /// **'Sign in to access your account.'**
  String get authSignInToAccess;

  /// No description provided for @authEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmailAddress;

  /// No description provided for @authEnterEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email...'**
  String get authEnterEmailHint;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authEnterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password...'**
  String get authEnterPasswordHint;

  /// No description provided for @authForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get authSignIn;

  /// No description provided for @authOrQuickSwitch.
  ///
  /// In en, this message translates to:
  /// **'OR QUICK SWITCH'**
  String get authOrQuickSwitch;

  /// No description provided for @authLoginWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Log in with phone number'**
  String get authLoginWithPhone;

  /// No description provided for @authNoAccountInline.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get authNoAccountInline;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authNewCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A new verification code has been sent.'**
  String get authNewCodeSent;

  /// No description provided for @authEnterComplete6.
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete 6-digit code'**
  String get authEnterComplete6;

  /// No description provided for @authVerifyContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & continue'**
  String get authVerifyContinue;

  /// No description provided for @authSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get authSendOtp;

  /// No description provided for @authOtpLogin.
  ///
  /// In en, this message translates to:
  /// **'OTP Login'**
  String get authOtpLogin;

  /// No description provided for @authLoginWithOtp.
  ///
  /// In en, this message translates to:
  /// **'Login with OTP'**
  String get authLoginWithOtp;

  /// No description provided for @authOtpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter 6 digit verification code sent via secure SMS to your registered mobile.'**
  String get authOtpSubtitle;

  /// No description provided for @authLoginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Log in with email'**
  String get authLoginWithEmail;

  /// No description provided for @authRegisteredNumber.
  ///
  /// In en, this message translates to:
  /// **'Registered number'**
  String get authRegisteredNumber;

  /// No description provided for @authPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get authPhoneNumber;

  /// No description provided for @authEnterPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number...'**
  String get authEnterPhoneHint;

  /// No description provided for @approvalVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Account verification is required to proceed further'**
  String get approvalVerificationRequired;

  /// No description provided for @approvalPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Approval Pending'**
  String get approvalPendingTitle;

  /// No description provided for @approvalUnderReviewBadge.
  ///
  /// In en, this message translates to:
  /// **'APPLICATION UNDER REVIEW • PENDING ADMIN APPROVAL'**
  String get approvalUnderReviewBadge;

  /// No description provided for @approvalInProgress.
  ///
  /// In en, this message translates to:
  /// **'Approval in Progress'**
  String get approvalInProgress;

  /// No description provided for @approvalSubmittedBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile and lending parameters have been submitted. An administrator will review and approve your account soon.'**
  String get approvalSubmittedBody;

  /// No description provided for @approvalWhatNext.
  ///
  /// In en, this message translates to:
  /// **'What to expect next'**
  String get approvalWhatNext;

  /// No description provided for @approvalWhatNextBody.
  ///
  /// In en, this message translates to:
  /// **'Your profile is currently under review by the administrator. You will be notified once your account has been approved and activated.'**
  String get approvalWhatNextBody;

  /// No description provided for @approvalReviewTimeframe.
  ///
  /// In en, this message translates to:
  /// **'REVIEW TIMEFRAME'**
  String get approvalReviewTimeframe;

  /// No description provided for @approvalTypicalTime.
  ///
  /// In en, this message translates to:
  /// **'Typical review time: 24-48 business hours'**
  String get approvalTypicalTime;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Password Reset'**
  String get resetTitle;

  /// No description provided for @resetHeading.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetHeading;

  /// No description provided for @resetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your registered email or phone number to create a secure new password for your account.'**
  String get resetSubtitle;

  /// No description provided for @resetRememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your Password? '**
  String get resetRememberPassword;

  /// No description provided for @resetBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get resetBackToLogin;

  /// No description provided for @resetRegisteredEmail.
  ///
  /// In en, this message translates to:
  /// **'Registered email address'**
  String get resetRegisteredEmail;

  /// No description provided for @resetRegisteredPhone.
  ///
  /// In en, this message translates to:
  /// **'Registered phone number'**
  String get resetRegisteredPhone;

  /// No description provided for @resetEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get resetEnterEmail;

  /// No description provided for @resetEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get resetEnterPhone;

  /// No description provided for @resetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get resetNewPassword;

  /// No description provided for @resetNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your strong new password'**
  String get resetNewPasswordHint;

  /// No description provided for @resetConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get resetConfirmPassword;

  /// No description provided for @resetConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Re-type your password to confirm'**
  String get resetConfirmHint;

  /// No description provided for @resetPasswordsMustMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords must match exactly'**
  String get resetPasswordsMustMatch;

  /// No description provided for @resetUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get resetUpdatePassword;

  /// No description provided for @resetGetCode.
  ///
  /// In en, this message translates to:
  /// **'Get Verification Code'**
  String get resetGetCode;

  /// No description provided for @regTitle.
  ///
  /// In en, this message translates to:
  /// **'Registration'**
  String get regTitle;

  /// No description provided for @regBackToStep1.
  ///
  /// In en, this message translates to:
  /// **'Back to step 1'**
  String get regBackToStep1;

  /// No description provided for @regStepN.
  ///
  /// In en, this message translates to:
  /// **'Step {step}'**
  String regStepN(int step);

  /// No description provided for @regPersonalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get regPersonalDetails;

  /// No description provided for @regLendingTerms.
  ///
  /// In en, this message translates to:
  /// **'Lending Terms'**
  String get regLendingTerms;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @regStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2: Personal Details. Enter your information to create your account.'**
  String get regStep1Subtitle;

  /// No description provided for @regFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get regFullName;

  /// No description provided for @regEnterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get regEnterName;

  /// No description provided for @regEnterMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number'**
  String get regEnterMobile;

  /// No description provided for @regCreatePassword.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get regCreatePassword;

  /// No description provided for @regEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get regEnterPassword;

  /// No description provided for @regSecurityRating.
  ///
  /// In en, this message translates to:
  /// **'Security Rating'**
  String get regSecurityRating;

  /// No description provided for @regStrengthLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get regStrengthLow;

  /// No description provided for @regStrengthMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get regStrengthMedium;

  /// No description provided for @regStrengthHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get regStrengthHigh;

  /// No description provided for @regStrengthExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get regStrengthExcellent;

  /// No description provided for @regLendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Final step - set your standard lending parameters. These defaults will pre-populate your loan origination calculator.'**
  String get regLendingSubtitle;

  /// No description provided for @regVerifiedProfile.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED PROFILE'**
  String get regVerifiedProfile;

  /// No description provided for @regFieldUser.
  ///
  /// In en, this message translates to:
  /// **'Field user'**
  String get regFieldUser;

  /// No description provided for @termsDefaultInterest.
  ///
  /// In en, this message translates to:
  /// **'Default Interest Rate'**
  String get termsDefaultInterest;

  /// No description provided for @termsFlatRate.
  ///
  /// In en, this message translates to:
  /// **'Flat Rate'**
  String get termsFlatRate;

  /// No description provided for @termsEnterInterest.
  ///
  /// In en, this message translates to:
  /// **'Enter your interest rate'**
  String get termsEnterInterest;

  /// No description provided for @termsInterestFooter.
  ///
  /// In en, this message translates to:
  /// **'Applied flat across the full loan cycle duration.'**
  String get termsInterestFooter;

  /// No description provided for @termsInterestRate.
  ///
  /// In en, this message translates to:
  /// **'Interest rate'**
  String get termsInterestRate;

  /// No description provided for @termsUpfrontFee.
  ///
  /// In en, this message translates to:
  /// **'Upfront Processing Fee'**
  String get termsUpfrontFee;

  /// No description provided for @termsAtDisbursement.
  ///
  /// In en, this message translates to:
  /// **'At Disbursement'**
  String get termsAtDisbursement;

  /// No description provided for @termsEnterUpfront.
  ///
  /// In en, this message translates to:
  /// **'Enter your upfront fee'**
  String get termsEnterUpfront;

  /// No description provided for @termsUpfrontFooter.
  ///
  /// In en, this message translates to:
  /// **'Deducted immediately from cash handover upon spot disbursement.'**
  String get termsUpfrontFooter;

  /// No description provided for @termsUpfrontFeeShort.
  ///
  /// In en, this message translates to:
  /// **'Upfront fee'**
  String get termsUpfrontFeeShort;

  /// No description provided for @termsTotalDurationMonths.
  ///
  /// In en, this message translates to:
  /// **'Total Duration (Months)'**
  String get termsTotalDurationMonths;

  /// No description provided for @termsWeeklySchedule.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get termsWeeklySchedule;

  /// No description provided for @termsMonthsShort.
  ///
  /// In en, this message translates to:
  /// **'{value} MO'**
  String termsMonthsShort(String value);

  /// No description provided for @termsMonths.
  ///
  /// In en, this message translates to:
  /// **'Months'**
  String get termsMonths;

  /// No description provided for @regBaselinePreview.
  ///
  /// In en, this message translates to:
  /// **'Standard Baseline\nPreview'**
  String get regBaselinePreview;

  /// No description provided for @regLoanModel.
  ///
  /// In en, this message translates to:
  /// **'{amount} \nLoan Model'**
  String regLoanModel(String amount);

  /// No description provided for @regNetHandover.
  ///
  /// In en, this message translates to:
  /// **'NET HANDOVER CASH'**
  String get regNetHandover;

  /// No description provided for @regDeductedFee.
  ///
  /// In en, this message translates to:
  /// **'Deducted fee: -{amount}\n'**
  String regDeductedFee(String amount);

  /// No description provided for @regTotalRepayable.
  ///
  /// In en, this message translates to:
  /// **'TOTAL REPAYABLE'**
  String get regTotalRepayable;

  /// No description provided for @regIncludesInterest.
  ///
  /// In en, this message translates to:
  /// **'Includes {amount} ({percent})'**
  String regIncludesInterest(String amount, String percent);

  /// No description provided for @regWeeklyCollection.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY COLLECTION AMOUNT'**
  String get regWeeklyCollection;

  /// No description provided for @regFixedEveryMonday.
  ///
  /// In en, this message translates to:
  /// **'Fixed installment every\nMonday'**
  String get regFixedEveryMonday;

  /// No description provided for @regPerWeek.
  ///
  /// In en, this message translates to:
  /// **'per week\n'**
  String get regPerWeek;

  /// No description provided for @regWeeksParen.
  ///
  /// In en, this message translates to:
  /// **'({weeks}) weeks'**
  String regWeeksParen(int weeks);

  /// No description provided for @regInstallmentSchedule.
  ///
  /// In en, this message translates to:
  /// **'Installment Schedule'**
  String get regInstallmentSchedule;

  /// No description provided for @regPrincipalFlat.
  ///
  /// In en, this message translates to:
  /// **'Principal + Flat Int.'**
  String get regPrincipalFlat;

  /// No description provided for @commonStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get commonStatus;

  /// No description provided for @regWeekHash.
  ///
  /// In en, this message translates to:
  /// **'Week #{week}'**
  String regWeekHash(String week);

  /// No description provided for @regAdditionalCycles.
  ///
  /// In en, this message translates to:
  /// **'+ {count} additonal Weekly cycles to maturity'**
  String regAdditionalCycles(int count);

  /// No description provided for @regHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get regHaveAccount;

  /// No description provided for @regSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get regSignIn;

  /// No description provided for @regDraftCached.
  ///
  /// In en, this message translates to:
  /// **'Draft cached locally'**
  String get regDraftCached;

  /// No description provided for @regStepOf.
  ///
  /// In en, this message translates to:
  /// **'STEP {step} of {total}'**
  String regStepOf(int step, int total);

  /// No description provided for @regVerifyPhone.
  ///
  /// In en, this message translates to:
  /// **'Verify Phone Number'**
  String get regVerifyPhone;

  /// No description provided for @regRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get regRegister;

  /// No description provided for @termsCalculateTerm.
  ///
  /// In en, this message translates to:
  /// **'Calculate Term:'**
  String get termsCalculateTerm;

  /// No description provided for @termsWeeksCount.
  ///
  /// In en, this message translates to:
  /// **'{weeks} Weeks '**
  String termsWeeksCount(int weeks);

  /// No description provided for @termsDaysParen.
  ///
  /// In en, this message translates to:
  /// **'({days} Days)'**
  String termsDaysParen(int days);

  /// No description provided for @termsAutoCalculated.
  ///
  /// In en, this message translates to:
  /// **'Auto calculated: '**
  String get termsAutoCalculated;

  /// No description provided for @termsEnterMonths.
  ///
  /// In en, this message translates to:
  /// **'enter the number of months'**
  String get termsEnterMonths;

  /// No description provided for @termsMonthsCount.
  ///
  /// In en, this message translates to:
  /// **'{months} months '**
  String termsMonthsCount(String months);

  /// No description provided for @termsTimesFourWeeks.
  ///
  /// In en, this message translates to:
  /// **'x 4 weeks = '**
  String get termsTimesFourWeeks;

  /// No description provided for @termsWeeklyCollections.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weekly collections'**
  String termsWeeklyCollections(int weeks);

  /// No description provided for @tabField.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get tabField;

  /// No description provided for @tabLoans.
  ///
  /// In en, this message translates to:
  /// **'Loans'**
  String get tabLoans;

  /// No description provided for @tabBorrowers.
  ///
  /// In en, this message translates to:
  /// **'Borrowers'**
  String get tabBorrowers;

  /// No description provided for @tabReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get tabReports;

  /// No description provided for @menuMyProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get menuMyProfile;

  /// No description provided for @menuMyProfileSub.
  ///
  /// In en, this message translates to:
  /// **'Name, phone, email and loan defaults'**
  String get menuMyProfileSub;

  /// No description provided for @menuAddBorrower.
  ///
  /// In en, this message translates to:
  /// **'Add borrower'**
  String get menuAddBorrower;

  /// No description provided for @menuAddBorrowerSub.
  ///
  /// In en, this message translates to:
  /// **'Register a new customer'**
  String get menuAddBorrowerSub;

  /// No description provided for @menuManageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage users'**
  String get menuManageUsers;

  /// No description provided for @menuManageUsersSub.
  ///
  /// In en, this message translates to:
  /// **'Add team members and set roles'**
  String get menuManageUsersSub;

  /// No description provided for @menuAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Advanced analytics'**
  String get menuAnalytics;

  /// No description provided for @menuAnalyticsSub.
  ///
  /// In en, this message translates to:
  /// **'Recovery, overdue trends and collections'**
  String get menuAnalyticsSub;

  /// No description provided for @menuAllAdmins.
  ///
  /// In en, this message translates to:
  /// **'All admins'**
  String get menuAllAdmins;

  /// No description provided for @menuAllAdminsSub.
  ///
  /// In en, this message translates to:
  /// **'Approve and manage admin accounts'**
  String get menuAllAdminsSub;

  /// No description provided for @menuAuditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get menuAuditLog;

  /// No description provided for @menuAuditLogSub.
  ///
  /// In en, this message translates to:
  /// **'Who changed what, and when'**
  String get menuAuditLogSub;

  /// No description provided for @menuDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get menuDownloads;

  /// No description provided for @menuDownloadsSub.
  ///
  /// In en, this message translates to:
  /// **'Sheets and reports you have exported'**
  String get menuDownloadsSub;

  /// No description provided for @greetMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetMorning;

  /// No description provided for @greetAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetAfternoon;

  /// No description provided for @greetEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetEvening;

  /// No description provided for @menuOpenProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile menu'**
  String get menuOpenProfile;

  /// No description provided for @menuSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get menuSignedOut;

  /// No description provided for @menuLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get menuLogOut;

  /// No description provided for @menuLogOutSub.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again.'**
  String get menuLogOutSub;

  /// No description provided for @menuLogOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get menuLogOutConfirm;

  /// No description provided for @errorPageNotFound.
  ///
  /// In en, this message translates to:
  /// **'404! Page not found.'**
  String get errorPageNotFound;

  /// No description provided for @roleUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get roleUser;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleSuperAdmin.
  ///
  /// In en, this message translates to:
  /// **'Super Admin'**
  String get roleSuperAdmin;

  /// No description provided for @manualStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get manualStatusClosed;

  /// No description provided for @manualStatusDefaulted.
  ///
  /// In en, this message translates to:
  /// **'Defaulted'**
  String get manualStatusDefaulted;

  /// No description provided for @manualStatusReopen.
  ///
  /// In en, this message translates to:
  /// **'Active (reopen)'**
  String get manualStatusReopen;

  /// No description provided for @manualStatusClosedDesc.
  ///
  /// In en, this message translates to:
  /// **'Ends the loan. Nothing more can be collected on it.'**
  String get manualStatusClosedDesc;

  /// No description provided for @manualStatusDefaultedDesc.
  ///
  /// In en, this message translates to:
  /// **'The borrower will not repay. The loan is written off as a default.'**
  String get manualStatusDefaultedDesc;

  /// No description provided for @manualStatusReopenDesc.
  ///
  /// In en, this message translates to:
  /// **'Reopens the loan so collections can resume. It shows as overdue again if weeks are already past due.'**
  String get manualStatusReopenDesc;

  /// No description provided for @exportWeekdaySheet.
  ///
  /// In en, this message translates to:
  /// **'Collection sheet'**
  String get exportWeekdaySheet;

  /// No description provided for @exportWeekdaySheetBlurb.
  ///
  /// In en, this message translates to:
  /// **'One block per customer for a weekday: loan details and what was paid each week (W1 - 300, W2 - 400).'**
  String get exportWeekdaySheetBlurb;

  /// No description provided for @exportDueThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Route sheet'**
  String get exportDueThisWeek;

  /// No description provided for @exportDueThisWeekBlurb.
  ///
  /// In en, this message translates to:
  /// **'Weekly instalments falling due, by day, with amount due, paid and balance.'**
  String get exportDueThisWeekBlurb;

  /// No description provided for @exportCustomerList.
  ///
  /// In en, this message translates to:
  /// **'Customer list'**
  String get exportCustomerList;

  /// No description provided for @exportCustomerListBlurb.
  ///
  /// In en, this message translates to:
  /// **'Customers with phone, area, payment day, active loans and outstanding.'**
  String get exportCustomerListBlurb;

  /// No description provided for @exportOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue loans'**
  String get exportOverdue;

  /// No description provided for @exportOverdueBlurb.
  ///
  /// In en, this message translates to:
  /// **'Overdue and defaulted loans with days late and the overdue amount.'**
  String get exportOverdueBlurb;

  /// No description provided for @exportCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get exportCollections;

  /// No description provided for @exportCollectionsBlurb.
  ///
  /// In en, this message translates to:
  /// **'Every payment taken in a date range.'**
  String get exportCollectionsBlurb;

  /// No description provided for @exportLoansRegister.
  ///
  /// In en, this message translates to:
  /// **'Loans register'**
  String get exportLoansRegister;

  /// No description provided for @exportLoansRegisterBlurb.
  ///
  /// In en, this message translates to:
  /// **'Every loan with its money columns. Filter by status and issue date.'**
  String get exportLoansRegisterBlurb;

  /// No description provided for @exportClosedLoans.
  ///
  /// In en, this message translates to:
  /// **'Closed loans'**
  String get exportClosedLoans;

  /// No description provided for @exportClosedLoansBlurb.
  ///
  /// In en, this message translates to:
  /// **'Loans closed, paid off or defaulted in a range, with collected and shortfall.'**
  String get exportClosedLoansBlurb;

  /// No description provided for @exportNewCustomers.
  ///
  /// In en, this message translates to:
  /// **'New customers'**
  String get exportNewCustomers;

  /// No description provided for @exportNewCustomersBlurb.
  ///
  /// In en, this message translates to:
  /// **'Customers added in a range, with referrer and who added them.'**
  String get exportNewCustomersBlurb;

  /// No description provided for @exportAuditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get exportAuditLog;

  /// No description provided for @exportAuditLogBlurb.
  ///
  /// In en, this message translates to:
  /// **'Who changed what, with old and new values.'**
  String get exportAuditLogBlurb;

  /// No description provided for @exportEmployeePerformance.
  ///
  /// In en, this message translates to:
  /// **'Employee performance'**
  String get exportEmployeePerformance;

  /// No description provided for @exportEmployeePerformanceBlurb.
  ///
  /// In en, this message translates to:
  /// **'Per employee: collected, target, rates, overdue, new customers and loans.'**
  String get exportEmployeePerformanceBlurb;

  /// No description provided for @exportTeamSummary.
  ///
  /// In en, this message translates to:
  /// **'Team summary'**
  String get exportTeamSummary;

  /// No description provided for @exportTeamSummaryBlurb.
  ///
  /// In en, this message translates to:
  /// **'One row per admin.'**
  String get exportTeamSummaryBlurb;

  /// No description provided for @dayMonShort.
  ///
  /// In en, this message translates to:
  /// **'MON'**
  String get dayMonShort;

  /// No description provided for @dayTueShort.
  ///
  /// In en, this message translates to:
  /// **'TUE'**
  String get dayTueShort;

  /// No description provided for @dayWedShort.
  ///
  /// In en, this message translates to:
  /// **'WED'**
  String get dayWedShort;

  /// No description provided for @dayThuShort.
  ///
  /// In en, this message translates to:
  /// **'THR'**
  String get dayThuShort;

  /// No description provided for @dayFriShort.
  ///
  /// In en, this message translates to:
  /// **'FRI'**
  String get dayFriShort;

  /// No description provided for @daySatShort.
  ///
  /// In en, this message translates to:
  /// **'SAT'**
  String get daySatShort;

  /// No description provided for @daySunShort.
  ///
  /// In en, this message translates to:
  /// **'SUN'**
  String get daySunShort;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @custFillHighlighted.
  ///
  /// In en, this message translates to:
  /// **'Please fill the highlighted fields.'**
  String get custFillHighlighted;

  /// No description provided for @custOtpSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send the verification code. Try again.'**
  String get custOtpSendFailed;

  /// No description provided for @custOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to {phone}.'**
  String custOtpSentTo(String phone);

  /// No description provided for @custVerifyToAdd.
  ///
  /// In en, this message translates to:
  /// **'Verify the phone number to add this borrower.'**
  String get custVerifyToAdd;

  /// No description provided for @custPhoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone number verified.'**
  String get custPhoneVerified;

  /// No description provided for @custAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} was added successfully.'**
  String custAddedSuccess(String name);

  /// No description provided for @custAddFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t add the borrower. Please try again.'**
  String get custAddFailed;

  /// No description provided for @commonSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonSomethingWrong;

  /// No description provided for @custSaveAdd.
  ///
  /// In en, this message translates to:
  /// **'Save & Add Borrower'**
  String get custSaveAdd;

  /// No description provided for @custCancelDiscard.
  ///
  /// In en, this message translates to:
  /// **'Cancel & Discard'**
  String get custCancelDiscard;

  /// No description provided for @custIdentityCredentials.
  ///
  /// In en, this message translates to:
  /// **'Identity Credentials'**
  String get custIdentityCredentials;

  /// No description provided for @custRequiredBadge.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get custRequiredBadge;

  /// No description provided for @custFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get custFullName;

  /// No description provided for @custEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get custEnterFullName;

  /// No description provided for @custMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get custMobileNumber;

  /// No description provided for @custEnterMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get custEnterMobile;

  /// No description provided for @custPreferredDayBatch.
  ///
  /// In en, this message translates to:
  /// **'Preferred Day Batch'**
  String get custPreferredDayBatch;

  /// No description provided for @custAssignedRoute.
  ///
  /// In en, this message translates to:
  /// **'Assigned to weekly field collection route'**
  String get custAssignedRoute;

  /// No description provided for @custDayBatch.
  ///
  /// In en, this message translates to:
  /// **'{day} Batch'**
  String custDayBatch(String day);

  /// No description provided for @custAddressLocation.
  ///
  /// In en, this message translates to:
  /// **'Address & Location'**
  String get custAddressLocation;

  /// No description provided for @custVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get custVerification;

  /// No description provided for @custStreet.
  ///
  /// In en, this message translates to:
  /// **'Street Name / House No.'**
  String get custStreet;

  /// No description provided for @custStreetHint.
  ///
  /// In en, this message translates to:
  /// **'Street name or number'**
  String get custStreetHint;

  /// No description provided for @custCity.
  ///
  /// In en, this message translates to:
  /// **'City / Town'**
  String get custCity;

  /// No description provided for @custEnterCity.
  ///
  /// In en, this message translates to:
  /// **'Enter city'**
  String get custEnterCity;

  /// No description provided for @custDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get custDistrict;

  /// No description provided for @custEnterDistrict.
  ///
  /// In en, this message translates to:
  /// **'Enter district'**
  String get custEnterDistrict;

  /// No description provided for @custReferredBy.
  ///
  /// In en, this message translates to:
  /// **'Referred By Borrower'**
  String get custReferredBy;

  /// No description provided for @custOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get custOptional;

  /// No description provided for @custSelectReferrer.
  ///
  /// In en, this message translates to:
  /// **'Select Referrer Borrower'**
  String get custSelectReferrer;

  /// No description provided for @custReferrerIdLine.
  ///
  /// In en, this message translates to:
  /// **'ID {id} • 2 Fully Repaid Loans'**
  String custReferrerIdLine(String id);

  /// No description provided for @custChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get custChange;

  /// No description provided for @custAddBorrower.
  ///
  /// In en, this message translates to:
  /// **'Add Borrower'**
  String get custAddBorrower;

  /// No description provided for @custSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search borrower, street, city, district...'**
  String get custSearchHint;

  /// No description provided for @custNoneScheduled.
  ///
  /// In en, this message translates to:
  /// **'No customers scheduled'**
  String get custNoneScheduled;

  /// No description provided for @commonTapToRetry.
  ///
  /// In en, this message translates to:
  /// **'Tap to retry'**
  String get commonTapToRetry;

  /// No description provided for @custNoMore.
  ///
  /// In en, this message translates to:
  /// **'No more customers'**
  String get custNoMore;

  /// No description provided for @custTodaysTarget.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S TARGET ROUTE'**
  String get custTodaysTarget;

  /// No description provided for @custDueSuffix.
  ///
  /// In en, this message translates to:
  /// **' due'**
  String get custDueSuffix;

  /// No description provided for @custCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get custCollected;

  /// No description provided for @custPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get custPending;

  /// No description provided for @custBorrowersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Borrowers'**
  String custBorrowersCount(int count);

  /// No description provided for @commonNA.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get commonNA;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get commonHistory;

  /// No description provided for @custRegOn.
  ///
  /// In en, this message translates to:
  /// **'• Reg: {date}'**
  String custRegOn(String date);

  /// No description provided for @custCycleEligible.
  ///
  /// In en, this message translates to:
  /// **'Cycle {count} Eligible'**
  String custCycleEligible(String count);

  /// No description provided for @custAssignedRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Assigned Route'**
  String get custAssignedRouteLabel;

  /// No description provided for @custDayRoute.
  ///
  /// In en, this message translates to:
  /// **'{day} Route'**
  String custDayRoute(String day);

  /// No description provided for @custCallBorrower.
  ///
  /// In en, this message translates to:
  /// **'Call Borrower'**
  String get custCallBorrower;

  /// No description provided for @custCloseActiveFirst.
  ///
  /// In en, this message translates to:
  /// **'Close the current active loan before issuing a new one.'**
  String get custCloseActiveFirst;

  /// No description provided for @issueStepBorrower.
  ///
  /// In en, this message translates to:
  /// **'Borrower'**
  String get issueStepBorrower;

  /// No description provided for @issueStepProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get issueStepProfile;

  /// No description provided for @issueStepSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get issueStepSelected;

  /// No description provided for @issueStepTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get issueStepTerms;

  /// No description provided for @issueStepCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get issueStepCalculator;

  /// No description provided for @issueStepConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get issueStepConfirmed;

  /// No description provided for @issueStepDisburse.
  ///
  /// In en, this message translates to:
  /// **'Disburse'**
  String get issueStepDisburse;

  /// No description provided for @issueStepConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get issueStepConfirmation;

  /// No description provided for @issueTitleBorrower.
  ///
  /// In en, this message translates to:
  /// **'Borrower Profile & History'**
  String get issueTitleBorrower;

  /// No description provided for @issueTitleTerms.
  ///
  /// In en, this message translates to:
  /// **'Loan Terms & Calculator'**
  String get issueTitleTerms;

  /// No description provided for @issueTitleDisburse.
  ///
  /// In en, this message translates to:
  /// **'Review & Disburse'**
  String get issueTitleDisburse;

  /// No description provided for @issueSwitchBorrowers.
  ///
  /// In en, this message translates to:
  /// **'Switch Borrowers'**
  String get issueSwitchBorrowers;

  /// No description provided for @issueAlreadyHasOverdue.
  ///
  /// In en, this message translates to:
  /// **'{name} already has an overdue loan ({id}). Close it before issuing a new one.'**
  String issueAlreadyHasOverdue(String name, String id);

  /// No description provided for @issueAlreadyHasActive.
  ///
  /// In en, this message translates to:
  /// **'{name} already has an active loan ({id}). Close it before issuing a new one.'**
  String issueAlreadyHasActive(String name, String id);

  /// No description provided for @issueConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue loan & disburse?'**
  String get issueConfirmTitle;

  /// No description provided for @issuePayoutCash.
  ///
  /// In en, this message translates to:
  /// **'cash'**
  String get issuePayoutCash;

  /// No description provided for @issuePayoutBank.
  ///
  /// In en, this message translates to:
  /// **'bank transfer'**
  String get issuePayoutBank;

  /// No description provided for @issueConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Hand over {net} ({payout}) to {name}.\n\nRepayable: {total} over {weeks} weeks, {weekly} a week.\n\nThis cannot be undone.'**
  String issueConfirmBody(
    String net,
    String payout,
    String name,
    String total,
    int weeks,
    String weekly,
  );

  /// No description provided for @issueLoanAction.
  ///
  /// In en, this message translates to:
  /// **'Issue loan'**
  String get issueLoanAction;

  /// No description provided for @issueReviewAgain.
  ///
  /// In en, this message translates to:
  /// **'Review again'**
  String get issueReviewAgain;

  /// No description provided for @issueLoanIssued.
  ///
  /// In en, this message translates to:
  /// **'Loan {id} issued to {name}.'**
  String issueLoanIssued(String id, String name);

  /// No description provided for @issueNoServerAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer from the server. Check the borrower’s loans before trying again, in case the loan was already issued.'**
  String get issueNoServerAnswer;

  /// No description provided for @issueNewLoan.
  ///
  /// In en, this message translates to:
  /// **'Issue New Loan'**
  String get issueNewLoan;

  /// No description provided for @issueStepOfTitle.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}: {title}'**
  String issueStepOfTitle(int step, int total, String title);

  /// No description provided for @issueLoadBorrowerFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the borrower.'**
  String get issueLoadBorrowerFailed;

  /// No description provided for @issueChooseBorrower.
  ///
  /// In en, this message translates to:
  /// **'Choose a borrower first.'**
  String get issueChooseBorrower;

  /// No description provided for @issueContinueTerms.
  ///
  /// In en, this message translates to:
  /// **'Continue to terms'**
  String get issueContinueTerms;

  /// No description provided for @issueNextStep.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get issueNextStep;

  /// No description provided for @facilityPaymentOverdue.
  ///
  /// In en, this message translates to:
  /// **'Payment overdue'**
  String get facilityPaymentOverdue;

  /// No description provided for @facilityAllPaid.
  ///
  /// In en, this message translates to:
  /// **'All installments paid'**
  String get facilityAllPaid;

  /// No description provided for @facilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Facility'**
  String get facilityTitle;

  /// No description provided for @facilityRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining Balance'**
  String get facilityRemaining;

  /// No description provided for @facilityOfTotal.
  ///
  /// In en, this message translates to:
  /// **'of {amount} Total'**
  String facilityOfTotal(String amount);

  /// No description provided for @facilityNextInstallment.
  ///
  /// In en, this message translates to:
  /// **'Next Installment'**
  String get facilityNextInstallment;

  /// No description provided for @facilityRepaidPercent.
  ///
  /// In en, this message translates to:
  /// **'Repaid: {percent}%'**
  String facilityRepaidPercent(int percent);

  /// No description provided for @facilityPaidAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} Paid'**
  String facilityPaidAmount(String amount);

  /// No description provided for @facilityViewTracks.
  ///
  /// In en, this message translates to:
  /// **'View Tracks'**
  String get facilityViewTracks;

  /// No description provided for @facilityViewPayments.
  ///
  /// In en, this message translates to:
  /// **'View payments'**
  String get facilityViewPayments;

  /// No description provided for @addressNoStreet.
  ///
  /// In en, this message translates to:
  /// **'No street on file'**
  String get addressNoStreet;

  /// No description provided for @creditNewBorrower.
  ///
  /// In en, this message translates to:
  /// **'NEW BORROWER'**
  String get creditNewBorrower;

  /// No description provided for @creditAtRisk.
  ///
  /// In en, this message translates to:
  /// **'AT RISK'**
  String get creditAtRisk;

  /// No description provided for @creditGoodStanding.
  ///
  /// In en, this message translates to:
  /// **'GOOD STANDING'**
  String get creditGoodStanding;

  /// No description provided for @creditFair.
  ///
  /// In en, this message translates to:
  /// **'FAIR'**
  String get creditFair;

  /// No description provided for @creditTitle.
  ///
  /// In en, this message translates to:
  /// **'Field Credit History'**
  String get creditTitle;

  /// No description provided for @creditOnTime.
  ///
  /// In en, this message translates to:
  /// **'ON-TIME'**
  String get creditOnTime;

  /// No description provided for @creditRatio.
  ///
  /// In en, this message translates to:
  /// **'{ratio}% Ratio'**
  String creditRatio(int ratio);

  /// No description provided for @creditDelayed.
  ///
  /// In en, this message translates to:
  /// **'DELAYED'**
  String get creditDelayed;

  /// No description provided for @creditRepaidLate.
  ///
  /// In en, this message translates to:
  /// **'Repaid late'**
  String get creditRepaidLate;

  /// No description provided for @creditDefault.
  ///
  /// In en, this message translates to:
  /// **'DEFAULT'**
  String get creditDefault;

  /// No description provided for @creditCleanSheet.
  ///
  /// In en, this message translates to:
  /// **'Clean Sheet'**
  String get creditCleanSheet;

  /// No description provided for @creditNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get creditNeedsReview;

  /// No description provided for @creditCompletedCycles.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED CYCLES'**
  String get creditCompletedCycles;

  /// No description provided for @creditNoCycles.
  ///
  /// In en, this message translates to:
  /// **'No completed cycles yet'**
  String get creditNoCycles;

  /// No description provided for @creditDelayRepaid.
  ///
  /// In en, this message translates to:
  /// **'DELAY REPAID'**
  String get creditDelayRepaid;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'CLOSED'**
  String get statusClosed;

  /// No description provided for @creditCycleLine.
  ///
  /// In en, this message translates to:
  /// **'Cycle #{cycle} • {id}'**
  String creditCycleLine(int cycle, String id);

  /// No description provided for @creditClosedLine.
  ///
  /// In en, this message translates to:
  /// **'Closed {date} • {amount}'**
  String creditClosedLine(String date, String amount);

  /// No description provided for @issueBarOnePerBorrower.
  ///
  /// In en, this message translates to:
  /// **'One active loan per borrower'**
  String get issueBarOnePerBorrower;

  /// No description provided for @issueBarCycle.
  ///
  /// In en, this message translates to:
  /// **'Cycle {cycle}'**
  String issueBarCycle(int cycle);

  /// No description provided for @issueBarIssueLoan.
  ///
  /// In en, this message translates to:
  /// **'ISSUE LOAN'**
  String get issueBarIssueLoan;

  /// No description provided for @issueBarIssueLoanTo.
  ///
  /// In en, this message translates to:
  /// **'ISSUE LOAN TO {name}'**
  String issueBarIssueLoanTo(String name);

  /// No description provided for @issueBarHint.
  ///
  /// In en, this message translates to:
  /// **'Check credit limits & calculate custom repayment schedule'**
  String get issueBarHint;

  /// No description provided for @socialTitle.
  ///
  /// In en, this message translates to:
  /// **'Social Network & Guarantees'**
  String get socialTitle;

  /// No description provided for @socialReferredBy.
  ///
  /// In en, this message translates to:
  /// **'Referred By Guarantor'**
  String get socialReferredBy;

  /// No description provided for @socialBorrowersReferred.
  ///
  /// In en, this message translates to:
  /// **'Borrowers Referred'**
  String get socialBorrowersReferred;

  /// No description provided for @profileCycleN.
  ///
  /// In en, this message translates to:
  /// **'Cycle {cycle}'**
  String profileCycleN(int cycle);

  /// No description provided for @profileSince.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String profileSince(String date);

  /// No description provided for @profileSwitchBorrower.
  ///
  /// In en, this message translates to:
  /// **'Switch borrower'**
  String get profileSwitchBorrower;

  /// No description provided for @profileNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profileNotSet;

  /// No description provided for @profileEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every {day}'**
  String profileEveryDay(String day);

  /// No description provided for @profileCollectionRoute.
  ///
  /// In en, this message translates to:
  /// **'Collection route'**
  String get profileCollectionRoute;

  /// No description provided for @profileCollectionDay.
  ///
  /// In en, this message translates to:
  /// **'Collection day'**
  String get profileCollectionDay;

  /// No description provided for @profileStreet.
  ///
  /// In en, this message translates to:
  /// **'Street'**
  String get profileStreet;

  /// No description provided for @profileTownDistrict.
  ///
  /// In en, this message translates to:
  /// **'Town & district'**
  String get profileTownDistrict;

  /// No description provided for @profileCreditHistory.
  ///
  /// In en, this message translates to:
  /// **'Credit history'**
  String get profileCreditHistory;

  /// No description provided for @profileFirstLoan.
  ///
  /// In en, this message translates to:
  /// **'First loan for this borrower. There is no repayment history yet.'**
  String get profileFirstLoan;

  /// No description provided for @profileOnTimeAcross.
  ///
  /// In en, this message translates to:
  /// **'{percent}% repaid on time across {total, plural, =1{1 loan} other{{total} loans}}'**
  String profileOnTimeAcross(int percent, int total);

  /// No description provided for @profileReferralNetwork.
  ///
  /// In en, this message translates to:
  /// **'Referral network'**
  String get profileReferralNetwork;

  /// No description provided for @profileReferredBy.
  ///
  /// In en, this message translates to:
  /// **'Referred by'**
  String get profileReferredBy;

  /// No description provided for @profileSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get profileSource;

  /// No description provided for @profileDirectWalkIn.
  ///
  /// In en, this message translates to:
  /// **'Direct walk-in'**
  String get profileDirectWalkIn;

  /// No description provided for @profileReferred.
  ///
  /// In en, this message translates to:
  /// **'REFERRED'**
  String get profileReferred;

  /// No description provided for @profileActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get profileActive;

  /// No description provided for @profilePaired.
  ///
  /// In en, this message translates to:
  /// **'PAIRED'**
  String get profilePaired;

  /// No description provided for @disburseReady.
  ///
  /// In en, this message translates to:
  /// **'READY FOR DISBURSAL'**
  String get disburseReady;

  /// No description provided for @disburseCheckTerms.
  ///
  /// In en, this message translates to:
  /// **'CHECK TERMS'**
  String get disburseCheckTerms;

  /// No description provided for @disburseSanctioned.
  ///
  /// In en, this message translates to:
  /// **'Sanctioned Principal'**
  String get disburseSanctioned;

  /// No description provided for @disburseUpfrontFeePct.
  ///
  /// In en, this message translates to:
  /// **'Upfront Fee ({percent})'**
  String disburseUpfrontFeePct(String percent);

  /// No description provided for @disburseNetCash.
  ///
  /// In en, this message translates to:
  /// **'NET CASH HANDOVER'**
  String get disburseNetCash;

  /// No description provided for @disburseImmediate.
  ///
  /// In en, this message translates to:
  /// **'Immediate physical disbursal'**
  String get disburseImmediate;

  /// No description provided for @disburseTotalRepayable.
  ///
  /// In en, this message translates to:
  /// **'TOTAL REPAYABLE'**
  String get disburseTotalRepayable;

  /// No description provided for @disburseWeeksShort.
  ///
  /// In en, this message translates to:
  /// **'{weeks} wks'**
  String disburseWeeksShort(int weeks);

  /// No description provided for @disburseWeeklyCadence.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY CADENCE'**
  String get disburseWeeklyCadence;

  /// No description provided for @disbursePayoutMode.
  ///
  /// In en, this message translates to:
  /// **'Payout Mode'**
  String get disbursePayoutMode;

  /// No description provided for @disburseSelectChannel.
  ///
  /// In en, this message translates to:
  /// **'Select 1 channel'**
  String get disburseSelectChannel;

  /// No description provided for @disburseCashInHand.
  ///
  /// In en, this message translates to:
  /// **'Cash in hand'**
  String get disburseCashInHand;

  /// No description provided for @disburseCashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Agent hands over {amount} in currency notes from the collection pouch.'**
  String disburseCashSubtitle(String amount);

  /// No description provided for @disburseFieldStandard.
  ///
  /// In en, this message translates to:
  /// **'FIELD STANDARD'**
  String get disburseFieldStandard;

  /// No description provided for @disburseBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Instant UPI / IMPS Bank Transfer'**
  String get disburseBankTitle;

  /// No description provided for @disburseBankAvailable.
  ///
  /// In en, this message translates to:
  /// **'Disburse to the verified account on file.'**
  String get disburseBankAvailable;

  /// No description provided for @disburseBankUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No verified bank account on file for this borrower.'**
  String get disburseBankUnavailable;

  /// No description provided for @disburseModeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get disburseModeCash;

  /// No description provided for @disburseModeBank.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get disburseModeBank;

  /// No description provided for @disburseNetPhysical.
  ///
  /// In en, this message translates to:
  /// **'NET PHYSICAL HANDOVER'**
  String get disburseNetPhysical;

  /// No description provided for @disburseIssueButton.
  ///
  /// In en, this message translates to:
  /// **'ISSUE LOAN & DISBURSE {amount}'**
  String disburseIssueButton(String amount);

  /// No description provided for @disburseRecorded.
  ///
  /// In en, this message translates to:
  /// **'Disbursal is recorded to the field ledger'**
  String get disburseRecorded;

  /// No description provided for @termsUsingDefaults.
  ///
  /// In en, this message translates to:
  /// **'Using your saved defaults ({fee} fee, {interest} interest, {months} months)'**
  String termsUsingDefaults(String fee, String interest, String months);

  /// No description provided for @termsChangedDefaults.
  ///
  /// In en, this message translates to:
  /// **'You changed the saved defaults'**
  String get termsChangedDefaults;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @termsPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Sanctioned principal amount'**
  String get termsPrincipal;

  /// No description provided for @termsRepaymentMonths.
  ///
  /// In en, this message translates to:
  /// **'Repayment term (months)'**
  String get termsRepaymentMonths;

  /// No description provided for @termsWeeklyMeetings.
  ///
  /// In en, this message translates to:
  /// **'Weekly center meetings'**
  String get termsWeeklyMeetings;

  /// No description provided for @termsCalculatedWeeks.
  ///
  /// In en, this message translates to:
  /// **'Calculated: {weeks} Weeks (4 wks / month cadence)'**
  String termsCalculatedWeeks(int weeks);

  /// No description provided for @termsAutoComputed.
  ///
  /// In en, this message translates to:
  /// **'Auto-computed'**
  String get termsAutoComputed;

  /// No description provided for @termsMonthChip.
  ///
  /// In en, this message translates to:
  /// **'{months} Mo ({weeks} Wks)'**
  String termsMonthChip(String months, int weeks);

  /// No description provided for @termsUpfrontFeeLower.
  ///
  /// In en, this message translates to:
  /// **'Upfront fee'**
  String get termsUpfrontFeeLower;

  /// No description provided for @termsProcessingRisk.
  ///
  /// In en, this message translates to:
  /// **'Processing & risk cover'**
  String get termsProcessingRisk;

  /// No description provided for @termsFlatOnPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Flat on principal, once'**
  String get termsFlatOnPrincipal;

  /// No description provided for @termsDisbursedToday.
  ///
  /// In en, this message translates to:
  /// **'Disbursed: Today, {date}'**
  String termsDisbursedToday(String date);

  /// No description provided for @termsFirstDue.
  ///
  /// In en, this message translates to:
  /// **'1st Due: {date}'**
  String termsFirstDue(String date);

  /// No description provided for @termsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Disbursement Breakdown'**
  String get termsBreakdown;

  /// No description provided for @termsGrossPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Gross Sanctioned Principal'**
  String get termsGrossPrincipal;

  /// No description provided for @termsProcessingRiskPct.
  ///
  /// In en, this message translates to:
  /// **'Processing & Risk Cover ({percent})'**
  String termsProcessingRiskPct(String percent);

  /// No description provided for @termsPhysicalDisbursement.
  ///
  /// In en, this message translates to:
  /// **'PHYSICAL DISBURSEMENT'**
  String get termsPhysicalDisbursement;

  /// No description provided for @termsFlatInterestAdded.
  ///
  /// In en, this message translates to:
  /// **'Flat Interest Added ({percent})'**
  String termsFlatInterestAdded(String percent);

  /// No description provided for @termsTotalRepayablePI.
  ///
  /// In en, this message translates to:
  /// **'Total Repayable (Principal + Int)'**
  String get termsTotalRepayablePI;

  /// No description provided for @termsWeeklyInstallmentWeeks.
  ///
  /// In en, this message translates to:
  /// **'Weekly Installment ({weeks} Weeks)'**
  String termsWeeklyInstallmentWeeks(int weeks);

  /// No description provided for @termsWeeklyCollection.
  ///
  /// In en, this message translates to:
  /// **'Weekly collection'**
  String get termsWeeklyCollection;

  /// No description provided for @termsEveryDayCollection.
  ///
  /// In en, this message translates to:
  /// **'Every {day} collection'**
  String termsEveryDayCollection(String day);

  /// No description provided for @termsPerWeekShort.
  ///
  /// In en, this message translates to:
  /// **' / wk'**
  String get termsPerWeekShort;

  /// No description provided for @termsMilestonePreview.
  ///
  /// In en, this message translates to:
  /// **'Schedule milestone preview'**
  String get termsMilestonePreview;

  /// No description provided for @termsTotalWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks} Total Weeks'**
  String termsTotalWeeks(int weeks);

  /// No description provided for @termsHideAmortization.
  ///
  /// In en, this message translates to:
  /// **'Hide amortization'**
  String get termsHideAmortization;

  /// No description provided for @termsViewAmortization.
  ///
  /// In en, this message translates to:
  /// **'View detailed {weeks}-week amortization'**
  String termsViewAmortization(int weeks);

  /// No description provided for @termsPreviewOnly.
  ///
  /// In en, this message translates to:
  /// **'Preview only. The final schedule is calculated when the loan is issued.'**
  String get termsPreviewOnly;

  /// No description provided for @termsWeekDate.
  ///
  /// In en, this message translates to:
  /// **'Wk #{week} ({date})'**
  String termsWeekDate(int week, String date);

  /// No description provided for @termsFinalSettlement.
  ///
  /// In en, this message translates to:
  /// **'Final Settlement'**
  String get termsFinalSettlement;

  /// No description provided for @termsColWeek.
  ///
  /// In en, this message translates to:
  /// **'WEEK'**
  String get termsColWeek;

  /// No description provided for @termsColDue.
  ///
  /// In en, this message translates to:
  /// **'DUE'**
  String get termsColDue;

  /// No description provided for @termsColInstallment.
  ///
  /// In en, this message translates to:
  /// **'INSTALLMENT'**
  String get termsColInstallment;

  /// No description provided for @termsColBalance.
  ///
  /// In en, this message translates to:
  /// **'BALANCE'**
  String get termsColBalance;

  /// No description provided for @termsDayRoute.
  ///
  /// In en, this message translates to:
  /// **' • {day} Route'**
  String termsDayRoute(String day);

  /// No description provided for @commonDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get commonDecrease;

  /// No description provided for @commonIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get commonIncrease;

  /// No description provided for @loanStageActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get loanStageActive;

  /// No description provided for @loanStagePaidOff.
  ///
  /// In en, this message translates to:
  /// **'PAID OFF'**
  String get loanStagePaidOff;

  /// No description provided for @loanStageDefaulted.
  ///
  /// In en, this message translates to:
  /// **'DEFAULTED'**
  String get loanStageDefaulted;

  /// No description provided for @loanStageUnknown.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get loanStageUnknown;

  /// No description provided for @loanReopenBlockedOther.
  ///
  /// In en, this message translates to:
  /// **'This borrower already has another active or overdue loan.'**
  String get loanReopenBlockedOther;

  /// No description provided for @loanReopenCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check the borrower’s other loans. Refresh and try again.'**
  String get loanReopenCheckFailed;

  /// No description provided for @loanStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Loan status updated.'**
  String get loanStatusUpdated;

  /// No description provided for @loanPaymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded.'**
  String get loanPaymentRecorded;

  /// No description provided for @loanTitleId.
  ///
  /// In en, this message translates to:
  /// **'Loan {id}'**
  String loanTitleId(String id);

  /// No description provided for @loanMenuTracks.
  ///
  /// In en, this message translates to:
  /// **'Repayment tracks'**
  String get loanMenuTracks;

  /// No description provided for @loanMenuPayments.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get loanMenuPayments;

  /// No description provided for @loanMenuCall.
  ///
  /// In en, this message translates to:
  /// **'Call borrower'**
  String get loanMenuCall;

  /// No description provided for @loanMenuChangeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get loanMenuChangeStatus;

  /// No description provided for @loanLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this loan.'**
  String get loanLoadFailed;

  /// No description provided for @loanRepaymentSchedule.
  ///
  /// In en, this message translates to:
  /// **'Repayment schedule'**
  String get loanRepaymentSchedule;

  /// No description provided for @loanViewAllWeeks.
  ///
  /// In en, this message translates to:
  /// **'View all {count} weeks'**
  String loanViewAllWeeks(int count);

  /// No description provided for @loanMoreOverdueWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count} more overdue weeks'**
  String loanMoreOverdueWeeks(int count);

  /// No description provided for @loanCollectOverdue.
  ///
  /// In en, this message translates to:
  /// **'Collect overdue • {amount}'**
  String loanCollectOverdue(String amount);

  /// No description provided for @loanRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get loanRecordPayment;

  /// No description provided for @loanIssueNew.
  ///
  /// In en, this message translates to:
  /// **'Issue new loan'**
  String get loanIssueNew;

  /// No description provided for @loanViewPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'View payment history'**
  String get loanViewPaymentHistory;

  /// No description provided for @loanPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get loanPayments;

  /// No description provided for @loanLoadDetailsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the loan details.'**
  String get loanLoadDetailsFailed;

  /// No description provided for @loanTotalCollected.
  ///
  /// In en, this message translates to:
  /// **'TOTAL COLLECTED'**
  String get loanTotalCollected;

  /// No description provided for @loanOutstanding.
  ///
  /// In en, this message translates to:
  /// **'OUTSTANDING'**
  String get loanOutstanding;

  /// No description provided for @loanTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {amount}'**
  String loanTarget(String amount);

  /// No description provided for @loanPercentCleared.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Cleared'**
  String loanPercentCleared(int percent);

  /// No description provided for @loanTotalPaid.
  ///
  /// In en, this message translates to:
  /// **'TOTAL PAID'**
  String get loanTotalPaid;

  /// No description provided for @loanCoverage.
  ///
  /// In en, this message translates to:
  /// **'COVERAGE'**
  String get loanCoverage;

  /// No description provided for @loanWeeksCount.
  ///
  /// In en, this message translates to:
  /// **'{weeks} Weeks'**
  String loanWeeksCount(int weeks);

  /// No description provided for @loanLastLog.
  ///
  /// In en, this message translates to:
  /// **'LAST LOG'**
  String get loanLastLog;

  /// No description provided for @loanNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments found'**
  String get loanNoPayments;

  /// No description provided for @loanLoadingOlder.
  ///
  /// In en, this message translates to:
  /// **'Loading older payments...'**
  String get loanLoadingOlder;

  /// No description provided for @loanNoMorePayments.
  ///
  /// In en, this message translates to:
  /// **'No more payments'**
  String get loanNoMorePayments;

  /// No description provided for @trackerPaymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Successfull'**
  String get trackerPaymentSuccess;

  /// No description provided for @trackerOnlyOpenLoans.
  ///
  /// In en, this message translates to:
  /// **'Only active or overdue loans take payments.'**
  String get trackerOnlyOpenLoans;

  /// No description provided for @trackerAllWeeksHavePayment.
  ///
  /// In en, this message translates to:
  /// **'Every week already has a payment. Use Collect on a partial week.'**
  String get trackerAllWeeksHavePayment;

  /// No description provided for @trackerRecordWeekly.
  ///
  /// In en, this message translates to:
  /// **'+ Record Weekly Payment'**
  String get trackerRecordWeekly;

  /// No description provided for @trackerCycle.
  ///
  /// In en, this message translates to:
  /// **'CYCLE {cycle}'**
  String trackerCycle(int cycle);

  /// No description provided for @trackerActiveLoan.
  ///
  /// In en, this message translates to:
  /// **'Active Loan'**
  String get trackerActiveLoan;

  /// No description provided for @trackerWeeklyTarget.
  ///
  /// In en, this message translates to:
  /// **'Weekly Target'**
  String get trackerWeeklyTarget;

  /// No description provided for @trackerPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get trackerPrincipal;

  /// No description provided for @trackerTotalDue.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get trackerTotalDue;

  /// No description provided for @trackerTenure.
  ///
  /// In en, this message translates to:
  /// **'Tenure'**
  String get trackerTenure;

  /// No description provided for @trackerCollected.
  ///
  /// In en, this message translates to:
  /// **'COLLECTED'**
  String get trackerCollected;

  /// No description provided for @trackerWeeksLeft.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks left'**
  String trackerWeeksLeft(int weeks);

  /// No description provided for @trackerNextDue.
  ///
  /// In en, this message translates to:
  /// **'NEXT DUE'**
  String get trackerNextDue;

  /// No description provided for @trackerAllPaid.
  ///
  /// In en, this message translates to:
  /// **'ALL PAID'**
  String get trackerAllPaid;

  /// No description provided for @trackerLoanCompleted.
  ///
  /// In en, this message translates to:
  /// **'Loan completed'**
  String get trackerLoanCompleted;

  /// No description provided for @trackerWeekShortDate.
  ///
  /// In en, this message translates to:
  /// **'W{week} • {date}'**
  String trackerWeekShortDate(int week, String date);

  /// No description provided for @trackerDaysLate.
  ///
  /// In en, this message translates to:
  /// **'W{week} • {days}d late'**
  String trackerDaysLate(int week, int days);

  /// No description provided for @trackerDueToday.
  ///
  /// In en, this message translates to:
  /// **'DUE TODAY'**
  String get trackerDueToday;

  /// No description provided for @trackerDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'DUE TOMORROW'**
  String get trackerDueTomorrow;

  /// No description provided for @trackerWeeklyTracks.
  ///
  /// In en, this message translates to:
  /// **'Weekly Repayment Tracks'**
  String get trackerWeeklyTracks;

  /// No description provided for @trackerInstallmentsPlanned.
  ///
  /// In en, this message translates to:
  /// **'{count} Total Installments Planned'**
  String trackerInstallmentsPlanned(int count);

  /// No description provided for @trackerLedger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get trackerLedger;

  /// No description provided for @loansFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get loansFilterAll;

  /// No description provided for @loansFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get loansFilterActive;

  /// No description provided for @loansFilterOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get loansFilterOverdue;

  /// No description provided for @loansFilterPaidOff.
  ///
  /// In en, this message translates to:
  /// **'Paid off'**
  String get loansFilterPaidOff;

  /// No description provided for @loansFilterDefaulted.
  ///
  /// In en, this message translates to:
  /// **'Defaulted'**
  String get loansFilterDefaulted;

  /// No description provided for @loansFilterClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get loansFilterClosed;

  /// No description provided for @loansSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search loan by name and phone number...'**
  String get loansSearchHint;

  /// No description provided for @loansNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No loans found'**
  String get loansNoneFound;

  /// No description provided for @loansNoMore.
  ///
  /// In en, this message translates to:
  /// **'No more loans'**
  String get loansNoMore;

  /// No description provided for @loansCallPhone.
  ///
  /// In en, this message translates to:
  /// **'call {phone}'**
  String loansCallPhone(String phone);

  /// No description provided for @loansSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get loansSettled;

  /// No description provided for @loansPerWeek.
  ///
  /// In en, this message translates to:
  /// **'{amount}/wk'**
  String loansPerWeek(String amount);

  /// No description provided for @loansTotalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Payable'**
  String get loansTotalPayable;

  /// No description provided for @loansCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get loansCollected;

  /// No description provided for @loansRemaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get loansRemaining;

  /// No description provided for @loansDisbursed.
  ///
  /// In en, this message translates to:
  /// **'Disbursed: {amount}'**
  String loansDisbursed(String amount);

  /// No description provided for @loansViewLedger.
  ///
  /// In en, this message translates to:
  /// **'View Ledger'**
  String get loansViewLedger;

  /// No description provided for @statusFooterClosed.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get statusFooterClosed;

  /// No description provided for @statusFooterDefaulted.
  ///
  /// In en, this message translates to:
  /// **'An admin can reopen it later if needed.'**
  String get statusFooterDefaulted;

  /// No description provided for @statusFooterReopen.
  ///
  /// In en, this message translates to:
  /// **'You can mark it defaulted or closed again later.'**
  String get statusFooterReopen;

  /// No description provided for @statusReopenMessage.
  ///
  /// In en, this message translates to:
  /// **'{who}\n\n{amount} becomes collectable again. If a week is already past due, the loan shows as overdue automatically.\n\n{footer}'**
  String statusReopenMessage(String who, String amount, String footer);

  /// No description provided for @statusWriteOffLine.
  ///
  /// In en, this message translates to:
  /// **'{amount} is still unpaid and will be written off.\n\n'**
  String statusWriteOffLine(String amount);

  /// No description provided for @statusReopenTitle.
  ///
  /// In en, this message translates to:
  /// **'Reopen this loan?'**
  String get statusReopenTitle;

  /// No description provided for @statusMarkAsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark loan as {status}?'**
  String statusMarkAsTitle(String status);

  /// No description provided for @statusReopenLoan.
  ///
  /// In en, this message translates to:
  /// **'Reopen loan'**
  String get statusReopenLoan;

  /// No description provided for @statusMarkAs.
  ///
  /// In en, this message translates to:
  /// **'Mark {status}'**
  String statusMarkAs(String status);

  /// No description provided for @statusGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get statusGoBack;

  /// No description provided for @statusNoServerAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer from the server. Refresh the loan before trying again, in case the status was already changed.'**
  String get statusNoServerAnswer;

  /// No description provided for @statusSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Change loan status'**
  String get statusSheetTitle;

  /// No description provided for @statusAutoNote.
  ///
  /// In en, this message translates to:
  /// **'Overdue and Paid off are set automatically from payments, so they cannot be chosen here.'**
  String get statusAutoNote;

  /// No description provided for @statusClosedCannotChange.
  ///
  /// In en, this message translates to:
  /// **'This loan is closed and cannot be changed.'**
  String get statusClosedCannotChange;

  /// No description provided for @statusNoPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to change this loan’s status.'**
  String get statusNoPermission;

  /// No description provided for @statusMoveTo.
  ///
  /// In en, this message translates to:
  /// **'MOVE TO'**
  String get statusMoveTo;

  /// No description provided for @statusReopenWarning.
  ///
  /// In en, this message translates to:
  /// **'Collections resume on this loan. If a week is already past due, it will show as overdue automatically.'**
  String get statusReopenWarning;

  /// No description provided for @statusDefaultWarning.
  ///
  /// In en, this message translates to:
  /// **'{amount} is still unpaid. Marking the loan as defaulted writes it off.'**
  String statusDefaultWarning(String amount);

  /// No description provided for @statusCloseWarning.
  ///
  /// In en, this message translates to:
  /// **'{amount} is still unpaid. Closing the loan writes it off.'**
  String statusCloseWarning(String amount);

  /// No description provided for @statusUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update status'**
  String get statusUpdate;

  /// No description provided for @statusCurrentStatus.
  ///
  /// In en, this message translates to:
  /// **'CURRENT STATUS'**
  String get statusCurrentStatus;

  /// No description provided for @statusCurrent.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get statusCurrent;

  /// No description provided for @bannerOverdueTitle.
  ///
  /// In en, this message translates to:
  /// **'Overdue • {days, plural, =1{1 day} other{{days} days}} late'**
  String bannerOverdueTitle(int days);

  /// No description provided for @bannerOverdueBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} across {weeks, plural, =1{1 week} other{{weeks} weeks}} is past due.'**
  String bannerOverdueBody(String amount, int weeks);

  /// No description provided for @bannerTermEnded.
  ///
  /// In en, this message translates to:
  /// **' The {weeks}-week term has ended.'**
  String bannerTermEnded(int weeks);

  /// No description provided for @bannerFullyRepaid.
  ///
  /// In en, this message translates to:
  /// **'Fully repaid'**
  String get bannerFullyRepaid;

  /// No description provided for @bannerPaidOffBody.
  ///
  /// In en, this message translates to:
  /// **'All {weeks} weekly installments are collected. {amount} received in total.'**
  String bannerPaidOffBody(int weeks, String amount);

  /// No description provided for @bannerLoanClosed.
  ///
  /// In en, this message translates to:
  /// **'Loan closed'**
  String get bannerLoanClosed;

  /// No description provided for @bannerClosedOn.
  ///
  /// In en, this message translates to:
  /// **'Closed on {date}.'**
  String bannerClosedOn(String date);

  /// No description provided for @bannerLeftUnpaid.
  ///
  /// In en, this message translates to:
  /// **'{amount} was left unpaid.'**
  String bannerLeftUnpaid(String amount);

  /// No description provided for @bannerThisLoanClosed.
  ///
  /// In en, this message translates to:
  /// **'This loan is closed.'**
  String get bannerThisLoanClosed;

  /// No description provided for @bannerMarkedDefaulted.
  ///
  /// In en, this message translates to:
  /// **'Marked as defaulted'**
  String get bannerMarkedDefaulted;

  /// No description provided for @bannerStillOutstanding.
  ///
  /// In en, this message translates to:
  /// **'{amount} is still outstanding.'**
  String bannerStillOutstanding(String amount);

  /// No description provided for @sectionDayRoute.
  ///
  /// In en, this message translates to:
  /// **'{day} route'**
  String sectionDayRoute(String day);

  /// No description provided for @balanceWeeksPastDue.
  ///
  /// In en, this message translates to:
  /// **'{weeks, plural, =1{1 week} other{{weeks} weeks}} past due'**
  String balanceWeeksPastDue(int weeks);

  /// No description provided for @balanceNextInstallment.
  ///
  /// In en, this message translates to:
  /// **'NEXT INSTALLMENT'**
  String get balanceNextInstallment;

  /// No description provided for @balanceNothingScheduled.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled'**
  String get balanceNothingScheduled;

  /// No description provided for @balanceSettled.
  ///
  /// In en, this message translates to:
  /// **'SETTLED'**
  String get balanceSettled;

  /// No description provided for @balanceNoBalance.
  ///
  /// In en, this message translates to:
  /// **'No balance left'**
  String get balanceNoBalance;

  /// No description provided for @balanceUnpaidAtClose.
  ///
  /// In en, this message translates to:
  /// **'UNPAID AT CLOSE'**
  String get balanceUnpaidAtClose;

  /// No description provided for @balanceRepaymentProgress.
  ///
  /// In en, this message translates to:
  /// **'Loan repayment progress'**
  String get balanceRepaymentProgress;

  /// No description provided for @balanceRepaidPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% repaid'**
  String balanceRepaidPercent(String percent);

  /// No description provided for @balanceWeeksPaid.
  ///
  /// In en, this message translates to:
  /// **'{paid} of {total} weeks paid'**
  String balanceWeeksPaid(int paid, int total);

  /// No description provided for @recentNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded yet.'**
  String get recentNoPayments;

  /// No description provided for @recentPayments.
  ///
  /// In en, this message translates to:
  /// **'Recent payments'**
  String get recentPayments;

  /// No description provided for @commonViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get commonViewAll;

  /// No description provided for @contractPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Sanctioned principal'**
  String get contractPrincipal;

  /// No description provided for @contractUpfrontFee.
  ///
  /// In en, this message translates to:
  /// **'Upfront fee ({percent}%)'**
  String contractUpfrontFee(String percent);

  /// No description provided for @contractNetDisbursed.
  ///
  /// In en, this message translates to:
  /// **'Net disbursed'**
  String get contractNetDisbursed;

  /// No description provided for @contractFlatInterest.
  ///
  /// In en, this message translates to:
  /// **'Flat interest'**
  String get contractFlatInterest;

  /// No description provided for @contractTotalRepayable.
  ///
  /// In en, this message translates to:
  /// **'Total repayable'**
  String get contractTotalRepayable;

  /// No description provided for @contractWeeklyInstallment.
  ///
  /// In en, this message translates to:
  /// **'Weekly installment'**
  String get contractWeeklyInstallment;

  /// No description provided for @contractTerm.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get contractTerm;

  /// No description provided for @contractTermValue.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks ({months} months)'**
  String contractTermValue(int weeks, String months);

  /// No description provided for @contractDisbursedOn.
  ///
  /// In en, this message translates to:
  /// **'Disbursed on'**
  String get contractDisbursedOn;

  /// No description provided for @contractMaturesOn.
  ///
  /// In en, this message translates to:
  /// **'Matures on'**
  String get contractMaturesOn;

  /// No description provided for @contractClosedOn.
  ///
  /// In en, this message translates to:
  /// **'Closed on'**
  String get contractClosedOn;

  /// No description provided for @contractDetails.
  ///
  /// In en, this message translates to:
  /// **'Contract details'**
  String get contractDetails;

  /// No description provided for @borrowersTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get borrowersTotal;

  /// No description provided for @borrowersActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get borrowersActive;

  /// No description provided for @borrowersDues.
  ///
  /// In en, this message translates to:
  /// **'dues'**
  String get borrowersDues;

  /// No description provided for @borrowersReferrals.
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get borrowersReferrals;

  /// No description provided for @borrowersNet.
  ///
  /// In en, this message translates to:
  /// **'net'**
  String get borrowersNet;

  /// No description provided for @borrowersActiveLoan.
  ///
  /// In en, this message translates to:
  /// **'Active Loan'**
  String get borrowersActiveLoan;

  /// No description provided for @borrowersOverdueLoan.
  ///
  /// In en, this message translates to:
  /// **'Overdue Loan'**
  String get borrowersOverdueLoan;

  /// No description provided for @borrowersNoActiveLoans.
  ///
  /// In en, this message translates to:
  /// **'No Active Loans'**
  String get borrowersNoActiveLoans;

  /// No description provided for @borrowersCollectPayment.
  ///
  /// In en, this message translates to:
  /// **'Collect payment'**
  String get borrowersCollectPayment;

  /// No description provided for @tracksNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No tracks found'**
  String get tracksNoneFound;

  /// No description provided for @tracksTitle.
  ///
  /// In en, this message translates to:
  /// **'Repayment Tracks'**
  String get tracksTitle;

  /// No description provided for @tracksWeeksShort.
  ///
  /// In en, this message translates to:
  /// **'{weeks} Wks'**
  String tracksWeeksShort(int weeks);

  /// No description provided for @tracksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{name} • Active Facility {id}'**
  String tracksSubtitle(String name, String id);

  /// No description provided for @tracksCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get tracksCompleted;

  /// No description provided for @tracksPaidCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Paid'**
  String tracksPaidCount(int count);

  /// No description provided for @tracksTrackCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Track'**
  String tracksTrackCount(int count);

  /// No description provided for @tracksFacilityBal.
  ///
  /// In en, this message translates to:
  /// **'FACILITY BAL'**
  String get tracksFacilityBal;

  /// No description provided for @rangeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rangeToday;

  /// No description provided for @rangeLast7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get rangeLast7;

  /// No description provided for @rangeLast30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get rangeLast30;

  /// No description provided for @rangeLast90.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get rangeLast90;

  /// No description provided for @rangeThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get rangeThisMonth;

  /// No description provided for @rangeLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get rangeLastMonth;

  /// No description provided for @rangeCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get rangeCustom;

  /// No description provided for @agoJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get agoJustNow;

  /// No description provided for @agoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{m} min ago'**
  String agoMinutes(int m);

  /// No description provided for @agoHours.
  ///
  /// In en, this message translates to:
  /// **'{h} h ago'**
  String agoHours(int h);

  /// No description provided for @agoDays.
  ///
  /// In en, this message translates to:
  /// **'{d} d ago'**
  String agoDays(int d);

  /// No description provided for @offlineNoData.
  ///
  /// In en, this message translates to:
  /// **'You are offline.'**
  String get offlineNoData;

  /// No description provided for @offlineShowingFrom.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Showing numbers from {ago}.'**
  String offlineShowingFrom(String ago);

  /// No description provided for @updatedPullRefresh.
  ///
  /// In en, this message translates to:
  /// **'Updated {ago}. Pull down to refresh.'**
  String updatedPullRefresh(String ago);

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh.'**
  String get pullToRefresh;

  /// No description provided for @anTabPulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get anTabPulse;

  /// No description provided for @anTabCollections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get anTabCollections;

  /// No description provided for @anTabPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get anTabPortfolio;

  /// No description provided for @anTabCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get anTabCustomers;

  /// No description provided for @anTabTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get anTabTeam;

  /// No description provided for @anTabForecast.
  ///
  /// In en, this message translates to:
  /// **'Forecast'**
  String get anTabForecast;

  /// No description provided for @anTabAdmins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get anTabAdmins;

  /// No description provided for @anTabMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get anTabMoney;

  /// No description provided for @anTabRisk.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get anTabRisk;

  /// No description provided for @anTabGeography.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get anTabGeography;

  /// No description provided for @anTabPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get anTabPeople;

  /// No description provided for @anNoAccess.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to this view.'**
  String get anNoAccess;

  /// No description provided for @anSegAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get anSegAnalytics;

  /// No description provided for @anSegPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get anSegPlatform;

  /// No description provided for @dueListTitle.
  ///
  /// In en, this message translates to:
  /// **'Due list'**
  String get dueListTitle;

  /// No description provided for @dueNoneScheduled.
  ///
  /// In en, this message translates to:
  /// **'No loans are scheduled for {day}.'**
  String dueNoneScheduled(String day);

  /// No description provided for @dueNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No loans match \"{query}\".'**
  String dueNoMatch(String query);

  /// No description provided for @dueCollectedVsTarget.
  ///
  /// In en, this message translates to:
  /// **'Collected against target for the day'**
  String get dueCollectedVsTarget;

  /// No description provided for @dueCollectedOfTarget.
  ///
  /// In en, this message translates to:
  /// **'{collected} collected of {target} target'**
  String dueCollectedOfTarget(String collected, String target);

  /// No description provided for @dueScheduledFor.
  ///
  /// In en, this message translates to:
  /// **'Loans scheduled for {day}'**
  String dueScheduledFor(String day);

  /// No description provided for @dueSummaryLine.
  ///
  /// In en, this message translates to:
  /// **'{customers} customers • {active} active • {overdue} overdue'**
  String dueSummaryLine(int customers, int active, int overdue);

  /// No description provided for @dueListNote.
  ///
  /// In en, this message translates to:
  /// **'The list shows loans scheduled for {day} as they stand now, not who paid on this date.'**
  String dueListNote(String day);

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// No description provided for @dueOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding {amount}'**
  String dueOutstanding(String amount);

  /// No description provided for @dueLabel.
  ///
  /// In en, this message translates to:
  /// **'due'**
  String get dueLabel;

  /// No description provided for @dueOnSchedule.
  ///
  /// In en, this message translates to:
  /// **'ON SCHEDULE'**
  String get dueOnSchedule;

  /// No description provided for @anViewing.
  ///
  /// In en, this message translates to:
  /// **'Viewing: {name}'**
  String anViewing(String name);

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @anAllAdmins.
  ///
  /// In en, this message translates to:
  /// **'All admins'**
  String get anAllAdmins;

  /// No description provided for @anAllEmployees.
  ///
  /// In en, this message translates to:
  /// **'All employees'**
  String get anAllEmployees;

  /// No description provided for @anMaxRange.
  ///
  /// In en, this message translates to:
  /// **'Pick a range of at most {days} days.'**
  String anMaxRange(int days);

  /// No description provided for @anDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get anDateRange;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @anChooseAdmin.
  ///
  /// In en, this message translates to:
  /// **'Choose an admin'**
  String get anChooseAdmin;

  /// No description provided for @anChooseEmployee.
  ///
  /// In en, this message translates to:
  /// **'Choose an employee'**
  String get anChooseEmployee;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @anNobodyMatches.
  ///
  /// In en, this message translates to:
  /// **'Nobody matches.'**
  String get anNobodyMatches;

  /// No description provided for @anTakingLonger.
  ///
  /// In en, this message translates to:
  /// **'Taking longer than usual.'**
  String get anTakingLonger;

  /// No description provided for @anCardLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this card.'**
  String get anCardLoadFailed;

  /// No description provided for @anDeltaPts.
  ///
  /// In en, this message translates to:
  /// **'{value} pts'**
  String anDeltaPts(String value);

  /// No description provided for @anNoChange.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get anNoChange;

  /// No description provided for @anDeltaNew.
  ///
  /// In en, this message translates to:
  /// **'{value} (new)'**
  String anDeltaNew(String value);

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// No description provided for @anShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show more ({left} left)'**
  String anShowMore(int left);

  /// No description provided for @dayMonAbbr.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMonAbbr;

  /// No description provided for @dayTueAbbr.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTueAbbr;

  /// No description provided for @dayWedAbbr.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWedAbbr;

  /// No description provided for @dayThuAbbr.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThuAbbr;

  /// No description provided for @dayFriAbbr.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFriAbbr;

  /// No description provided for @daySatAbbr.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySatAbbr;

  /// No description provided for @daySunAbbr.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySunAbbr;

  /// No description provided for @anInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get anInsights;

  /// No description provided for @anInsightsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Insights appear once your customers have loans.'**
  String get anInsightsEmpty;

  /// No description provided for @anShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get anShowLess;

  /// No description provided for @anSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all {count}'**
  String anSeeAll(int count);

  /// No description provided for @anCollectionsVsTarget.
  ///
  /// In en, this message translates to:
  /// **'Collections vs target'**
  String get anCollectionsVsTarget;

  /// No description provided for @anGroupDayShort.
  ///
  /// In en, this message translates to:
  /// **'D'**
  String get anGroupDayShort;

  /// No description provided for @anGroupWeekShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get anGroupWeekShort;

  /// No description provided for @anGroupMonthShort.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get anGroupMonthShort;

  /// No description provided for @anNoCollectionsPeriod.
  ///
  /// In en, this message translates to:
  /// **'No collections in this period. Try a longer range.'**
  String get anNoCollectionsPeriod;

  /// No description provided for @anTrendSemantics.
  ///
  /// In en, this message translates to:
  /// **'Collections trend, total {amount}'**
  String anTrendSemantics(String amount);

  /// No description provided for @anBestDay.
  ///
  /// In en, this message translates to:
  /// **'Best day: {label} {amount}'**
  String anBestDay(String label, String amount);

  /// No description provided for @anBestWeek.
  ///
  /// In en, this message translates to:
  /// **'Best week: {label} {amount}'**
  String anBestWeek(String label, String amount);

  /// No description provided for @anBestMonth.
  ///
  /// In en, this message translates to:
  /// **'Best month: {label} {amount}'**
  String anBestMonth(String label, String amount);

  /// No description provided for @anOfTarget.
  ///
  /// In en, this message translates to:
  /// **' of {amount}'**
  String anOfTarget(String amount);

  /// No description provided for @anOutstandingByAge.
  ///
  /// In en, this message translates to:
  /// **'Outstanding by age'**
  String get anOutstandingByAge;

  /// No description provided for @anNothingOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Nothing outstanding right now.'**
  String get anNothingOutstanding;

  /// No description provided for @anAgingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Aging, total outstanding {amount}'**
  String anAgingSemantics(String amount);

  /// No description provided for @anLoansAmount.
  ///
  /// In en, this message translates to:
  /// **'{count} loans • {amount}'**
  String anLoansAmount(int count, String amount);

  /// No description provided for @anPortfolioHealth.
  ///
  /// In en, this message translates to:
  /// **'Portfolio health'**
  String get anPortfolioHealth;

  /// No description provided for @anNoLoansYet.
  ///
  /// In en, this message translates to:
  /// **'No loans yet.'**
  String get anNoLoansYet;

  /// No description provided for @anStatusSemantics.
  ///
  /// In en, this message translates to:
  /// **'Loan status, {total} loans'**
  String anStatusSemantics(int total);

  /// No description provided for @anLoansWord.
  ///
  /// In en, this message translates to:
  /// **'loans'**
  String get anLoansWord;

  /// No description provided for @anCollectionCalendar.
  ///
  /// In en, this message translates to:
  /// **'Collection calendar'**
  String get anCollectionCalendar;

  /// No description provided for @anPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get anPrevMonth;

  /// No description provided for @anNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get anNextMonth;

  /// No description provided for @anCollectedOf.
  ///
  /// In en, this message translates to:
  /// **'{collected} of {target}'**
  String anCollectedOf(String collected, String target);

  /// No description provided for @anTargetAmount.
  ///
  /// In en, this message translates to:
  /// **'Target {amount}'**
  String anTargetAmount(String amount);

  /// No description provided for @anPaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid {amount}'**
  String anPaidAmount(String amount);

  /// No description provided for @anOpenDueList.
  ///
  /// In en, this message translates to:
  /// **'Open due list'**
  String get anOpenDueList;

  /// No description provided for @anTapDay.
  ///
  /// In en, this message translates to:
  /// **'Tap a day for its target and collection.'**
  String get anTapDay;

  /// No description provided for @anDayUpcoming.
  ///
  /// In en, this message translates to:
  /// **'upcoming'**
  String get anDayUpcoming;

  /// No description provided for @anDayNothingDue.
  ///
  /// In en, this message translates to:
  /// **'nothing due'**
  String get anDayNothingDue;

  /// No description provided for @anByWeekday.
  ///
  /// In en, this message translates to:
  /// **'By weekday'**
  String get anByWeekday;

  /// No description provided for @anWeekdaySemantics.
  ///
  /// In en, this message translates to:
  /// **'Target against collected for each weekday'**
  String get anWeekdaySemantics;

  /// No description provided for @anTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get anTarget;

  /// No description provided for @anCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get anCollected;

  /// No description provided for @anCustomersUnderDay.
  ///
  /// In en, this message translates to:
  /// **'Customers under each day'**
  String get anCustomersUnderDay;

  /// No description provided for @anRepaymentByMonth.
  ///
  /// In en, this message translates to:
  /// **'Repayment by issue month'**
  String get anRepaymentByMonth;

  /// No description provided for @anRepaid.
  ///
  /// In en, this message translates to:
  /// **'Repaid'**
  String get anRepaid;

  /// No description provided for @anOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get anOnTrack;

  /// No description provided for @anCohortsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cohorts appear once loans have been issued for a few weeks.'**
  String get anCohortsEmpty;

  /// No description provided for @anCohortSemantics.
  ///
  /// In en, this message translates to:
  /// **'Repayment curves for each issue month'**
  String get anCohortSemantics;

  /// No description provided for @anWeeksSinceIssue.
  ///
  /// In en, this message translates to:
  /// **'Weeks since issue'**
  String get anWeeksSinceIssue;

  /// No description provided for @anWeekPercent.
  ///
  /// In en, this message translates to:
  /// **'Week {week}: {percent}%'**
  String anWeekPercent(int week, String percent);

  /// No description provided for @anCohortSummary.
  ///
  /// In en, this message translates to:
  /// **'{month}: {loans} loans • {amount}'**
  String anCohortSummary(String month, int loans, String amount);

  /// No description provided for @anPercentDefaulted.
  ///
  /// In en, this message translates to:
  /// **' • {percent}% defaulted'**
  String anPercentDefaulted(String percent);

  /// No description provided for @anCohortTooEarly.
  ///
  /// In en, this message translates to:
  /// **'Too early to read this cohort.'**
  String get anCohortTooEarly;

  /// No description provided for @anCohortRepaid.
  ///
  /// In en, this message translates to:
  /// **'Loans issued in {month} have repaid {percent}% of what they owe after {weeks} weeks'**
  String anCohortRepaid(String month, String percent, int weeks);

  /// No description provided for @anCohortOnTrack.
  ///
  /// In en, this message translates to:
  /// **'; the schedule says {percent}%, so they are on track.'**
  String anCohortOnTrack(String percent);

  /// No description provided for @anCohortBehind.
  ///
  /// In en, this message translates to:
  /// **'; the schedule says {percent}%, so they are behind.'**
  String anCohortBehind(String percent);

  /// No description provided for @anNoDataPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data in this period. Try a longer range.'**
  String get anNoDataPeriod;

  /// No description provided for @anAdminN.
  ///
  /// In en, this message translates to:
  /// **'Admin {n}'**
  String anAdminN(int n);

  /// No description provided for @anOthers.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get anOthers;

  /// No description provided for @anComparedPrevious.
  ///
  /// In en, this message translates to:
  /// **'Compared with the previous {days} days'**
  String anComparedPrevious(int days);

  /// No description provided for @anLoansRightNow.
  ///
  /// In en, this message translates to:
  /// **'loans right now'**
  String get anLoansRightNow;

  /// No description provided for @anPar.
  ///
  /// In en, this message translates to:
  /// **'PAR {percent}%'**
  String anPar(String percent);

  /// No description provided for @anToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get anToday;

  /// No description provided for @anThisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get anThisWeek;

  /// No description provided for @anThisMonth.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get anThisMonth;

  /// No description provided for @anPaymentBehaviour.
  ///
  /// In en, this message translates to:
  /// **'Payment behaviour'**
  String get anPaymentBehaviour;

  /// No description provided for @anNoPaymentsPeriod.
  ///
  /// In en, this message translates to:
  /// **'No payments in this period. Try a longer range.'**
  String get anNoPaymentsPeriod;

  /// No description provided for @anOnTimeUpper.
  ///
  /// In en, this message translates to:
  /// **'ON TIME'**
  String get anOnTimeUpper;

  /// No description provided for @anLate.
  ///
  /// In en, this message translates to:
  /// **'LATE'**
  String get anLate;

  /// No description provided for @anAvgDaysLate.
  ///
  /// In en, this message translates to:
  /// **'AVG DAYS LATE'**
  String get anAvgDaysLate;

  /// No description provided for @anWorst.
  ///
  /// In en, this message translates to:
  /// **'WORST'**
  String get anWorst;

  /// No description provided for @anDaysShort.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String anDaysShort(int days);

  /// No description provided for @anWeeklyInstalmentsDue.
  ///
  /// In en, this message translates to:
  /// **'Weekly instalments ({count} due)'**
  String anWeeklyInstalmentsDue(int count);

  /// No description provided for @anPaidPct.
  ///
  /// In en, this message translates to:
  /// **'Paid {percent}%'**
  String anPaidPct(String percent);

  /// No description provided for @anPartialPct.
  ///
  /// In en, this message translates to:
  /// **'Partial {percent}%'**
  String anPartialPct(String percent);

  /// No description provided for @anUnpaidPct.
  ///
  /// In en, this message translates to:
  /// **'Unpaid {percent}%'**
  String anUnpaidPct(String percent);

  /// No description provided for @anOverpaidPct.
  ///
  /// In en, this message translates to:
  /// **'Overpaid {percent}%'**
  String anOverpaidPct(String percent);

  /// No description provided for @anDisbursements.
  ///
  /// In en, this message translates to:
  /// **'Disbursements'**
  String get anDisbursements;

  /// No description provided for @anLoansCount.
  ///
  /// In en, this message translates to:
  /// **'{count} loans'**
  String anLoansCount(int count);

  /// No description provided for @anDisbursed.
  ///
  /// In en, this message translates to:
  /// **'Disbursed'**
  String get anDisbursed;

  /// No description provided for @anEarnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get anEarnings;

  /// No description provided for @anTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get anTotal;

  /// No description provided for @anFeesUpper.
  ///
  /// In en, this message translates to:
  /// **'FEES'**
  String get anFeesUpper;

  /// No description provided for @anInterestUpper.
  ///
  /// In en, this message translates to:
  /// **'INTEREST'**
  String get anInterestUpper;

  /// No description provided for @anExpected.
  ///
  /// In en, this message translates to:
  /// **'EXPECTED'**
  String get anExpected;

  /// No description provided for @anFees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get anFees;

  /// No description provided for @anInterest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get anInterest;

  /// No description provided for @anInterestEarned.
  ///
  /// In en, this message translates to:
  /// **'Interest earned'**
  String get anInterestEarned;

  /// No description provided for @anPlatformEarnings.
  ///
  /// In en, this message translates to:
  /// **'Platform earnings'**
  String get anPlatformEarnings;

  /// No description provided for @anMaturingIn.
  ///
  /// In en, this message translates to:
  /// **'Maturing in {days} days'**
  String anMaturingIn(int days);

  /// No description provided for @anNoneMaturing.
  ///
  /// In en, this message translates to:
  /// **'No loans mature in the next {days} days.'**
  String anNoneMaturing(int days);

  /// No description provided for @anWeeklyAmount.
  ///
  /// In en, this message translates to:
  /// **'Weekly {amount}'**
  String anWeeklyAmount(String amount);

  /// No description provided for @anDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days}d left'**
  String anDaysLeft(int days);

  /// No description provided for @anCustomersAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Customers at risk'**
  String get anCustomersAtRisk;

  /// No description provided for @anNoneAtRisk.
  ///
  /// In en, this message translates to:
  /// **'No customers at risk right now.'**
  String get anNoneAtRisk;

  /// No description provided for @anRiskLine.
  ///
  /// In en, this message translates to:
  /// **'{days} days late • {weeks} missed weeks'**
  String anRiskLine(int days, int weeks);

  /// No description provided for @anReferrerAtRisk.
  ///
  /// In en, this message translates to:
  /// **' • referrer at risk'**
  String get anReferrerAtRisk;

  /// No description provided for @anRiskScore.
  ///
  /// In en, this message translates to:
  /// **'Risk {score}'**
  String anRiskScore(String score);

  /// No description provided for @anRepeatBorrowers.
  ///
  /// In en, this message translates to:
  /// **'Repeat borrowers'**
  String get anRepeatBorrowers;

  /// No description provided for @anRepeatRate.
  ///
  /// In en, this message translates to:
  /// **'REPEAT RATE'**
  String get anRepeatRate;

  /// No description provided for @anRetention.
  ///
  /// In en, this message translates to:
  /// **'RETENTION'**
  String get anRetention;

  /// No description provided for @anAvgLoans.
  ///
  /// In en, this message translates to:
  /// **'AVG LOANS'**
  String get anAvgLoans;

  /// No description provided for @anLoanCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 loan} other{{count} loans}}'**
  String anLoanCountLabel(int count);

  /// No description provided for @anCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get anCustomers;

  /// No description provided for @anTopReferrers.
  ///
  /// In en, this message translates to:
  /// **'Top referrers'**
  String get anTopReferrers;

  /// No description provided for @anNoReferrals.
  ///
  /// In en, this message translates to:
  /// **'No referrals yet.'**
  String get anNoReferrals;

  /// No description provided for @anConverted.
  ///
  /// In en, this message translates to:
  /// **'{percent}% converted'**
  String anConverted(String percent);

  /// No description provided for @anReferredConverted.
  ///
  /// In en, this message translates to:
  /// **'Referred {referred} • converted {converted}'**
  String anReferredConverted(int referred, int converted);

  /// No description provided for @anAtRiskCount.
  ///
  /// In en, this message translates to:
  /// **' • {count} at risk'**
  String anAtRiskCount(int count);

  /// No description provided for @anGeography.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get anGeography;

  /// No description provided for @anOutstandingByArea.
  ///
  /// In en, this message translates to:
  /// **'Outstanding by area'**
  String get anOutstandingByArea;

  /// No description provided for @anDistrict.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get anDistrict;

  /// No description provided for @anCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get anCity;

  /// No description provided for @anNoBorrowersScope.
  ///
  /// In en, this message translates to:
  /// **'No borrowers in this scope yet.'**
  String get anNoBorrowersScope;

  /// No description provided for @anBorrowersPar.
  ///
  /// In en, this message translates to:
  /// **'{count} borrowers • PAR {percent}%'**
  String anBorrowersPar(int count, String percent);

  /// No description provided for @anEmployeeLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Employee leaderboard'**
  String get anEmployeeLeaderboard;

  /// No description provided for @anTeamLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Team leaderboard'**
  String get anTeamLeaderboard;

  /// No description provided for @anNoEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees to show yet.'**
  String get anNoEmployees;

  /// No description provided for @anParOverdue.
  ///
  /// In en, this message translates to:
  /// **'PAR {percent}% • {overdue} overdue'**
  String anParOverdue(String percent, int overdue);

  /// No description provided for @anEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get anEmployee;

  /// No description provided for @anPAR.
  ///
  /// In en, this message translates to:
  /// **'PAR'**
  String get anPAR;

  /// No description provided for @anNoRisky.
  ///
  /// In en, this message translates to:
  /// **'No risky customers.'**
  String get anNoRisky;

  /// No description provided for @anCashflowForecast.
  ///
  /// In en, this message translates to:
  /// **'Cash-flow forecast'**
  String get anCashflowForecast;

  /// No description provided for @anExpectedNextWeeks.
  ///
  /// In en, this message translates to:
  /// **'Expected next {weeks} weeks'**
  String anExpectedNextWeeks(int weeks);

  /// No description provided for @anPlusArrears.
  ///
  /// In en, this message translates to:
  /// **'Plus {amount} overdue and due now'**
  String anPlusArrears(String amount);

  /// No description provided for @anDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get anDue;

  /// No description provided for @anCurrentWeekHighlighted.
  ///
  /// In en, this message translates to:
  /// **' The current week is highlighted.'**
  String get anCurrentWeekHighlighted;

  /// No description provided for @anPlatformAtGlance.
  ///
  /// In en, this message translates to:
  /// **'Platform at a glance'**
  String get anPlatformAtGlance;

  /// No description provided for @anCollectedMonth.
  ///
  /// In en, this message translates to:
  /// **'COLLECTED (MONTH)'**
  String get anCollectedMonth;

  /// No description provided for @anAdminsUpper.
  ///
  /// In en, this message translates to:
  /// **'ADMINS'**
  String get anAdminsUpper;

  /// No description provided for @anEmployeesUpper.
  ///
  /// In en, this message translates to:
  /// **'EMPLOYEES'**
  String get anEmployeesUpper;

  /// No description provided for @anEarned.
  ///
  /// In en, this message translates to:
  /// **'EARNED'**
  String get anEarned;

  /// No description provided for @anNoAdmins.
  ///
  /// In en, this message translates to:
  /// **'No admins yet.'**
  String get anNoAdmins;

  /// No description provided for @anAdminRowLine.
  ///
  /// In en, this message translates to:
  /// **'{employees} employees • PAR {percent}% • {overdue} overdue'**
  String anAdminRowLine(int employees, String percent, int overdue);

  /// No description provided for @anDisbursedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Disbursed by admin'**
  String get anDisbursedByAdmin;

  /// No description provided for @anDisbursedByAdminMonthly.
  ///
  /// In en, this message translates to:
  /// **'Disbursed by admin (monthly)'**
  String get anDisbursedByAdminMonthly;

  /// No description provided for @anSplitByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Split by admin'**
  String get anSplitByAdmin;

  /// No description provided for @anPlatformCollections.
  ///
  /// In en, this message translates to:
  /// **'Platform collections'**
  String get anPlatformCollections;

  /// No description provided for @anAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get anAccounts;

  /// No description provided for @anActiveInactive.
  ///
  /// In en, this message translates to:
  /// **'{active} active • {inactive} inactive'**
  String anActiveInactive(String active, String inactive);

  /// No description provided for @anPendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String anPendingCount(String count);

  /// No description provided for @anEmployeesPerAdmin.
  ///
  /// In en, this message translates to:
  /// **'EMPLOYEES PER ADMIN'**
  String get anEmployeesPerAdmin;

  /// No description provided for @anPlatformOutstandingByAge.
  ///
  /// In en, this message translates to:
  /// **'Platform outstanding by age'**
  String get anPlatformOutstandingByAge;

  /// No description provided for @anRiskConcentration.
  ///
  /// In en, this message translates to:
  /// **'Risk concentration'**
  String get anRiskConcentration;

  /// No description provided for @anOutstandingByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Outstanding by admin'**
  String get anOutstandingByAdmin;

  /// No description provided for @anShareOfBook.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of book'**
  String anShareOfBook(String percent);

  /// No description provided for @anLargestExposures.
  ///
  /// In en, this message translates to:
  /// **'Largest exposures'**
  String get anLargestExposures;

  /// No description provided for @anNoExposures.
  ///
  /// In en, this message translates to:
  /// **'No exposures to show.'**
  String get anNoExposures;

  /// No description provided for @anExposureLine.
  ///
  /// In en, this message translates to:
  /// **'{days} days late • {percent}% of book'**
  String anExposureLine(String days, String percent);

  /// No description provided for @repAdvancedSemantics.
  ///
  /// In en, this message translates to:
  /// **'Advanced analytics. Trends, cohorts and team performance.'**
  String get repAdvancedSemantics;

  /// No description provided for @repAdvancedSub.
  ///
  /// In en, this message translates to:
  /// **'Trends, cohorts and team performance'**
  String get repAdvancedSub;

  /// No description provided for @repAsOfToday.
  ///
  /// In en, this message translates to:
  /// **'As of today'**
  String get repAsOfToday;

  /// No description provided for @repCashOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Cash outstanding'**
  String get repCashOutstanding;

  /// No description provided for @repNoLoansInBook.
  ///
  /// In en, this message translates to:
  /// **'No loans in the book yet.'**
  String get repNoLoansInBook;

  /// No description provided for @repOutstandingSemantics.
  ///
  /// In en, this message translates to:
  /// **'Outstanding receivable {amount}, {percent} percent of the payable amount collected'**
  String repOutstandingSemantics(String amount, int percent);

  /// No description provided for @repOutstandingReceivable.
  ///
  /// In en, this message translates to:
  /// **'Outstanding receivable'**
  String get repOutstandingReceivable;

  /// No description provided for @repPayableCollected.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of payable collected'**
  String repPayableCollected(int percent);

  /// No description provided for @repDisbursed.
  ///
  /// In en, this message translates to:
  /// **'Disbursed'**
  String get repDisbursed;

  /// No description provided for @repPayable.
  ///
  /// In en, this message translates to:
  /// **'Payable'**
  String get repPayable;

  /// No description provided for @repCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get repCollected;

  /// No description provided for @repLoansInBook.
  ///
  /// In en, this message translates to:
  /// **'{count} loans in the book'**
  String repLoansInBook(int count);

  /// No description provided for @repEarningsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Earnings appear once loans are issued.'**
  String get repEarningsEmpty;

  /// No description provided for @repTotalEarnedSemantics.
  ///
  /// In en, this message translates to:
  /// **'Total earned {amount}'**
  String repTotalEarnedSemantics(String amount);

  /// No description provided for @repTotalEarned.
  ///
  /// In en, this message translates to:
  /// **'Total earned'**
  String get repTotalEarned;

  /// No description provided for @repExpectedInterest.
  ///
  /// In en, this message translates to:
  /// **'Expected interest'**
  String get repExpectedInterest;

  /// No description provided for @repInterestNote.
  ///
  /// In en, this message translates to:
  /// **'Interest counts only what was collected above the principal, so it trails the expected figure until loans are repaid.'**
  String get repInterestNote;

  /// No description provided for @repOverdueSemantics.
  ///
  /// In en, this message translates to:
  /// **'{name}, {amount} outstanding, {days} days late'**
  String repOverdueSemantics(String name, String amount, int days);

  /// No description provided for @repAmountOutstanding.
  ///
  /// In en, this message translates to:
  /// **'{amount} outstanding'**
  String repAmountOutstanding(String amount);

  /// No description provided for @repOverdueLoans.
  ///
  /// In en, this message translates to:
  /// **'Overdue loans'**
  String get repOverdueLoans;

  /// No description provided for @repNoOverdue.
  ///
  /// In en, this message translates to:
  /// **'No overdue loans. Everything is on schedule.'**
  String get repNoOverdue;

  /// No description provided for @repSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get repSeeAll;

  /// No description provided for @repNoOverdueShort.
  ///
  /// In en, this message translates to:
  /// **'No overdue loans.'**
  String get repNoOverdueShort;

  /// No description provided for @auditNoAccess.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access to the audit log.'**
  String get auditNoAccess;

  /// No description provided for @auditEntry.
  ///
  /// In en, this message translates to:
  /// **'Audit entry'**
  String get auditEntry;

  /// No description provided for @auditRecordGone.
  ///
  /// In en, this message translates to:
  /// **'This record is no longer available.'**
  String get auditRecordGone;

  /// No description provided for @auditLoadEntryFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load this entry.'**
  String get auditLoadEntryFailed;

  /// No description provided for @auditLogIdCopied.
  ///
  /// In en, this message translates to:
  /// **'Log id copied'**
  String get auditLogIdCopied;

  /// No description provided for @auditAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get auditAttention;

  /// No description provided for @auditWho.
  ///
  /// In en, this message translates to:
  /// **'Who'**
  String get auditWho;

  /// No description provided for @auditOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get auditOn;

  /// No description provided for @auditOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get auditOpen;

  /// No description provided for @auditMoreFromActor.
  ///
  /// In en, this message translates to:
  /// **'More from this actor'**
  String get auditMoreFromActor;

  /// No description provided for @auditMoreOnRecord.
  ///
  /// In en, this message translates to:
  /// **'More on this record'**
  String get auditMoreOnRecord;

  /// No description provided for @auditChanges.
  ///
  /// In en, this message translates to:
  /// **'Changes'**
  String get auditChanges;

  /// No description provided for @auditRawJson.
  ///
  /// In en, this message translates to:
  /// **'Raw JSON'**
  String get auditRawJson;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @auditJsonCopied.
  ///
  /// In en, this message translates to:
  /// **'JSON copied'**
  String get auditJsonCopied;

  /// No description provided for @auditCreatedWith.
  ///
  /// In en, this message translates to:
  /// **'Created with'**
  String get auditCreatedWith;

  /// No description provided for @auditChangesCount.
  ///
  /// In en, this message translates to:
  /// **'Changes ({count})'**
  String auditChangesCount(int count);

  /// No description provided for @auditDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get auditDetails;

  /// No description provided for @auditNoFieldChanges.
  ///
  /// In en, this message translates to:
  /// **'No field changes were recorded for this entry.'**
  String get auditNoFieldChanges;

  /// No description provided for @auditRequestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request details'**
  String get auditRequestDetails;

  /// No description provided for @auditIp.
  ///
  /// In en, this message translates to:
  /// **'IP'**
  String get auditIp;

  /// No description provided for @auditDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get auditDevice;

  /// No description provided for @auditRequest.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get auditRequest;

  /// No description provided for @auditLogId.
  ///
  /// In en, this message translates to:
  /// **'Log id'**
  String get auditLogId;

  /// No description provided for @auditTeam.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get auditTeam;

  /// No description provided for @auditFiltersApplied.
  ///
  /// In en, this message translates to:
  /// **'{count} filters applied'**
  String auditFiltersApplied(int count);

  /// No description provided for @auditFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get auditFilters;

  /// No description provided for @auditAllTeams.
  ///
  /// In en, this message translates to:
  /// **'All teams'**
  String get auditAllTeams;

  /// No description provided for @auditAbout.
  ///
  /// In en, this message translates to:
  /// **'About: {name}'**
  String auditAbout(String name);

  /// No description provided for @auditThisUser.
  ///
  /// In en, this message translates to:
  /// **'this user'**
  String get auditThisUser;

  /// No description provided for @auditBy.
  ///
  /// In en, this message translates to:
  /// **'By: {name}'**
  String auditBy(String name);

  /// No description provided for @auditThisPerson.
  ///
  /// In en, this message translates to:
  /// **'this person'**
  String get auditThisPerson;

  /// No description provided for @auditClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get auditClearAll;

  /// No description provided for @auditNothingMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters'**
  String get auditNothingMatches;

  /// No description provided for @auditNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get auditNoActivity;

  /// No description provided for @auditTryWider.
  ///
  /// In en, this message translates to:
  /// **'Try a wider date range or fewer filters.'**
  String get auditTryWider;

  /// No description provided for @auditChangesAppear.
  ///
  /// In en, this message translates to:
  /// **'Changes made in the app will appear here.'**
  String get auditChangesAppear;

  /// No description provided for @auditClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get auditClearFilters;

  /// No description provided for @auditEntriesCount.
  ///
  /// In en, this message translates to:
  /// **'{shown} of {total} entries'**
  String auditEntriesCount(int shown, int total);

  /// No description provided for @auditWhoDidIt.
  ///
  /// In en, this message translates to:
  /// **'Who did it'**
  String get auditWhoDidIt;

  /// No description provided for @auditWhoAffected.
  ///
  /// In en, this message translates to:
  /// **'Who it affected'**
  String get auditWhoAffected;

  /// No description provided for @auditAnyone.
  ///
  /// In en, this message translates to:
  /// **'Anyone'**
  String get auditAnyone;

  /// No description provided for @auditModule.
  ///
  /// In en, this message translates to:
  /// **'MODULE'**
  String get auditModule;

  /// No description provided for @auditActions.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get auditActions;

  /// No description provided for @auditNoActionsScope.
  ///
  /// In en, this message translates to:
  /// **'No actions have been recorded in your scope yet.'**
  String get auditNoActionsScope;

  /// No description provided for @auditSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get auditSelected;

  /// No description provided for @auditApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get auditApplyFilters;

  /// No description provided for @auditMe.
  ///
  /// In en, this message translates to:
  /// **'{name} (me)'**
  String auditMe(String name);

  /// No description provided for @auditAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get auditAll;

  /// No description provided for @auditModuleSemantics.
  ///
  /// In en, this message translates to:
  /// **'{label} module'**
  String auditModuleSemantics(String label);

  /// No description provided for @auditNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention. '**
  String get auditNeedsAttention;

  /// No description provided for @auditBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get auditBefore;

  /// No description provided for @auditAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get auditAfter;

  /// No description provided for @auditView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get auditView;

  /// No description provided for @auditBeforeUpper.
  ///
  /// In en, this message translates to:
  /// **'BEFORE'**
  String get auditBeforeUpper;

  /// No description provided for @auditAfterUpper.
  ///
  /// In en, this message translates to:
  /// **'AFTER'**
  String get auditAfterUpper;

  /// No description provided for @expCouldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Could not open the file.'**
  String get expCouldNotOpen;

  /// No description provided for @expAlreadyInProgress.
  ///
  /// In en, this message translates to:
  /// **'That export is already in progress.'**
  String get expAlreadyInProgress;

  /// No description provided for @expStarted.
  ///
  /// In en, this message translates to:
  /// **'Export started.'**
  String get expStarted;

  /// No description provided for @expNoDownloads.
  ///
  /// In en, this message translates to:
  /// **'No downloads yet. Reports you export appear here for 24 hours.'**
  String get expNoDownloads;

  /// No description provided for @expExpired.
  ///
  /// In en, this message translates to:
  /// **'EXPIRED'**
  String get expExpired;

  /// No description provided for @expQueued.
  ///
  /// In en, this message translates to:
  /// **'QUEUED'**
  String get expQueued;

  /// No description provided for @expBuilding.
  ///
  /// In en, this message translates to:
  /// **'BUILDING'**
  String get expBuilding;

  /// No description provided for @expReady.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get expReady;

  /// No description provided for @expFailed.
  ///
  /// In en, this message translates to:
  /// **'FAILED'**
  String get expFailed;

  /// No description provided for @expPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get expPreparing;

  /// No description provided for @expRowsProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} rows'**
  String expRowsProgress(int done, int total);

  /// No description provided for @expOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get expOpen;

  /// No description provided for @expShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get expShare;

  /// No description provided for @expUntil.
  ///
  /// In en, this message translates to:
  /// **'Until {time}'**
  String expUntil(String time);

  /// No description provided for @expCreateAgain.
  ///
  /// In en, this message translates to:
  /// **'Create again'**
  String get expCreateAgain;

  /// No description provided for @expExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get expExport;

  /// No description provided for @expDownloadsBuilding.
  ///
  /// In en, this message translates to:
  /// **'Downloads ({count} building)'**
  String expDownloadsBuilding(int count);

  /// No description provided for @expThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get expThisWeek;

  /// No description provided for @expNext7.
  ///
  /// In en, this message translates to:
  /// **'Next 7 days'**
  String get expNext7;

  /// No description provided for @expPickAtMost.
  ///
  /// In en, this message translates to:
  /// **'Pick at most {days} days.'**
  String expPickAtMost(int days);

  /// No description provided for @expCustomersAddedBy.
  ///
  /// In en, this message translates to:
  /// **'Customers added by'**
  String get expCustomersAddedBy;

  /// No description provided for @expChooseWeekday.
  ///
  /// In en, this message translates to:
  /// **'Choose a weekday.'**
  String get expChooseWeekday;

  /// No description provided for @expChooseRange.
  ///
  /// In en, this message translates to:
  /// **'Choose a date range.'**
  String get expChooseRange;

  /// No description provided for @expStartBeforeEnd.
  ///
  /// In en, this message translates to:
  /// **'The start date must be on or before the end date.'**
  String get expStartBeforeEnd;

  /// No description provided for @expNoServerAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer from the server. Open Downloads to see whether it was created, then try again.'**
  String get expNoServerAnswer;

  /// No description provided for @expScopeSuper.
  ///
  /// In en, this message translates to:
  /// **'Covers every team unless you pick one.'**
  String get expScopeSuper;

  /// No description provided for @expScopeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Covers your team only.'**
  String get expScopeAdmin;

  /// No description provided for @expScopeUser.
  ///
  /// In en, this message translates to:
  /// **'Covers only the customers you created.'**
  String get expScopeUser;

  /// No description provided for @expHintXlsx.
  ///
  /// In en, this message translates to:
  /// **'Best for Excel. Up to 100,000 rows.'**
  String get expHintXlsx;

  /// No description provided for @expHintCsv.
  ///
  /// In en, this message translates to:
  /// **'Plain text that opens anywhere. Up to 300,000 rows.'**
  String get expHintCsv;

  /// No description provided for @expHintPdfWeekday.
  ///
  /// In en, this message translates to:
  /// **'One block per customer, ready to print for the route. Up to 1,000 loans.'**
  String get expHintPdfWeekday;

  /// No description provided for @expHintPdfAudit.
  ///
  /// In en, this message translates to:
  /// **'For printing. Up to 1,000 rows, and long values are shortened. Use Excel or CSV for full values.'**
  String get expHintPdfAudit;

  /// No description provided for @expHintPdf.
  ///
  /// In en, this message translates to:
  /// **'For printing. Up to 1,000 rows.'**
  String get expHintPdf;

  /// No description provided for @expGone.
  ///
  /// In en, this message translates to:
  /// **'This export is no longer available.'**
  String get expGone;

  /// No description provided for @expStartAgain.
  ///
  /// In en, this message translates to:
  /// **'Start again'**
  String get expStartAgain;

  /// No description provided for @expFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get expFormat;

  /// No description provided for @expWeekday.
  ///
  /// In en, this message translates to:
  /// **'Weekday'**
  String get expWeekday;

  /// No description provided for @expPaymentDay.
  ///
  /// In en, this message translates to:
  /// **'Payment day'**
  String get expPaymentDay;

  /// No description provided for @expOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get expOptional;

  /// No description provided for @expAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get expAny;

  /// No description provided for @expUpToDays.
  ///
  /// In en, this message translates to:
  /// **'Up to {days} days'**
  String expUpToDays(int days);

  /// No description provided for @expAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get expAllTime;

  /// No description provided for @expIssuedBetween.
  ///
  /// In en, this message translates to:
  /// **'Issued between'**
  String get expIssuedBetween;

  /// No description provided for @expAnyDate.
  ///
  /// In en, this message translates to:
  /// **'Any date'**
  String get expAnyDate;

  /// No description provided for @expPickDates.
  ///
  /// In en, this message translates to:
  /// **'Pick dates'**
  String get expPickDates;

  /// No description provided for @expScope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get expScope;

  /// No description provided for @expAuditNote.
  ///
  /// In en, this message translates to:
  /// **'Also uses the audit screen filters: {note}.'**
  String expAuditNote(String note);

  /// No description provided for @expSwitchCsv.
  ///
  /// In en, this message translates to:
  /// **'Switch to CSV'**
  String get expSwitchCsv;

  /// No description provided for @expSwitchExcel.
  ///
  /// In en, this message translates to:
  /// **'Switch to Excel'**
  String get expSwitchExcel;

  /// No description provided for @expCreateFormat.
  ///
  /// In en, this message translates to:
  /// **'Create {format}'**
  String expCreateFormat(String format);

  /// No description provided for @expWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting in line...'**
  String get expWaiting;

  /// No description provided for @expBuildingFile.
  ///
  /// In en, this message translates to:
  /// **'Building your file...'**
  String get expBuildingFile;

  /// No description provided for @expCountingRows.
  ///
  /// In en, this message translates to:
  /// **'Counting rows...'**
  String get expCountingRows;

  /// No description provided for @expAlreadyInProgressSuffix.
  ///
  /// In en, this message translates to:
  /// **' • already in progress'**
  String get expAlreadyInProgressSuffix;

  /// No description provided for @expReadyLabel.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get expReadyLabel;

  /// No description provided for @expDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get expDownloading;

  /// No description provided for @expBuildFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not build the file'**
  String get expBuildFailed;

  /// No description provided for @expTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get expTryAgain;

  /// No description provided for @expFileExpired.
  ///
  /// In en, this message translates to:
  /// **'This file has expired.'**
  String get expFileExpired;

  /// No description provided for @expKeptExpired.
  ///
  /// In en, this message translates to:
  /// **'Files are kept for 24 hours. Create it again to get a new one.'**
  String get expKeptExpired;

  /// No description provided for @expCanClose.
  ///
  /// In en, this message translates to:
  /// **'You can close this. It keeps building and appears in Downloads.'**
  String get expCanClose;

  /// No description provided for @expKept24.
  ///
  /// In en, this message translates to:
  /// **'Files are kept for 24 hours.'**
  String get expKept24;

  /// No description provided for @empWorksUnder.
  ///
  /// In en, this message translates to:
  /// **'Works under'**
  String get empWorksUnder;

  /// No description provided for @empNoActiveAdmins.
  ///
  /// In en, this message translates to:
  /// **'There are no active admins.'**
  String get empNoActiveAdmins;

  /// No description provided for @empEmployeesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} employees'**
  String empEmployeesCount(int count);

  /// No description provided for @empEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get empEnterNumber;

  /// No description provided for @empRangeError.
  ///
  /// In en, this message translates to:
  /// **'{label} must be {min} to {max}'**
  String empRangeError(String label, String min, String max);

  /// No description provided for @empOneDecimal.
  ///
  /// In en, this message translates to:
  /// **'One decimal place at most'**
  String get empOneDecimal;

  /// No description provided for @empFee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get empFee;

  /// No description provided for @empInterest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get empInterest;

  /// No description provided for @empTerm.
  ///
  /// In en, this message translates to:
  /// **'Term'**
  String get empTerm;

  /// No description provided for @empNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name needs at least 2 characters'**
  String get empNameTooShort;

  /// No description provided for @empNameChars.
  ///
  /// In en, this message translates to:
  /// **'Use letters, spaces and . \' - only'**
  String get empNameChars;

  /// No description provided for @empInvalidMobile.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid mobile number'**
  String get empInvalidMobile;

  /// No description provided for @empInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get empInvalidEmail;

  /// No description provided for @empChooseAdmin.
  ///
  /// In en, this message translates to:
  /// **'Choose the admin this employee works under.'**
  String get empChooseAdmin;

  /// No description provided for @empFixDefaults.
  ///
  /// In en, this message translates to:
  /// **'Fix the loan defaults first.'**
  String get empFixDefaults;

  /// No description provided for @empAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} was added. If they cannot sign in yet, approve them under Pending.'**
  String empAdded(String name);

  /// No description provided for @empNoServerAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer from the server. Check Manage users before trying again, in case the account was already created.'**
  String get empNoServerAnswer;

  /// No description provided for @empAddEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add employee'**
  String get empAddEmployee;

  /// No description provided for @empDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this employee?'**
  String get empDiscardTitle;

  /// No description provided for @empDiscardMessage.
  ///
  /// In en, this message translates to:
  /// **'You have details that are not saved.'**
  String get empDiscardMessage;

  /// No description provided for @empDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get empDiscard;

  /// No description provided for @empKeepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get empKeepEditing;

  /// No description provided for @empCreate.
  ///
  /// In en, this message translates to:
  /// **'Create employee'**
  String get empCreate;

  /// No description provided for @empAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get empAdmin;

  /// No description provided for @empChooseAnAdmin.
  ///
  /// In en, this message translates to:
  /// **'Choose an admin'**
  String get empChooseAnAdmin;

  /// No description provided for @empAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get empAccount;

  /// No description provided for @empFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get empFullName;

  /// No description provided for @empPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get empPhoneNumber;

  /// No description provided for @empPhoneHelper.
  ///
  /// In en, this message translates to:
  /// **'They sign in with this number.'**
  String get empPhoneHelper;

  /// No description provided for @empEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get empEmailOptional;

  /// No description provided for @empPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get empPassword;

  /// No description provided for @empGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get empGenerate;

  /// No description provided for @empMin8.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get empMin8;

  /// No description provided for @empHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get empHide;

  /// No description provided for @empShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get empShow;

  /// No description provided for @empPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get empPasswordsMismatch;

  /// No description provided for @empConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get empConfirmPassword;

  /// No description provided for @empSharePassword.
  ///
  /// In en, this message translates to:
  /// **'Share this password with them. They can change it later from their profile.'**
  String get empSharePassword;

  /// No description provided for @empLoanDefaults.
  ///
  /// In en, this message translates to:
  /// **'Loan defaults'**
  String get empLoanDefaults;

  /// No description provided for @empCustomise.
  ///
  /// In en, this message translates to:
  /// **'Customise for this employee'**
  String get empCustomise;

  /// No description provided for @empOnlyThisEmployee.
  ///
  /// In en, this message translates to:
  /// **'These values are only for this employee.'**
  String get empOnlyThisEmployee;

  /// No description provided for @empUsesAdminDefaults.
  ///
  /// In en, this message translates to:
  /// **'Uses {admin} defaults: fee {fee}%, interest {interest}%, {months} months. Later changes apply to them too.'**
  String empUsesAdminDefaults(
    String admin,
    String fee,
    String interest,
    String months,
  );

  /// No description provided for @empUsesYourDefaults.
  ///
  /// In en, this message translates to:
  /// **'Uses your defaults: fee {fee}%, interest {interest}%, {months} months. Later changes apply to them too.'**
  String empUsesYourDefaults(String fee, String interest, String months);

  /// No description provided for @empTheAdmin.
  ///
  /// In en, this message translates to:
  /// **'the admin'**
  String get empTheAdmin;

  /// No description provided for @empUpfrontFee.
  ///
  /// In en, this message translates to:
  /// **'Upfront fee'**
  String get empUpfrontFee;

  /// No description provided for @empMonthsSuffix.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get empMonthsSuffix;

  /// No description provided for @empResetInherited.
  ///
  /// In en, this message translates to:
  /// **'Reset to inherited values'**
  String get empResetInherited;

  /// No description provided for @empExample.
  ///
  /// In en, this message translates to:
  /// **'On a {loan} loan: fee {fee}, {handed} handed over, {total} repayable, {weekly} a week for {weeks} weeks.'**
  String empExample(
    String loan,
    String fee,
    String handed,
    String total,
    String weekly,
    int weeks,
  );

  /// No description provided for @manApproved.
  ///
  /// In en, this message translates to:
  /// **'{name} approved.'**
  String manApproved(String name);

  /// No description provided for @manApprovedCanSignIn.
  ///
  /// In en, this message translates to:
  /// **'{name} approved. They can sign in now.'**
  String manApprovedCanSignIn(String name);

  /// No description provided for @manRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject {name}?'**
  String manRejectTitle(String name);

  /// No description provided for @manRejectMessage.
  ///
  /// In en, this message translates to:
  /// **'The account is deactivated and cannot sign in. It is never deleted.'**
  String get manRejectMessage;

  /// No description provided for @manReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get manReject;

  /// No description provided for @manRejected.
  ///
  /// In en, this message translates to:
  /// **'{name} rejected.'**
  String manRejected(String name);

  /// No description provided for @manDeactivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate {name}?'**
  String manDeactivateTitle(String name);

  /// No description provided for @manDeactivateAdminMsg.
  ///
  /// In en, this message translates to:
  /// **'They are signed out once their access token expires. Their employees are not changed.'**
  String get manDeactivateAdminMsg;

  /// No description provided for @manDeactivateUserMsg.
  ///
  /// In en, this message translates to:
  /// **'They are signed out once their access token expires. Their customers and loans stay as they are.'**
  String get manDeactivateUserMsg;

  /// No description provided for @manDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get manDeactivate;

  /// No description provided for @manDeactivated.
  ///
  /// In en, this message translates to:
  /// **'{name} deactivated.'**
  String manDeactivated(String name);

  /// No description provided for @manReactivatedPending.
  ///
  /// In en, this message translates to:
  /// **'{name} reactivated. They are waiting for approval again.'**
  String manReactivatedPending(String name);

  /// No description provided for @manReactivated.
  ///
  /// In en, this message translates to:
  /// **'{name} reactivated.'**
  String manReactivated(String name);

  /// No description provided for @manCountsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the counts.'**
  String get manCountsFailed;

  /// No description provided for @manPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get manPending;

  /// No description provided for @manAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'awaiting approval'**
  String get manAwaitingApproval;

  /// No description provided for @manTeams.
  ///
  /// In en, this message translates to:
  /// **'TEAMS'**
  String get manTeams;

  /// No description provided for @manApprovedAdmins.
  ///
  /// In en, this message translates to:
  /// **'approved admins'**
  String get manApprovedAdmins;

  /// No description provided for @manEmployees.
  ///
  /// In en, this message translates to:
  /// **'EMPLOYEES'**
  String get manEmployees;

  /// No description provided for @manAcrossAllTeams.
  ///
  /// In en, this message translates to:
  /// **'across all teams'**
  String get manAcrossAllTeams;

  /// No description provided for @manAcrossTeams.
  ///
  /// In en, this message translates to:
  /// **'across teams'**
  String get manAcrossTeams;

  /// No description provided for @manActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get manActive;

  /// No description provided for @manCanSignIn.
  ///
  /// In en, this message translates to:
  /// **'can sign in'**
  String get manCanSignIn;

  /// No description provided for @manInactive.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get manInactive;

  /// No description provided for @manDeactivatedLower.
  ///
  /// In en, this message translates to:
  /// **'deactivated'**
  String get manDeactivatedLower;

  /// No description provided for @manManageAdmins.
  ///
  /// In en, this message translates to:
  /// **'Manage admins'**
  String get manManageAdmins;

  /// No description provided for @manSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, phone or email'**
  String get manSearchHint;

  /// No description provided for @manNoAdminsPending.
  ///
  /// In en, this message translates to:
  /// **'No admins are waiting for approval.'**
  String get manNoAdminsPending;

  /// No description provided for @manNoActiveAdmins.
  ///
  /// In en, this message translates to:
  /// **'No active admins yet.'**
  String get manNoActiveAdmins;

  /// No description provided for @manNoInactiveAdmins.
  ///
  /// In en, this message translates to:
  /// **'No inactive admins.'**
  String get manNoInactiveAdmins;

  /// No description provided for @manFilterByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Filter by admin'**
  String get manFilterByAdmin;

  /// No description provided for @manNoEmployeesPending.
  ///
  /// In en, this message translates to:
  /// **'No employees are waiting for approval.'**
  String get manNoEmployeesPending;

  /// No description provided for @manNoActiveEmployees.
  ///
  /// In en, this message translates to:
  /// **'No active employees yet.'**
  String get manNoActiveEmployees;

  /// No description provided for @manNoInactiveEmployees.
  ///
  /// In en, this message translates to:
  /// **'No inactive employees.'**
  String get manNoInactiveEmployees;

  /// No description provided for @accPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get accPhone;

  /// No description provided for @accEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accEmail;

  /// No description provided for @accNotAdded.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get accNotAdded;

  /// No description provided for @accJoined.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get accJoined;

  /// No description provided for @accLoanDefaultsOwn.
  ///
  /// In en, this message translates to:
  /// **'Loan defaults (own)'**
  String get accLoanDefaultsOwn;

  /// No description provided for @accDefaultsLine.
  ///
  /// In en, this message translates to:
  /// **'Fee {fee}% • Interest {interest}% • {months} months'**
  String accDefaultsLine(String fee, String interest, String months);

  /// No description provided for @accTeamCount.
  ///
  /// In en, this message translates to:
  /// **'Team ({count})'**
  String accTeamCount(int count);

  /// No description provided for @accPendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String accPendingCount(int count);

  /// No description provided for @accNoEmployees.
  ///
  /// In en, this message translates to:
  /// **'No employees under this admin yet.'**
  String get accNoEmployees;

  /// No description provided for @accCustomersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} customers'**
  String accCustomersCount(int count);

  /// No description provided for @accOpenManageUsers.
  ///
  /// In en, this message translates to:
  /// **'Open Manage users to approve or deactivate employees.'**
  String get accOpenManageUsers;

  /// No description provided for @accActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get accActivity;

  /// No description provided for @accCustomers.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMERS'**
  String get accCustomers;

  /// No description provided for @accCreated.
  ///
  /// In en, this message translates to:
  /// **'created'**
  String get accCreated;

  /// No description provided for @accActiveLoans.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE LOANS'**
  String get accActiveLoans;

  /// No description provided for @accActiveAndOverdue.
  ///
  /// In en, this message translates to:
  /// **'active and overdue'**
  String get accActiveAndOverdue;

  /// No description provided for @accViewPerformance.
  ///
  /// In en, this message translates to:
  /// **'View performance'**
  String get accViewPerformance;

  /// No description provided for @manTabPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get manTabPending;

  /// No description provided for @manTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get manTabActive;

  /// No description provided for @manTabInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get manTabInactive;

  /// No description provided for @manOwnDefaults.
  ///
  /// In en, this message translates to:
  /// **'Own defaults'**
  String get manOwnDefaults;

  /// No description provided for @manAdminDefaults.
  ///
  /// In en, this message translates to:
  /// **'Admin defaults'**
  String get manAdminDefaults;

  /// No description provided for @manDefaultsShort.
  ///
  /// In en, this message translates to:
  /// **'Fee {fee}% • Int {interest}% • {months} mo'**
  String manDefaultsShort(String fee, String interest, String months);

  /// No description provided for @manJoinedOn.
  ///
  /// In en, this message translates to:
  /// **'Joined {date}'**
  String manJoinedOn(String date);

  /// No description provided for @manApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get manApprove;

  /// No description provided for @manDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get manDetails;

  /// No description provided for @manReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get manReactivate;

  /// No description provided for @manNobodyMatches.
  ///
  /// In en, this message translates to:
  /// **'Nobody matches \"{query}\".'**
  String manNobodyMatches(String query);

  /// No description provided for @manThatIsEveryone.
  ///
  /// In en, this message translates to:
  /// **'That is everyone'**
  String get manThatIsEveryone;

  /// No description provided for @profPhoneUpdated.
  ///
  /// In en, this message translates to:
  /// **'Phone number updated.'**
  String get profPhoneUpdated;

  /// No description provided for @profPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed.'**
  String get profPasswordChanged;

  /// No description provided for @profSignOutDevice.
  ///
  /// In en, this message translates to:
  /// **'Sign out this device?'**
  String get profSignOutDevice;

  /// No description provided for @profSignedInOn.
  ///
  /// In en, this message translates to:
  /// **'Signed in on {date}.'**
  String profSignedInOn(String date);

  /// No description provided for @profSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profSignOut;

  /// No description provided for @profSignOutAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of all devices?'**
  String get profSignOutAllTitle;

  /// No description provided for @profSignOutAllMsg.
  ///
  /// In en, this message translates to:
  /// **'This device is signed out too, and you will need to log in again.'**
  String get profSignOutAllMsg;

  /// No description provided for @profSignOutAll.
  ///
  /// In en, this message translates to:
  /// **'Sign out all'**
  String get profSignOutAll;

  /// No description provided for @profApproveTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve {name}?'**
  String profApproveTitle(String name);

  /// No description provided for @profApproveMsg.
  ///
  /// In en, this message translates to:
  /// **'They will be able to sign in and manage a team.'**
  String get profApproveMsg;

  /// No description provided for @profRejectMsg.
  ///
  /// In en, this message translates to:
  /// **'The account will be deactivated. It is never deleted.'**
  String get profRejectMsg;

  /// No description provided for @profAdminApproved.
  ///
  /// In en, this message translates to:
  /// **'Admin approved.'**
  String get profAdminApproved;

  /// No description provided for @profAdminRejected.
  ///
  /// In en, this message translates to:
  /// **'Admin rejected.'**
  String get profAdminRejected;

  /// No description provided for @profLimitsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Limits updated.'**
  String get profLimitsUpdated;

  /// No description provided for @profDiscardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get profDiscardChanges;

  /// No description provided for @profUnsavedEdits.
  ///
  /// In en, this message translates to:
  /// **'You have edits that are not saved.'**
  String get profUnsavedEdits;

  /// No description provided for @profLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile.'**
  String get profLoadFailed;

  /// No description provided for @profHidePasswords.
  ///
  /// In en, this message translates to:
  /// **'Hide passwords'**
  String get profHidePasswords;

  /// No description provided for @profShowPasswords.
  ///
  /// In en, this message translates to:
  /// **'Show passwords'**
  String get profShowPasswords;

  /// No description provided for @profChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profChangePassword;

  /// No description provided for @profOtherDevicesSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Your other devices will be signed out.'**
  String get profOtherDevicesSignedOut;

  /// No description provided for @profEnterCurrent.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get profEnterCurrent;

  /// No description provided for @profCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get profCurrentPassword;

  /// No description provided for @profDifferentPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a different password'**
  String get profDifferentPassword;

  /// No description provided for @profNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get profNewPassword;

  /// No description provided for @profConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get profConfirmNewPassword;

  /// No description provided for @profUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get profUpdatePassword;

  /// No description provided for @profSamePhone.
  ///
  /// In en, this message translates to:
  /// **'That is already your phone number'**
  String get profSamePhone;

  /// No description provided for @profSendCodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the code. Try again.'**
  String get profSendCodeFailed;

  /// No description provided for @profEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get profEnterCode;

  /// No description provided for @profSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get profSomethingWrong;

  /// No description provided for @profChangePhone.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get profChangePhone;

  /// No description provided for @profWillSendCode.
  ///
  /// In en, this message translates to:
  /// **'We will send a code to the new number.'**
  String get profWillSendCode;

  /// No description provided for @profCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String profCodeSentTo(String phone);

  /// No description provided for @profNewPhone.
  ///
  /// In en, this message translates to:
  /// **'New phone number'**
  String get profNewPhone;

  /// No description provided for @profSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get profSixDigitCode;

  /// No description provided for @profSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get profSendCode;

  /// No description provided for @profVerifyUpdate.
  ///
  /// In en, this message translates to:
  /// **'Verify and update'**
  String get profVerifyUpdate;

  /// No description provided for @profUseAnother.
  ///
  /// In en, this message translates to:
  /// **'Use another number'**
  String get profUseAnother;

  /// No description provided for @profResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String profResendIn(int seconds);

  /// No description provided for @profResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get profResendCode;

  /// No description provided for @profMinPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Minimum principal (₹)'**
  String get profMinPrincipal;

  /// No description provided for @profMaxPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Maximum principal (₹)'**
  String get profMaxPrincipal;

  /// No description provided for @profMinTerm.
  ///
  /// In en, this message translates to:
  /// **'Minimum term (months)'**
  String get profMinTerm;

  /// No description provided for @profMaxTerm.
  ///
  /// In en, this message translates to:
  /// **'Maximum term (months)'**
  String get profMaxTerm;

  /// No description provided for @profMaxFee.
  ///
  /// In en, this message translates to:
  /// **'Maximum upfront fee (%)'**
  String get profMaxFee;

  /// No description provided for @profMaxInterest.
  ///
  /// In en, this message translates to:
  /// **'Maximum interest (%)'**
  String get profMaxInterest;

  /// No description provided for @profMinPrincipalExceeds.
  ///
  /// In en, this message translates to:
  /// **'Minimum principal cannot exceed maximum principal'**
  String get profMinPrincipalExceeds;

  /// No description provided for @profMinTermExceeds.
  ///
  /// In en, this message translates to:
  /// **'Minimum term cannot exceed maximum term'**
  String get profMinTermExceeds;

  /// No description provided for @profChangeOneLimit.
  ///
  /// In en, this message translates to:
  /// **'Change at least one limit'**
  String get profChangeOneLimit;

  /// No description provided for @profLoanLimits.
  ///
  /// In en, this message translates to:
  /// **'Loan limits'**
  String get profLoanLimits;

  /// No description provided for @profLimitsNote.
  ///
  /// In en, this message translates to:
  /// **'Existing admin defaults are not rewritten. A tighter limit applies the next time defaults are saved.'**
  String get profLimitsNote;

  /// No description provided for @profPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive number'**
  String get profPositiveNumber;

  /// No description provided for @profMustBeOrLess.
  ///
  /// In en, this message translates to:
  /// **'Must be {max} or less'**
  String profMustBeOrLess(String max);

  /// No description provided for @profSaveLimits.
  ///
  /// In en, this message translates to:
  /// **'Save limits'**
  String get profSaveLimits;

  /// No description provided for @pcAwaitingApproval.
  ///
  /// In en, this message translates to:
  /// **'AWAITING APPROVAL'**
  String get pcAwaitingApproval;

  /// No description provided for @pcVerified.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get pcVerified;

  /// No description provided for @pcMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String pcMemberSince(String date);

  /// No description provided for @pcProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get pcProfileUpdated;

  /// No description provided for @pcContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get pcContact;

  /// No description provided for @pcEditNameEmail.
  ///
  /// In en, this message translates to:
  /// **'Edit name and email'**
  String get pcEditNameEmail;

  /// No description provided for @pcName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get pcName;

  /// No description provided for @pcMyNumbers.
  ///
  /// In en, this message translates to:
  /// **'My numbers'**
  String get pcMyNumbers;

  /// No description provided for @pcMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get pcMe;

  /// No description provided for @pcMyTeam.
  ///
  /// In en, this message translates to:
  /// **'My team'**
  String get pcMyTeam;

  /// No description provided for @pcEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get pcEveryone;

  /// No description provided for @pcNumbersFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the numbers.'**
  String get pcNumbersFailed;

  /// No description provided for @pcCollectedVsTarget.
  ///
  /// In en, this message translates to:
  /// **'Collected against target'**
  String get pcCollectedVsTarget;

  /// No description provided for @pcOfTarget.
  ///
  /// In en, this message translates to:
  /// **'of {amount} target'**
  String pcOfTarget(String amount);

  /// No description provided for @pcCustomersPaid.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMERS PAID'**
  String get pcCustomersPaid;

  /// No description provided for @pcInThisPeriod.
  ///
  /// In en, this message translates to:
  /// **'in this period'**
  String get pcInThisPeriod;

  /// No description provided for @pcPaymentsByDue.
  ///
  /// In en, this message translates to:
  /// **'payments by due date'**
  String get pcPaymentsByDue;

  /// No description provided for @pcDefaultsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Loan defaults updated.'**
  String get pcDefaultsUpdated;

  /// No description provided for @pcEditDefaults.
  ///
  /// In en, this message translates to:
  /// **'Edit loan defaults'**
  String get pcEditDefaults;

  /// No description provided for @pcUpfrontFeeUpper.
  ///
  /// In en, this message translates to:
  /// **'UPFRONT FEE'**
  String get pcUpfrontFeeUpper;

  /// No description provided for @pcOnPrincipal.
  ///
  /// In en, this message translates to:
  /// **'on principal'**
  String get pcOnPrincipal;

  /// No description provided for @pcInterestUpper.
  ///
  /// In en, this message translates to:
  /// **'INTEREST'**
  String get pcInterestUpper;

  /// No description provided for @pcFlatOnce.
  ///
  /// In en, this message translates to:
  /// **'flat, once'**
  String get pcFlatOnce;

  /// No description provided for @pcTermUpper.
  ///
  /// In en, this message translates to:
  /// **'TERM'**
  String get pcTermUpper;

  /// No description provided for @pcMonthsShort.
  ///
  /// In en, this message translates to:
  /// **'{months} mo'**
  String pcMonthsShort(String months);

  /// No description provided for @pcWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks} weeks'**
  String pcWeeks(int weeks);

  /// No description provided for @pcSetByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Set by your admin. Only new loans use these values.'**
  String get pcSetByAdmin;

  /// No description provided for @pcAppliesNewOnly.
  ///
  /// In en, this message translates to:
  /// **'Applies to new loans only, never existing ones. Employees who inherit these values pick them up at once.'**
  String get pcAppliesNewOnly;

  /// No description provided for @pcOnlyAdminsChange.
  ///
  /// In en, this message translates to:
  /// **'Only admins can change these. Only new loans use them.'**
  String get pcOnlyAdminsChange;

  /// No description provided for @pcSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get pcSecurity;

  /// No description provided for @pcChangeYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Change your password'**
  String get pcChangeYourPassword;

  /// No description provided for @pcSignedInDevices.
  ///
  /// In en, this message translates to:
  /// **'SIGNED-IN DEVICES'**
  String get pcSignedInDevices;

  /// No description provided for @pcSessionsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your sessions.'**
  String get pcSessionsFailed;

  /// No description provided for @pcNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No active sessions.'**
  String get pcNoSessions;

  /// No description provided for @pcExpires.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String pcExpires(String date);

  /// No description provided for @pcDeviceNamesNote.
  ///
  /// In en, this message translates to:
  /// **'Device names are not recorded, so the current device is not marked.'**
  String get pcDeviceNamesNote;

  /// No description provided for @pcSignOutAllDevices.
  ///
  /// In en, this message translates to:
  /// **'Sign out of all devices'**
  String get pcSignOutAllDevices;

  /// No description provided for @pcTeamFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the team.'**
  String get pcTeamFailed;

  /// No description provided for @pcNoApprovedTeams.
  ///
  /// In en, this message translates to:
  /// **'No approved teams yet.'**
  String get pcNoApprovedTeams;

  /// No description provided for @pcMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String pcMembersCount(int count);

  /// No description provided for @pcPendingSuffix.
  ///
  /// In en, this message translates to:
  /// **' • {count} pending'**
  String pcPendingSuffix(int count);

  /// No description provided for @pcNoTeamMembers.
  ///
  /// In en, this message translates to:
  /// **'No team members yet.'**
  String get pcNoTeamMembers;

  /// No description provided for @pcMoreInManage.
  ///
  /// In en, this message translates to:
  /// **'+{count} more in Manage users'**
  String pcMoreInManage(int count);

  /// No description provided for @pcSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get pcSystem;

  /// No description provided for @pcWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting'**
  String pcWaiting(int count);

  /// No description provided for @pcAdminApprovals.
  ///
  /// In en, this message translates to:
  /// **'ADMIN APPROVALS'**
  String get pcAdminApprovals;

  /// No description provided for @pcApprovalQueueFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the approval queue.'**
  String get pcApprovalQueueFailed;

  /// No description provided for @pcRejectName.
  ///
  /// In en, this message translates to:
  /// **'Reject {name}'**
  String pcRejectName(String name);

  /// No description provided for @pcApproveName.
  ///
  /// In en, this message translates to:
  /// **'Approve {name}'**
  String pcApproveName(String name);

  /// No description provided for @pcLoanLimitsUpper.
  ///
  /// In en, this message translates to:
  /// **'LOAN LIMITS'**
  String get pcLoanLimitsUpper;

  /// No description provided for @pcLimitsSummary.
  ///
  /// In en, this message translates to:
  /// **'Principal {minP} to {maxP}\nTerm {minM} to {maxM} months\nFee up to {fee}% • Interest up to {interest}%'**
  String pcLimitsSummary(
    String minP,
    String maxP,
    String minM,
    String maxM,
    String fee,
    String interest,
  );

  /// No description provided for @pcEditLimits.
  ///
  /// In en, this message translates to:
  /// **'Edit loan limits'**
  String get pcEditLimits;

  /// No description provided for @pcApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get pcApp;

  /// No description provided for @pcVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get pcVersion;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @profNoAnswerReloaded.
  ///
  /// In en, this message translates to:
  /// **'No answer from the server. Your profile was reloaded; check it and save again if needed.'**
  String get profNoAnswerReloaded;

  /// No description provided for @profNoApprovedTeam.
  ///
  /// In en, this message translates to:
  /// **'There is no approved team to show yet.'**
  String get profNoApprovedTeam;

  /// No description provided for @expDownloadExpired.
  ///
  /// In en, this message translates to:
  /// **'This file has expired. Create it again.'**
  String get expDownloadExpired;

  /// No description provided for @expDownloadNotReady.
  ///
  /// In en, this message translates to:
  /// **'The file is not ready yet.'**
  String get expDownloadNotReady;

  /// No description provided for @expDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'The download did not finish. Check your connection and try again.'**
  String get expDownloadFailed;

  /// No description provided for @expDownloadEmpty.
  ///
  /// In en, this message translates to:
  /// **'The downloaded file is empty. Try again.'**
  String get expDownloadEmpty;

  /// No description provided for @valRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String valRequired(String field);

  /// No description provided for @valThisField.
  ///
  /// In en, this message translates to:
  /// **'This field'**
  String get valThisField;

  /// No description provided for @valValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get valValue;

  /// No description provided for @valFieldCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get valFieldCity;

  /// No description provided for @valFieldConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get valFieldConfirmPassword;

  /// No description provided for @valNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get valNameRequired;

  /// No description provided for @valNameShort.
  ///
  /// In en, this message translates to:
  /// **'Name is too short'**
  String get valNameShort;

  /// No description provided for @valNameChars.
  ///
  /// In en, this message translates to:
  /// **'Name can only contain letters, spaces, and certain punctuation'**
  String get valNameChars;

  /// No description provided for @valPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get valPhoneRequired;

  /// No description provided for @valPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number'**
  String get valPhoneInvalid;

  /// No description provided for @valOtpRequired.
  ///
  /// In en, this message translates to:
  /// **'OTP is required'**
  String get valOtpRequired;

  /// No description provided for @valOtpLength.
  ///
  /// In en, this message translates to:
  /// **'Enter the {length}-digit OTP'**
  String valOtpLength(int length);

  /// No description provided for @valEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get valEmailRequired;

  /// No description provided for @valEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get valEmailInvalid;

  /// No description provided for @valPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get valPasswordRequired;

  /// No description provided for @valPasswordMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing: {items}'**
  String valPasswordMissing(String items);

  /// No description provided for @valMinChars.
  ///
  /// In en, this message translates to:
  /// **'{count}+ chars'**
  String valMinChars(int count);

  /// No description provided for @valUppercase.
  ///
  /// In en, this message translates to:
  /// **'uppercase'**
  String get valUppercase;

  /// No description provided for @valNumber.
  ///
  /// In en, this message translates to:
  /// **'number'**
  String get valNumber;

  /// No description provided for @valSpecialChar.
  ///
  /// In en, this message translates to:
  /// **'special char'**
  String get valSpecialChar;

  /// No description provided for @valConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get valConfirmPassword;

  /// No description provided for @valPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get valPasswordsMismatch;

  /// No description provided for @valAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get valAmountRequired;

  /// No description provided for @valAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than 0'**
  String get valAmountPositive;

  /// No description provided for @valAmountMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum is {amount}'**
  String valAmountMin(String amount);

  /// No description provided for @valAmountMax.
  ///
  /// In en, this message translates to:
  /// **'Maximum is {amount}'**
  String valAmountMax(String amount);

  /// No description provided for @valPercentRequired.
  ///
  /// In en, this message translates to:
  /// **'Percentage is required'**
  String get valPercentRequired;

  /// No description provided for @valNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get valNumberInvalid;

  /// No description provided for @valPercentRange.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 0 and {max}'**
  String valPercentRange(int max);

  /// No description provided for @valPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number greater than 0'**
  String get valPositiveNumber;

  /// No description provided for @audModAuth.
  ///
  /// In en, this message translates to:
  /// **'Auth'**
  String get audModAuth;

  /// No description provided for @audModProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get audModProfile;

  /// No description provided for @audModAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get audModAdmin;

  /// No description provided for @audModEmployee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get audModEmployee;

  /// No description provided for @audModCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get audModCustomer;

  /// No description provided for @audModLoan.
  ///
  /// In en, this message translates to:
  /// **'Loan'**
  String get audModLoan;

  /// No description provided for @audModPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get audModPayment;

  /// No description provided for @audModSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get audModSettings;

  /// No description provided for @audModSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get audModSystem;

  /// No description provided for @audModOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get audModOther;

  /// No description provided for @audActAdminRegistered.
  ///
  /// In en, this message translates to:
  /// **'Admin registered'**
  String get audActAdminRegistered;

  /// No description provided for @audActLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get audActLoginFailed;

  /// No description provided for @audActLoginBlocked.
  ///
  /// In en, this message translates to:
  /// **'Login blocked'**
  String get audActLoginBlocked;

  /// No description provided for @audActPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Password reset'**
  String get audActPasswordReset;

  /// No description provided for @audActSessionsRevoked.
  ///
  /// In en, this message translates to:
  /// **'Sessions signed out'**
  String get audActSessionsRevoked;

  /// No description provided for @audActProfileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get audActProfileUpdated;

  /// No description provided for @audActPhoneChanged.
  ///
  /// In en, this message translates to:
  /// **'Phone number changed'**
  String get audActPhoneChanged;

  /// No description provided for @audActPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed'**
  String get audActPasswordChanged;

  /// No description provided for @audActLoanDefaultsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Loan defaults updated'**
  String get audActLoanDefaultsUpdated;

  /// No description provided for @audActAdminVerificationChanged.
  ///
  /// In en, this message translates to:
  /// **'Admin approval changed'**
  String get audActAdminVerificationChanged;

  /// No description provided for @audActAdminActiveChanged.
  ///
  /// In en, this message translates to:
  /// **'Admin activated or deactivated'**
  String get audActAdminActiveChanged;

  /// No description provided for @audActAdminDefaultsChanged.
  ///
  /// In en, this message translates to:
  /// **'Admin defaults changed'**
  String get audActAdminDefaultsChanged;

  /// No description provided for @audActEmployeeCreated.
  ///
  /// In en, this message translates to:
  /// **'Employee created'**
  String get audActEmployeeCreated;

  /// No description provided for @audActEmployeeVerificationChanged.
  ///
  /// In en, this message translates to:
  /// **'Employee approval changed'**
  String get audActEmployeeVerificationChanged;

  /// No description provided for @audActEmployeeActiveChanged.
  ///
  /// In en, this message translates to:
  /// **'Employee activated or deactivated'**
  String get audActEmployeeActiveChanged;

  /// No description provided for @audActEmployeeReassigned.
  ///
  /// In en, this message translates to:
  /// **'Employee moved to another admin'**
  String get audActEmployeeReassigned;

  /// No description provided for @audActEmployeeDefaultsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Employee defaults updated'**
  String get audActEmployeeDefaultsUpdated;

  /// No description provided for @audActEmployeeProfileEdited.
  ///
  /// In en, this message translates to:
  /// **'Employee profile edited'**
  String get audActEmployeeProfileEdited;

  /// No description provided for @audActCustomerCreated.
  ///
  /// In en, this message translates to:
  /// **'Customer created'**
  String get audActCustomerCreated;

  /// No description provided for @audActCustomerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Customer updated'**
  String get audActCustomerUpdated;

  /// No description provided for @audActCustomerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted'**
  String get audActCustomerDeleted;

  /// No description provided for @audActCustomerReassigned.
  ///
  /// In en, this message translates to:
  /// **'Customer reassigned'**
  String get audActCustomerReassigned;

  /// No description provided for @audActReferrerChanged.
  ///
  /// In en, this message translates to:
  /// **'Referrer changed'**
  String get audActReferrerChanged;

  /// No description provided for @audActLoanCreated.
  ///
  /// In en, this message translates to:
  /// **'Loan created'**
  String get audActLoanCreated;

  /// No description provided for @audActLoanStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'Loan status changed'**
  String get audActLoanStatusChanged;

  /// No description provided for @audActLoanTermsEdited.
  ///
  /// In en, this message translates to:
  /// **'Loan terms edited'**
  String get audActLoanTermsEdited;

  /// No description provided for @audActLoanClosed.
  ///
  /// In en, this message translates to:
  /// **'Loan closed'**
  String get audActLoanClosed;

  /// No description provided for @audActLoanWrittenOff.
  ///
  /// In en, this message translates to:
  /// **'Loan written off'**
  String get audActLoanWrittenOff;

  /// No description provided for @audActLoanDeleted.
  ///
  /// In en, this message translates to:
  /// **'Loan deleted'**
  String get audActLoanDeleted;

  /// No description provided for @audActPaymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get audActPaymentRecorded;

  /// No description provided for @audActPaymentEdited.
  ///
  /// In en, this message translates to:
  /// **'Payment edited'**
  String get audActPaymentEdited;

  /// No description provided for @audActPaymentReversed.
  ///
  /// In en, this message translates to:
  /// **'Payment reversed'**
  String get audActPaymentReversed;

  /// No description provided for @audActWeekStatusChanged.
  ///
  /// In en, this message translates to:
  /// **'Week status changed'**
  String get audActWeekStatusChanged;

  /// No description provided for @audActBackdatedPayment.
  ///
  /// In en, this message translates to:
  /// **'Backdated payment'**
  String get audActBackdatedPayment;

  /// No description provided for @audActLoanLimitsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Loan limits updated'**
  String get audActLoanLimitsUpdated;

  /// No description provided for @audActSettingsChanged.
  ///
  /// In en, this message translates to:
  /// **'Settings changed'**
  String get audActSettingsChanged;

  /// No description provided for @audActDataExported.
  ///
  /// In en, this message translates to:
  /// **'Data exported'**
  String get audActDataExported;

  /// No description provided for @audActBulkImport.
  ///
  /// In en, this message translates to:
  /// **'Bulk import'**
  String get audActBulkImport;

  /// No description provided for @audEntUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get audEntUser;

  /// No description provided for @audEntWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get audEntWeek;

  /// No description provided for @audEntSetting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get audEntSetting;

  /// No description provided for @audFieldStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get audFieldStatus;

  /// No description provided for @audFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get audFieldName;

  /// No description provided for @audFieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get audFieldPhone;

  /// No description provided for @audFieldEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get audFieldEmail;

  /// No description provided for @audFieldApproval.
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get audFieldApproval;

  /// No description provided for @audFieldActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get audFieldActive;

  /// No description provided for @audFieldDefaultUpfrontFee.
  ///
  /// In en, this message translates to:
  /// **'Default upfront fee'**
  String get audFieldDefaultUpfrontFee;

  /// No description provided for @audFieldDefaultInterest.
  ///
  /// In en, this message translates to:
  /// **'Default interest'**
  String get audFieldDefaultInterest;

  /// No description provided for @audFieldDefaultTerm.
  ///
  /// In en, this message translates to:
  /// **'Default term'**
  String get audFieldDefaultTerm;

  /// No description provided for @audFieldDefaultTermWeeks.
  ///
  /// In en, this message translates to:
  /// **'Default term (weeks)'**
  String get audFieldDefaultTermWeeks;

  /// No description provided for @audFieldPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get audFieldPrincipal;

  /// No description provided for @audFieldTotalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total payable'**
  String get audFieldTotalPayable;

  /// No description provided for @audFieldWeeklyInstallment.
  ///
  /// In en, this message translates to:
  /// **'Weekly installment'**
  String get audFieldWeeklyInstallment;

  /// No description provided for @audFieldUpfrontFee.
  ///
  /// In en, this message translates to:
  /// **'Upfront fee'**
  String get audFieldUpfrontFee;

  /// No description provided for @audFieldMinPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Minimum principal'**
  String get audFieldMinPrincipal;

  /// No description provided for @audFieldMaxPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Maximum principal'**
  String get audFieldMaxPrincipal;

  /// No description provided for @audFieldMinTerm.
  ///
  /// In en, this message translates to:
  /// **'Minimum term'**
  String get audFieldMinTerm;

  /// No description provided for @audFieldMaxTerm.
  ///
  /// In en, this message translates to:
  /// **'Maximum term'**
  String get audFieldMaxTerm;

  /// No description provided for @audFieldMaxFee.
  ///
  /// In en, this message translates to:
  /// **'Maximum fee'**
  String get audFieldMaxFee;

  /// No description provided for @audFieldMaxInterest.
  ///
  /// In en, this message translates to:
  /// **'Maximum interest'**
  String get audFieldMaxInterest;

  /// No description provided for @audFieldAmountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get audFieldAmountPaid;

  /// No description provided for @audFieldCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer name'**
  String get audFieldCustomerName;

  /// No description provided for @audFieldCollectionDay.
  ///
  /// In en, this message translates to:
  /// **'Collection day'**
  String get audFieldCollectionDay;

  /// No description provided for @audFieldReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get audFieldReason;

  /// No description provided for @audFieldSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get audFieldSource;

  /// No description provided for @audValEmpty.
  ///
  /// In en, this message translates to:
  /// **'empty'**
  String get audValEmpty;

  /// No description provided for @audValVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get audValVerified;

  /// No description provided for @audValNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get audValNotVerified;

  /// No description provided for @audValInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get audValInactive;

  /// No description provided for @audValYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get audValYes;

  /// No description provided for @audValNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get audValNo;

  /// No description provided for @audValMonths.
  ///
  /// In en, this message translates to:
  /// **'{n} months'**
  String audValMonths(String n);

  /// No description provided for @audValWeeks.
  ///
  /// In en, this message translates to:
  /// **'{n} weeks'**
  String audValWeeks(String n);

  /// No description provided for @audMoreCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String audMoreCount(int count);

  /// No description provided for @audYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get audYesterday;

  /// No description provided for @trackerNothingLeft.
  ///
  /// In en, this message translates to:
  /// **'Nothing left to collect on this loan.'**
  String get trackerNothingLeft;

  /// No description provided for @payPastTermOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue — past the {weeks}-week term'**
  String payPastTermOverdue(int weeks);

  /// No description provided for @payHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get payHistory;

  /// No description provided for @payCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payment} other{{count} payments}}'**
  String payCount(int count);

  /// No description provided for @payOfTotal.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String payOfTotal(String amount);

  /// No description provided for @payWeeksPaid.
  ///
  /// In en, this message translates to:
  /// **'WEEKS PAID'**
  String get payWeeksPaid;

  /// No description provided for @payWeeksPaidValue.
  ///
  /// In en, this message translates to:
  /// **'{paid} of {total}'**
  String payWeeksPaidValue(int paid, int total);

  /// No description provided for @payLastPaid.
  ///
  /// In en, this message translates to:
  /// **'LAST PAID'**
  String get payLastPaid;

  /// No description provided for @payWeekClearedShort.
  ///
  /// In en, this message translates to:
  /// **'Week cleared'**
  String get payWeekClearedShort;

  /// No description provided for @payLeftForWeek.
  ///
  /// In en, this message translates to:
  /// **'{amount} left for this week'**
  String payLeftForWeek(String amount);

  /// No description provided for @payDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment details'**
  String get payDetails;

  /// No description provided for @payPaidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get payPaidOn;

  /// No description provided for @payCollectedBy.
  ///
  /// In en, this message translates to:
  /// **'Collected by'**
  String get payCollectedBy;

  /// No description provided for @payReference.
  ///
  /// In en, this message translates to:
  /// **'Payment reference'**
  String get payReference;

  /// No description provided for @payWeekRecord.
  ///
  /// In en, this message translates to:
  /// **'Week record'**
  String get payWeekRecord;

  /// No description provided for @payOpenDetails.
  ///
  /// In en, this message translates to:
  /// **'Open payment details'**
  String get payOpenDetails;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
