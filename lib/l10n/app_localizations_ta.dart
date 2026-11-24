// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get languageTitle => 'மொழி';

  @override
  String get languageSubtitle => 'செயலியின் மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTamil => 'தமிழ்';

  @override
  String get deviceLanguageNotice =>
      'உங்கள் தொலைபேசியில் தமிழ் விருப்ப மொழியாக உள்ளது, அதனால் செயலி தமிழில் திறக்கப்பட்டுள்ளது. முகப்புத் திரையின் மேலே உள்ள மொழி பொத்தானில் இதை மாற்றலாம்.';

  @override
  String get commonOk => 'சரி';

  @override
  String get commonCancel => 'ரத்து செய்';

  @override
  String get commonSave => 'சேமி';

  @override
  String get commonClose => 'மூடு';

  @override
  String get commonRetry => 'மீண்டும் முயற்சி';

  @override
  String daysLate(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count நாட்கள் தாமதம்',
      one: '1 நாள் தாமதம்',
    );
    return '$_temp0';
  }

  @override
  String commonWeekN(int week) {
    return 'வாரம் $week';
  }

  @override
  String payWeekAlreadyPaid(int week) {
    return 'வாரம் $week ஏற்கனவே முழுமையாகச் செலுத்தப்பட்டது';
  }

  @override
  String get payDueToday => 'இன்று செலுத்த வேண்டும்';

  @override
  String get payScheduledAhead => 'முன்கூட்டியே திட்டமிடப்பட்டது';

  @override
  String get payPartialOnFile => 'பகுதி கட்டணம் பதிவில் உள்ளது';

  @override
  String get payOverdueNotCollected => 'தாமதம் — இன்னும் வசூலிக்கப்படவில்லை';

  @override
  String payWeekDate(int week, String date) {
    return 'வாரம் $week • $date';
  }

  @override
  String payStillOwedForWeek(String amount, int week) {
    return 'வாரம் $week-க்கு இன்னும் $amount நிலுவை';
  }

  @override
  String payWeekWasDue(int week, String date) {
    return 'வாரம் $week $date அன்று செலுத்த வேண்டியது';
  }

  @override
  String get payEnterValidAmount => 'சரியான கட்டணத் தொகையை உள்ளிடவும்';

  @override
  String get payCash => 'ரொக்கம்';

  @override
  String get payUpi => 'UPI';

  @override
  String get payCollectPayment => 'கட்டணம் வசூல்';

  @override
  String payWeekOfTotal(int week, int total) {
    return 'வாரம் $week / $total';
  }

  @override
  String get payAmountToCollect => 'வசூலிக்க வேண்டிய தொகை';

  @override
  String payUpToCollectable(String amount) {
    return 'இந்தக் கடனில் அதிகபட்சம் $amount வசூலிக்கலாம்';
  }

  @override
  String payClearWeek(int week) {
    return 'வாரம் $week முடி';
  }

  @override
  String get payTwoWeeks => '2 வாரம் செலுத்து';

  @override
  String paySettleFullLoan(String amount) {
    return 'முழுக் கடனையும் முடி — $amount';
  }

  @override
  String get payThisWeek => 'இந்த வாரம்';

  @override
  String get payEntireLoan => 'முழுக் கடன்';

  @override
  String get payCleared => 'முடிந்தது ✓';

  @override
  String payConfirmClose(String amount) {
    return 'உறுதிசெய்து கடனை முடி — $amount';
  }

  @override
  String payConfirmRecord(String amount) {
    return 'உறுதிசெய்து $amount பதிவு செய்';
  }

  @override
  String otpEnterComplete(int length) {
    return 'முழு $length இலக்கக் குறியீட்டை உள்ளிடவும்';
  }

  @override
  String get otpNewCodeSent => 'புதிய குறியீடு அனுப்பப்பட்டது.';

  @override
  String get otpVerifyPhone => 'தொலைபேசி எண்ணைச் சரிபார்க்கவும்';

  @override
  String otpEnterCodeSentTo(int length, String phone) {
    return '$phone எண்ணுக்கு அனுப்பப்பட்ட $length இலக்கக் குறியீட்டை உள்ளிடவும்.';
  }

  @override
  String otpResendIn(int seconds) {
    return '$seconds வினாடிகளில் மீண்டும் அனுப்பலாம்';
  }

  @override
  String get otpResend => 'OTP மீண்டும் அனுப்பு';

  @override
  String get commonContinue => 'தொடரவும்';

  @override
  String get statusPaid => 'செலுத்தப்பட்டது';

  @override
  String get statusPartial => 'பகுதி';

  @override
  String get statusUnpaid => 'செலுத்தவில்லை';

  @override
  String get statusScheduled => 'திட்டமிடப்பட்டது';

  @override
  String get statusUpcoming => 'வரவிருக்கிறது';

  @override
  String get statusOverdue => 'தாமதம்';

  @override
  String trackDueOn(String date) {
    return 'செலுத்த வேண்டியது $date';
  }

  @override
  String get trackPaidInFull => 'முழுமையாகச் செலுத்தப்பட்டது';

  @override
  String trackDueToClear(String amount) {
    return 'முடிக்க $amount நிலுவை';
  }

  @override
  String get trackNotCollected => 'வசூலிக்கப்படவில்லை';

  @override
  String trackPending(String amount) {
    return '$amount நிலுவையில்';
  }

  @override
  String get trackUpcoming => 'வரவிருக்கிறது';

  @override
  String trackPastTerm(int weeks) {
    return '$weeks வாரக் காலம் கடந்தது';
  }

  @override
  String trackOverdueAmount(String amount) {
    return '$amount தாமதம்';
  }

  @override
  String trackWeekShort(String week) {
    return 'வா $week';
  }

  @override
  String trackCollectAmount(String amount) {
    return '$amount வசூல் செய்';
  }

  @override
  String get referralSelectTitle =>
      'பரிந்துரைத்த கடன் பெறுநரைத் தேர்ந்தெடுக்கவும்';

  @override
  String get commonSearchNamePhone => 'பெயர் அல்லது தொலைபேசி மூலம் தேடவும்';

  @override
  String get referralNoneFound => 'பரிந்துரையாளர்கள் இல்லை';

  @override
  String get payPastTerm => 'காலம் கடந்தது';

  @override
  String get payAmountPaid => 'செலுத்திய தொகை';

  @override
  String get payWeekCleared => 'வாரம் முடிந்தது';

  @override
  String payWeekProgress(int week) {
    return 'வாரம் $week முன்னேற்றம்';
  }

  @override
  String payWeekFullyCollected(int week, String amount) {
    return 'வாரம் $week முழுமையாக வசூலானது ($amount)';
  }

  @override
  String payCollectedOfLeft(String collected, String target, String left) {
    return '$target-இல் $collected வசூலானது • $left மீதம்';
  }

  @override
  String get payIdCopied => 'கட்டண ஐடி நகலெடுக்கப்பட்டது';

  @override
  String get commonCall => 'அழை';

  @override
  String get commonUnableOpenDialer => 'டயலரைத் திறக்க முடியவில்லை';

  @override
  String stepDecrease(String label) {
    return '$label குறை';
  }

  @override
  String stepIncrease(String label) {
    return '$label கூட்டு';
  }

  @override
  String get recoveryOverallTarget => 'மொத்த வசூல் இலக்கு';

  @override
  String recoveryPercentCompleted(String percent) {
    return '$percent% நிறைவு';
  }

  @override
  String get recoveryOverall => 'மொத்த வசூல்';

  @override
  String recoveryOverdueLine(String percent, String amount) {
    return '$percent% தாமதம் • $amount';
  }

  @override
  String ringPercentCollected(int percent) {
    return '$percent சதவீதம் வசூலானது';
  }

  @override
  String get securityRating => 'பாதுகாப்பு மதிப்பீடு';

  @override
  String get securityWeak => 'பலவீனம்';

  @override
  String get securityFair => 'பரவாயில்லை';

  @override
  String get securityGood => 'நல்லது';

  @override
  String get securityStrong => 'வலுவானது';

  @override
  String securityLevelOf(int level, int total) {
    return '$total-இல் $level';
  }

  @override
  String placeholderComingSoon(String title) {
    return '$title: விரைவில் வருகிறது';
  }

  @override
  String get commonRequired => '*அவசியம்';

  @override
  String get appName => 'தவணை';

  @override
  String get authSelectLoginMethod => 'உள்நுழைவு முறையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get authWelcomeBack => 'மீண்டும் வருக';

  @override
  String get authSelectMethodSubtitle =>
      'உங்கள் கள பேரேடு மற்றும் தினசரி வசூல்களை அணுக விருப்பமான உள்நுழைவு முறையைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get authEmailPassword => 'மின்னஞ்சல் & கடவுச்சொல்';

  @override
  String get authEmailPasswordSubtitle =>
      'பதிவுசெய்த மின்னஞ்சல் முகவரி மூலம் உள்நுழையவும்...';

  @override
  String get authPhoneOtp => 'தொலைபேசி OTP சரிபார்ப்பு';

  @override
  String get authPhoneOtpSubtitle =>
      'பதிவுசெய்த மொபைல் எண்ணுக்கு வரும் 6 இலக்க OTP மூலம் உடனடி உள்நுழைவு';

  @override
  String get commonOr => 'அல்லது';

  @override
  String get authNoAccount => 'கணக்கு இல்லையா?';

  @override
  String get authRegisterHere => 'இங்கே பதிவு செய்யவும்';

  @override
  String get authEmailLogin => 'மின்னஞ்சல் உள்நுழைவு';

  @override
  String get authSignInToAccess => 'உங்கள் கணக்கை அணுக உள்நுழையவும்.';

  @override
  String get authEmailAddress => 'மின்னஞ்சல் முகவரி';

  @override
  String get authEnterEmailHint => 'உங்கள் மின்னஞ்சலை உள்ளிடவும்...';

  @override
  String get authPassword => 'கடவுச்சொல்';

  @override
  String get authEnterPasswordHint => 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்...';

  @override
  String get authForgotPassword => 'கடவுச்சொல் மறந்துவிட்டதா?';

  @override
  String get authSignIn => 'உள்நுழை';

  @override
  String get authOrQuickSwitch => 'அல்லது விரைவாக மாற்று';

  @override
  String get authLoginWithPhone => 'தொலைபேசி எண் மூலம் உள்நுழை';

  @override
  String get authNoAccountInline => 'கணக்கு இல்லையா? ';

  @override
  String get authCreateAccount => 'கணக்கை உருவாக்கு';

  @override
  String get authNewCodeSent => 'புதிய சரிபார்ப்புக் குறியீடு அனுப்பப்பட்டது.';

  @override
  String get authEnterComplete6 => 'முழு 6 இலக்கக் குறியீட்டை உள்ளிடவும்';

  @override
  String get authVerifyContinue => 'சரிபார்த்துத் தொடரவும்';

  @override
  String get authSendOtp => 'OTP அனுப்பு';

  @override
  String get authOtpLogin => 'OTP உள்நுழைவு';

  @override
  String get authLoginWithOtp => 'OTP மூலம் உள்நுழை';

  @override
  String get authOtpSubtitle =>
      'உங்கள் பதிவுசெய்த மொபைலுக்கு பாதுகாப்பான SMS மூலம் அனுப்பப்பட்ட 6 இலக்கக் குறியீட்டை உள்ளிடவும்.';

  @override
  String get authLoginWithEmail => 'மின்னஞ்சல் மூலம் உள்நுழை';

  @override
  String get authRegisteredNumber => 'பதிவுசெய்த எண்';

  @override
  String get authPhoneNumber => 'தொலைபேசி எண்';

  @override
  String get authEnterPhoneHint => 'உங்கள் தொலைபேசி எண்ணை உள்ளிடவும்...';

  @override
  String get approvalVerificationRequired =>
      'தொடர கணக்குச் சரிபார்ப்பு அவசியம்';

  @override
  String get approvalPendingTitle => 'ஒப்புதல் நிலுவையில்';

  @override
  String get approvalUnderReviewBadge =>
      'விண்ணப்பம் பரிசீலனையில் • நிர்வாகி ஒப்புதலுக்காகக் காத்திருக்கிறது';

  @override
  String get approvalInProgress => 'ஒப்புதல் நடைபெறுகிறது';

  @override
  String get approvalSubmittedBody =>
      'உங்கள் சுயவிவரம் மற்றும் கடன் அளவுருக்கள் சமர்ப்பிக்கப்பட்டன. நிர்வாகி விரைவில் உங்கள் கணக்கைப் பரிசீலித்து ஒப்புதல் அளிப்பார்.';

  @override
  String get approvalWhatNext => 'அடுத்து என்ன நடக்கும்';

  @override
  String get approvalWhatNextBody =>
      'உங்கள் சுயவிவரம் தற்போது நிர்வாகியின் பரிசீலனையில் உள்ளது. கணக்கு அங்கீகரிக்கப்பட்டு செயல்படுத்தப்பட்டதும் உங்களுக்குத் தெரிவிக்கப்படும்.';

  @override
  String get approvalReviewTimeframe => 'பரிசீலனைக் காலம்';

  @override
  String get approvalTypicalTime =>
      'வழக்கமான பரிசீலனை நேரம்: 24-48 வேலை நேரங்கள்';

  @override
  String get resetTitle => 'கடவுச்சொல் மீட்டமைப்பு';

  @override
  String get resetHeading => 'உங்கள் கடவுச்சொல்லை மீட்டமைக்கவும்';

  @override
  String get resetSubtitle =>
      'உங்கள் கணக்கிற்குப் பாதுகாப்பான புதிய கடவுச்சொல்லை உருவாக்க, பதிவுசெய்த மின்னஞ்சல் அல்லது தொலைபேசி எண்ணைச் சரிபார்க்கவும்.';

  @override
  String get resetRememberPassword => 'கடவுச்சொல் நினைவிருக்கிறதா? ';

  @override
  String get resetBackToLogin => 'உள்நுழைவுக்குத் திரும்பு';

  @override
  String get resetRegisteredEmail => 'பதிவுசெய்த மின்னஞ்சல் முகவரி';

  @override
  String get resetRegisteredPhone => 'பதிவுசெய்த தொலைபேசி எண்';

  @override
  String get resetEnterEmail => 'உங்கள் மின்னஞ்சல் முகவரியை உள்ளிடவும்';

  @override
  String get resetEnterPhone => 'உங்கள் தொலைபேசி எண்ணை உள்ளிடவும்';

  @override
  String get resetNewPassword => 'புதிய கடவுச்சொல்';

  @override
  String get resetNewPasswordHint => 'வலுவான புதிய கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get resetConfirmPassword => 'புதிய கடவுச்சொல்லை உறுதிசெய்';

  @override
  String get resetConfirmHint => 'உறுதிசெய்ய கடவுச்சொல்லை மீண்டும் உள்ளிடவும்';

  @override
  String get resetPasswordsMustMatch =>
      'கடவுச்சொற்கள் சரியாகப் பொருந்த வேண்டும்';

  @override
  String get resetUpdatePassword => 'கடவுச்சொல்லைப் புதுப்பி';

  @override
  String get resetGetCode => 'சரிபார்ப்புக் குறியீட்டைப் பெறு';

  @override
  String get regTitle => 'பதிவு';

  @override
  String get regBackToStep1 => 'படி 1-க்குத் திரும்பு';

  @override
  String regStepN(int step) {
    return 'படி $step';
  }

  @override
  String get regPersonalDetails => 'தனிப்பட்ட விவரங்கள்';

  @override
  String get regLendingTerms => 'கடன் விதிமுறைகள்';

  @override
  String get commonDone => 'முடிந்தது';

  @override
  String get regStep1Subtitle =>
      'படி 1 / 2: தனிப்பட்ட விவரங்கள். கணக்கை உருவாக்க உங்கள் தகவலை உள்ளிடவும்.';

  @override
  String get regFullName => 'முழுப் பெயர்';

  @override
  String get regEnterName => 'உங்கள் பெயரை உள்ளிடவும்';

  @override
  String get regEnterMobile => 'உங்கள் மொபைல் எண்ணை உள்ளிடவும்';

  @override
  String get regCreatePassword => 'கடவுச்சொல்லை உருவாக்கு';

  @override
  String get regEnterPassword => 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get regSecurityRating => 'பாதுகாப்பு மதிப்பீடு';

  @override
  String get regStrengthLow => 'குறைவு';

  @override
  String get regStrengthMedium => 'நடுத்தரம்';

  @override
  String get regStrengthHigh => 'அதிகம்';

  @override
  String get regStrengthExcellent => 'மிகச் சிறப்பு';

  @override
  String get regLendingSubtitle =>
      'இறுதிப் படி - உங்கள் நிலையான கடன் அளவுருக்களை அமைக்கவும். இவை கடன் கணக்கீட்டில் இயல்பாக நிரப்பப்படும்.';

  @override
  String get regVerifiedProfile => 'சரிபார்க்கப்பட்ட சுயவிவரம்';

  @override
  String get regFieldUser => 'கள பயனர்';

  @override
  String get termsDefaultInterest => 'இயல்பு வட்டி விகிதம்';

  @override
  String get termsFlatRate => 'நிலையான விகிதம்';

  @override
  String get termsEnterInterest => 'உங்கள் வட்டி விகிதத்தை உள்ளிடவும்';

  @override
  String get termsInterestFooter =>
      'முழுக் கடன் காலத்திற்கும் நிலையாகப் பொருந்தும்.';

  @override
  String get termsInterestRate => 'வட்டி விகிதம்';

  @override
  String get termsUpfrontFee => 'முன்கூட்டிய செயலாக்கக் கட்டணம்';

  @override
  String get termsAtDisbursement => 'வழங்கும்போது';

  @override
  String get termsEnterUpfront => 'முன்கூட்டிய கட்டணத்தை உள்ளிடவும்';

  @override
  String get termsUpfrontFooter =>
      'உடனடி வழங்கலின்போது ஒப்படைக்கும் பணத்திலிருந்து உடனே கழிக்கப்படும்.';

  @override
  String get termsUpfrontFeeShort => 'முன்கூட்டிய கட்டணம்';

  @override
  String get termsTotalDurationMonths => 'மொத்தக் காலம் (மாதங்கள்)';

  @override
  String get termsWeeklySchedule => 'வாராந்திர அட்டவணை';

  @override
  String termsMonthsShort(String value) {
    return '$value மா';
  }

  @override
  String get termsMonths => 'மாதங்கள்';

  @override
  String get regBaselinePreview => 'நிலையான அடிப்படை\nமுன்னோட்டம்';

  @override
  String regLoanModel(String amount) {
    return '$amount \nகடன் மாதிரி';
  }

  @override
  String get regNetHandover => 'நிகர ஒப்படைப்புப் பணம்';

  @override
  String regDeductedFee(String amount) {
    return 'கழிக்கப்பட்ட கட்டணம்: -$amount\n';
  }

  @override
  String get regTotalRepayable => 'மொத்தத் திருப்பிச் செலுத்தல்';

  @override
  String regIncludesInterest(String amount, String percent) {
    return '$amount ($percent) உட்பட';
  }

  @override
  String get regWeeklyCollection => 'வாராந்திர வசூல் தொகை';

  @override
  String get regFixedEveryMonday => 'ஒவ்வொரு திங்கள்\nநிலையான தவணை';

  @override
  String get regPerWeek => 'வாரத்திற்கு\n';

  @override
  String regWeeksParen(int weeks) {
    return '($weeks) வாரங்கள்';
  }

  @override
  String get regInstallmentSchedule => 'தவணை அட்டவணை';

  @override
  String get regPrincipalFlat => 'அசல் + நிலை வட்டி';

  @override
  String get commonStatus => 'நிலை';

  @override
  String regWeekHash(String week) {
    return 'வாரம் #$week';
  }

  @override
  String regAdditionalCycles(int count) {
    return '+ முதிர்வு வரை மேலும் $count வாராந்திர சுழற்சிகள்';
  }

  @override
  String get regHaveAccount => 'ஏற்கனவே கணக்கு உள்ளதா? ';

  @override
  String get regSignIn => 'உள்நுழை';

  @override
  String get regDraftCached => 'வரைவு சாதனத்தில் சேமிக்கப்பட்டது';

  @override
  String regStepOf(int step, int total) {
    return 'படி $step / $total';
  }

  @override
  String get regVerifyPhone => 'தொலைபேசி எண்ணைச் சரிபார்';

  @override
  String get regRegister => 'பதிவு செய்';

  @override
  String get termsCalculateTerm => 'காலம் கணக்கிடு:';

  @override
  String termsWeeksCount(int weeks) {
    return '$weeks வாரங்கள் ';
  }

  @override
  String termsDaysParen(int days) {
    return '($days நாட்கள்)';
  }

  @override
  String get termsAutoCalculated => 'தானியங்கு கணக்கீடு: ';

  @override
  String get termsEnterMonths => 'மாதங்களின் எண்ணிக்கையை உள்ளிடவும்';

  @override
  String termsMonthsCount(String months) {
    return '$months மாதங்கள் ';
  }

  @override
  String get termsTimesFourWeeks => 'x 4 வாரங்கள் = ';

  @override
  String termsWeeklyCollections(int weeks) {
    return '$weeks வாராந்திர வசூல்கள்';
  }

  @override
  String get tabField => 'களம்';

  @override
  String get tabLoans => 'கடன்கள்';

  @override
  String get tabBorrowers => 'கடன் பெறுநர்கள்';

  @override
  String get tabReports => 'அறிக்கைகள்';

  @override
  String get menuMyProfile => 'என் சுயவிவரம்';

  @override
  String get menuMyProfileSub =>
      'பெயர், தொலைபேசி, மின்னஞ்சல் மற்றும் கடன் இயல்புகள்';

  @override
  String get menuAddBorrower => 'கடன் பெறுநரைச் சேர்';

  @override
  String get menuAddBorrowerSub => 'புதிய வாடிக்கையாளரைப் பதிவு செய்';

  @override
  String get menuManageUsers => 'பயனர்களை நிர்வகி';

  @override
  String get menuManageUsersSub => 'குழு உறுப்பினர்களைச் சேர்த்து பங்குகளை அமை';

  @override
  String get menuAnalytics => 'மேம்பட்ட பகுப்பாய்வு';

  @override
  String get menuAnalyticsSub => 'வசூல், தாமதப் போக்குகள் மற்றும் சேகரிப்புகள்';

  @override
  String get menuAllAdmins => 'அனைத்து நிர்வாகிகள்';

  @override
  String get menuAllAdminsSub => 'நிர்வாகி கணக்குகளை அங்கீகரித்து நிர்வகி';

  @override
  String get menuAuditLog => 'தணிக்கைப் பதிவு';

  @override
  String get menuAuditLogSub => 'யார், எதை, எப்போது மாற்றினார்கள்';

  @override
  String get menuDownloads => 'பதிவிறக்கங்கள்';

  @override
  String get menuDownloadsSub =>
      'நீங்கள் ஏற்றுமதி செய்த தாள்கள் மற்றும் அறிக்கைகள்';

  @override
  String get greetMorning => 'காலை வணக்கம்';

  @override
  String get greetAfternoon => 'மதிய வணக்கம்';

  @override
  String get greetEvening => 'மாலை வணக்கம்';

  @override
  String get menuOpenProfile => 'சுயவிவர மெனுவைத் திற';

  @override
  String get menuSignedOut => 'வெளியேறியது';

  @override
  String get menuLogOut => 'வெளியேறு';

  @override
  String get menuLogOutSub => 'நீங்கள் மீண்டும் உள்நுழைய வேண்டும்.';

  @override
  String get menuLogOutConfirm => 'வெளியேறவா?';

  @override
  String get errorPageNotFound => '404! பக்கம் கிடைக்கவில்லை.';

  @override
  String get roleUser => 'பயனர்';

  @override
  String get roleAdmin => 'நிர்வாகி';

  @override
  String get roleSuperAdmin => 'முதன்மை நிர்வாகி';

  @override
  String get manualStatusClosed => 'மூடப்பட்டது';

  @override
  String get manualStatusDefaulted => 'தவறியது';

  @override
  String get manualStatusReopen => 'செயலில் (மீண்டும் திற)';

  @override
  String get manualStatusClosedDesc =>
      'கடனை முடிக்கிறது. இதில் இனி எதுவும் வசூலிக்க முடியாது.';

  @override
  String get manualStatusDefaultedDesc =>
      'கடன் பெறுநர் திருப்பிச் செலுத்த மாட்டார். கடன் தவறியதாகத் தள்ளுபடி செய்யப்படும்.';

  @override
  String get manualStatusReopenDesc =>
      'வசூலை மீண்டும் தொடங்க கடனை மீண்டும் திறக்கிறது. வாரங்கள் ஏற்கனவே கடந்திருந்தால் மீண்டும் தாமதமாகக் காட்டப்படும்.';

  @override
  String get exportWeekdaySheet => 'வசூல் தாள்';

  @override
  String get exportWeekdaySheetBlurb =>
      'ஒரு வார நாளுக்கு ஒவ்வொரு வாடிக்கையாளருக்கும் ஒரு பகுதி: கடன் விவரங்கள் மற்றும் ஒவ்வொரு வாரமும் செலுத்தியது (W1 - 300, W2 - 400).';

  @override
  String get exportDueThisWeek => 'வழித் தாள்';

  @override
  String get exportDueThisWeekBlurb =>
      'நாள்வாரியாக செலுத்த வேண்டிய வாராந்திரத் தவணைகள், நிலுவை, செலுத்தியது மற்றும் மீதத் தொகையுடன்.';

  @override
  String get exportCustomerList => 'வாடிக்கையாளர் பட்டியல்';

  @override
  String get exportCustomerListBlurb =>
      'தொலைபேசி, பகுதி, செலுத்தும் நாள், செயலில் உள்ள கடன்கள் மற்றும் நிலுவையுடன் வாடிக்கையாளர்கள்.';

  @override
  String get exportOverdue => 'தாமதக் கடன்கள்';

  @override
  String get exportOverdueBlurb =>
      'தாமத நாட்கள் மற்றும் தாமதத் தொகையுடன் தாமதமான மற்றும் தவறிய கடன்கள்.';

  @override
  String get exportCollections => 'வசூல்கள்';

  @override
  String get exportCollectionsBlurb =>
      'ஒரு தேதி வரம்பில் பெறப்பட்ட ஒவ்வொரு கட்டணமும்.';

  @override
  String get exportLoansRegister => 'கடன் பதிவேடு';

  @override
  String get exportLoansRegisterBlurb =>
      'பணப் பத்திகளுடன் ஒவ்வொரு கடனும். நிலை மற்றும் வழங்கிய தேதி மூலம் வடிகட்டலாம்.';

  @override
  String get exportClosedLoans => 'மூடப்பட்ட கடன்கள்';

  @override
  String get exportClosedLoansBlurb =>
      'ஒரு வரம்பில் மூடப்பட்ட, முழுமையாகச் செலுத்தப்பட்ட அல்லது தவறிய கடன்கள், வசூல் மற்றும் பற்றாக்குறையுடன்.';

  @override
  String get exportNewCustomers => 'புதிய வாடிக்கையாளர்கள்';

  @override
  String get exportNewCustomersBlurb =>
      'ஒரு வரம்பில் சேர்க்கப்பட்ட வாடிக்கையாளர்கள், பரிந்துரையாளர் மற்றும் சேர்த்தவருடன்.';

  @override
  String get exportAuditLog => 'தணிக்கைப் பதிவு';

  @override
  String get exportAuditLogBlurb =>
      'யார் எதை மாற்றினார்கள், பழைய மற்றும் புதிய மதிப்புகளுடன்.';

  @override
  String get exportEmployeePerformance => 'ஊழியர் செயல்திறன்';

  @override
  String get exportEmployeePerformanceBlurb =>
      'ஒவ்வொரு ஊழியருக்கும்: வசூல், இலக்கு, விகிதங்கள், தாமதம், புதிய வாடிக்கையாளர்கள் மற்றும் கடன்கள்.';

  @override
  String get exportTeamSummary => 'குழுச் சுருக்கம்';

  @override
  String get exportTeamSummaryBlurb => 'ஒவ்வொரு நிர்வாகிக்கும் ஒரு வரிசை.';

  @override
  String get dayMonShort => 'திங்';

  @override
  String get dayTueShort => 'செவ்';

  @override
  String get dayWedShort => 'புத';

  @override
  String get dayThuShort => 'வியா';

  @override
  String get dayFriShort => 'வெள்';

  @override
  String get daySatShort => 'சனி';

  @override
  String get daySunShort => 'ஞாயி';

  @override
  String get dayMonday => 'திங்கள்';

  @override
  String get dayTuesday => 'செவ்வாய்';

  @override
  String get dayWednesday => 'புதன்';

  @override
  String get dayThursday => 'வியாழன்';

  @override
  String get dayFriday => 'வெள்ளி';

  @override
  String get daySaturday => 'சனி';

  @override
  String get daySunday => 'ஞாயிறு';

  @override
  String get custFillHighlighted => 'குறிக்கப்பட்ட புலங்களை நிரப்பவும்.';

  @override
  String get custOtpSendFailed =>
      'சரிபார்ப்புக் குறியீட்டை அனுப்ப முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String custOtpSentTo(String phone) {
    return '$phone எண்ணுக்கு சரிபார்ப்புக் குறியீடு அனுப்பப்பட்டது.';
  }

  @override
  String get custVerifyToAdd =>
      'இந்தக் கடன் பெறுநரைச் சேர்க்க தொலைபேசி எண்ணைச் சரிபார்க்கவும்.';

  @override
  String get custPhoneVerified => 'தொலைபேசி எண் சரிபார்க்கப்பட்டது.';

  @override
  String custAddedSuccess(String name) {
    return '$name வெற்றிகரமாகச் சேர்க்கப்பட்டார்.';
  }

  @override
  String get custAddFailed =>
      'கடன் பெறுநரைச் சேர்க்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get commonSomethingWrong =>
      'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get custSaveAdd => 'சேமித்து கடன் பெறுநரைச் சேர்';

  @override
  String get custCancelDiscard => 'ரத்து செய்து நிராகரி';

  @override
  String get custIdentityCredentials => 'அடையாள விவரங்கள்';

  @override
  String get custRequiredBadge => 'அவசியம்';

  @override
  String get custFullName => 'முழுப் பெயர்';

  @override
  String get custEnterFullName => 'முழுப் பெயரை உள்ளிடவும்';

  @override
  String get custMobileNumber => 'மொபைல் எண்';

  @override
  String get custEnterMobile => 'மொபைல் எண்ணை உள்ளிடவும்';

  @override
  String get custPreferredDayBatch => 'விருப்ப நாள் குழு';

  @override
  String get custAssignedRoute => 'வாராந்திர கள வசூல் வழியில் ஒதுக்கப்பட்டது';

  @override
  String custDayBatch(String day) {
    return '$day குழு';
  }

  @override
  String get custAddressLocation => 'முகவரி & இருப்பிடம்';

  @override
  String get custVerification => 'சரிபார்ப்பு';

  @override
  String get custStreet => 'தெருப் பெயர் / வீட்டு எண்';

  @override
  String get custStreetHint => 'தெருப் பெயர் அல்லது எண்';

  @override
  String get custCity => 'நகரம் / ஊர்';

  @override
  String get custEnterCity => 'நகரத்தை உள்ளிடவும்';

  @override
  String get custDistrict => 'மாவட்டம்';

  @override
  String get custEnterDistrict => 'மாவட்டத்தை உள்ளிடவும்';

  @override
  String get custReferredBy => 'பரிந்துரைத்த கடன் பெறுநர்';

  @override
  String get custOptional => 'விருப்பத்தேர்வு';

  @override
  String get custSelectReferrer => 'பரிந்துரையாளரைத் தேர்ந்தெடு';

  @override
  String custReferrerIdLine(String id) {
    return 'ஐடி $id • 2 முழுமையாகச் செலுத்திய கடன்கள்';
  }

  @override
  String get custChange => 'மாற்று';

  @override
  String get custAddBorrower => 'கடன் பெறுநரைச் சேர்';

  @override
  String get custSearchHint => 'கடன் பெறுநர், தெரு, நகரம், மாவட்டம் தேடவும்...';

  @override
  String get custNoneScheduled => 'திட்டமிடப்பட்ட வாடிக்கையாளர்கள் இல்லை';

  @override
  String get commonTapToRetry => 'மீண்டும் முயற்சிக்கத் தட்டவும்';

  @override
  String get custNoMore => 'மேலும் வாடிக்கையாளர்கள் இல்லை';

  @override
  String get custTodaysTarget => 'இன்றைய இலக்கு வழி';

  @override
  String get custDueSuffix => ' நிலுவை';

  @override
  String get custCollected => 'வசூலானது';

  @override
  String get custPending => 'நிலுவையில்';

  @override
  String custBorrowersCount(int count) {
    return '$count கடன் பெறுநர்கள்';
  }

  @override
  String get commonNA => 'இல்லை';

  @override
  String get commonBack => 'பின்செல்';

  @override
  String get commonHistory => 'வரலாறு';

  @override
  String custRegOn(String date) {
    return '• பதிவு: $date';
  }

  @override
  String custCycleEligible(String count) {
    return 'சுழற்சி $count தகுதி';
  }

  @override
  String get custAssignedRouteLabel => 'ஒதுக்கப்பட்ட வழி';

  @override
  String custDayRoute(String day) {
    return '$day வழி';
  }

  @override
  String get custCallBorrower => 'கடன் பெறுநரை அழை';

  @override
  String get custCloseActiveFirst =>
      'புதிய கடன் வழங்கும் முன் தற்போதைய செயலில் உள்ள கடனை மூடவும்.';

  @override
  String get issueStepBorrower => 'கடன் பெறுநர்';

  @override
  String get issueStepProfile => 'சுயவிவரம்';

  @override
  String get issueStepSelected => 'தேர்ந்தெடுக்கப்பட்டது';

  @override
  String get issueStepTerms => 'விதிமுறைகள்';

  @override
  String get issueStepCalculator => 'கணிப்பான்';

  @override
  String get issueStepConfirmed => 'உறுதிசெய்யப்பட்டது';

  @override
  String get issueStepDisburse => 'வழங்கு';

  @override
  String get issueStepConfirmation => 'உறுதிப்படுத்தல்';

  @override
  String get issueTitleBorrower => 'கடன் பெறுநர் சுயவிவரம் & வரலாறு';

  @override
  String get issueTitleTerms => 'கடன் விதிமுறைகள் & கணிப்பான்';

  @override
  String get issueTitleDisburse => 'சரிபார்த்து வழங்கு';

  @override
  String get issueSwitchBorrowers => 'கடன் பெறுநரை மாற்று';

  @override
  String issueAlreadyHasOverdue(String name, String id) {
    return '$name-க்கு ஏற்கனவே தாமதமான கடன் ($id) உள்ளது. புதியதை வழங்கும் முன் அதை மூடவும்.';
  }

  @override
  String issueAlreadyHasActive(String name, String id) {
    return '$name-க்கு ஏற்கனவே செயலில் உள்ள கடன் ($id) உள்ளது. புதியதை வழங்கும் முன் அதை மூடவும்.';
  }

  @override
  String get issueConfirmTitle => 'கடன் வழங்கி பணம் ஒப்படைக்கவா?';

  @override
  String get issuePayoutCash => 'ரொக்கம்';

  @override
  String get issuePayoutBank => 'வங்கிப் பரிமாற்றம்';

  @override
  String issueConfirmBody(
    String net,
    String payout,
    String name,
    String total,
    int weeks,
    String weekly,
  ) {
    return '$name-இடம் $net ($payout) ஒப்படைக்கவும்.\n\nதிருப்பிச் செலுத்த வேண்டியது: $weeks வாரங்களில் $total, வாரத்திற்கு $weekly.\n\nஇதைத் திரும்பப் பெற முடியாது.';
  }

  @override
  String get issueLoanAction => 'கடன் வழங்கு';

  @override
  String get issueReviewAgain => 'மீண்டும் சரிபார்';

  @override
  String issueLoanIssued(String id, String name) {
    return 'கடன் $id $name-க்கு வழங்கப்பட்டது.';
  }

  @override
  String get issueNoServerAnswer =>
      'சேவையகத்திலிருந்து பதில் இல்லை. கடன் ஏற்கனவே வழங்கப்பட்டிருக்கலாம் என்பதால், மீண்டும் முயலும் முன் கடன் பெறுநரின் கடன்களைச் சரிபார்க்கவும்.';

  @override
  String get issueNewLoan => 'புதிய கடன் வழங்கு';

  @override
  String issueStepOfTitle(int step, int total, String title) {
    return 'படி $step / $total: $title';
  }

  @override
  String get issueLoadBorrowerFailed => 'கடன் பெறுநரை ஏற்ற முடியவில்லை.';

  @override
  String get issueChooseBorrower => 'முதலில் கடன் பெறுநரைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get issueContinueTerms => 'விதிமுறைகளுக்குத் தொடர்';

  @override
  String get issueNextStep => 'அடுத்த படி';

  @override
  String get facilityPaymentOverdue => 'கட்டணம் தாமதம்';

  @override
  String get facilityAllPaid => 'அனைத்துத் தவணைகளும் செலுத்தப்பட்டன';

  @override
  String get facilityTitle => 'செயலில் உள்ள கடன்';

  @override
  String get facilityRemaining => 'மீதமுள்ள தொகை';

  @override
  String facilityOfTotal(String amount) {
    return 'மொத்தம் $amount-இல்';
  }

  @override
  String get facilityNextInstallment => 'அடுத்த தவணை';

  @override
  String facilityRepaidPercent(int percent) {
    return 'திருப்பிச் செலுத்தியது: $percent%';
  }

  @override
  String facilityPaidAmount(String amount) {
    return '$amount செலுத்தப்பட்டது';
  }

  @override
  String get facilityViewTracks => 'தவணைகளைக் காண்';

  @override
  String get facilityViewPayments => 'கட்டணங்களைக் காண்';

  @override
  String get addressNoStreet => 'தெரு விவரம் இல்லை';

  @override
  String get creditNewBorrower => 'புதிய கடன் பெறுநர்';

  @override
  String get creditAtRisk => 'ஆபத்தில்';

  @override
  String get creditGoodStanding => 'நல்ல நிலை';

  @override
  String get creditFair => 'சராசரி';

  @override
  String get creditTitle => 'கள கடன் வரலாறு';

  @override
  String get creditOnTime => 'சரியான நேரம்';

  @override
  String creditRatio(int ratio) {
    return '$ratio% விகிதம்';
  }

  @override
  String get creditDelayed => 'தாமதம்';

  @override
  String get creditRepaidLate => 'தாமதமாகச் செலுத்தியது';

  @override
  String get creditDefault => 'தவறியது';

  @override
  String get creditCleanSheet => 'சுத்தமான பதிவு';

  @override
  String get creditNeedsReview => 'பரிசீலனை தேவை';

  @override
  String get creditCompletedCycles => 'முடிந்த சுழற்சிகள்';

  @override
  String get creditNoCycles => 'இதுவரை முடிந்த சுழற்சிகள் இல்லை';

  @override
  String get creditDelayRepaid => 'தாமதமாகச் செலுத்தியது';

  @override
  String get statusClosed => 'மூடப்பட்டது';

  @override
  String creditCycleLine(int cycle, String id) {
    return 'சுழற்சி #$cycle • $id';
  }

  @override
  String creditClosedLine(String date, String amount) {
    return 'மூடியது $date • $amount';
  }

  @override
  String get issueBarOnePerBorrower => 'ஒருவருக்கு ஒரே ஒரு செயலில் உள்ள கடன்';

  @override
  String issueBarCycle(int cycle) {
    return 'சுழற்சி $cycle';
  }

  @override
  String get issueBarIssueLoan => 'கடன் வழங்கு';

  @override
  String issueBarIssueLoanTo(String name) {
    return '$name-க்கு கடன் வழங்கு';
  }

  @override
  String get issueBarHint =>
      'கடன் வரம்புகளைச் சரிபார்த்து தனிப்பயன் திருப்பிச் செலுத்தும் அட்டவணையைக் கணக்கிடு';

  @override
  String get socialTitle => 'சமூக வலையமைப்பு & உத்தரவாதங்கள்';

  @override
  String get socialReferredBy => 'உத்தரவாதம் அளித்தவர் பரிந்துரை';

  @override
  String get socialBorrowersReferred => 'பரிந்துரைத்த கடன் பெறுநர்கள்';

  @override
  String profileCycleN(int cycle) {
    return 'சுழற்சி $cycle';
  }

  @override
  String profileSince(String date) {
    return '$date முதல்';
  }

  @override
  String get profileSwitchBorrower => 'கடன் பெறுநரை மாற்று';

  @override
  String get profileNotSet => 'அமைக்கப்படவில்லை';

  @override
  String profileEveryDay(String day) {
    return 'ஒவ்வொரு $day';
  }

  @override
  String get profileCollectionRoute => 'வசூல் வழி';

  @override
  String get profileCollectionDay => 'வசூல் நாள்';

  @override
  String get profileStreet => 'தெரு';

  @override
  String get profileTownDistrict => 'ஊர் & மாவட்டம்';

  @override
  String get profileCreditHistory => 'கடன் வரலாறு';

  @override
  String get profileFirstLoan =>
      'இந்தக் கடன் பெறுநருக்கு இது முதல் கடன். இதுவரை திருப்பிச் செலுத்திய வரலாறு இல்லை.';

  @override
  String profileOnTimeAcross(int percent, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total கடன்களில்',
      one: '1 கடனில்',
    );
    return '$_temp0 $percent% சரியான நேரத்தில் செலுத்தப்பட்டது';
  }

  @override
  String get profileReferralNetwork => 'பரிந்துரை வலையமைப்பு';

  @override
  String get profileReferredBy => 'பரிந்துரைத்தவர்';

  @override
  String get profileSource => 'மூலம்';

  @override
  String get profileDirectWalkIn => 'நேரடி வருகை';

  @override
  String get profileReferred => 'பரிந்துரைத்தது';

  @override
  String get profileActive => 'செயலில்';

  @override
  String get profilePaired => 'இணைந்தது';

  @override
  String get disburseReady => 'வழங்கத் தயார்';

  @override
  String get disburseCheckTerms => 'விதிமுறைகளைச் சரிபார்';

  @override
  String get disburseSanctioned => 'அனுமதிக்கப்பட்ட அசல்';

  @override
  String disburseUpfrontFeePct(String percent) {
    return 'முன்கூட்டிய கட்டணம் ($percent)';
  }

  @override
  String get disburseNetCash => 'நிகர ரொக்க ஒப்படைப்பு';

  @override
  String get disburseImmediate => 'உடனடி நேரடி வழங்கல்';

  @override
  String get disburseTotalRepayable => 'மொத்தத் திருப்பிச் செலுத்தல்';

  @override
  String disburseWeeksShort(int weeks) {
    return '$weeks வா';
  }

  @override
  String get disburseWeeklyCadence => 'வாராந்திர இடைவெளி';

  @override
  String get disbursePayoutMode => 'வழங்கும் முறை';

  @override
  String get disburseSelectChannel => '1 வழியைத் தேர்ந்தெடு';

  @override
  String get disburseCashInHand => 'கையில் ரொக்கம்';

  @override
  String disburseCashSubtitle(String amount) {
    return 'முகவர் வசூல் பையிலிருந்து $amount ரூபாய் நோட்டுகளாக ஒப்படைப்பார்.';
  }

  @override
  String get disburseFieldStandard => 'கள நிலையானது';

  @override
  String get disburseBankTitle => 'உடனடி UPI / IMPS வங்கிப் பரிமாற்றம்';

  @override
  String get disburseBankAvailable =>
      'பதிவில் உள்ள சரிபார்க்கப்பட்ட கணக்கிற்கு வழங்கு.';

  @override
  String get disburseBankUnavailable =>
      'இந்தக் கடன் பெறுநருக்குச் சரிபார்க்கப்பட்ட வங்கிக் கணக்கு இல்லை.';

  @override
  String get disburseModeCash => 'ரொக்கம்';

  @override
  String get disburseModeBank => 'வங்கிப் பரிமாற்றம்';

  @override
  String get disburseNetPhysical => 'நிகர நேரடி ஒப்படைப்பு';

  @override
  String disburseIssueButton(String amount) {
    return 'கடன் வழங்கி $amount ஒப்படை';
  }

  @override
  String get disburseRecorded => 'வழங்கல் கள பேரேட்டில் பதிவு செய்யப்படும்';

  @override
  String termsUsingDefaults(String fee, String interest, String months) {
    return 'உங்கள் சேமித்த இயல்புகள் பயன்படுத்தப்படுகின்றன ($fee கட்டணம், $interest வட்டி, $months மாதங்கள்)';
  }

  @override
  String get termsChangedDefaults => 'சேமித்த இயல்புகளை மாற்றியுள்ளீர்கள்';

  @override
  String get commonReset => 'மீட்டமை';

  @override
  String get termsPrincipal => 'அனுமதிக்கப்பட்ட அசல் தொகை';

  @override
  String get termsRepaymentMonths => 'திருப்பிச் செலுத்தும் காலம் (மாதங்கள்)';

  @override
  String get termsWeeklyMeetings => 'வாராந்திர மையக் கூட்டங்கள்';

  @override
  String termsCalculatedWeeks(int weeks) {
    return 'கணக்கிடப்பட்டது: $weeks வாரங்கள் (மாதத்திற்கு 4 வாரம்)';
  }

  @override
  String get termsAutoComputed => 'தானாகக் கணக்கிடப்பட்டது';

  @override
  String termsMonthChip(String months, int weeks) {
    return '$months மா ($weeks வா)';
  }

  @override
  String get termsUpfrontFeeLower => 'முன்கூட்டிய கட்டணம்';

  @override
  String get termsProcessingRisk => 'செயலாக்கம் & இடர் காப்பு';

  @override
  String get termsFlatOnPrincipal => 'அசல் மீது ஒருமுறை நிலையானது';

  @override
  String termsDisbursedToday(String date) {
    return 'வழங்கியது: இன்று, $date';
  }

  @override
  String termsFirstDue(String date) {
    return 'முதல் தவணை: $date';
  }

  @override
  String get termsBreakdown => 'வழங்கல் விவரம்';

  @override
  String get termsGrossPrincipal => 'மொத்த அனுமதிக்கப்பட்ட அசல்';

  @override
  String termsProcessingRiskPct(String percent) {
    return 'செயலாக்கம் & இடர் காப்பு ($percent)';
  }

  @override
  String get termsPhysicalDisbursement => 'நேரடி வழங்கல்';

  @override
  String termsFlatInterestAdded(String percent) {
    return 'சேர்க்கப்பட்ட நிலை வட்டி ($percent)';
  }

  @override
  String get termsTotalRepayablePI =>
      'மொத்தத் திருப்பிச் செலுத்தல் (அசல் + வட்டி)';

  @override
  String termsWeeklyInstallmentWeeks(int weeks) {
    return 'வாராந்திரத் தவணை ($weeks வாரங்கள்)';
  }

  @override
  String get termsWeeklyCollection => 'வாராந்திர வசூல்';

  @override
  String termsEveryDayCollection(String day) {
    return 'ஒவ்வொரு $day வசூல்';
  }

  @override
  String get termsPerWeekShort => ' / வாரம்';

  @override
  String get termsMilestonePreview => 'அட்டவணை முன்னோட்டம்';

  @override
  String termsTotalWeeks(int weeks) {
    return 'மொத்தம் $weeks வாரங்கள்';
  }

  @override
  String get termsHideAmortization => 'தவணை அட்டவணையை மறை';

  @override
  String termsViewAmortization(int weeks) {
    return '$weeks வார விரிவான தவணை அட்டவணையைக் காண்';
  }

  @override
  String get termsPreviewOnly =>
      'முன்னோட்டம் மட்டும். கடன் வழங்கும்போது இறுதி அட்டவணை கணக்கிடப்படும்.';

  @override
  String termsWeekDate(int week, String date) {
    return 'வா #$week ($date)';
  }

  @override
  String get termsFinalSettlement => 'இறுதித் தீர்வு';

  @override
  String get termsColWeek => 'வாரம்';

  @override
  String get termsColDue => 'தேதி';

  @override
  String get termsColInstallment => 'தவணை';

  @override
  String get termsColBalance => 'மீதம்';

  @override
  String termsDayRoute(String day) {
    return ' • $day வழி';
  }

  @override
  String get commonDecrease => 'குறை';

  @override
  String get commonIncrease => 'கூட்டு';

  @override
  String get loanStageActive => 'செயலில்';

  @override
  String get loanStagePaidOff => 'முழுமையாகச் செலுத்தப்பட்டது';

  @override
  String get loanStageDefaulted => 'தவறியது';

  @override
  String get loanStageUnknown => 'தெரியவில்லை';

  @override
  String get loanReopenBlockedOther =>
      'இந்தக் கடன் பெறுநருக்கு ஏற்கனவே வேறு செயலில் உள்ள அல்லது தாமதமான கடன் உள்ளது.';

  @override
  String get loanReopenCheckFailed =>
      'கடன் பெறுநரின் மற்ற கடன்களைச் சரிபார்க்க முடியவில்லை. புதுப்பித்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get loanStatusUpdated => 'கடன் நிலை புதுப்பிக்கப்பட்டது.';

  @override
  String get loanPaymentRecorded => 'கட்டணம் பதிவு செய்யப்பட்டது.';

  @override
  String loanTitleId(String id) {
    return 'கடன் $id';
  }

  @override
  String get loanMenuTracks => 'திருப்பிச் செலுத்தும் தவணைகள்';

  @override
  String get loanMenuPayments => 'கட்டண வரலாறு';

  @override
  String get loanMenuCall => 'கடன் பெறுநரை அழை';

  @override
  String get loanMenuChangeStatus => 'நிலையை மாற்று';

  @override
  String get loanLoadFailed => 'இந்தக் கடனை ஏற்ற முடியவில்லை.';

  @override
  String get loanRepaymentSchedule => 'திருப்பிச் செலுத்தும் அட்டவணை';

  @override
  String loanViewAllWeeks(int count) {
    return 'அனைத்து $count வாரங்களையும் காண்';
  }

  @override
  String loanMoreOverdueWeeks(int count) {
    return 'மேலும் $count தாமத வாரங்கள்';
  }

  @override
  String loanCollectOverdue(String amount) {
    return 'தாமதத் தொகை வசூல் • $amount';
  }

  @override
  String get loanRecordPayment => 'கட்டணம் பதிவு செய்';

  @override
  String get loanIssueNew => 'புதிய கடன் வழங்கு';

  @override
  String get loanViewPaymentHistory => 'கட்டண வரலாற்றைக் காண்';

  @override
  String get loanPayments => 'கட்டணங்கள்';

  @override
  String get loanLoadDetailsFailed => 'கடன் விவரங்களை ஏற்ற முடியவில்லை.';

  @override
  String get loanTotalCollected => 'மொத்த வசூல்';

  @override
  String get loanOutstanding => 'நிலுவை';

  @override
  String loanTarget(String amount) {
    return 'இலக்கு: $amount';
  }

  @override
  String loanPercentCleared(int percent) {
    return '$percent% முடிந்தது';
  }

  @override
  String get loanTotalPaid => 'மொத்தம் செலுத்தியது';

  @override
  String get loanCoverage => 'காலம்';

  @override
  String loanWeeksCount(int weeks) {
    return '$weeks வாரங்கள்';
  }

  @override
  String get loanLastLog => 'கடைசிப் பதிவு';

  @override
  String get loanNoPayments => 'கட்டணங்கள் இல்லை';

  @override
  String get loanLoadingOlder => 'பழைய கட்டணங்கள் ஏற்றப்படுகின்றன...';

  @override
  String get loanNoMorePayments => 'மேலும் கட்டணங்கள் இல்லை';

  @override
  String get trackerPaymentSuccess => 'கட்டணம் வெற்றிகரமாகச் செலுத்தப்பட்டது';

  @override
  String get trackerOnlyOpenLoans =>
      'செயலில் உள்ள அல்லது தாமதமான கடன்கள் மட்டுமே கட்டணம் ஏற்கும்.';

  @override
  String get trackerAllWeeksHavePayment =>
      'ஒவ்வொரு வாரத்திலும் ஏற்கனவே கட்டணம் உள்ளது. பகுதி வாரத்தில் \'வசூல்\' பயன்படுத்தவும்.';

  @override
  String get trackerRecordWeekly => '+ வாராந்திரக் கட்டணம் பதிவு செய்';

  @override
  String trackerCycle(int cycle) {
    return 'சுழற்சி $cycle';
  }

  @override
  String get trackerActiveLoan => 'செயலில் உள்ள கடன்';

  @override
  String get trackerWeeklyTarget => 'வாராந்திர இலக்கு';

  @override
  String get trackerPrincipal => 'அசல்';

  @override
  String get trackerTotalDue => 'மொத்த நிலுவை';

  @override
  String get trackerTenure => 'காலம்';

  @override
  String get trackerCollected => 'வசூலானது';

  @override
  String trackerWeeksLeft(int weeks) {
    return '$weeks வாரங்கள் மீதம்';
  }

  @override
  String get trackerNextDue => 'அடுத்த தவணை';

  @override
  String get trackerAllPaid => 'அனைத்தும் செலுத்தப்பட்டது';

  @override
  String get trackerLoanCompleted => 'கடன் நிறைவடைந்தது';

  @override
  String trackerWeekShortDate(int week, String date) {
    return 'வா$week • $date';
  }

  @override
  String trackerDaysLate(int week, int days) {
    return 'வா$week • $days நா தாமதம்';
  }

  @override
  String get trackerDueToday => 'இன்று செலுத்த வேண்டும்';

  @override
  String get trackerDueTomorrow => 'நாளை செலுத்த வேண்டும்';

  @override
  String get trackerWeeklyTracks => 'வாராந்திரத் திருப்பிச் செலுத்தும் தவணைகள்';

  @override
  String trackerInstallmentsPlanned(int count) {
    return 'மொத்தம் $count தவணைகள் திட்டமிடப்பட்டுள்ளன';
  }

  @override
  String get trackerLedger => 'பேரேடு';

  @override
  String get loansFilterAll => 'அனைத்தும்';

  @override
  String get loansFilterActive => 'செயலில்';

  @override
  String get loansFilterOverdue => 'தாமதம்';

  @override
  String get loansFilterPaidOff => 'செலுத்தி முடிந்தது';

  @override
  String get loansFilterDefaulted => 'தவறியது';

  @override
  String get loansFilterClosed => 'மூடப்பட்டது';

  @override
  String get loansSearchHint =>
      'பெயர் மற்றும் தொலைபேசி எண் மூலம் கடனைத் தேடவும்...';

  @override
  String get loansNoneFound => 'கடன்கள் இல்லை';

  @override
  String get loansNoMore => 'மேலும் கடன்கள் இல்லை';

  @override
  String loansCallPhone(String phone) {
    return 'அழை $phone';
  }

  @override
  String get loansSettled => 'தீர்க்கப்பட்டது';

  @override
  String loansPerWeek(String amount) {
    return '$amount/வாரம்';
  }

  @override
  String get loansTotalPayable => 'மொத்தம் செலுத்த வேண்டியது';

  @override
  String get loansCollected => 'வசூலானது';

  @override
  String get loansRemaining => 'மீதம்';

  @override
  String loansDisbursed(String amount) {
    return 'வழங்கியது: $amount';
  }

  @override
  String get loansViewLedger => 'பேரேட்டைக் காண்';

  @override
  String get statusFooterClosed => 'இதைத் திரும்பப் பெற முடியாது.';

  @override
  String get statusFooterDefaulted =>
      'தேவைப்பட்டால் நிர்வாகி பின்னர் மீண்டும் திறக்கலாம்.';

  @override
  String get statusFooterReopen =>
      'பின்னர் மீண்டும் தவறியது அல்லது மூடப்பட்டது எனக் குறிக்கலாம்.';

  @override
  String statusReopenMessage(String who, String amount, String footer) {
    return '$who\n\n$amount மீண்டும் வசூலிக்கக்கூடியதாகும். ஏற்கனவே ஒரு வாரம் கடந்திருந்தால், கடன் தானாகத் தாமதமாகக் காட்டப்படும்.\n\n$footer';
  }

  @override
  String statusWriteOffLine(String amount) {
    return '$amount இன்னும் செலுத்தப்படவில்லை, அது தள்ளுபடி செய்யப்படும்.\n\n';
  }

  @override
  String get statusReopenTitle => 'இந்தக் கடனை மீண்டும் திறக்கவா?';

  @override
  String statusMarkAsTitle(String status) {
    return 'கடனை $status எனக் குறிக்கவா?';
  }

  @override
  String get statusReopenLoan => 'கடனை மீண்டும் திற';

  @override
  String statusMarkAs(String status) {
    return '$status எனக் குறி';
  }

  @override
  String get statusGoBack => 'பின்செல்';

  @override
  String get statusNoServerAnswer =>
      'சேவையகத்திலிருந்து பதில் இல்லை. நிலை ஏற்கனவே மாறியிருக்கலாம் என்பதால், மீண்டும் முயலும் முன் கடனைப் புதுப்பிக்கவும்.';

  @override
  String get statusSheetTitle => 'கடன் நிலையை மாற்று';

  @override
  String get statusAutoNote =>
      '\'தாமதம்\' மற்றும் \'செலுத்தி முடிந்தது\' கட்டணங்களிலிருந்து தானாக அமைக்கப்படுவதால், இங்கே தேர்ந்தெடுக்க முடியாது.';

  @override
  String get statusClosedCannotChange =>
      'இந்தக் கடன் மூடப்பட்டுள்ளது, மாற்ற முடியாது.';

  @override
  String get statusNoPermission =>
      'இந்தக் கடனின் நிலையை மாற்ற உங்களுக்கு அனுமதி இல்லை.';

  @override
  String get statusMoveTo => 'இதற்கு மாற்று';

  @override
  String get statusReopenWarning =>
      'இந்தக் கடனில் வசூல் மீண்டும் தொடங்கும். ஏற்கனவே ஒரு வாரம் கடந்திருந்தால், தானாகத் தாமதமாகக் காட்டப்படும்.';

  @override
  String statusDefaultWarning(String amount) {
    return '$amount இன்னும் செலுத்தப்படவில்லை. கடனைத் தவறியது எனக் குறித்தால் அது தள்ளுபடி செய்யப்படும்.';
  }

  @override
  String statusCloseWarning(String amount) {
    return '$amount இன்னும் செலுத்தப்படவில்லை. கடனை மூடினால் அது தள்ளுபடி செய்யப்படும்.';
  }

  @override
  String get statusUpdate => 'நிலையைப் புதுப்பி';

  @override
  String get statusCurrentStatus => 'தற்போதைய நிலை';

  @override
  String get statusCurrent => 'தற்போது';

  @override
  String bannerOverdueTitle(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days நாட்கள்',
      one: '1 நாள்',
    );
    return 'தாமதம் • $_temp0';
  }

  @override
  String bannerOverdueBody(String amount, int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks வாரங்களில்',
      one: '1 வாரத்தில்',
    );
    return '$_temp0 $amount நிலுவை கடந்துவிட்டது.';
  }

  @override
  String bannerTermEnded(int weeks) {
    return ' $weeks வாரக் காலம் முடிந்துவிட்டது.';
  }

  @override
  String get bannerFullyRepaid => 'முழுமையாகத் திருப்பிச் செலுத்தப்பட்டது';

  @override
  String bannerPaidOffBody(int weeks, String amount) {
    return 'அனைத்து $weeks வாராந்திரத் தவணைகளும் வசூலிக்கப்பட்டன. மொத்தம் $amount பெறப்பட்டது.';
  }

  @override
  String get bannerLoanClosed => 'கடன் மூடப்பட்டது';

  @override
  String bannerClosedOn(String date) {
    return '$date அன்று மூடப்பட்டது.';
  }

  @override
  String bannerLeftUnpaid(String amount) {
    return '$amount செலுத்தப்படாமல் விடப்பட்டது.';
  }

  @override
  String get bannerThisLoanClosed => 'இந்தக் கடன் மூடப்பட்டது.';

  @override
  String get bannerMarkedDefaulted => 'தவறியதாகக் குறிக்கப்பட்டது';

  @override
  String bannerStillOutstanding(String amount) {
    return '$amount இன்னும் நிலுவையில் உள்ளது.';
  }

  @override
  String sectionDayRoute(String day) {
    return '$day வழி';
  }

  @override
  String balanceWeeksPastDue(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: '$weeks வாரங்கள்',
      one: '1 வாரம்',
    );
    return '$_temp0 கடந்தது';
  }

  @override
  String get balanceNextInstallment => 'அடுத்த தவணை';

  @override
  String get balanceNothingScheduled => 'எதுவும் திட்டமிடப்படவில்லை';

  @override
  String get balanceSettled => 'தீர்க்கப்பட்டது';

  @override
  String get balanceNoBalance => 'மீதத் தொகை இல்லை';

  @override
  String get balanceUnpaidAtClose => 'மூடும்போது செலுத்தப்படாதது';

  @override
  String get balanceRepaymentProgress =>
      'கடன் திருப்பிச் செலுத்தும் முன்னேற்றம்';

  @override
  String balanceRepaidPercent(String percent) {
    return '$percent% செலுத்தப்பட்டது';
  }

  @override
  String balanceWeeksPaid(int paid, int total) {
    return '$total வாரங்களில் $paid செலுத்தப்பட்டது';
  }

  @override
  String get recentNoPayments => 'இதுவரை கட்டணங்கள் பதிவு செய்யப்படவில்லை.';

  @override
  String get recentPayments => 'சமீபத்திய கட்டணங்கள்';

  @override
  String get commonViewAll => 'அனைத்தையும் காண்';

  @override
  String get contractPrincipal => 'அனுமதிக்கப்பட்ட அசல்';

  @override
  String contractUpfrontFee(String percent) {
    return 'முன்கூட்டிய கட்டணம் ($percent%)';
  }

  @override
  String get contractNetDisbursed => 'நிகர வழங்கல்';

  @override
  String get contractFlatInterest => 'நிலை வட்டி';

  @override
  String get contractTotalRepayable => 'மொத்தத் திருப்பிச் செலுத்தல்';

  @override
  String get contractWeeklyInstallment => 'வாராந்திரத் தவணை';

  @override
  String get contractTerm => 'காலம்';

  @override
  String contractTermValue(int weeks, String months) {
    return '$weeks வாரங்கள் ($months மாதங்கள்)';
  }

  @override
  String get contractDisbursedOn => 'வழங்கிய தேதி';

  @override
  String get contractMaturesOn => 'முதிர்வு தேதி';

  @override
  String get contractClosedOn => 'மூடிய தேதி';

  @override
  String get contractDetails => 'ஒப்பந்த விவரங்கள்';

  @override
  String get borrowersTotal => 'மொத்தம்';

  @override
  String get borrowersActive => 'செயலில்';

  @override
  String get borrowersDues => 'நிலுவைகள்';

  @override
  String get borrowersReferrals => 'பரிந்துரைகள்';

  @override
  String get borrowersNet => 'நிகரம்';

  @override
  String get borrowersActiveLoan => 'செயலில் உள்ள கடன்';

  @override
  String get borrowersOverdueLoan => 'தாமதக் கடன்';

  @override
  String get borrowersNoActiveLoans => 'செயலில் கடன்கள் இல்லை';

  @override
  String get borrowersCollectPayment => 'கட்டணம் வசூல்';

  @override
  String get tracksNoneFound => 'தவணைகள் இல்லை';

  @override
  String get tracksTitle => 'திருப்பிச் செலுத்தும் தவணைகள்';

  @override
  String tracksWeeksShort(int weeks) {
    return '$weeks வா';
  }

  @override
  String tracksSubtitle(String name, String id) {
    return '$name • செயலில் உள்ள கடன் $id';
  }

  @override
  String get tracksCompleted => 'முடிந்தது';

  @override
  String tracksPaidCount(int count) {
    return '$count செலுத்தியது';
  }

  @override
  String tracksTrackCount(int count) {
    return '$count தவணை';
  }

  @override
  String get tracksFacilityBal => 'கடன் மீதம்';

  @override
  String get rangeToday => 'இன்று';

  @override
  String get rangeLast7 => 'கடந்த 7 நாட்கள்';

  @override
  String get rangeLast30 => 'கடந்த 30 நாட்கள்';

  @override
  String get rangeLast90 => 'கடந்த 90 நாட்கள்';

  @override
  String get rangeThisMonth => 'இந்த மாதம்';

  @override
  String get rangeLastMonth => 'கடந்த மாதம்';

  @override
  String get rangeCustom => 'தனிப்பயன்';

  @override
  String get agoJustNow => 'இப்போது';

  @override
  String agoMinutes(int m) {
    return '$m நிமிடம் முன்';
  }

  @override
  String agoHours(int h) {
    return '$h மணி முன்';
  }

  @override
  String agoDays(int d) {
    return '$d நாள் முன்';
  }

  @override
  String get offlineNoData => 'நீங்கள் இணைப்பில் இல்லை.';

  @override
  String offlineShowingFrom(String ago) {
    return 'நீங்கள் இணைப்பில் இல்லை. $ago உள்ள எண்கள் காட்டப்படுகின்றன.';
  }

  @override
  String updatedPullRefresh(String ago) {
    return '$ago புதுப்பிக்கப்பட்டது. புதுப்பிக்க கீழே இழுக்கவும்.';
  }

  @override
  String get pullToRefresh => 'புதுப்பிக்க கீழே இழுக்கவும்.';

  @override
  String get anTabPulse => 'நிலவரம்';

  @override
  String get anTabCollections => 'வசூல்கள்';

  @override
  String get anTabPortfolio => 'கடன் தொகுப்பு';

  @override
  String get anTabCustomers => 'வாடிக்கையாளர்கள்';

  @override
  String get anTabTeam => 'குழு';

  @override
  String get anTabForecast => 'முன்கணிப்பு';

  @override
  String get anTabAdmins => 'நிர்வாகிகள்';

  @override
  String get anTabMoney => 'பணம்';

  @override
  String get anTabRisk => 'இடர்';

  @override
  String get anTabGeography => 'புவியியல்';

  @override
  String get anTabPeople => 'நபர்கள்';

  @override
  String get anNoAccess => 'இந்தப் பக்கத்தை அணுக உங்களுக்கு அனுமதி இல்லை.';

  @override
  String get anSegAnalytics => 'பகுப்பாய்வு';

  @override
  String get anSegPlatform => 'தளம்';

  @override
  String get dueListTitle => 'நிலுவைப் பட்டியல்';

  @override
  String dueNoneScheduled(String day) {
    return '$day அன்று கடன்கள் எதுவும் திட்டமிடப்படவில்லை.';
  }

  @override
  String dueNoMatch(String query) {
    return '\"$query\" உடன் பொருந்தும் கடன்கள் இல்லை.';
  }

  @override
  String get dueCollectedVsTarget => 'அன்றைய இலக்குக்கு எதிரான வசூல்';

  @override
  String dueCollectedOfTarget(String collected, String target) {
    return '$target இலக்கில் $collected வசூலானது';
  }

  @override
  String dueScheduledFor(String day) {
    return '$day அன்று திட்டமிடப்பட்ட கடன்கள்';
  }

  @override
  String dueSummaryLine(int customers, int active, int overdue) {
    return '$customers வாடிக்கையாளர்கள் • $active செயலில் • $overdue தாமதம்';
  }

  @override
  String dueListNote(String day) {
    return 'இந்தப் பட்டியல் $day அன்று திட்டமிடப்பட்ட கடன்களின் தற்போதைய நிலையைக் காட்டுகிறது, இந்தத் தேதியில் யார் செலுத்தினார்கள் என்பதை அல்ல.';
  }

  @override
  String get commonUnknown => 'தெரியவில்லை';

  @override
  String dueOutstanding(String amount) {
    return 'நிலுவை $amount';
  }

  @override
  String get dueLabel => 'நிலுவை';

  @override
  String get dueOnSchedule => 'சரியான நேரத்தில்';

  @override
  String anViewing(String name) {
    return 'காண்பது: $name';
  }

  @override
  String get commonClear => 'அழி';

  @override
  String get anAllAdmins => 'அனைத்து நிர்வாகிகள்';

  @override
  String get anAllEmployees => 'அனைத்து ஊழியர்கள்';

  @override
  String anMaxRange(int days) {
    return 'அதிகபட்சம் $days நாட்கள் வரம்பைத் தேர்ந்தெடுக்கவும்.';
  }

  @override
  String get anDateRange => 'தேதி வரம்பு';

  @override
  String get commonApply => 'பயன்படுத்து';

  @override
  String get anChooseAdmin => 'நிர்வாகியைத் தேர்ந்தெடு';

  @override
  String get anChooseEmployee => 'ஊழியரைத் தேர்ந்தெடு';

  @override
  String get commonSearch => 'தேடு';

  @override
  String get anNobodyMatches => 'யாரும் பொருந்தவில்லை.';

  @override
  String get anTakingLonger => 'வழக்கத்தை விட அதிக நேரம் ஆகிறது.';

  @override
  String get anCardLoadFailed => 'இந்த அட்டையை ஏற்ற முடியவில்லை.';

  @override
  String anDeltaPts(String value) {
    return '$value புள்ளிகள்';
  }

  @override
  String get anNoChange => 'மாற்றம் இல்லை';

  @override
  String anDeltaNew(String value) {
    return '$value (புதியது)';
  }

  @override
  String get commonLoading => 'ஏற்றப்படுகிறது...';

  @override
  String anShowMore(int left) {
    return 'மேலும் காண் ($left மீதம்)';
  }

  @override
  String get dayMonAbbr => 'திங்';

  @override
  String get dayTueAbbr => 'செவ்';

  @override
  String get dayWedAbbr => 'புத';

  @override
  String get dayThuAbbr => 'வியா';

  @override
  String get dayFriAbbr => 'வெள்';

  @override
  String get daySatAbbr => 'சனி';

  @override
  String get daySunAbbr => 'ஞாயி';

  @override
  String get anInsights => 'நுண்ணறிவுகள்';

  @override
  String get anInsightsEmpty =>
      'உங்கள் வாடிக்கையாளர்களுக்குக் கடன்கள் வந்ததும் நுண்ணறிவுகள் தோன்றும்.';

  @override
  String get anShowLess => 'குறைவாகக் காண்';

  @override
  String anSeeAll(int count) {
    return 'அனைத்து $count-ஐயும் காண்';
  }

  @override
  String get anCollectionsVsTarget => 'வசூல் vs இலக்கு';

  @override
  String get anGroupDayShort => 'நா';

  @override
  String get anGroupWeekShort => 'வா';

  @override
  String get anGroupMonthShort => 'மா';

  @override
  String get anNoCollectionsPeriod =>
      'இந்தக் காலத்தில் வசூல் இல்லை. நீண்ட வரம்பை முயற்சிக்கவும்.';

  @override
  String anTrendSemantics(String amount) {
    return 'வசூல் போக்கு, மொத்தம் $amount';
  }

  @override
  String anBestDay(String label, String amount) {
    return 'சிறந்த நாள்: $label $amount';
  }

  @override
  String anBestWeek(String label, String amount) {
    return 'சிறந்த வாரம்: $label $amount';
  }

  @override
  String anBestMonth(String label, String amount) {
    return 'சிறந்த மாதம்: $label $amount';
  }

  @override
  String anOfTarget(String amount) {
    return ' / $amount';
  }

  @override
  String get anOutstandingByAge => 'காலவாரியான நிலுவை';

  @override
  String get anNothingOutstanding => 'தற்போது நிலுவை எதுவும் இல்லை.';

  @override
  String anAgingSemantics(String amount) {
    return 'கால வரிசை, மொத்த நிலுவை $amount';
  }

  @override
  String anLoansAmount(int count, String amount) {
    return '$count கடன்கள் • $amount';
  }

  @override
  String get anPortfolioHealth => 'கடன் தொகுப்பு நிலை';

  @override
  String get anNoLoansYet => 'இதுவரை கடன்கள் இல்லை.';

  @override
  String anStatusSemantics(int total) {
    return 'கடன் நிலை, $total கடன்கள்';
  }

  @override
  String get anLoansWord => 'கடன்கள்';

  @override
  String get anCollectionCalendar => 'வசூல் நாட்காட்டி';

  @override
  String get anPrevMonth => 'முந்தைய மாதம்';

  @override
  String get anNextMonth => 'அடுத்த மாதம்';

  @override
  String anCollectedOf(String collected, String target) {
    return '$target-இல் $collected';
  }

  @override
  String anTargetAmount(String amount) {
    return 'இலக்கு $amount';
  }

  @override
  String anPaidAmount(String amount) {
    return 'செலுத்தியது $amount';
  }

  @override
  String get anOpenDueList => 'நிலுவைப் பட்டியலைத் திற';

  @override
  String get anTapDay =>
      'ஒரு நாளின் இலக்கு மற்றும் வசூலைக் காண அதைத் தட்டவும்.';

  @override
  String get anDayUpcoming => 'வரவிருக்கிறது';

  @override
  String get anDayNothingDue => 'நிலுவை இல்லை';

  @override
  String get anByWeekday => 'வார நாள் வாரியாக';

  @override
  String get anWeekdaySemantics => 'ஒவ்வொரு வார நாளுக்கும் இலக்கு vs வசூல்';

  @override
  String get anTarget => 'இலக்கு';

  @override
  String get anCollected => 'வசூலானது';

  @override
  String get anCustomersUnderDay => 'ஒவ்வொரு நாளின் கீழ் வாடிக்கையாளர்கள்';

  @override
  String get anRepaymentByMonth => 'வழங்கிய மாதவாரியான திருப்பிச் செலுத்தல்';

  @override
  String get anRepaid => 'செலுத்தியது';

  @override
  String get anOnTrack => 'சரியான பாதையில்';

  @override
  String get anCohortsEmpty =>
      'கடன்கள் வழங்கி சில வாரங்கள் ஆனதும் குழுக்கள் தோன்றும்.';

  @override
  String get anCohortSemantics =>
      'ஒவ்வொரு வழங்கிய மாதத்திற்கும் திருப்பிச் செலுத்தும் வளைவுகள்';

  @override
  String get anWeeksSinceIssue => 'வழங்கியதிலிருந்து வாரங்கள்';

  @override
  String anWeekPercent(int week, String percent) {
    return 'வாரம் $week: $percent%';
  }

  @override
  String anCohortSummary(String month, int loans, String amount) {
    return '$month: $loans கடன்கள் • $amount';
  }

  @override
  String anPercentDefaulted(String percent) {
    return ' • $percent% தவறியது';
  }

  @override
  String get anCohortTooEarly =>
      'இந்தக் குழுவை மதிப்பிட இன்னும் நேரம் ஆகவில்லை.';

  @override
  String anCohortRepaid(String month, String percent, int weeks) {
    return '$month-இல் வழங்கிய கடன்கள் $weeks வாரங்களுக்குப் பிறகு செலுத்த வேண்டியதில் $percent% செலுத்தியுள்ளன';
  }

  @override
  String anCohortOnTrack(String percent) {
    return '; அட்டவணைப்படி $percent%, எனவே சரியான பாதையில் உள்ளன.';
  }

  @override
  String anCohortBehind(String percent) {
    return '; அட்டவணைப்படி $percent%, எனவே பின்தங்கியுள்ளன.';
  }

  @override
  String get anNoDataPeriod =>
      'இந்தக் காலத்தில் தரவு இல்லை. நீண்ட வரம்பை முயற்சிக்கவும்.';

  @override
  String anAdminN(int n) {
    return 'நிர்வாகி $n';
  }

  @override
  String get anOthers => 'மற்றவை';

  @override
  String anComparedPrevious(int days) {
    return 'முந்தைய $days நாட்களுடன் ஒப்பிடுகையில்';
  }

  @override
  String get anLoansRightNow => 'தற்போதைய கடன்கள்';

  @override
  String anPar(String percent) {
    return 'PAR $percent%';
  }

  @override
  String get anToday => 'இன்று';

  @override
  String get anThisWeek => 'இந்த வாரம்';

  @override
  String get anThisMonth => 'இந்த மாதம்';

  @override
  String get anPaymentBehaviour => 'கட்டண நடத்தை';

  @override
  String get anNoPaymentsPeriod =>
      'இந்தக் காலத்தில் கட்டணங்கள் இல்லை. நீண்ட வரம்பை முயற்சிக்கவும்.';

  @override
  String get anOnTimeUpper => 'சரியான நேரம்';

  @override
  String get anLate => 'தாமதம்';

  @override
  String get anAvgDaysLate => 'சராசரி தாமத நாட்கள்';

  @override
  String get anWorst => 'மோசமானது';

  @override
  String anDaysShort(int days) {
    return '$daysநா';
  }

  @override
  String anWeeklyInstalmentsDue(int count) {
    return 'வாராந்திரத் தவணைகள் ($count நிலுவை)';
  }

  @override
  String anPaidPct(String percent) {
    return 'செலுத்தியது $percent%';
  }

  @override
  String anPartialPct(String percent) {
    return 'பகுதி $percent%';
  }

  @override
  String anUnpaidPct(String percent) {
    return 'செலுத்தாதது $percent%';
  }

  @override
  String anOverpaidPct(String percent) {
    return 'அதிகமாகச் செலுத்தியது $percent%';
  }

  @override
  String get anDisbursements => 'வழங்கல்கள்';

  @override
  String anLoansCount(int count) {
    return '$count கடன்கள்';
  }

  @override
  String get anDisbursed => 'வழங்கியது';

  @override
  String get anEarnings => 'வருவாய்';

  @override
  String get anTotal => 'மொத்தம்';

  @override
  String get anFeesUpper => 'கட்டணங்கள்';

  @override
  String get anInterestUpper => 'வட்டி';

  @override
  String get anExpected => 'எதிர்பார்ப்பு';

  @override
  String get anFees => 'கட்டணங்கள்';

  @override
  String get anInterest => 'வட்டி';

  @override
  String get anInterestEarned => 'ஈட்டிய வட்டி';

  @override
  String get anPlatformEarnings => 'தள வருவாய்';

  @override
  String anMaturingIn(int days) {
    return '$days நாட்களில் முதிர்வு';
  }

  @override
  String anNoneMaturing(int days) {
    return 'அடுத்த $days நாட்களில் எந்தக் கடனும் முதிர்வடையவில்லை.';
  }

  @override
  String anWeeklyAmount(String amount) {
    return 'வாராந்திரம் $amount';
  }

  @override
  String anDaysLeft(int days) {
    return '$daysநா மீதம்';
  }

  @override
  String get anCustomersAtRisk => 'ஆபத்தில் உள்ள வாடிக்கையாளர்கள்';

  @override
  String get anNoneAtRisk => 'தற்போது ஆபத்தில் உள்ள வாடிக்கையாளர்கள் இல்லை.';

  @override
  String anRiskLine(int days, int weeks) {
    return '$days நாட்கள் தாமதம் • $weeks வாரங்கள் தவறியது';
  }

  @override
  String get anReferrerAtRisk => ' • பரிந்துரையாளர் ஆபத்தில்';

  @override
  String anRiskScore(String score) {
    return 'இடர் $score';
  }

  @override
  String get anRepeatBorrowers => 'மீண்டும் கடன் பெறுபவர்கள்';

  @override
  String get anRepeatRate => 'மீண்டும் பெறும் விகிதம்';

  @override
  String get anRetention => 'தக்கவைப்பு';

  @override
  String get anAvgLoans => 'சராசரி கடன்கள்';

  @override
  String anLoanCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கடன்கள்',
      one: '1 கடன்',
    );
    return '$_temp0';
  }

  @override
  String get anCustomers => 'வாடிக்கையாளர்கள்';

  @override
  String get anTopReferrers => 'சிறந்த பரிந்துரையாளர்கள்';

  @override
  String get anNoReferrals => 'இதுவரை பரிந்துரைகள் இல்லை.';

  @override
  String anConverted(String percent) {
    return '$percent% மாற்றப்பட்டது';
  }

  @override
  String anReferredConverted(int referred, int converted) {
    return 'பரிந்துரைத்தது $referred • மாற்றப்பட்டது $converted';
  }

  @override
  String anAtRiskCount(int count) {
    return ' • $count ஆபத்தில்';
  }

  @override
  String get anGeography => 'புவியியல்';

  @override
  String get anOutstandingByArea => 'பகுதிவாரியான நிலுவை';

  @override
  String get anDistrict => 'மாவட்டம்';

  @override
  String get anCity => 'நகரம்';

  @override
  String get anNoBorrowersScope =>
      'இந்த வரம்பில் இதுவரை கடன் பெறுநர்கள் இல்லை.';

  @override
  String anBorrowersPar(int count, String percent) {
    return '$count கடன் பெறுநர்கள் • PAR $percent%';
  }

  @override
  String get anEmployeeLeaderboard => 'ஊழியர் தரவரிசை';

  @override
  String get anTeamLeaderboard => 'குழு தரவரிசை';

  @override
  String get anNoEmployees => 'காட்ட ஊழியர்கள் இதுவரை இல்லை.';

  @override
  String anParOverdue(String percent, int overdue) {
    return 'PAR $percent% • $overdue தாமதம்';
  }

  @override
  String get anEmployee => 'ஊழியர்';

  @override
  String get anPAR => 'PAR';

  @override
  String get anNoRisky => 'ஆபத்தான வாடிக்கையாளர்கள் இல்லை.';

  @override
  String get anCashflowForecast => 'பணப்புழக்க முன்கணிப்பு';

  @override
  String anExpectedNextWeeks(int weeks) {
    return 'அடுத்த $weeks வாரங்களில் எதிர்பார்ப்பு';
  }

  @override
  String anPlusArrears(String amount) {
    return 'மேலும் $amount தாமதம் மற்றும் தற்போது நிலுவை';
  }

  @override
  String get anDue => 'நிலுவை';

  @override
  String get anCurrentWeekHighlighted =>
      ' நடப்பு வாரம் முன்னிலைப்படுத்தப்பட்டுள்ளது.';

  @override
  String get anPlatformAtGlance => 'தளம் ஒரு பார்வையில்';

  @override
  String get anCollectedMonth => 'வசூல் (மாதம்)';

  @override
  String get anAdminsUpper => 'நிர்வாகிகள்';

  @override
  String get anEmployeesUpper => 'ஊழியர்கள்';

  @override
  String get anEarned => 'ஈட்டியது';

  @override
  String get anNoAdmins => 'இதுவரை நிர்வாகிகள் இல்லை.';

  @override
  String anAdminRowLine(int employees, String percent, int overdue) {
    return '$employees ஊழியர்கள் • PAR $percent% • $overdue தாமதம்';
  }

  @override
  String get anDisbursedByAdmin => 'நிர்வாகிவாரியான வழங்கல்';

  @override
  String get anDisbursedByAdminMonthly =>
      'நிர்வாகிவாரியான வழங்கல் (மாதாந்திரம்)';

  @override
  String get anSplitByAdmin => 'நிர்வாகிவாரியாகப் பிரி';

  @override
  String get anPlatformCollections => 'தள வசூல்கள்';

  @override
  String get anAccounts => 'கணக்குகள்';

  @override
  String anActiveInactive(String active, String inactive) {
    return '$active செயலில் • $inactive செயலற்றது';
  }

  @override
  String anPendingCount(String count) {
    return '$count நிலுவையில்';
  }

  @override
  String get anEmployeesPerAdmin => 'நிர்வாகிக்கு ஊழியர்கள்';

  @override
  String get anPlatformOutstandingByAge => 'தளத்தின் காலவாரியான நிலுவை';

  @override
  String get anRiskConcentration => 'இடர் செறிவு';

  @override
  String get anOutstandingByAdmin => 'நிர்வாகிவாரியான நிலுவை';

  @override
  String anShareOfBook(String percent) {
    return 'மொத்தத்தில் $percent%';
  }

  @override
  String get anLargestExposures => 'மிகப்பெரிய வெளிப்பாடுகள்';

  @override
  String get anNoExposures => 'காட்ட வெளிப்பாடுகள் இல்லை.';

  @override
  String anExposureLine(String days, String percent) {
    return '$days நாட்கள் தாமதம் • மொத்தத்தில் $percent%';
  }

  @override
  String get repAdvancedSemantics =>
      'மேம்பட்ட பகுப்பாய்வு. போக்குகள், குழுக்கள் மற்றும் குழு செயல்திறன்.';

  @override
  String get repAdvancedSub => 'போக்குகள், குழுக்கள் மற்றும் குழு செயல்திறன்';

  @override
  String get repAsOfToday => 'இன்றைய நிலவரம்';

  @override
  String get repCashOutstanding => 'நிலுவைப் பணம்';

  @override
  String get repNoLoansInBook => 'இதுவரை கடன்கள் இல்லை.';

  @override
  String repOutstandingSemantics(String amount, int percent) {
    return 'பெற வேண்டிய நிலுவை $amount, செலுத்த வேண்டிய தொகையில் $percent சதவீதம் வசூலானது';
  }

  @override
  String get repOutstandingReceivable => 'பெற வேண்டிய நிலுவை';

  @override
  String repPayableCollected(int percent) {
    return 'செலுத்த வேண்டியதில் $percent% வசூலானது';
  }

  @override
  String get repDisbursed => 'வழங்கியது';

  @override
  String get repPayable => 'செலுத்த வேண்டியது';

  @override
  String get repCollected => 'வசூலானது';

  @override
  String repLoansInBook(int count) {
    return 'மொத்தம் $count கடன்கள்';
  }

  @override
  String get repEarningsEmpty => 'கடன்கள் வழங்கப்பட்டதும் வருவாய் தோன்றும்.';

  @override
  String repTotalEarnedSemantics(String amount) {
    return 'மொத்த வருவாய் $amount';
  }

  @override
  String get repTotalEarned => 'மொத்த வருவாய்';

  @override
  String get repExpectedInterest => 'எதிர்பார்க்கும் வட்டி';

  @override
  String get repInterestNote =>
      'அசலுக்கு மேல் வசூலானது மட்டுமே வட்டியாகக் கணக்கிடப்படும், எனவே கடன்கள் திருப்பிச் செலுத்தப்படும் வரை அது எதிர்பார்ப்பை விடக் குறைவாக இருக்கும்.';

  @override
  String repOverdueSemantics(String name, String amount, int days) {
    return '$name, $amount நிலுவை, $days நாட்கள் தாமதம்';
  }

  @override
  String repAmountOutstanding(String amount) {
    return '$amount நிலுவை';
  }

  @override
  String get repOverdueLoans => 'தாமதக் கடன்கள்';

  @override
  String get repNoOverdue =>
      'தாமதக் கடன்கள் இல்லை. அனைத்தும் அட்டவணைப்படி உள்ளன.';

  @override
  String get repSeeAll => 'அனைத்தையும் காண்';

  @override
  String get repNoOverdueShort => 'தாமதக் கடன்கள் இல்லை.';

  @override
  String get auditNoAccess => 'தணிக்கைப் பதிவை அணுக உங்களுக்கு அனுமதி இல்லை.';

  @override
  String get auditEntry => 'தணிக்கைப் பதிவு விவரம்';

  @override
  String get auditRecordGone => 'இந்தப் பதிவு இனி கிடைக்காது.';

  @override
  String get auditLoadEntryFailed => 'இந்தப் பதிவை ஏற்ற முடியவில்லை.';

  @override
  String get auditLogIdCopied => 'பதிவு ஐடி நகலெடுக்கப்பட்டது';

  @override
  String get auditAttention => 'கவனம்';

  @override
  String get auditWho => 'யார்';

  @override
  String get auditOn => 'எதில்';

  @override
  String get auditOpen => 'திற';

  @override
  String get auditMoreFromActor => 'இவரின் மேலும் செயல்கள்';

  @override
  String get auditMoreOnRecord => 'இந்தப் பதிவில் மேலும்';

  @override
  String get auditChanges => 'மாற்றங்கள்';

  @override
  String get auditRawJson => 'மூல JSON';

  @override
  String get commonCopy => 'நகலெடு';

  @override
  String get auditJsonCopied => 'JSON நகலெடுக்கப்பட்டது';

  @override
  String get auditCreatedWith => 'உருவாக்கியது';

  @override
  String auditChangesCount(int count) {
    return 'மாற்றங்கள் ($count)';
  }

  @override
  String get auditDetails => 'விவரங்கள்';

  @override
  String get auditNoFieldChanges =>
      'இந்தப் பதிவில் புல மாற்றங்கள் எதுவும் பதிவாகவில்லை.';

  @override
  String get auditRequestDetails => 'கோரிக்கை விவரங்கள்';

  @override
  String get auditIp => 'IP';

  @override
  String get auditDevice => 'சாதனம்';

  @override
  String get auditRequest => 'கோரிக்கை';

  @override
  String get auditLogId => 'பதிவு ஐடி';

  @override
  String get auditTeam => 'குழு';

  @override
  String auditFiltersApplied(int count) {
    return '$count வடிகட்டிகள் பயன்படுத்தப்பட்டன';
  }

  @override
  String get auditFilters => 'வடிகட்டிகள்';

  @override
  String get auditAllTeams => 'அனைத்துக் குழுக்கள்';

  @override
  String auditAbout(String name) {
    return 'தொடர்பானவர்: $name';
  }

  @override
  String get auditThisUser => 'இந்தப் பயனர்';

  @override
  String auditBy(String name) {
    return 'செய்தவர்: $name';
  }

  @override
  String get auditThisPerson => 'இந்த நபர்';

  @override
  String get auditClearAll => 'அனைத்தையும் அழி';

  @override
  String get auditNothingMatches => 'இந்த வடிகட்டிகளுடன் எதுவும் பொருந்தவில்லை';

  @override
  String get auditNoActivity => 'இதுவரை செயல்பாடு இல்லை';

  @override
  String get auditTryWider =>
      'பரந்த தேதி வரம்பு அல்லது குறைவான வடிகட்டிகளை முயற்சிக்கவும்.';

  @override
  String get auditChangesAppear =>
      'செயலியில் செய்யப்படும் மாற்றங்கள் இங்கே தோன்றும்.';

  @override
  String get auditClearFilters => 'வடிகட்டிகளை அழி';

  @override
  String auditEntriesCount(int shown, int total) {
    return '$total பதிவுகளில் $shown';
  }

  @override
  String get auditWhoDidIt => 'யார் செய்தார்';

  @override
  String get auditWhoAffected => 'யாரைப் பாதித்தது';

  @override
  String get auditAnyone => 'யாரும்';

  @override
  String get auditModule => 'பிரிவு';

  @override
  String get auditActions => 'செயல்கள்';

  @override
  String get auditNoActionsScope =>
      'உங்கள் வரம்பில் இதுவரை செயல்கள் எதுவும் பதிவாகவில்லை.';

  @override
  String get auditSelected => 'தேர்ந்தெடுக்கப்பட்டது';

  @override
  String get auditApplyFilters => 'வடிகட்டிகளைப் பயன்படுத்து';

  @override
  String auditMe(String name) {
    return '$name (நான்)';
  }

  @override
  String get auditAll => 'அனைத்தும்';

  @override
  String auditModuleSemantics(String label) {
    return '$label பிரிவு';
  }

  @override
  String get auditNeedsAttention => 'கவனம் தேவை. ';

  @override
  String get auditBefore => 'முன்';

  @override
  String get auditAfter => 'பின்';

  @override
  String get auditView => 'காண்';

  @override
  String get auditBeforeUpper => 'முன்';

  @override
  String get auditAfterUpper => 'பின்';

  @override
  String get expCouldNotOpen => 'கோப்பைத் திறக்க முடியவில்லை.';

  @override
  String get expAlreadyInProgress => 'அந்த ஏற்றுமதி ஏற்கனவே நடைபெறுகிறது.';

  @override
  String get expStarted => 'ஏற்றுமதி தொடங்கியது.';

  @override
  String get expNoDownloads =>
      'இதுவரை பதிவிறக்கங்கள் இல்லை. நீங்கள் ஏற்றுமதி செய்யும் அறிக்கைகள் 24 மணிநேரம் இங்கே தோன்றும்.';

  @override
  String get expExpired => 'காலாவதியானது';

  @override
  String get expQueued => 'வரிசையில்';

  @override
  String get expBuilding => 'உருவாகிறது';

  @override
  String get expReady => 'தயார்';

  @override
  String get expFailed => 'தோல்வி';

  @override
  String get expPreparing => 'தயாராகிறது...';

  @override
  String expRowsProgress(int done, int total) {
    return '$total வரிசைகளில் $done';
  }

  @override
  String get expOpen => 'திற';

  @override
  String get expShare => 'பகிர்';

  @override
  String expUntil(String time) {
    return '$time வரை';
  }

  @override
  String get expCreateAgain => 'மீண்டும் உருவாக்கு';

  @override
  String get expExport => 'ஏற்றுமதி';

  @override
  String expDownloadsBuilding(int count) {
    return 'பதிவிறக்கங்கள் ($count உருவாகிறது)';
  }

  @override
  String get expThisWeek => 'இந்த வாரம்';

  @override
  String get expNext7 => 'அடுத்த 7 நாட்கள்';

  @override
  String expPickAtMost(int days) {
    return 'அதிகபட்சம் $days நாட்களைத் தேர்ந்தெடுக்கவும்.';
  }

  @override
  String get expCustomersAddedBy => 'வாடிக்கையாளர்களைச் சேர்த்தவர்';

  @override
  String get expChooseWeekday => 'ஒரு வார நாளைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get expChooseRange => 'தேதி வரம்பைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get expStartBeforeEnd =>
      'தொடக்கத் தேதி முடிவுத் தேதிக்கு முன் அல்லது அதே நாளாக இருக்க வேண்டும்.';

  @override
  String get expNoServerAnswer =>
      'சேவையகத்திலிருந்து பதில் இல்லை. உருவாக்கப்பட்டதா எனப் பதிவிறக்கங்களில் பார்த்து, பின் மீண்டும் முயற்சிக்கவும்.';

  @override
  String get expScopeSuper =>
      'ஒரு குழுவைத் தேர்ந்தெடுக்காவிட்டால் அனைத்துக் குழுக்களும் அடங்கும்.';

  @override
  String get expScopeAdmin => 'உங்கள் குழு மட்டும் அடங்கும்.';

  @override
  String get expScopeUser =>
      'நீங்கள் உருவாக்கிய வாடிக்கையாளர்கள் மட்டும் அடங்குவர்.';

  @override
  String get expHintXlsx => 'Excel-க்குச் சிறந்தது. 1,00,000 வரிசைகள் வரை.';

  @override
  String get expHintCsv => 'எங்கும் திறக்கும் எளிய உரை. 3,00,000 வரிசைகள் வரை.';

  @override
  String get expHintPdfWeekday =>
      'வழிக்காக அச்சிடத் தயாராக, ஒவ்வொரு வாடிக்கையாளருக்கும் ஒரு பகுதி. 1,000 கடன்கள் வரை.';

  @override
  String get expHintPdfAudit =>
      'அச்சிடுவதற்கு. 1,000 வரிசைகள் வரை, நீண்ட மதிப்புகள் சுருக்கப்படும். முழு மதிப்புகளுக்கு Excel அல்லது CSV பயன்படுத்தவும்.';

  @override
  String get expHintPdf => 'அச்சிடுவதற்கு. 1,000 வரிசைகள் வரை.';

  @override
  String get expGone => 'இந்த ஏற்றுமதி இனி கிடைக்காது.';

  @override
  String get expStartAgain => 'மீண்டும் தொடங்கு';

  @override
  String get expFormat => 'வடிவம்';

  @override
  String get expWeekday => 'வார நாள்';

  @override
  String get expPaymentDay => 'செலுத்தும் நாள்';

  @override
  String get expOptional => 'விருப்பத்தேர்வு';

  @override
  String get expAny => 'ஏதேனும்';

  @override
  String expUpToDays(int days) {
    return '$days நாட்கள் வரை';
  }

  @override
  String get expAllTime => 'எல்லா காலமும்';

  @override
  String get expIssuedBetween => 'வழங்கிய காலம்';

  @override
  String get expAnyDate => 'எந்தத் தேதியும்';

  @override
  String get expPickDates => 'தேதிகளைத் தேர்ந்தெடு';

  @override
  String get expScope => 'வரம்பு';

  @override
  String expAuditNote(String note) {
    return 'தணிக்கைத் திரையின் வடிகட்டிகளையும் பயன்படுத்துகிறது: $note.';
  }

  @override
  String get expSwitchCsv => 'CSV-க்கு மாற்று';

  @override
  String get expSwitchExcel => 'Excel-க்கு மாற்று';

  @override
  String expCreateFormat(String format) {
    return '$format உருவாக்கு';
  }

  @override
  String get expWaiting => 'வரிசையில் காத்திருக்கிறது...';

  @override
  String get expBuildingFile => 'உங்கள் கோப்பு உருவாகிறது...';

  @override
  String get expCountingRows => 'வரிசைகள் எண்ணப்படுகின்றன...';

  @override
  String get expAlreadyInProgressSuffix => ' • ஏற்கனவே நடைபெறுகிறது';

  @override
  String get expReadyLabel => 'தயார்';

  @override
  String get expDownloading => 'பதிவிறக்கப்படுகிறது...';

  @override
  String get expBuildFailed => 'கோப்பை உருவாக்க முடியவில்லை';

  @override
  String get expTryAgain => 'மீண்டும் முயற்சி';

  @override
  String get expFileExpired => 'இந்தக் கோப்பு காலாவதியானது.';

  @override
  String get expKeptExpired =>
      'கோப்புகள் 24 மணிநேரம் வைக்கப்படும். புதியதைப் பெற மீண்டும் உருவாக்கவும்.';

  @override
  String get expCanClose =>
      'இதை மூடலாம். இது தொடர்ந்து உருவாகி பதிவிறக்கங்களில் தோன்றும்.';

  @override
  String get expKept24 => 'கோப்புகள் 24 மணிநேரம் வைக்கப்படும்.';

  @override
  String get empWorksUnder => 'கீழ் பணியாற்றுபவர்';

  @override
  String get empNoActiveAdmins => 'செயலில் உள்ள நிர்வாகிகள் இல்லை.';

  @override
  String empEmployeesCount(int count) {
    return '$count ஊழியர்கள்';
  }

  @override
  String get empEnterNumber => 'ஒரு எண்ணை உள்ளிடவும்';

  @override
  String empRangeError(String label, String min, String max) {
    return '$label $min முதல் $max வரை இருக்க வேண்டும்';
  }

  @override
  String get empOneDecimal => 'அதிகபட்சம் ஒரு தசம இடம்';

  @override
  String get empFee => 'கட்டணம்';

  @override
  String get empInterest => 'வட்டி';

  @override
  String get empTerm => 'காலம்';

  @override
  String get empNameTooShort => 'பெயரில் குறைந்தது 2 எழுத்துகள் வேண்டும்';

  @override
  String get empNameChars =>
      'எழுத்துகள், இடைவெளிகள் மற்றும் . \' - மட்டும் பயன்படுத்தவும்';

  @override
  String get empInvalidMobile => 'சரியான மொபைல் எண்ணை உள்ளிடவும்';

  @override
  String get empInvalidEmail => 'சரியான மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get empChooseAdmin =>
      'இந்த ஊழியர் பணியாற்றும் நிர்வாகியைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get empFixDefaults => 'முதலில் கடன் இயல்புகளைச் சரிசெய்யவும்.';

  @override
  String empAdded(String name) {
    return '$name சேர்க்கப்பட்டார். அவரால் இன்னும் உள்நுழைய முடியாவிட்டால், \'நிலுவையில்\' பகுதியில் அங்கீகரிக்கவும்.';
  }

  @override
  String get empNoServerAnswer =>
      'சேவையகத்திலிருந்து பதில் இல்லை. கணக்கு ஏற்கனவே உருவாக்கப்பட்டிருக்கலாம் என்பதால், மீண்டும் முயலும் முன் \'பயனர்களை நிர்வகி\' பகுதியைச் சரிபார்க்கவும்.';

  @override
  String get empAddEmployee => 'ஊழியரைச் சேர்';

  @override
  String get empDiscardTitle => 'இந்த ஊழியரை நிராகரிக்கவா?';

  @override
  String get empDiscardMessage => 'சேமிக்கப்படாத விவரங்கள் உள்ளன.';

  @override
  String get empDiscard => 'நிராகரி';

  @override
  String get empKeepEditing => 'தொடர்ந்து திருத்து';

  @override
  String get empCreate => 'ஊழியரை உருவாக்கு';

  @override
  String get empAdmin => 'நிர்வாகி';

  @override
  String get empChooseAnAdmin => 'நிர்வாகியைத் தேர்ந்தெடு';

  @override
  String get empAccount => 'கணக்கு';

  @override
  String get empFullName => 'முழுப் பெயர்';

  @override
  String get empPhoneNumber => 'தொலைபேசி எண்';

  @override
  String get empPhoneHelper => 'அவர் இந்த எண் மூலம் உள்நுழைவார்.';

  @override
  String get empEmailOptional => 'மின்னஞ்சல் (விருப்பத்தேர்வு)';

  @override
  String get empPassword => 'கடவுச்சொல்';

  @override
  String get empGenerate => 'உருவாக்கு';

  @override
  String get empMin8 => 'குறைந்தது 8 எழுத்துகள் பயன்படுத்தவும்';

  @override
  String get empHide => 'மறை';

  @override
  String get empShow => 'காட்டு';

  @override
  String get empPasswordsMismatch => 'கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String get empConfirmPassword => 'கடவுச்சொல்லை உறுதிசெய்';

  @override
  String get empSharePassword =>
      'இந்தக் கடவுச்சொல்லை அவருடன் பகிரவும். பின்னர் அவர் தனது சுயவிவரத்தில் மாற்றலாம்.';

  @override
  String get empLoanDefaults => 'கடன் இயல்புகள்';

  @override
  String get empCustomise => 'இந்த ஊழியருக்குத் தனிப்பயனாக்கு';

  @override
  String get empOnlyThisEmployee => 'இந்த மதிப்புகள் இந்த ஊழியருக்கு மட்டும்.';

  @override
  String empUsesAdminDefaults(
    String admin,
    String fee,
    String interest,
    String months,
  ) {
    return '$admin இயல்புகளைப் பயன்படுத்துகிறது: கட்டணம் $fee%, வட்டி $interest%, $months மாதங்கள். பின்னர் செய்யும் மாற்றங்களும் பொருந்தும்.';
  }

  @override
  String empUsesYourDefaults(String fee, String interest, String months) {
    return 'உங்கள் இயல்புகளைப் பயன்படுத்துகிறது: கட்டணம் $fee%, வட்டி $interest%, $months மாதங்கள். பின்னர் செய்யும் மாற்றங்களும் பொருந்தும்.';
  }

  @override
  String get empTheAdmin => 'நிர்வாகி';

  @override
  String get empUpfrontFee => 'முன்கூட்டிய கட்டணம்';

  @override
  String get empMonthsSuffix => 'மாதங்கள்';

  @override
  String get empResetInherited => 'பெறப்பட்ட மதிப்புகளுக்கு மீட்டமை';

  @override
  String empExample(
    String loan,
    String fee,
    String handed,
    String total,
    String weekly,
    int weeks,
  ) {
    return '$loan கடனுக்கு: கட்டணம் $fee, $handed ஒப்படைப்பு, $total திருப்பிச் செலுத்தல், $weeks வாரங்களுக்கு வாரம் $weekly.';
  }

  @override
  String manApproved(String name) {
    return '$name அங்கீகரிக்கப்பட்டார்.';
  }

  @override
  String manApprovedCanSignIn(String name) {
    return '$name அங்கீகரிக்கப்பட்டார். இப்போது உள்நுழையலாம்.';
  }

  @override
  String manRejectTitle(String name) {
    return '$name-ஐ நிராகரிக்கவா?';
  }

  @override
  String get manRejectMessage =>
      'கணக்கு செயலிழக்கப்படும், உள்நுழைய முடியாது. அது ஒருபோதும் நீக்கப்படாது.';

  @override
  String get manReject => 'நிராகரி';

  @override
  String manRejected(String name) {
    return '$name நிராகரிக்கப்பட்டார்.';
  }

  @override
  String manDeactivateTitle(String name) {
    return '$name-ஐ செயலிழக்கவா?';
  }

  @override
  String get manDeactivateAdminMsg =>
      'அவர்களின் அணுகல் டோக்கன் காலாவதியானதும் வெளியேற்றப்படுவார்கள். அவர்களின் ஊழியர்கள் மாற்றப்பட மாட்டார்கள்.';

  @override
  String get manDeactivateUserMsg =>
      'அவர்களின் அணுகல் டோக்கன் காலாவதியானதும் வெளியேற்றப்படுவார்கள். அவர்களின் வாடிக்கையாளர்கள் மற்றும் கடன்கள் அப்படியே இருக்கும்.';

  @override
  String get manDeactivate => 'செயலிழக்கு';

  @override
  String manDeactivated(String name) {
    return '$name செயலிழக்கப்பட்டார்.';
  }

  @override
  String manReactivatedPending(String name) {
    return '$name மீண்டும் செயல்படுத்தப்பட்டார். மீண்டும் அங்கீகாரத்திற்குக் காத்திருக்கிறார்.';
  }

  @override
  String manReactivated(String name) {
    return '$name மீண்டும் செயல்படுத்தப்பட்டார்.';
  }

  @override
  String get manCountsFailed => 'எண்ணிக்கைகளை ஏற்ற முடியவில்லை.';

  @override
  String get manPending => 'நிலுவையில்';

  @override
  String get manAwaitingApproval => 'அங்கீகாரத்திற்குக் காத்திருக்கிறது';

  @override
  String get manTeams => 'குழுக்கள்';

  @override
  String get manApprovedAdmins => 'அங்கீகரிக்கப்பட்ட நிர்வாகிகள்';

  @override
  String get manEmployees => 'ஊழியர்கள்';

  @override
  String get manAcrossAllTeams => 'அனைத்துக் குழுக்களிலும்';

  @override
  String get manAcrossTeams => 'குழுக்களில்';

  @override
  String get manActive => 'செயலில்';

  @override
  String get manCanSignIn => 'உள்நுழையலாம்';

  @override
  String get manInactive => 'செயலற்றது';

  @override
  String get manDeactivatedLower => 'செயலிழக்கப்பட்டது';

  @override
  String get manManageAdmins => 'நிர்வாகிகளை நிர்வகி';

  @override
  String get manSearchHint => 'பெயர், தொலைபேசி அல்லது மின்னஞ்சல் மூலம் தேடவும்';

  @override
  String get manNoAdminsPending =>
      'அங்கீகாரத்திற்குக் காத்திருக்கும் நிர்வாகிகள் இல்லை.';

  @override
  String get manNoActiveAdmins => 'இதுவரை செயலில் உள்ள நிர்வாகிகள் இல்லை.';

  @override
  String get manNoInactiveAdmins => 'செயலற்ற நிர்வாகிகள் இல்லை.';

  @override
  String get manFilterByAdmin => 'நிர்வாகி மூலம் வடிகட்டு';

  @override
  String get manNoEmployeesPending =>
      'அங்கீகாரத்திற்குக் காத்திருக்கும் ஊழியர்கள் இல்லை.';

  @override
  String get manNoActiveEmployees => 'இதுவரை செயலில் உள்ள ஊழியர்கள் இல்லை.';

  @override
  String get manNoInactiveEmployees => 'செயலற்ற ஊழியர்கள் இல்லை.';

  @override
  String get accPhone => 'தொலைபேசி';

  @override
  String get accEmail => 'மின்னஞ்சல்';

  @override
  String get accNotAdded => 'சேர்க்கப்படவில்லை';

  @override
  String get accJoined => 'இணைந்தது';

  @override
  String get accLoanDefaultsOwn => 'கடன் இயல்புகள் (சொந்தம்)';

  @override
  String accDefaultsLine(String fee, String interest, String months) {
    return 'கட்டணம் $fee% • வட்டி $interest% • $months மாதங்கள்';
  }

  @override
  String accTeamCount(int count) {
    return 'குழு ($count)';
  }

  @override
  String accPendingCount(int count) {
    return '$count நிலுவையில்';
  }

  @override
  String get accNoEmployees => 'இந்த நிர்வாகியின் கீழ் இதுவரை ஊழியர்கள் இல்லை.';

  @override
  String accCustomersCount(int count) {
    return '$count வாடிக்கையாளர்கள்';
  }

  @override
  String get accOpenManageUsers =>
      'ஊழியர்களை அங்கீகரிக்க அல்லது செயலிழக்க \'பயனர்களை நிர்வகி\' பகுதியைத் திறக்கவும்.';

  @override
  String get accActivity => 'செயல்பாடு';

  @override
  String get accCustomers => 'வாடிக்கையாளர்கள்';

  @override
  String get accCreated => 'உருவாக்கியது';

  @override
  String get accActiveLoans => 'செயலில் உள்ள கடன்கள்';

  @override
  String get accActiveAndOverdue => 'செயலில் மற்றும் தாமதம்';

  @override
  String get accViewPerformance => 'செயல்திறனைக் காண்';

  @override
  String get manTabPending => 'நிலுவையில்';

  @override
  String get manTabActive => 'செயலில்';

  @override
  String get manTabInactive => 'செயலற்றது';

  @override
  String get manOwnDefaults => 'சொந்த இயல்புகள்';

  @override
  String get manAdminDefaults => 'நிர்வாகி இயல்புகள்';

  @override
  String manDefaultsShort(String fee, String interest, String months) {
    return 'கட்டணம் $fee% • வட்டி $interest% • $months மா';
  }

  @override
  String manJoinedOn(String date) {
    return 'இணைந்தது $date';
  }

  @override
  String get manApprove => 'அங்கீகரி';

  @override
  String get manDetails => 'விவரங்கள்';

  @override
  String get manReactivate => 'மீண்டும் செயல்படுத்து';

  @override
  String manNobodyMatches(String query) {
    return '\"$query\" உடன் யாரும் பொருந்தவில்லை.';
  }

  @override
  String get manThatIsEveryone => 'அவ்வளவுதான்';

  @override
  String get profPhoneUpdated => 'தொலைபேசி எண் புதுப்பிக்கப்பட்டது.';

  @override
  String get profPasswordChanged => 'கடவுச்சொல் மாற்றப்பட்டது.';

  @override
  String get profSignOutDevice => 'இந்தச் சாதனத்திலிருந்து வெளியேறவா?';

  @override
  String profSignedInOn(String date) {
    return '$date அன்று உள்நுழைந்தது.';
  }

  @override
  String get profSignOut => 'வெளியேறு';

  @override
  String get profSignOutAllTitle => 'அனைத்துச் சாதனங்களிலிருந்தும் வெளியேறவா?';

  @override
  String get profSignOutAllMsg =>
      'இந்தச் சாதனமும் வெளியேற்றப்படும், நீங்கள் மீண்டும் உள்நுழைய வேண்டும்.';

  @override
  String get profSignOutAll => 'அனைத்திலிருந்தும் வெளியேறு';

  @override
  String profApproveTitle(String name) {
    return '$name-ஐ அங்கீகரிக்கவா?';
  }

  @override
  String get profApproveMsg =>
      'அவர் உள்நுழைந்து ஒரு குழுவை நிர்வகிக்க முடியும்.';

  @override
  String get profRejectMsg =>
      'கணக்கு செயலிழக்கப்படும். அது ஒருபோதும் நீக்கப்படாது.';

  @override
  String get profAdminApproved => 'நிர்வாகி அங்கீகரிக்கப்பட்டார்.';

  @override
  String get profAdminRejected => 'நிர்வாகி நிராகரிக்கப்பட்டார்.';

  @override
  String get profLimitsUpdated => 'வரம்புகள் புதுப்பிக்கப்பட்டன.';

  @override
  String get profDiscardChanges => 'மாற்றங்களை நிராகரிக்கவா?';

  @override
  String get profUnsavedEdits => 'சேமிக்கப்படாத திருத்தங்கள் உள்ளன.';

  @override
  String get profLoadFailed => 'உங்கள் சுயவிவரத்தை ஏற்ற முடியவில்லை.';

  @override
  String get profHidePasswords => 'கடவுச்சொற்களை மறை';

  @override
  String get profShowPasswords => 'கடவுச்சொற்களைக் காட்டு';

  @override
  String get profChangePassword => 'கடவுச்சொல்லை மாற்று';

  @override
  String get profOtherDevicesSignedOut =>
      'உங்கள் மற்ற சாதனங்கள் வெளியேற்றப்படும்.';

  @override
  String get profEnterCurrent => 'தற்போதைய கடவுச்சொல்லை உள்ளிடவும்';

  @override
  String get profCurrentPassword => 'தற்போதைய கடவுச்சொல்';

  @override
  String get profDifferentPassword => 'வேறு கடவுச்சொல்லைத் தேர்ந்தெடுக்கவும்';

  @override
  String get profNewPassword => 'புதிய கடவுச்சொல்';

  @override
  String get profConfirmNewPassword => 'புதிய கடவுச்சொல்லை உறுதிசெய்';

  @override
  String get profUpdatePassword => 'கடவுச்சொல்லைப் புதுப்பி';

  @override
  String get profSamePhone => 'அது ஏற்கனவே உங்கள் தொலைபேசி எண்';

  @override
  String get profSendCodeFailed =>
      'குறியீட்டை அனுப்ப முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get profEnterCode => '6 இலக்கக் குறியீட்டை உள்ளிடவும்';

  @override
  String get profSomethingWrong => 'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get profChangePhone => 'தொலைபேசி எண்ணை மாற்று';

  @override
  String get profWillSendCode => 'புதிய எண்ணுக்கு ஒரு குறியீட்டை அனுப்புவோம்.';

  @override
  String profCodeSentTo(String phone) {
    return '$phone எண்ணுக்குக் குறியீடு அனுப்பப்பட்டது';
  }

  @override
  String get profNewPhone => 'புதிய தொலைபேசி எண்';

  @override
  String get profSixDigitCode => '6 இலக்கக் குறியீடு';

  @override
  String get profSendCode => 'குறியீட்டை அனுப்பு';

  @override
  String get profVerifyUpdate => 'சரிபார்த்துப் புதுப்பி';

  @override
  String get profUseAnother => 'வேறு எண்ணைப் பயன்படுத்து';

  @override
  String profResendIn(int seconds) {
    return '$seconds வினாடிகளில் மீண்டும் அனுப்பு';
  }

  @override
  String get profResendCode => 'குறியீட்டை மீண்டும் அனுப்பு';

  @override
  String get profMinPrincipal => 'குறைந்தபட்ச அசல் (₹)';

  @override
  String get profMaxPrincipal => 'அதிகபட்ச அசல் (₹)';

  @override
  String get profMinTerm => 'குறைந்தபட்சக் காலம் (மாதங்கள்)';

  @override
  String get profMaxTerm => 'அதிகபட்சக் காலம் (மாதங்கள்)';

  @override
  String get profMaxFee => 'அதிகபட்ச முன்கூட்டிய கட்டணம் (%)';

  @override
  String get profMaxInterest => 'அதிகபட்ச வட்டி (%)';

  @override
  String get profMinPrincipalExceeds =>
      'குறைந்தபட்ச அசல் அதிகபட்ச அசலை விட அதிகமாக இருக்கக்கூடாது';

  @override
  String get profMinTermExceeds =>
      'குறைந்தபட்சக் காலம் அதிகபட்சக் காலத்தை விட அதிகமாக இருக்கக்கூடாது';

  @override
  String get profChangeOneLimit => 'குறைந்தது ஒரு வரம்பையாவது மாற்றவும்';

  @override
  String get profLoanLimits => 'கடன் வரம்புகள்';

  @override
  String get profLimitsNote =>
      'ஏற்கனவே உள்ள நிர்வாகி இயல்புகள் மாற்றப்படாது. அடுத்த முறை இயல்புகள் சேமிக்கப்படும்போது கடுமையான வரம்பு பொருந்தும்.';

  @override
  String get profPositiveNumber => 'நேர்மறை எண்ணை உள்ளிடவும்';

  @override
  String profMustBeOrLess(String max) {
    return '$max அல்லது அதற்குக் குறைவாக இருக்க வேண்டும்';
  }

  @override
  String get profSaveLimits => 'வரம்புகளைச் சேமி';

  @override
  String get pcAwaitingApproval => 'அங்கீகாரத்திற்குக் காத்திருக்கிறது';

  @override
  String get pcVerified => 'சரிபார்க்கப்பட்டது';

  @override
  String pcMemberSince(String date) {
    return '$date முதல் உறுப்பினர்';
  }

  @override
  String get pcProfileUpdated => 'சுயவிவரம் புதுப்பிக்கப்பட்டது.';

  @override
  String get pcContact => 'தொடர்பு';

  @override
  String get pcEditNameEmail => 'பெயர் மற்றும் மின்னஞ்சலைத் திருத்து';

  @override
  String get pcName => 'பெயர்';

  @override
  String get pcMyNumbers => 'என் எண்ணிக்கைகள்';

  @override
  String get pcMe => 'நான்';

  @override
  String get pcMyTeam => 'என் குழு';

  @override
  String get pcEveryone => 'அனைவரும்';

  @override
  String get pcNumbersFailed => 'எண்ணிக்கைகளை ஏற்ற முடியவில்லை.';

  @override
  String get pcCollectedVsTarget => 'இலக்குக்கு எதிரான வசூல்';

  @override
  String pcOfTarget(String amount) {
    return '$amount இலக்கில்';
  }

  @override
  String get pcCustomersPaid => 'செலுத்திய வாடிக்கையாளர்கள்';

  @override
  String get pcInThisPeriod => 'இந்தக் காலத்தில்';

  @override
  String get pcPaymentsByDue => 'நிலுவைத் தேதிக்குள் கட்டணங்கள்';

  @override
  String get pcDefaultsUpdated => 'கடன் இயல்புகள் புதுப்பிக்கப்பட்டன.';

  @override
  String get pcEditDefaults => 'கடன் இயல்புகளைத் திருத்து';

  @override
  String get pcUpfrontFeeUpper => 'முன்கூட்டிய கட்டணம்';

  @override
  String get pcOnPrincipal => 'அசல் மீது';

  @override
  String get pcInterestUpper => 'வட்டி';

  @override
  String get pcFlatOnce => 'நிலையானது, ஒருமுறை';

  @override
  String get pcTermUpper => 'காலம்';

  @override
  String pcMonthsShort(String months) {
    return '$months மா';
  }

  @override
  String pcWeeks(int weeks) {
    return '$weeks வாரங்கள்';
  }

  @override
  String get pcSetByAdmin =>
      'உங்கள் நிர்வாகியால் அமைக்கப்பட்டது. புதிய கடன்கள் மட்டுமே இந்த மதிப்புகளைப் பயன்படுத்தும்.';

  @override
  String get pcAppliesNewOnly =>
      'புதிய கடன்களுக்கு மட்டுமே பொருந்தும், ஏற்கனவே உள்ளவற்றுக்கு அல்ல. இந்த மதிப்புகளைப் பெறும் ஊழியர்களுக்கு உடனே பொருந்தும்.';

  @override
  String get pcOnlyAdminsChange =>
      'நிர்வாகிகள் மட்டுமே இவற்றை மாற்ற முடியும். புதிய கடன்கள் மட்டுமே பயன்படுத்தும்.';

  @override
  String get pcSecurity => 'பாதுகாப்பு';

  @override
  String get pcChangeYourPassword => 'உங்கள் கடவுச்சொல்லை மாற்றவும்';

  @override
  String get pcSignedInDevices => 'உள்நுழைந்த சாதனங்கள்';

  @override
  String get pcSessionsFailed => 'உங்கள் அமர்வுகளை ஏற்ற முடியவில்லை.';

  @override
  String get pcNoSessions => 'செயலில் அமர்வுகள் இல்லை.';

  @override
  String pcExpires(String date) {
    return '$date அன்று காலாவதியாகும்';
  }

  @override
  String get pcDeviceNamesNote =>
      'சாதனப் பெயர்கள் பதிவு செய்யப்படுவதில்லை, எனவே தற்போதைய சாதனம் குறிக்கப்படவில்லை.';

  @override
  String get pcSignOutAllDevices => 'அனைத்துச் சாதனங்களிலிருந்தும் வெளியேறு';

  @override
  String get pcTeamFailed => 'குழுவை ஏற்ற முடியவில்லை.';

  @override
  String get pcNoApprovedTeams => 'இதுவரை அங்கீகரிக்கப்பட்ட குழுக்கள் இல்லை.';

  @override
  String pcMembersCount(int count) {
    return '$count உறுப்பினர்கள்';
  }

  @override
  String pcPendingSuffix(int count) {
    return ' • $count நிலுவையில்';
  }

  @override
  String get pcNoTeamMembers => 'இதுவரை குழு உறுப்பினர்கள் இல்லை.';

  @override
  String pcMoreInManage(int count) {
    return '+$count மேலும் \'பயனர்களை நிர்வகி\' பகுதியில்';
  }

  @override
  String get pcSystem => 'அமைப்பு';

  @override
  String pcWaiting(int count) {
    return '$count காத்திருக்கின்றனர்';
  }

  @override
  String get pcAdminApprovals => 'நிர்வாகி அங்கீகாரங்கள்';

  @override
  String get pcApprovalQueueFailed => 'அங்கீகார வரிசையை ஏற்ற முடியவில்லை.';

  @override
  String pcRejectName(String name) {
    return '$name-ஐ நிராகரி';
  }

  @override
  String pcApproveName(String name) {
    return '$name-ஐ அங்கீகரி';
  }

  @override
  String get pcLoanLimitsUpper => 'கடன் வரம்புகள்';

  @override
  String pcLimitsSummary(
    String minP,
    String maxP,
    String minM,
    String maxM,
    String fee,
    String interest,
  ) {
    return 'அசல் $minP முதல் $maxP வரை\nகாலம் $minM முதல் $maxM மாதங்கள்\nகட்டணம் $fee% வரை • வட்டி $interest% வரை';
  }

  @override
  String get pcEditLimits => 'கடன் வரம்புகளைத் திருத்து';

  @override
  String get pcApp => 'செயலி';

  @override
  String get pcVersion => 'பதிப்பு';

  @override
  String get commonConfirm => 'உறுதிசெய்';

  @override
  String get profNoAnswerReloaded =>
      'சேவையகத்திலிருந்து பதில் இல்லை. உங்கள் சுயவிவரம் மீண்டும் ஏற்றப்பட்டது; சரிபார்த்து தேவைப்பட்டால் மீண்டும் சேமிக்கவும்.';

  @override
  String get profNoApprovedTeam => 'காட்ட அங்கீகரிக்கப்பட்ட குழு இதுவரை இல்லை.';

  @override
  String get expDownloadExpired =>
      'இந்தக் கோப்பு காலாவதியானது. மீண்டும் உருவாக்கவும்.';

  @override
  String get expDownloadNotReady => 'கோப்பு இன்னும் தயாராகவில்லை.';

  @override
  String get expDownloadFailed =>
      'பதிவிறக்கம் முடியவில்லை. இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get expDownloadEmpty =>
      'பதிவிறக்கிய கோப்பு காலியாக உள்ளது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String valRequired(String field) {
    return '$field தேவை';
  }

  @override
  String get valThisField => 'இந்த புலம்';

  @override
  String get valValue => 'மதிப்பு';

  @override
  String get valFieldCity => 'நகரம்';

  @override
  String get valFieldConfirmPassword => 'கடவுச்சொல்லை உறுதிப்படுத்து';

  @override
  String get valNameRequired => 'பெயர் தேவை';

  @override
  String get valNameShort => 'பெயர் மிகவும் சிறியது';

  @override
  String get valNameChars =>
      'பெயரில் எழுத்துகள், இடைவெளிகள் மற்றும் சில நிறுத்தக்குறிகள் மட்டுமே இருக்கலாம்';

  @override
  String get valPhoneRequired => 'தொலைபேசி எண் தேவை';

  @override
  String get valPhoneInvalid => 'சரியான 10 இலக்க மொபைல் எண்ணை உள்ளிடவும்';

  @override
  String get valOtpRequired => 'OTP தேவை';

  @override
  String valOtpLength(int length) {
    return '$length இலக்க OTP-ஐ உள்ளிடவும்';
  }

  @override
  String get valEmailRequired => 'மின்னஞ்சல் தேவை';

  @override
  String get valEmailInvalid => 'சரியான மின்னஞ்சலை உள்ளிடவும்';

  @override
  String get valPasswordRequired => 'கடவுச்சொல் தேவை';

  @override
  String valPasswordMissing(String items) {
    return 'இல்லாதவை: $items';
  }

  @override
  String valMinChars(int count) {
    return '$count+ எழுத்துகள்';
  }

  @override
  String get valUppercase => 'பெரிய எழுத்து';

  @override
  String get valNumber => 'எண்';

  @override
  String get valSpecialChar => 'சிறப்பு எழுத்து';

  @override
  String get valConfirmPassword => 'உங்கள் கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get valPasswordsMismatch => 'கடவுச்சொற்கள் பொருந்தவில்லை';

  @override
  String get valAmountRequired => 'தொகை தேவை';

  @override
  String get valAmountPositive => '0-ஐ விட அதிகமான தொகையை உள்ளிடவும்';

  @override
  String valAmountMin(String amount) {
    return 'குறைந்தபட்சம் $amount';
  }

  @override
  String valAmountMax(String amount) {
    return 'அதிகபட்சம் $amount';
  }

  @override
  String get valPercentRequired => 'சதவீதம் தேவை';

  @override
  String get valNumberInvalid => 'சரியான எண்ணை உள்ளிடவும்';

  @override
  String valPercentRange(int max) {
    return '0 முதல் $max வரையிலான மதிப்பை உள்ளிடவும்';
  }

  @override
  String get valPositiveNumber => '0-ஐ விட அதிகமான சரியான எண்ணை உள்ளிடவும்';

  @override
  String get audModAuth => 'அங்கீகாரம்';

  @override
  String get audModProfile => 'சுயவிவரம்';

  @override
  String get audModAdmin => 'நிர்வாகி';

  @override
  String get audModEmployee => 'பணியாளர்';

  @override
  String get audModCustomer => 'வாடிக்கையாளர்';

  @override
  String get audModLoan => 'கடன்';

  @override
  String get audModPayment => 'கட்டணம்';

  @override
  String get audModSettings => 'அமைப்புகள்';

  @override
  String get audModSystem => 'அமைப்பு';

  @override
  String get audModOther => 'மற்றவை';

  @override
  String get audActAdminRegistered => 'நிர்வாகி பதிவு செய்யப்பட்டார்';

  @override
  String get audActLoginFailed => 'உள்நுழைவு தோல்வி';

  @override
  String get audActLoginBlocked => 'உள்நுழைவு தடுக்கப்பட்டது';

  @override
  String get audActPasswordReset => 'கடவுச்சொல் மீட்டமைக்கப்பட்டது';

  @override
  String get audActSessionsRevoked => 'அமர்வுகள் வெளியேற்றப்பட்டன';

  @override
  String get audActProfileUpdated => 'சுயவிவரம் புதுப்பிக்கப்பட்டது';

  @override
  String get audActPhoneChanged => 'தொலைபேசி எண் மாற்றப்பட்டது';

  @override
  String get audActPasswordChanged => 'கடவுச்சொல் மாற்றப்பட்டது';

  @override
  String get audActLoanDefaultsUpdated =>
      'கடன் இயல்புநிலைகள் புதுப்பிக்கப்பட்டன';

  @override
  String get audActAdminVerificationChanged =>
      'நிர்வாகி ஒப்புதல் மாற்றப்பட்டது';

  @override
  String get audActAdminActiveChanged =>
      'நிர்வாகி செயல்படுத்தப்பட்டார் அல்லது முடக்கப்பட்டார்';

  @override
  String get audActAdminDefaultsChanged =>
      'நிர்வாகி இயல்புநிலைகள் மாற்றப்பட்டன';

  @override
  String get audActEmployeeCreated => 'பணியாளர் உருவாக்கப்பட்டார்';

  @override
  String get audActEmployeeVerificationChanged =>
      'பணியாளர் ஒப்புதல் மாற்றப்பட்டது';

  @override
  String get audActEmployeeActiveChanged =>
      'பணியாளர் செயல்படுத்தப்பட்டார் அல்லது முடக்கப்பட்டார்';

  @override
  String get audActEmployeeReassigned =>
      'பணியாளர் வேறு நிர்வாகிக்கு மாற்றப்பட்டார்';

  @override
  String get audActEmployeeDefaultsUpdated =>
      'பணியாளர் இயல்புநிலைகள் புதுப்பிக்கப்பட்டன';

  @override
  String get audActEmployeeProfileEdited =>
      'பணியாளர் சுயவிவரம் திருத்தப்பட்டது';

  @override
  String get audActCustomerCreated => 'வாடிக்கையாளர் உருவாக்கப்பட்டார்';

  @override
  String get audActCustomerUpdated => 'வாடிக்கையாளர் புதுப்பிக்கப்பட்டார்';

  @override
  String get audActCustomerDeleted => 'வாடிக்கையாளர் நீக்கப்பட்டார்';

  @override
  String get audActCustomerReassigned =>
      'வாடிக்கையாளர் மறுஒதுக்கீடு செய்யப்பட்டார்';

  @override
  String get audActReferrerChanged => 'பரிந்துரைப்பவர் மாற்றப்பட்டார்';

  @override
  String get audActLoanCreated => 'கடன் உருவாக்கப்பட்டது';

  @override
  String get audActLoanStatusChanged => 'கடன் நிலை மாற்றப்பட்டது';

  @override
  String get audActLoanTermsEdited => 'கடன் விதிமுறைகள் திருத்தப்பட்டன';

  @override
  String get audActLoanClosed => 'கடன் மூடப்பட்டது';

  @override
  String get audActLoanWrittenOff => 'கடன் தள்ளுபடி செய்யப்பட்டது';

  @override
  String get audActLoanDeleted => 'கடன் நீக்கப்பட்டது';

  @override
  String get audActPaymentRecorded => 'கட்டணம் பதிவு செய்யப்பட்டது';

  @override
  String get audActPaymentEdited => 'கட்டணம் திருத்தப்பட்டது';

  @override
  String get audActPaymentReversed => 'கட்டணம் திரும்பப்பெறப்பட்டது';

  @override
  String get audActWeekStatusChanged => 'வார நிலை மாற்றப்பட்டது';

  @override
  String get audActBackdatedPayment => 'பின்தேதியிட்ட கட்டணம்';

  @override
  String get audActLoanLimitsUpdated => 'கடன் வரம்புகள் புதுப்பிக்கப்பட்டன';

  @override
  String get audActSettingsChanged => 'அமைப்புகள் மாற்றப்பட்டன';

  @override
  String get audActDataExported => 'தரவு ஏற்றுமதி செய்யப்பட்டது';

  @override
  String get audActBulkImport => 'மொத்த இறக்குமதி';

  @override
  String get audEntUser => 'பயனர்';

  @override
  String get audEntWeek => 'வாரம்';

  @override
  String get audEntSetting => 'அமைப்பு';

  @override
  String get audFieldStatus => 'நிலை';

  @override
  String get audFieldName => 'பெயர்';

  @override
  String get audFieldPhone => 'தொலைபேசி';

  @override
  String get audFieldEmail => 'மின்னஞ்சல்';

  @override
  String get audFieldApproval => 'ஒப்புதல்';

  @override
  String get audFieldActive => 'செயலில்';

  @override
  String get audFieldDefaultUpfrontFee => 'இயல்புநிலை முன்கட்டணம்';

  @override
  String get audFieldDefaultInterest => 'இயல்புநிலை வட்டி';

  @override
  String get audFieldDefaultTerm => 'இயல்புநிலை காலம்';

  @override
  String get audFieldDefaultTermWeeks => 'இயல்புநிலை காலம் (வாரங்கள்)';

  @override
  String get audFieldPrincipal => 'அசல்';

  @override
  String get audFieldTotalPayable => 'செலுத்த வேண்டிய மொத்தம்';

  @override
  String get audFieldWeeklyInstallment => 'வாராந்திர தவணை';

  @override
  String get audFieldUpfrontFee => 'முன்கட்டணம்';

  @override
  String get audFieldMinPrincipal => 'குறைந்தபட்ச அசல்';

  @override
  String get audFieldMaxPrincipal => 'அதிகபட்ச அசல்';

  @override
  String get audFieldMinTerm => 'குறைந்தபட்ச காலம்';

  @override
  String get audFieldMaxTerm => 'அதிகபட்ச காலம்';

  @override
  String get audFieldMaxFee => 'அதிகபட்ச கட்டணம்';

  @override
  String get audFieldMaxInterest => 'அதிகபட்ச வட்டி';

  @override
  String get audFieldAmountPaid => 'செலுத்திய தொகை';

  @override
  String get audFieldCustomerName => 'வாடிக்கையாளர் பெயர்';

  @override
  String get audFieldCollectionDay => 'வசூல் நாள்';

  @override
  String get audFieldReason => 'காரணம்';

  @override
  String get audFieldSource => 'மூலம்';

  @override
  String get audValEmpty => 'காலி';

  @override
  String get audValVerified => 'சரிபார்க்கப்பட்டது';

  @override
  String get audValNotVerified => 'சரிபார்க்கப்படவில்லை';

  @override
  String get audValInactive => 'செயலற்றது';

  @override
  String get audValYes => 'ஆம்';

  @override
  String get audValNo => 'இல்லை';

  @override
  String audValMonths(String n) {
    return '$n மாதங்கள்';
  }

  @override
  String audValWeeks(String n) {
    return '$n வாரங்கள்';
  }

  @override
  String audMoreCount(int count) {
    return '+$count மேலும்';
  }

  @override
  String get audYesterday => 'நேற்று';

  @override
  String get trackerNothingLeft => 'இந்தக் கடனில் வசூலிக்க எதுவும் இல்லை.';

  @override
  String payPastTermOverdue(int weeks) {
    return 'நிலுவை — $weeks வார காலம் கடந்தது';
  }

  @override
  String get payHistory => 'கட்டண வரலாறு';

  @override
  String payCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கட்டணங்கள்',
      one: '1 கட்டணம்',
    );
    return '$_temp0';
  }

  @override
  String payOfTotal(String amount) {
    return '$amount-இல்';
  }

  @override
  String get payWeeksPaid => 'செலுத்திய வாரங்கள்';

  @override
  String payWeeksPaidValue(int paid, int total) {
    return '$total-இல் $paid';
  }

  @override
  String get payLastPaid => 'கடைசி கட்டணம்';

  @override
  String get payWeekClearedShort => 'வாரம் முடிந்தது';

  @override
  String payLeftForWeek(String amount) {
    return 'இந்த வாரத்திற்கு $amount மீதம்';
  }

  @override
  String get payDetails => 'கட்டண விவரங்கள்';

  @override
  String get payPaidOn => 'செலுத்திய நேரம்';

  @override
  String get payCollectedBy => 'வசூலித்தவர்';

  @override
  String get payReference => 'கட்டண குறிப்பு எண்';

  @override
  String get payWeekRecord => 'வாரப் பதிவு';

  @override
  String get payOpenDetails => 'கட்டண விவரங்களைத் திற';

  @override
  String get trackerClosedPaidOff => 'கடன் முழுமையாகச் செலுத்தப்பட்டது';

  @override
  String trackerClosedStatus(String status) {
    return 'கடன் நிலை: $status';
  }

  @override
  String get trackerClosedNoPayments =>
      'இந்தக் கடனில் இனி கட்டணம் பதிவு செய்ய முடியாது.';

  @override
  String get expStorageDenied =>
      'Lending Docs-இல் கோப்புகளைச் சேமிக்க சேமிப்பக அனுமதியை வழங்குங்கள்.';

  @override
  String expSavedTo(String folder) {
    return '$folder-இல் சேமிக்கப்பட்டது';
  }

  @override
  String get paySavedOffline =>
      'இணைப்பு இல்லை. கட்டணம் இந்த மொபைலில் சேமிக்கப்பட்டது, தானாக ஒத்திசைக்கப்படும்.';

  @override
  String syncWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கட்டணங்கள் ஒத்திசைக்கக் காத்திருக்கின்றன',
      one: '1 கட்டணம் ஒத்திசைக்கக் காத்திருக்கிறது',
    );
    return '$_temp0';
  }

  @override
  String syncFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கட்டணங்களை ஒத்திசைக்க முடியவில்லை',
      one: '1 கட்டணத்தை ஒத்திசைக்க முடியவில்லை',
    );
    return '$_temp0';
  }

  @override
  String get syncWaitingHint =>
      'இந்த மொபைலில் சேமிக்கப்பட்டது. இணைப்பு வந்ததும் அனுப்பப்படும்.';

  @override
  String get syncNow => 'இப்போது ஒத்திசை';

  @override
  String get syncSyncing => 'ஒத்திசைக்கிறது…';

  @override
  String get syncReview => 'பார்வையிடு';

  @override
  String get syncFailedTitle => 'ஒத்திசைக்க முடியாத கட்டணங்கள்';

  @override
  String get syncFailedHelp =>
      'சர்வர் இவற்றை ஏற்கவில்லை, அதனால் எதுவும் பதிவாகவில்லை. காரணத்தைப் பார்த்து, தேவைப்பட்டால் கட்டணத்தை மீண்டும் பதிவு செய்யுங்கள்.';

  @override
  String get syncRemove => 'நீக்கு';

  @override
  String syncItemLine(String amount, int week, String date) {
    return '$amount • வாரம் $week • $date';
  }

  @override
  String get syncPendingLabel => 'ஒத்திசைக்கக் காத்திருக்கிறது';

  @override
  String syncLogoutWarn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count கட்டணங்கள் இன்னும் ஒத்திசைக்கப்படவில்லை. அவை இந்த மொபைலில் இருக்கும், அடுத்த முறை இங்கே உள்நுழையும்போது ஒத்திசைக்கப்படும்.',
      one: '1 கட்டணம் இன்னும் ஒத்திசைக்கப்படவில்லை. இது இந்த மொபைலில் இருக்கும், அடுத்த முறை இங்கே உள்நுழையும்போது ஒத்திசைக்கப்படும்.',
    );
    return '$_temp0';
  }

  @override
  String get netGood => 'இணைப்பில் உள்ளது';

  @override
  String get netWeak => 'பலவீனமான இணைப்பு';

  @override
  String netSyncing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count கட்டணங்கள் ஒத்திசைக்கின்றன…',
      one: '1 கட்டணம் ஒத்திசைக்கிறது…',
    );
    return '$_temp0';
  }

  @override
  String netStatusA11y(String status) {
    return 'இணைப்பு: $status';
  }

  @override
  String get netOfflineTitle => 'இணைப்பு இல்லை';

  @override
  String get netOfflineBody =>
      'சேமித்த தரவு காட்டப்படுகிறது. கட்டணங்கள் இந்த மொபைலில் சேமிக்கப்படும்.';

  @override
  String get netWeakBody => 'பக்கங்கள் மெதுவாக ஏறலாம்.';

  @override
  String get netBackOnline => 'மீண்டும் இணைப்பில்';

  @override
  String get netSynced => 'அனைத்து கட்டணங்களும் ஒத்திசைக்கப்பட்டன';

  @override
  String get netDismiss => 'மூடு';
}
