import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ha.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('fr'), Locale('ha')];

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @identity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get identity;

  /// No description provided for @liveness.
  ///
  /// In en, this message translates to:
  /// **'Liveness'**
  String get liveness;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @s2fa.
  ///
  /// In en, this message translates to:
  /// **'2FA'**
  String get s2fa;

  /// No description provided for @kyc.
  ///
  /// In en, this message translates to:
  /// **'KYC'**
  String get kyc;

  /// No description provided for @step1Of6Verification.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 6 · Verification'**
  String get step1Of6Verification;

  /// No description provided for @step1Of11YourCountry.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 11 · Your country'**
  String get step1Of11YourCountry;

  /// No description provided for @step2Of11Language.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 11 · Language'**
  String get step2Of11Language;

  /// No description provided for @step3Of11YourAccount.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 11 · Your account'**
  String get step3Of11YourAccount;

  /// No description provided for @step4Of11Verify.
  ///
  /// In en, this message translates to:
  /// **'Step 4 of 11 · Verify'**
  String get step4Of11Verify;

  /// No description provided for @step5Of11Verification.
  ///
  /// In en, this message translates to:
  /// **'Step 5 of 11 · Verification'**
  String get step5Of11Verification;

  /// No description provided for @step6Of11Verification.
  ///
  /// In en, this message translates to:
  /// **'Step 6 of 11 · Verification'**
  String get step6Of11Verification;

  /// No description provided for @step7Of11Verification.
  ///
  /// In en, this message translates to:
  /// **'Step 7 of 11 · Verification'**
  String get step7Of11Verification;

  /// No description provided for @step8Of11Verification.
  ///
  /// In en, this message translates to:
  /// **'Step 8 of 11 · Verification'**
  String get step8Of11Verification;

  /// No description provided for @step9Of11Verification.
  ///
  /// In en, this message translates to:
  /// **'Step 9 of 11 · Verification'**
  String get step9Of11Verification;

  /// No description provided for @step10Of11Verification.
  ///
  /// In en, this message translates to:
  /// **'Step 10 of 11 · Verification'**
  String get step10Of11Verification;

  /// No description provided for @step11Of11Verification.
  ///
  /// In en, this message translates to:
  /// **'Step 11 of 11 · Verification'**
  String get step11Of11Verification;

  /// No description provided for @welcomeBackVerify.
  ///
  /// In en, this message translates to:
  /// **'Welcome back · Verify'**
  String get welcomeBackVerify;

  /// No description provided for @step4Of5Verify.
  ///
  /// In en, this message translates to:
  /// **'Step 4 of 5 · Verify'**
  String get step4Of5Verify;

  /// No description provided for @yourDetailsAreEncryptedAndOnly.
  ///
  /// In en, this message translates to:
  /// **'Your details are encrypted and only used to verify your identity, as required by regulation.'**
  String get yourDetailsAreEncryptedAndOnly;

  /// No description provided for @s1Create.
  ///
  /// In en, this message translates to:
  /// **'1 · Create'**
  String get s1Create;

  /// No description provided for @s2Confirm.
  ///
  /// In en, this message translates to:
  /// **'2 · Confirm'**
  String get s2Confirm;

  /// No description provided for @tier2AllSet.
  ///
  /// In en, this message translates to:
  /// **'Tier 2 · All set'**
  String get tier2AllSet;

  /// No description provided for @oneStepLeft.
  ///
  /// In en, this message translates to:
  /// **'One step left'**
  String get oneStepLeft;

  /// No description provided for @step3Of5YourAccount.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 5 · Your account'**
  String get step3Of5YourAccount;

  /// No description provided for @logInToJarina.
  ///
  /// In en, this message translates to:
  /// **'Log in to Jarina'**
  String get logInToJarina;

  /// No description provided for @weLlSendACodeOn.
  ///
  /// In en, this message translates to:
  /// **'We\'\'ll send a code on WhatsApp'**
  String get weLlSendACodeOn;

  /// No description provided for @sendWhatsappCode.
  ///
  /// In en, this message translates to:
  /// **'Send WhatsApp code'**
  String get sendWhatsappCode;

  /// No description provided for @ngxStocks.
  ///
  /// In en, this message translates to:
  /// **'NGX stocks'**
  String get ngxStocks;

  /// No description provided for @crypto247.
  ///
  /// In en, this message translates to:
  /// **'Crypto 24/7'**
  String get crypto247;

  /// No description provided for @s6Countries.
  ///
  /// In en, this message translates to:
  /// **'6 countries'**
  String get s6Countries;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @bankGradeEncryptionYourNumberIs.
  ///
  /// In en, this message translates to:
  /// **'Bank-grade encryption · Your number is only used to verify you and secure your account.'**
  String get bankGradeEncryptionYourNumberIs;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @balancesAndAddressesUpdateInReal.
  ///
  /// In en, this message translates to:
  /// **'Balances and addresses update in real time.'**
  String get balancesAndAddressesUpdateInReal;

  /// No description provided for @marketDataShownIsSampleData.
  ///
  /// In en, this message translates to:
  /// **'Market data shown is sample data. A live market feed is needed for production.'**
  String get marketDataShownIsSampleData;

  /// No description provided for @cryptoCustodyAccount.
  ///
  /// In en, this message translates to:
  /// **'Crypto custody account'**
  String get cryptoCustodyAccount;

  /// No description provided for @stockRulesArePaidFromYour.
  ///
  /// In en, this message translates to:
  /// **'Stock rules are paid from your Naira wallet.'**
  String get stockRulesArePaidFromYour;

  /// No description provided for @stockRulesArePaidFromYour2.
  ///
  /// In en, this message translates to:
  /// **'Stock rules are paid from your Cedi wallet, converted to Naira at the live rate when the rule triggers.'**
  String get stockRulesArePaidFromYour2;

  /// No description provided for @stockRulesArePaidFromYour3.
  ///
  /// In en, this message translates to:
  /// **'Stock rules are paid from your CFA · XOF wallet, converted to Naira at the live rate when the rule triggers.'**
  String get stockRulesArePaidFromYour3;

  /// No description provided for @stockRulesArePaidFromYour4.
  ///
  /// In en, this message translates to:
  /// **'Stock rules are paid from your CFA · XAF wallet, converted to Naira at the live rate when the rule triggers.'**
  String get stockRulesArePaidFromYour4;

  /// No description provided for @s020VsPreviousCandleVol.
  ///
  /// In en, this message translates to:
  /// **'▲ +0.20% vs previous candle · Vol 64'**
  String get s020VsPreviousCandleVol;

  /// No description provided for @s020VsPreviousCandleVol2.
  ///
  /// In en, this message translates to:
  /// **'▼ −0.20% vs previous candle · Vol 64'**
  String get s020VsPreviousCandleVol2;

  /// No description provided for @fromNairaWallet2.
  ///
  /// In en, this message translates to:
  /// **'From Naira wallet'**
  String get fromNairaWallet2;

  /// No description provided for @toNairaWallet2.
  ///
  /// In en, this message translates to:
  /// **'To Naira wallet'**
  String get toNairaWallet2;

  /// No description provided for @fromUsdtWallet.
  ///
  /// In en, this message translates to:
  /// **'From USDT wallet'**
  String get fromUsdtWallet;

  /// No description provided for @toUsdtWallet.
  ///
  /// In en, this message translates to:
  /// **'To USDT wallet'**
  String get toUsdtWallet;

  /// No description provided for @fromCediWallet.
  ///
  /// In en, this message translates to:
  /// **'From Cedi wallet'**
  String get fromCediWallet;

  /// No description provided for @sourceOfFunds.
  ///
  /// In en, this message translates to:
  /// **'Source of funds'**
  String get sourceOfFunds;

  /// No description provided for @proceedsGoTo.
  ///
  /// In en, this message translates to:
  /// **'Proceeds go to'**
  String get proceedsGoTo;

  /// No description provided for @yourCountry2.
  ///
  /// In en, this message translates to:
  /// **'Your country'**
  String get yourCountry2;

  /// No description provided for @nairaWallet.
  ///
  /// In en, this message translates to:
  /// **'Naira wallet'**
  String get nairaWallet;

  /// No description provided for @cediWallet.
  ///
  /// In en, this message translates to:
  /// **'Cedi wallet'**
  String get cediWallet;

  /// No description provided for @cfaXofWallet.
  ///
  /// In en, this message translates to:
  /// **'CFA · XOF wallet'**
  String get cfaXofWallet;

  /// No description provided for @cfaXafWallet.
  ///
  /// In en, this message translates to:
  /// **'CFA · XAF wallet'**
  String get cfaXafWallet;

  /// No description provided for @usdtWallet.
  ///
  /// In en, this message translates to:
  /// **'USDT wallet'**
  String get usdtWallet;

  /// No description provided for @usdcWallet.
  ///
  /// In en, this message translates to:
  /// **'USDC wallet'**
  String get usdcWallet;

  /// No description provided for @btcWallet.
  ///
  /// In en, this message translates to:
  /// **'BTC wallet'**
  String get btcWallet;

  /// No description provided for @ethWallet.
  ///
  /// In en, this message translates to:
  /// **'ETH wallet'**
  String get ethWallet;

  /// No description provided for @bnbWallet.
  ///
  /// In en, this message translates to:
  /// **'BNB wallet'**
  String get bnbWallet;

  /// No description provided for @solWallet.
  ///
  /// In en, this message translates to:
  /// **'SOL wallet'**
  String get solWallet;

  /// No description provided for @paidFromYourNairaWallet.
  ///
  /// In en, this message translates to:
  /// **'Paid from your Naira wallet.'**
  String get paidFromYourNairaWallet;

  /// No description provided for @paidFromYourCediWalletAnd.
  ///
  /// In en, this message translates to:
  /// **'Paid from your Cedi wallet and converted to Naira at the live rate when the rule triggers.'**
  String get paidFromYourCediWalletAnd;

  /// No description provided for @paidFromYourCfaXofWallet.
  ///
  /// In en, this message translates to:
  /// **'Paid from your CFA · XOF wallet and converted to Naira at the live rate when the rule triggers.'**
  String get paidFromYourCfaXofWallet;

  /// No description provided for @paidFromYourCfaXafWallet.
  ///
  /// In en, this message translates to:
  /// **'Paid from your CFA · XAF wallet and converted to Naira at the live rate when the rule triggers.'**
  String get paidFromYourCfaXafWallet;

  /// No description provided for @paidFromYourUsdtWalletAt.
  ///
  /// In en, this message translates to:
  /// **'Paid from your USDT wallet at the market rate when the rule triggers.'**
  String get paidFromYourUsdtWalletAt;

  /// No description provided for @paidFromYourUsdcWalletAt.
  ///
  /// In en, this message translates to:
  /// **'Paid from your USDC wallet at the market rate when the rule triggers.'**
  String get paidFromYourUsdcWalletAt;

  /// No description provided for @paidFromYourBtcWalletAt.
  ///
  /// In en, this message translates to:
  /// **'Paid from your BTC wallet at the market rate when the rule triggers.'**
  String get paidFromYourBtcWalletAt;

  /// No description provided for @paidFromYourEthWalletAt.
  ///
  /// In en, this message translates to:
  /// **'Paid from your ETH wallet at the market rate when the rule triggers.'**
  String get paidFromYourEthWalletAt;

  /// No description provided for @yourMtnnShares.
  ///
  /// In en, this message translates to:
  /// **'Your MTNN shares'**
  String get yourMtnnShares;

  /// No description provided for @s400SharesHeld.
  ///
  /// In en, this message translates to:
  /// **'400 shares held'**
  String get s400SharesHeld;

  /// No description provided for @saleProceedsArePaidIntoThis.
  ///
  /// In en, this message translates to:
  /// **'Sale proceeds are paid into this wallet after settlement.'**
  String get saleProceedsArePaidIntoThis;

  /// No description provided for @youReceiveThisCryptoWhenThe.
  ///
  /// In en, this message translates to:
  /// **'You receive this crypto when the rule sells.'**
  String get youReceiveThisCryptoWhenThe;

  /// No description provided for @fundsComeFromYourNairaWallet.
  ///
  /// In en, this message translates to:
  /// **'Funds come from your Naira wallet when the rule triggers. If there isn\'\'t enough, the rule is skipped and we notify you.'**
  String get fundsComeFromYourNairaWallet;

  /// No description provided for @fundsComeFromYourUsdtWallet.
  ///
  /// In en, this message translates to:
  /// **'Funds come from your USDT wallet when the rule triggers. If there isn\'\'t enough, the rule is skipped and we notify you.'**
  String get fundsComeFromYourUsdtWallet;

  /// No description provided for @fundsComeFromYourCediWallet.
  ///
  /// In en, this message translates to:
  /// **'Funds come from your Cedi wallet when the rule triggers. If there isn\'\'t enough, the rule is skipped and we notify you.'**
  String get fundsComeFromYourCediWallet;

  /// No description provided for @s7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get s7Days;

  /// No description provided for @yourTriggerPrice.
  ///
  /// In en, this message translates to:
  /// **'Your trigger price'**
  String get yourTriggerPrice;

  /// No description provided for @yourTriggerPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Your trigger price range'**
  String get yourTriggerPriceRange;

  /// No description provided for @amountUsdt.
  ///
  /// In en, this message translates to:
  /// **'Amount (USDT)'**
  String get amountUsdt;

  /// No description provided for @amountGh.
  ///
  /// In en, this message translates to:
  /// **'Amount (GH₵)'**
  String get amountGh;

  /// No description provided for @amountCfa.
  ///
  /// In en, this message translates to:
  /// **'Amount (CFA)'**
  String get amountCfa;

  /// No description provided for @candles2.
  ///
  /// In en, this message translates to:
  /// **'Candles'**
  String get candles2;

  /// No description provided for @line.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get line;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @s40Candles.
  ///
  /// In en, this message translates to:
  /// **'40 candles'**
  String get s40Candles;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @dragAcrossTheChartToInspect.
  ///
  /// In en, this message translates to:
  /// **'Drag across the chart to inspect · tap to use that price in your order'**
  String get dragAcrossTheChartToInspect;

  /// No description provided for @limitPriceSetTo97500.
  ///
  /// In en, this message translates to:
  /// **'Limit price set to ₦97,500,000'**
  String get limitPriceSetTo97500;

  /// No description provided for @whenBtcFallsBelow92000.
  ///
  /// In en, this message translates to:
  /// **'When BTC falls below ₦92,000,000, buy 50.00 USDT worth.'**
  String get whenBtcFallsBelow92000;

  /// No description provided for @halimaIssoufouNiger.
  ///
  /// In en, this message translates to:
  /// **'Halima Issoufou · Niger'**
  String get halimaIssoufouNiger;

  /// No description provided for @kwameMensahGhana.
  ///
  /// In en, this message translates to:
  /// **'Kwame Mensah · Ghana'**
  String get kwameMensahGhana;

  /// No description provided for @nigeriaNiger.
  ///
  /// In en, this message translates to:
  /// **'Nigeria → Niger'**
  String get nigeriaNiger;

  /// No description provided for @ghanaNigeria.
  ///
  /// In en, this message translates to:
  /// **'Ghana → Nigeria'**
  String get ghanaNigeria;

  /// No description provided for @startWithYourWhatsappNumberWe.
  ///
  /// In en, this message translates to:
  /// **'Start with your WhatsApp number. We\'\'ll send a one-time code to your WhatsApp to verify it.'**
  String get startWithYourWhatsappNumberWe;

  /// No description provided for @whatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get whatsappNumber;

  /// No description provided for @enterYour11DigitWhatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your 11-digit WhatsApp number, e.g. 0801 234 5678'**
  String get enterYour11DigitWhatsappNumber;

  /// No description provided for @enterYour10DigitWhatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your 10-digit WhatsApp number'**
  String get enterYour10DigitWhatsappNumber;

  /// No description provided for @logInWithYourWhatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'Log in with your WhatsApp number.'**
  String get logInWithYourWhatsappNumber;

  /// No description provided for @verifyYourWhatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your WhatsApp number'**
  String get verifyYourWhatsappNumber;

  /// No description provided for @enterThe6DigitCodeWe.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to your WhatsApp on +233 024 123 4567.'**
  String get enterThe6DigitCodeWe;

  /// No description provided for @sendBySmsInstead.
  ///
  /// In en, this message translates to:
  /// **'Send by SMS instead'**
  String get sendBySmsInstead;

  /// No description provided for @codeSentBySms.
  ///
  /// In en, this message translates to:
  /// **'Code sent by SMS'**
  String get codeSentBySms;

  /// No description provided for @s16Regions.
  ///
  /// In en, this message translates to:
  /// **'16 regions'**
  String get s16Regions;

  /// No description provided for @s37States.
  ///
  /// In en, this message translates to:
  /// **'37 states'**
  String get s37States;

  /// No description provided for @s12Departments.
  ///
  /// In en, this message translates to:
  /// **'12 departments'**
  String get s12Departments;

  /// No description provided for @s10Regions.
  ///
  /// In en, this message translates to:
  /// **'10 regions'**
  String get s10Regions;

  /// No description provided for @s8Regions.
  ///
  /// In en, this message translates to:
  /// **'8 regions'**
  String get s8Regions;

  /// No description provided for @s5Regions.
  ///
  /// In en, this message translates to:
  /// **'5 regions'**
  String get s5Regions;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @selectState.
  ///
  /// In en, this message translates to:
  /// **'Select state'**
  String get selectState;

  /// No description provided for @selectRegion2.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get selectRegion2;

  /// No description provided for @selectDepartment2.
  ///
  /// In en, this message translates to:
  /// **'Select department'**
  String get selectDepartment2;

  /// No description provided for @s2faIsOptionalDuringSignUp.
  ///
  /// In en, this message translates to:
  /// **'2FA is optional during sign-up, but your account stays disabled until you turn it on. You can still look around.'**
  String get s2faIsOptionalDuringSignUp;

  /// No description provided for @skipForNow2.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow2;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get almostThere;

  /// No description provided for @identityConfirmedYourAccountIsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Identity confirmed. Your account is disabled until you turn on two-factor authentication.'**
  String get identityConfirmedYourAccountIsDisabled;

  /// No description provided for @phoneBvn.
  ///
  /// In en, this message translates to:
  /// **'Phone + BVN'**
  String get phoneBvn;

  /// No description provided for @s50kDay.
  ///
  /// In en, this message translates to:
  /// **'₦50k / day'**
  String get s50kDay;

  /// No description provided for @s5mDay.
  ///
  /// In en, this message translates to:
  /// **'₦5m / day'**
  String get s5mDay;

  /// No description provided for @idSelfie.
  ///
  /// In en, this message translates to:
  /// **'ID + selfie'**
  String get idSelfie;

  /// No description provided for @proofOfIncome.
  ///
  /// In en, this message translates to:
  /// **'Proof of income'**
  String get proofOfIncome;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @requiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredLabel;

  /// No description provided for @turnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get turnOn;

  /// No description provided for @bankOrMomo.
  ///
  /// In en, this message translates to:
  /// **'Bank or MoMo'**
  String get bankOrMomo;

  /// No description provided for @buyStocks.
  ///
  /// In en, this message translates to:
  /// **'Buy stocks'**
  String get buyStocks;

  /// No description provided for @buyCrypto.
  ///
  /// In en, this message translates to:
  /// **'Buy crypto'**
  String get buyCrypto;

  /// No description provided for @sendMoney.
  ///
  /// In en, this message translates to:
  /// **'Send money'**
  String get sendMoney;

  /// No description provided for @airtimePower.
  ///
  /// In en, this message translates to:
  /// **'Airtime, power'**
  String get airtimePower;

  /// No description provided for @turnOn2fa.
  ///
  /// In en, this message translates to:
  /// **'Turn on 2FA'**
  String get turnOn2fa;

  /// No description provided for @authenticator.
  ///
  /// In en, this message translates to:
  /// **'Authenticator'**
  String get authenticator;

  /// No description provided for @accountDisabled.
  ///
  /// In en, this message translates to:
  /// **'Account disabled'**
  String get accountDisabled;

  /// No description provided for @turnOnTwoFactorAuthenticationTo.
  ///
  /// In en, this message translates to:
  /// **'Turn on two-factor authentication to send, trade and withdraw.'**
  String get turnOnTwoFactorAuthenticationTo;

  /// No description provided for @turnOnTwoFactorAuthenticationTo2.
  ///
  /// In en, this message translates to:
  /// **'Turn on two-factor authentication to send money, trade, withdraw or pay bills. It takes about a minute.'**
  String get turnOnTwoFactorAuthenticationTo2;

  /// No description provided for @viewBalancesAndPrices.
  ///
  /// In en, this message translates to:
  /// **'View balances and prices'**
  String get viewBalancesAndPrices;

  /// No description provided for @receiveMoney.
  ///
  /// In en, this message translates to:
  /// **'Receive money'**
  String get receiveMoney;

  /// No description provided for @sendTradeWithdrawAndPayBills.
  ///
  /// In en, this message translates to:
  /// **'Send, trade, withdraw and pay bills'**
  String get sendTradeWithdrawAndPayBills;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @jarinaSupport.
  ///
  /// In en, this message translates to:
  /// **'Jarina Support'**
  String get jarinaSupport;

  /// No description provided for @attachAScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Attach a screenshot'**
  String get attachAScreenshot;

  /// No description provided for @attachAScreenshotOrReceipt.
  ///
  /// In en, this message translates to:
  /// **'Attach a screenshot or receipt'**
  String get attachAScreenshotOrReceipt;

  /// No description provided for @transactionReceipt.
  ///
  /// In en, this message translates to:
  /// **'Transaction receipt'**
  String get transactionReceipt;

  /// No description provided for @transactionDetails.
  ///
  /// In en, this message translates to:
  /// **'Transaction details'**
  String get transactionDetails;

  /// No description provided for @stockTrade.
  ///
  /// In en, this message translates to:
  /// **'Stock trade'**
  String get stockTrade;

  /// No description provided for @billPayment2.
  ///
  /// In en, this message translates to:
  /// **'Bill payment'**
  String get billPayment2;

  /// No description provided for @crossBorderTransfer.
  ///
  /// In en, this message translates to:
  /// **'Cross-border transfer'**
  String get crossBorderTransfer;

  /// No description provided for @parties.
  ///
  /// In en, this message translates to:
  /// **'Parties'**
  String get parties;

  /// No description provided for @accountHolder.
  ///
  /// In en, this message translates to:
  /// **'Account holder'**
  String get accountHolder;

  /// No description provided for @paymentDetails.
  ///
  /// In en, this message translates to:
  /// **'Payment details'**
  String get paymentDetails;

  /// No description provided for @corridor.
  ///
  /// In en, this message translates to:
  /// **'Corridor'**
  String get corridor;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @destination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// No description provided for @scanToVerify.
  ///
  /// In en, this message translates to:
  /// **'Scan to verify'**
  String get scanToVerify;

  /// No description provided for @scanThisCodeInTheJarina.
  ///
  /// In en, this message translates to:
  /// **'Scan this code in the Jarina app to confirm this receipt is genuine.'**
  String get scanThisCodeInTheJarina;

  /// No description provided for @thisReceiptIsElectronicallyGeneratedAnd.
  ///
  /// In en, this message translates to:
  /// **'This receipt is electronically generated and valid without a signature. Keep it for your records.'**
  String get thisReceiptIsElectronicallyGeneratedAnd;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @reportAnIssueInChat.
  ///
  /// In en, this message translates to:
  /// **'Report an issue in chat'**
  String get reportAnIssueInChat;

  /// No description provided for @tier3UpgradeOpensInAccount.
  ///
  /// In en, this message translates to:
  /// **'Tier 3 upgrade opens in Account'**
  String get tier3UpgradeOpensInAccount;

  /// No description provided for @s25Included.
  ///
  /// In en, this message translates to:
  /// **'2.5% · included'**
  String get s25Included;

  /// No description provided for @s250.
  ///
  /// In en, this message translates to:
  /// **'2.5% · ₦0'**
  String get s250;

  /// No description provided for @cryptoCustody.
  ///
  /// In en, this message translates to:
  /// **'Crypto custody'**
  String get cryptoCustody;

  /// No description provided for @quidaxSubAccount.
  ///
  /// In en, this message translates to:
  /// **'Quidax sub-account'**
  String get quidaxSubAccount;

  /// No description provided for @linked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linked;

  /// No description provided for @subAccountId.
  ///
  /// In en, this message translates to:
  /// **'Sub-account ID'**
  String get subAccountId;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @withdrawalLimit.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal limit'**
  String get withdrawalLimit;

  /// No description provided for @s10000000PerDayTier.
  ///
  /// In en, this message translates to:
  /// **'₦10,000,000 per day · Tier 2'**
  String get s10000000PerDayTier;

  /// No description provided for @cryptoServices.
  ///
  /// In en, this message translates to:
  /// **'Crypto services'**
  String get cryptoServices;

  /// No description provided for @swap.
  ///
  /// In en, this message translates to:
  /// **'Swap'**
  String get swap;

  /// No description provided for @proTrade.
  ///
  /// In en, this message translates to:
  /// **'Pro trade'**
  String get proTrade;

  /// No description provided for @deposit2.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit2;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @cashOut.
  ///
  /// In en, this message translates to:
  /// **'Cash out'**
  String get cashOut;

  /// No description provided for @wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get wallets;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @borrow.
  ///
  /// In en, this message translates to:
  /// **'Borrow'**
  String get borrow;

  /// No description provided for @buyWithBankCardOrMomo.
  ///
  /// In en, this message translates to:
  /// **'Buy with bank, card or MoMo'**
  String get buyWithBankCardOrMomo;

  /// No description provided for @depositsWithdrawals.
  ///
  /// In en, this message translates to:
  /// **'Deposits & withdrawals'**
  String get depositsWithdrawals;

  /// No description provided for @s2Pending.
  ///
  /// In en, this message translates to:
  /// **'2 pending'**
  String get s2Pending;

  /// No description provided for @openOrders.
  ///
  /// In en, this message translates to:
  /// **'Open orders'**
  String get openOrders;

  /// No description provided for @autoSwapDeposits.
  ///
  /// In en, this message translates to:
  /// **'Auto-swap deposits'**
  String get autoSwapDeposits;

  /// No description provided for @s7New.
  ///
  /// In en, this message translates to:
  /// **'7 new'**
  String get s7New;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @instantSwap.
  ///
  /// In en, this message translates to:
  /// **'Instant swap'**
  String get instantSwap;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @balance32000Usdt.
  ///
  /// In en, this message translates to:
  /// **'Balance 320.00 USDT'**
  String get balance32000Usdt;

  /// No description provided for @youGetEstimated.
  ///
  /// In en, this message translates to:
  /// **'You get (estimated)'**
  String get youGetEstimated;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get rate;

  /// No description provided for @s05Included.
  ///
  /// In en, this message translates to:
  /// **'0.5% · included'**
  String get s05Included;

  /// No description provided for @settles.
  ///
  /// In en, this message translates to:
  /// **'Settles'**
  String get settles;

  /// No description provided for @instantly.
  ///
  /// In en, this message translates to:
  /// **'Instantly'**
  String get instantly;

  /// No description provided for @quote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get quote;

  /// No description provided for @refreshesIn15s.
  ///
  /// In en, this message translates to:
  /// **'Refreshes in 15s'**
  String get refreshesIn15s;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @quoteRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Quote refreshed'**
  String get quoteRefreshed;

  /// No description provided for @theRateIsLockedFor15.
  ///
  /// In en, this message translates to:
  /// **'The rate is locked for 15 seconds once you confirm. If it expires, we fetch a fresh quote — nothing moves until you confirm with your PIN.'**
  String get theRateIsLockedFor15;

  /// No description provided for @recentSwaps.
  ///
  /// In en, this message translates to:
  /// **'Recent swaps'**
  String get recentSwaps;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @failed2.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed2;

  /// No description provided for @swapNow.
  ///
  /// In en, this message translates to:
  /// **'Swap now'**
  String get swapNow;

  /// No description provided for @amountToSwap.
  ///
  /// In en, this message translates to:
  /// **'Amount to swap'**
  String get amountToSwap;

  /// No description provided for @switchLabel.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchLabel;

  /// No description provided for @s24hHigh.
  ///
  /// In en, this message translates to:
  /// **'24h high'**
  String get s24hHigh;

  /// No description provided for @s24hLow.
  ///
  /// In en, this message translates to:
  /// **'24h low'**
  String get s24hLow;

  /// No description provided for @s24hVolume.
  ///
  /// In en, this message translates to:
  /// **'24h volume'**
  String get s24hVolume;

  /// No description provided for @limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get limit;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get market;

  /// No description provided for @priceNgn.
  ///
  /// In en, this message translates to:
  /// **'Price (NGN)'**
  String get priceNgn;

  /// No description provided for @priceUsdt.
  ///
  /// In en, this message translates to:
  /// **'Price (USDT)'**
  String get priceUsdt;

  /// No description provided for @amountBtc.
  ///
  /// In en, this message translates to:
  /// **'Amount (BTC)'**
  String get amountBtc;

  /// No description provided for @amountEth.
  ///
  /// In en, this message translates to:
  /// **'Amount (ETH)'**
  String get amountEth;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @s01Maker02Taker.
  ///
  /// In en, this message translates to:
  /// **'0.1% maker · 0.2% taker'**
  String get s01Maker02Taker;

  /// No description provided for @orderBook.
  ///
  /// In en, this message translates to:
  /// **'Order book'**
  String get orderBook;

  /// No description provided for @tapAPriceToUseIt.
  ///
  /// In en, this message translates to:
  /// **'Tap a price to use it'**
  String get tapAPriceToUseIt;

  /// No description provided for @recentTrades.
  ///
  /// In en, this message translates to:
  /// **'Recent trades'**
  String get recentTrades;

  /// No description provided for @allOrders.
  ///
  /// In en, this message translates to:
  /// **'All orders'**
  String get allOrders;

  /// No description provided for @btcNgnLimit.
  ///
  /// In en, this message translates to:
  /// **'BTC/NGN · Limit'**
  String get btcNgnLimit;

  /// No description provided for @btcNgnMarket.
  ///
  /// In en, this message translates to:
  /// **'BTC/NGN · Market'**
  String get btcNgnMarket;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @orderCancelled2.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled2;

  /// No description provided for @marketDataShownIsSampleData2.
  ///
  /// In en, this message translates to:
  /// **'Market data shown is sample data. Live tickers, k-line, order book and trades come from the Quidax API.'**
  String get marketDataShownIsSampleData2;

  /// No description provided for @fillsNowAtTheBestAvailable.
  ///
  /// In en, this message translates to:
  /// **'Fills now at the best available price ≈ ₦98,000,000'**
  String get fillsNowAtTheBestAvailable;

  /// No description provided for @buyBtc.
  ///
  /// In en, this message translates to:
  /// **'Buy BTC'**
  String get buyBtc;

  /// No description provided for @sellBtc.
  ///
  /// In en, this message translates to:
  /// **'Sell BTC'**
  String get sellBtc;

  /// No description provided for @notEnoughBalanceForThisOrder.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance for this order.'**
  String get notEnoughBalanceForThisOrder;

  /// No description provided for @noOpenOrdersForEthUsdt.
  ///
  /// In en, this message translates to:
  /// **'No open orders for ETH/USDT'**
  String get noOpenOrdersForEthUsdt;

  /// No description provided for @cryptoWallets.
  ///
  /// In en, this message translates to:
  /// **'Crypto wallets'**
  String get cryptoWallets;

  /// No description provided for @currencyWallets.
  ///
  /// In en, this message translates to:
  /// **'Currency wallets'**
  String get currencyWallets;

  /// No description provided for @createYourUsername.
  ///
  /// In en, this message translates to:
  /// **'Create your username'**
  String get createYourUsername;

  /// No description provided for @yourUsernameLetsOtherJarinaUsers.
  ///
  /// In en, this message translates to:
  /// **'Your @username lets other Jarina users send you money, crypto and stocks — no account number needed.'**
  String get yourUsernameLetsOtherJarinaUsers;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @suggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// No description provided for @s320CharactersLettersNumbersOr.
  ///
  /// In en, this message translates to:
  /// **'3–20 characters · letters, numbers, _ or .'**
  String get s320CharactersLettersNumbersOr;

  /// No description provided for @atLeast3Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 3 characters'**
  String get atLeast3Characters;

  /// No description provided for @startWithALetter.
  ///
  /// In en, this message translates to:
  /// **'Start with a letter'**
  String get startWithALetter;

  /// No description provided for @receiveNairaCediCfa.
  ///
  /// In en, this message translates to:
  /// **'Receive Naira, Cedi & CFA'**
  String get receiveNairaCediCfa;

  /// No description provided for @receiveCryptoFreeInstant.
  ///
  /// In en, this message translates to:
  /// **'Receive crypto, free & instant'**
  String get receiveCryptoFreeInstant;

  /// No description provided for @receiveGiftedStocks.
  ///
  /// In en, this message translates to:
  /// **'Receive gifted stocks'**
  String get receiveGiftedStocks;

  /// No description provided for @yourUsernameIsPublicToPeople.
  ///
  /// In en, this message translates to:
  /// **'Your username is public to people who search for you. Your phone number and balance stay private. You can change it once every 30 days in More › Account.'**
  String get yourUsernameIsPublicToPeople;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction history'**
  String get transactionHistory;

  /// No description provided for @allWallets.
  ///
  /// In en, this message translates to:
  /// **'All wallets'**
  String get allWallets;

  /// No description provided for @totalCryptoBalance.
  ///
  /// In en, this message translates to:
  /// **'Total crypto balance'**
  String get totalCryptoBalance;

  /// No description provided for @s6710318Wallets.
  ///
  /// In en, this message translates to:
  /// **'≈ \$671.03 · 18 wallets'**
  String get s6710318Wallets;

  /// No description provided for @hideZeroBalances.
  ///
  /// In en, this message translates to:
  /// **'Hide zero balances'**
  String get hideZeroBalances;

  /// No description provided for @s0024000InOrders.
  ///
  /// In en, this message translates to:
  /// **'0.024000 in orders'**
  String get s0024000InOrders;

  /// No description provided for @balancesAndAddressesComeFromYour.
  ///
  /// In en, this message translates to:
  /// **'Balances and addresses come from your Quidax sub-account.'**
  String get balancesAndAddressesComeFromYour;

  /// No description provided for @inOpenOrders.
  ///
  /// In en, this message translates to:
  /// **'In open orders'**
  String get inOpenOrders;

  /// No description provided for @trade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get trade;

  /// No description provided for @depositAddress.
  ///
  /// In en, this message translates to:
  /// **'Deposit address'**
  String get depositAddress;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @addressCopied2.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get addressCopied2;

  /// No description provided for @newAddress.
  ///
  /// In en, this message translates to:
  /// **'New address'**
  String get newAddress;

  /// No description provided for @newUsdtAddressGenerated.
  ///
  /// In en, this message translates to:
  /// **'New USDT address generated'**
  String get newUsdtAddressGenerated;

  /// No description provided for @newWalletAddressGenerated.
  ///
  /// In en, this message translates to:
  /// **'New wallet address generated'**
  String get newWalletAddressGenerated;

  /// No description provided for @sendOnlyUsdtOnTronTrc.
  ///
  /// In en, this message translates to:
  /// **'Send only USDT on TRON (TRC-20) to this address. Deposits are credited after network confirmations.'**
  String get sendOnlyUsdtOnTronTrc;

  /// No description provided for @memoTag100839414.
  ///
  /// In en, this message translates to:
  /// **'Memo / tag: 100839414'**
  String get memoTag100839414;

  /// No description provided for @includeThisMemoOrYourDeposit.
  ///
  /// In en, this message translates to:
  /// **'Include this memo or your deposit will be lost.'**
  String get includeThisMemoOrYourDeposit;

  /// No description provided for @usdtHistory.
  ///
  /// In en, this message translates to:
  /// **'USDT history'**
  String get usdtHistory;

  /// No description provided for @noDepositsOrWithdrawalsYet.
  ///
  /// In en, this message translates to:
  /// **'No deposits or withdrawals yet'**
  String get noDepositsOrWithdrawalsYet;

  /// No description provided for @currentAddress.
  ///
  /// In en, this message translates to:
  /// **'Current address'**
  String get currentAddress;

  /// No description provided for @previousAddressStillActive.
  ///
  /// In en, this message translates to:
  /// **'Previous address · still active'**
  String get previousAddressStillActive;

  /// No description provided for @withdrawal.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get withdrawal;

  /// No description provided for @successful.
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get successful;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @confirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming'**
  String get confirming;

  /// No description provided for @onHold.
  ///
  /// In en, this message translates to:
  /// **'On hold'**
  String get onHold;

  /// No description provided for @filled.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get filled;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @partiallyFilled2.
  ///
  /// In en, this message translates to:
  /// **'Partially filled'**
  String get partiallyFilled2;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @repaid.
  ///
  /// In en, this message translates to:
  /// **'Repaid'**
  String get repaid;

  /// No description provided for @s1Of3NetworkConfirmations.
  ///
  /// In en, this message translates to:
  /// **'1 of 3 network confirmations'**
  String get s1Of3NetworkConfirmations;

  /// No description provided for @failedTheAmlScreeningContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Failed the AML screening. Contact support to arrange a return.'**
  String get failedTheAmlScreeningContactSupport;

  /// No description provided for @heldForARoutineComplianceReview.
  ///
  /// In en, this message translates to:
  /// **'Held for a routine compliance review. Usually cleared within 24 hours.'**
  String get heldForARoutineComplianceReview;

  /// No description provided for @cancelWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Cancel withdrawal'**
  String get cancelWithdrawal;

  /// No description provided for @withdrawalCancelled2.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal cancelled'**
  String get withdrawalCancelled2;

  /// No description provided for @cancelledByYouFundsReturnedTo.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by you. Funds returned to your wallet.'**
  String get cancelledByYouFundsReturnedTo;

  /// No description provided for @cashOutToGtbank.
  ///
  /// In en, this message translates to:
  /// **'Cash out to GTBank'**
  String get cashOutToGtbank;

  /// No description provided for @withdrawUsdt.
  ///
  /// In en, this message translates to:
  /// **'Withdraw USDT'**
  String get withdrawUsdt;

  /// No description provided for @externalAddress.
  ///
  /// In en, this message translates to:
  /// **'External address'**
  String get externalAddress;

  /// No description provided for @jarinaUser.
  ///
  /// In en, this message translates to:
  /// **'Jarina user'**
  String get jarinaUser;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @addressPasted.
  ///
  /// In en, this message translates to:
  /// **'Address pasted'**
  String get addressPasted;

  /// No description provided for @memoTag2.
  ///
  /// In en, this message translates to:
  /// **'Memo / tag'**
  String get memoTag2;

  /// No description provided for @requiredByMostExchanges.
  ///
  /// In en, this message translates to:
  /// **'Required by most exchanges'**
  String get requiredByMostExchanges;

  /// No description provided for @usernameOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Username or phone'**
  String get usernameOrPhone;

  /// No description provided for @transferFee2.
  ///
  /// In en, this message translates to:
  /// **'Transfer fee'**
  String get transferFee2;

  /// No description provided for @freeInstant.
  ///
  /// In en, this message translates to:
  /// **'Free · instant'**
  String get freeInstant;

  /// No description provided for @networkFee.
  ///
  /// In en, this message translates to:
  /// **'Network fee'**
  String get networkFee;

  /// No description provided for @amountIsMoreThanYourBalance.
  ///
  /// In en, this message translates to:
  /// **'Amount is more than your balance.'**
  String get amountIsMoreThanYourBalance;

  /// No description provided for @withdraw1000Usdt.
  ///
  /// In en, this message translates to:
  /// **'Withdraw 10.00 USDT'**
  String get withdraw1000Usdt;

  /// No description provided for @withdrawCrypto.
  ///
  /// In en, this message translates to:
  /// **'Withdraw crypto'**
  String get withdrawCrypto;

  /// No description provided for @chooseTheCoinToSendOut.
  ///
  /// In en, this message translates to:
  /// **'Choose the coin to send out.'**
  String get chooseTheCoinToSendOut;

  /// No description provided for @depositCrypto.
  ///
  /// In en, this message translates to:
  /// **'Deposit crypto'**
  String get depositCrypto;

  /// No description provided for @chooseTheCoinToReceiveEach.
  ///
  /// In en, this message translates to:
  /// **'Choose the coin to receive. Each coin has its own address.'**
  String get chooseTheCoinToReceiveEach;

  /// No description provided for @s40Filled.
  ///
  /// In en, this message translates to:
  /// **'40% filled'**
  String get s40Filled;

  /// No description provided for @placeANewOrder.
  ///
  /// In en, this message translates to:
  /// **'Place a new order'**
  String get placeANewOrder;

  /// No description provided for @noOrdersHere.
  ///
  /// In en, this message translates to:
  /// **'No orders here'**
  String get noOrdersHere;

  /// No description provided for @cashOutToBank.
  ///
  /// In en, this message translates to:
  /// **'Cash out to bank'**
  String get cashOutToBank;

  /// No description provided for @sellCryptoAndReceiveNairaIn.
  ///
  /// In en, this message translates to:
  /// **'Sell crypto and receive Naira in any Nigerian bank account, usually within minutes.'**
  String get sellCryptoAndReceiveNairaIn;

  /// No description provided for @available32000UsdtLimits10.
  ///
  /// In en, this message translates to:
  /// **'Available 320.00 USDT · limits 10.00 USDT to ₦10,000,000 per transaction'**
  String get available32000UsdtLimits10;

  /// No description provided for @savedGtbank4821.
  ///
  /// In en, this message translates to:
  /// **'Saved: GTBank ••4821'**
  String get savedGtbank4821;

  /// No description provided for @enterA10DigitAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a 10-digit account number'**
  String get enterA10DigitAccountNumber;

  /// No description provided for @youReceive2.
  ///
  /// In en, this message translates to:
  /// **'You receive'**
  String get youReceive2;

  /// No description provided for @belowTheMinimumForThisCoin.
  ///
  /// In en, this message translates to:
  /// **'Below the minimum for this coin.'**
  String get belowTheMinimumForThisCoin;

  /// No description provided for @aboveThe10000000Limit.
  ///
  /// In en, this message translates to:
  /// **'Above the ₦10,000,000 limit per transaction.'**
  String get aboveThe10000000Limit;

  /// No description provided for @payoutsGoOnlyToBankAccounts.
  ///
  /// In en, this message translates to:
  /// **'Payouts go only to bank accounts in your name. You\'\'ll confirm with your PIN and a 2FA code.'**
  String get payoutsGoOnlyToBankAccounts;

  /// No description provided for @cashOut76858.
  ///
  /// In en, this message translates to:
  /// **'Cash out ₦76,858'**
  String get cashOut76858;

  /// No description provided for @payWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get payWith;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @mobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile money'**
  String get mobileMoney;

  /// No description provided for @youPay.
  ///
  /// In en, this message translates to:
  /// **'You pay'**
  String get youPay;

  /// No description provided for @limits20005000000.
  ///
  /// In en, this message translates to:
  /// **'Limits ₦2,000 – ₦5,000,000 per purchase'**
  String get limits20005000000;

  /// No description provided for @limitsGh50Gh20000.
  ///
  /// In en, this message translates to:
  /// **'Limits GH₵50 – GH₵20,000 per purchase'**
  String get limitsGh50Gh20000;

  /// No description provided for @creditedTo.
  ///
  /// In en, this message translates to:
  /// **'Credited to'**
  String get creditedTo;

  /// No description provided for @yourUsdtWallet.
  ///
  /// In en, this message translates to:
  /// **'Your USDT wallet'**
  String get yourUsdtWallet;

  /// No description provided for @youLlGetAOneTime.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ll get a one-time account to pay into. Crypto is credited as soon as your transfer lands.'**
  String get youLlGetAOneTime;

  /// No description provided for @visaMastercardAndVerveCardsIn.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard and Verve cards in your name. Your bank may ask for a one-time code.'**
  String get visaMastercardAndVerveCardsIn;

  /// No description provided for @approveThePaymentPromptOnYour.
  ///
  /// In en, this message translates to:
  /// **'Approve the payment prompt on your phone. Crypto is credited once the payment is confirmed.'**
  String get approveThePaymentPromptOnYour;

  /// No description provided for @momoNumber.
  ///
  /// In en, this message translates to:
  /// **'MoMo number'**
  String get momoNumber;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @otpFromMtnMomo.
  ///
  /// In en, this message translates to:
  /// **'OTP from MTN MoMo'**
  String get otpFromMtnMomo;

  /// No description provided for @s6DigitCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get s6DigitCode;

  /// No description provided for @enterTheCodeSentToYour.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to your phone'**
  String get enterTheCodeSentToYour;

  /// No description provided for @mobileMoneyNumberVerified.
  ///
  /// In en, this message translates to:
  /// **'Mobile money number verified'**
  String get mobileMoneyNumberVerified;

  /// No description provided for @buyUsdt.
  ///
  /// In en, this message translates to:
  /// **'Buy USDT'**
  String get buyUsdt;

  /// No description provided for @deposits.
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get deposits;

  /// No description provided for @withdrawals.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals'**
  String get withdrawals;

  /// No description provided for @swaps.
  ///
  /// In en, this message translates to:
  /// **'Swaps'**
  String get swaps;

  /// No description provided for @buySell.
  ///
  /// In en, this message translates to:
  /// **'Buy/Sell'**
  String get buySell;

  /// No description provided for @nothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingHereYet;

  /// No description provided for @statusesUpdateLiveDepositsShowTheir.
  ///
  /// In en, this message translates to:
  /// **'Statuses update live: deposits show their network confirmations, deposits held for review show On hold, and pending withdrawals can be cancelled until they are broadcast.'**
  String get statusesUpdateLiveDepositsShowTheir;

  /// No description provided for @automaticallyConvertCryptoYouReceiveSo.
  ///
  /// In en, this message translates to:
  /// **'Automatically convert crypto you receive, so volatile coins become stable value the moment they land.'**
  String get automaticallyConvertCryptoYouReceiveSo;

  /// No description provided for @autoSwap.
  ///
  /// In en, this message translates to:
  /// **'Auto-swap'**
  String get autoSwap;

  /// No description provided for @convertNewDepositsAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Convert new deposits automatically'**
  String get convertNewDepositsAutomatically;

  /// No description provided for @convertTo2.
  ///
  /// In en, this message translates to:
  /// **'Convert to'**
  String get convertTo2;

  /// No description provided for @coinsToConvert.
  ///
  /// In en, this message translates to:
  /// **'Coins to convert'**
  String get coinsToConvert;

  /// No description provided for @conversionsUseTheInstantSwapRate.
  ///
  /// In en, this message translates to:
  /// **'Conversions use the instant-swap rate at the moment each deposit confirms. Each one gets its own receipt.'**
  String get conversionsUseTheInstantSwapRate;

  /// No description provided for @getNairaWithoutSellingYourCrypto.
  ///
  /// In en, this message translates to:
  /// **'Get Naira without selling your crypto. Your coins are held as collateral and returned when you repay.'**
  String get getNairaWithoutSellingYourCrypto;

  /// No description provided for @collateral.
  ///
  /// In en, this message translates to:
  /// **'Collateral'**
  String get collateral;

  /// No description provided for @collateralAmount.
  ///
  /// In en, this message translates to:
  /// **'Collateral amount'**
  String get collateralAmount;

  /// No description provided for @loanToValue.
  ///
  /// In en, this message translates to:
  /// **'Loan-to-value'**
  String get loanToValue;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @s30Days.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get s30Days;

  /// No description provided for @s60Days.
  ///
  /// In en, this message translates to:
  /// **'60 days'**
  String get s60Days;

  /// No description provided for @s90Days.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get s90Days;

  /// No description provided for @youBorrow.
  ///
  /// In en, this message translates to:
  /// **'You borrow'**
  String get youBorrow;

  /// No description provided for @interest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get interest;

  /// No description provided for @s35PerMonth0.
  ///
  /// In en, this message translates to:
  /// **'3.5% per month · ₦0'**
  String get s35PerMonth0;

  /// No description provided for @totalToRepay.
  ///
  /// In en, this message translates to:
  /// **'Total to repay'**
  String get totalToRepay;

  /// No description provided for @liquidationPrice.
  ///
  /// In en, this message translates to:
  /// **'Liquidation price'**
  String get liquidationPrice;

  /// No description provided for @s46117647PerBtc.
  ///
  /// In en, this message translates to:
  /// **'₦46,117,647 per BTC'**
  String get s46117647PerBtc;

  /// No description provided for @paidInto.
  ///
  /// In en, this message translates to:
  /// **'Paid into'**
  String get paidInto;

  /// No description provided for @ifTheValueOfYourCollateral.
  ///
  /// In en, this message translates to:
  /// **'If the value of your collateral falls and your loan-to-value reaches 85%, part of your collateral is sold to repay the loan.'**
  String get ifTheValueOfYourCollateral;

  /// No description provided for @borrow78400.
  ///
  /// In en, this message translates to:
  /// **'Borrow ₦78,400'**
  String get borrow78400;

  /// No description provided for @activeLoan.
  ///
  /// In en, this message translates to:
  /// **'Active loan'**
  String get activeLoan;

  /// No description provided for @collateral0002000BtcDue03.
  ///
  /// In en, this message translates to:
  /// **'Collateral 0.002000 BTC · due 03 Nov 2026 · repay ₦81,144'**
  String get collateral0002000BtcDue03;

  /// No description provided for @s40LiquidationAt85.
  ///
  /// In en, this message translates to:
  /// **'40% · liquidation at 85%'**
  String get s40LiquidationAt85;

  /// No description provided for @repay.
  ///
  /// In en, this message translates to:
  /// **'Repay'**
  String get repay;

  /// No description provided for @addCollateral.
  ///
  /// In en, this message translates to:
  /// **'Add collateral'**
  String get addCollateral;

  /// No description provided for @topUpCollateralToLowerYour.
  ///
  /// In en, this message translates to:
  /// **'Top up collateral to lower your LTV'**
  String get topUpCollateralToLowerYour;

  /// No description provided for @notEnoughInYourNairaWallet.
  ///
  /// In en, this message translates to:
  /// **'Not enough in your Naira wallet'**
  String get notEnoughInYourNairaWallet;

  /// No description provided for @loanRepaidCollateralReleased.
  ///
  /// In en, this message translates to:
  /// **'Loan repaid · collateral released'**
  String get loanRepaidCollateralReleased;

  /// No description provided for @loanRepaid.
  ///
  /// In en, this message translates to:
  /// **'Loan repaid'**
  String get loanRepaid;

  /// No description provided for @collateralReleased.
  ///
  /// In en, this message translates to:
  /// **'Collateral released'**
  String get collateralReleased;

  /// No description provided for @depositConfirming.
  ///
  /// In en, this message translates to:
  /// **'Deposit confirming'**
  String get depositConfirming;

  /// No description provided for @s00012Btc1Of3.
  ///
  /// In en, this message translates to:
  /// **'0.0012 BTC · 1 of 3 confirmations'**
  String get s00012Btc1Of3;

  /// No description provided for @swapCompleted.
  ///
  /// In en, this message translates to:
  /// **'Swap completed'**
  String get swapCompleted;

  /// No description provided for @orderFilled2.
  ///
  /// In en, this message translates to:
  /// **'Order filled'**
  String get orderFilled2;

  /// No description provided for @buy120UsdtAt1549.
  ///
  /// In en, this message translates to:
  /// **'Buy 120 USDT at ₦1,549'**
  String get buy120UsdtAt1549;

  /// No description provided for @sell0001000BtcAt98.
  ///
  /// In en, this message translates to:
  /// **'Sell 0.001000 BTC at ₦98,000,000'**
  String get sell0001000BtcAt98;

  /// No description provided for @depositSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Deposit successful'**
  String get depositSuccessful;

  /// No description provided for @s120UsdtIsNowAvailable.
  ///
  /// In en, this message translates to:
  /// **'120 USDT is now available'**
  String get s120UsdtIsNowAvailable;

  /// No description provided for @depositOnHold.
  ///
  /// In en, this message translates to:
  /// **'Deposit on hold'**
  String get depositOnHold;

  /// No description provided for @s005EthComplianceReview.
  ///
  /// In en, this message translates to:
  /// **'0.05 ETH · compliance review'**
  String get s005EthComplianceReview;

  /// No description provided for @withdrawalSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal successful'**
  String get withdrawalSuccessful;

  /// No description provided for @s00005BtcSent.
  ///
  /// In en, this message translates to:
  /// **'0.0005 BTC sent'**
  String get s00005BtcSent;

  /// No description provided for @swapFailed.
  ///
  /// In en, this message translates to:
  /// **'Swap failed'**
  String get swapFailed;

  /// No description provided for @quoteExpiredNoFundsMoved.
  ///
  /// In en, this message translates to:
  /// **'Quote expired · no funds moved'**
  String get quoteExpiredNoFundsMoved;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get allCaughtUp;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @yourBtcIsInYourWallet.
  ///
  /// In en, this message translates to:
  /// **'Your BTC is in your wallet.'**
  String get yourBtcIsInYourWallet;

  /// No description provided for @yourLimitOrderIsOnThe.
  ///
  /// In en, this message translates to:
  /// **'Your limit order is on the order book. We\'\'ll notify you when it fills.'**
  String get yourLimitOrderIsOnThe;

  /// No description provided for @yourOrderFilledAtTheBest.
  ///
  /// In en, this message translates to:
  /// **'Your order filled at the best available price.'**
  String get yourOrderFilledAtTheBest;

  /// No description provided for @itUsuallyArrivesWithinAFew.
  ///
  /// In en, this message translates to:
  /// **'It usually arrives within a few minutes. You can cancel it until it is broadcast.'**
  String get itUsuallyArrivesWithinAFew;

  /// No description provided for @withdrawalSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal submitted'**
  String get withdrawalSubmitted;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @zainabReceivedItInstantly.
  ///
  /// In en, this message translates to:
  /// **'@zainab received it instantly.'**
  String get zainabReceivedItInstantly;

  /// No description provided for @sentToZainab.
  ///
  /// In en, this message translates to:
  /// **'Sent to @zainab'**
  String get sentToZainab;

  /// No description provided for @cashOutOnItsWay.
  ///
  /// In en, this message translates to:
  /// **'Cash-out on its way'**
  String get cashOutOnItsWay;

  /// No description provided for @s76858IsBeingPaidTo.
  ///
  /// In en, this message translates to:
  /// **'₦76,858 is being paid to GTBank · AMINU BELLO.'**
  String get s76858IsBeingPaidTo;

  /// No description provided for @payToComplete.
  ///
  /// In en, this message translates to:
  /// **'Pay to complete'**
  String get payToComplete;

  /// No description provided for @transfer10000ToWemaBank.
  ///
  /// In en, this message translates to:
  /// **'Transfer ₦10,000 to Wema Bank · 7820 451 936 · Jarina/Quidax within 30 minutes. USDT is credited as soon as it lands.'**
  String get transfer10000ToWemaBank;

  /// No description provided for @purchaseComplete.
  ///
  /// In en, this message translates to:
  /// **'Purchase complete'**
  String get purchaseComplete;

  /// No description provided for @yourUsdtIsInYourWallet.
  ///
  /// In en, this message translates to:
  /// **'Your USDT is in your wallet.'**
  String get yourUsdtIsInYourWallet;

  /// No description provided for @loanApproved.
  ///
  /// In en, this message translates to:
  /// **'Loan approved'**
  String get loanApproved;

  /// No description provided for @s78400IsInYourNaira.
  ///
  /// In en, this message translates to:
  /// **'₦78,400 is in your Naira wallet. Repay by 03 Nov 2026 to get your BTC back.'**
  String get s78400IsInYourNaira;

  /// No description provided for @orderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get orderPlaced;

  /// No description provided for @s5000Usdt0000787Btc.
  ///
  /// In en, this message translates to:
  /// **'50.00 USDT → 0.000787 BTC'**
  String get s5000Usdt0000787Btc;

  /// No description provided for @cryptoBackedLoan.
  ///
  /// In en, this message translates to:
  /// **'Crypto-backed loan'**
  String get cryptoBackedLoan;

  /// No description provided for @requestedUsdtPurchase.
  ///
  /// In en, this message translates to:
  /// **'Requested USDT purchase'**
  String get requestedUsdtPurchase;

  /// No description provided for @cashedOutUsdt.
  ///
  /// In en, this message translates to:
  /// **'Cashed out USDT'**
  String get cashedOutUsdt;

  /// No description provided for @buyBtcNgnLimit.
  ///
  /// In en, this message translates to:
  /// **'Buy BTC/NGN · Limit'**
  String get buyBtcNgnLimit;

  /// No description provided for @sellBtcNgnMarket.
  ///
  /// In en, this message translates to:
  /// **'Sell BTC/NGN · Market'**
  String get sellBtcNgnMarket;

  /// No description provided for @swappedUsdtToBtc.
  ///
  /// In en, this message translates to:
  /// **'Swapped USDT to BTC'**
  String get swappedUsdtToBtc;

  /// No description provided for @withdrewUsdt.
  ///
  /// In en, this message translates to:
  /// **'Withdrew USDT'**
  String get withdrewUsdt;

  /// No description provided for @boughtUsdt.
  ///
  /// In en, this message translates to:
  /// **'Bought USDT'**
  String get boughtUsdt;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get due;

  /// No description provided for @paid2.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid2;

  /// No description provided for @method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  /// No description provided for @into.
  ///
  /// In en, this message translates to:
  /// **'Into'**
  String get into;

  /// No description provided for @s30Minutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get s30Minutes;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @sold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get sold;

  /// No description provided for @jarinaInternal.
  ///
  /// In en, this message translates to:
  /// **'Jarina (internal)'**
  String get jarinaInternal;

  /// No description provided for @free2.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free2;

  /// No description provided for @pair.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get pair;

  /// No description provided for @orderType.
  ///
  /// In en, this message translates to:
  /// **'Order type'**
  String get orderType;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @network.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get network;

  /// No description provided for @recipientGets.
  ///
  /// In en, this message translates to:
  /// **'Recipient gets'**
  String get recipientGets;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @fee.
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get fee;

  /// No description provided for @todayInstantSwap.
  ///
  /// In en, this message translates to:
  /// **'Today · instant swap'**
  String get todayInstantSwap;

  /// No description provided for @todayBankTransferAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Today · bank transfer · awaiting payment'**
  String get todayBankTransferAwaitingPayment;

  /// No description provided for @todayCollateralReleased.
  ///
  /// In en, this message translates to:
  /// **'Today · collateral released'**
  String get todayCollateralReleased;

  /// No description provided for @s0002000BtcCollateral.
  ///
  /// In en, this message translates to:
  /// **'0.002000 BTC collateral'**
  String get s0002000BtcCollateral;

  /// No description provided for @buyUsdtBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Buy USDT · bank transfer'**
  String get buyUsdtBankTransfer;

  /// No description provided for @buyUsdtCard.
  ///
  /// In en, this message translates to:
  /// **'Buy USDT · card'**
  String get buyUsdtCard;

  /// No description provided for @todayWaitingFor10000.
  ///
  /// In en, this message translates to:
  /// **'Today · waiting for ₦10,000'**
  String get todayWaitingFor10000;

  /// No description provided for @whereDoYouLive.
  ///
  /// In en, this message translates to:
  /// **'Where do you live?'**
  String get whereDoYouLive;

  /// No description provided for @chooseYourCountryWeLlShow.
  ///
  /// In en, this message translates to:
  /// **'Choose your country. We\'\'ll show the languages available there.'**
  String get chooseYourCountryWeLlShow;

  /// No description provided for @step1Of2.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2'**
  String get step1Of2;

  /// No description provided for @step2Of2.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2'**
  String get step2Of2;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseYourLanguage;

  /// No description provided for @jarinaWillUseThisLanguageOn.
  ///
  /// In en, this message translates to:
  /// **'Jarina will use this language on every screen. You can change it later in More.'**
  String get jarinaWillUseThisLanguageOn;

  /// No description provided for @jarinaIsAvailableInEnglishIn.
  ///
  /// In en, this message translates to:
  /// **'Jarina is available in English in your country.'**
  String get jarinaIsAvailableInEnglishIn;

  /// No description provided for @beninRepublic.
  ///
  /// In en, this message translates to:
  /// **'Benin Republic'**
  String get beninRepublic;

  /// No description provided for @togo.
  ///
  /// In en, this message translates to:
  /// **'Togo'**
  String get togo;

  /// No description provided for @hausa.
  ///
  /// In en, this message translates to:
  /// **'Hausa'**
  String get hausa;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @harshenHausa.
  ///
  /// In en, this message translates to:
  /// **'Harshen Hausa'**
  String get harshenHausa;

  /// No description provided for @languagesInNigeria.
  ///
  /// In en, this message translates to:
  /// **'Languages in Nigeria'**
  String get languagesInNigeria;

  /// No description provided for @languagesInNiger.
  ///
  /// In en, this message translates to:
  /// **'Languages in Niger'**
  String get languagesInNiger;

  /// No description provided for @languagesInGhana.
  ///
  /// In en, this message translates to:
  /// **'Languages in Ghana'**
  String get languagesInGhana;

  /// No description provided for @languagesInCameroon.
  ///
  /// In en, this message translates to:
  /// **'Languages in Cameroon'**
  String get languagesInCameroon;

  /// No description provided for @languagesInBeninRepublic.
  ///
  /// In en, this message translates to:
  /// **'Languages in Benin Republic'**
  String get languagesInBeninRepublic;

  /// No description provided for @languagesInTogo.
  ///
  /// In en, this message translates to:
  /// **'Languages in Togo'**
  String get languagesInTogo;

  /// No description provided for @otherLanguages.
  ///
  /// In en, this message translates to:
  /// **'Other languages'**
  String get otherLanguages;

  /// No description provided for @everyScreenIsTranslatedTheHausa.
  ///
  /// In en, this message translates to:
  /// **'Every screen is translated. The Hausa and French text should be reviewed by native speakers before launch.'**
  String get everyScreenIsTranslatedTheHausa;

  /// No description provided for @stocksCryptoAndCrossBorderMoney.
  ///
  /// In en, this message translates to:
  /// **'Stocks, crypto and cross-border money — in one place.'**
  String get stocksCryptoAndCrossBorderMoney;

  /// No description provided for @ngxShares.
  ///
  /// In en, this message translates to:
  /// **'NGX shares'**
  String get ngxShares;

  /// No description provided for @bitcoinStablecoins.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin & stablecoins'**
  String get bitcoinStablecoins;

  /// No description provided for @nairaCediCfaWallets.
  ///
  /// In en, this message translates to:
  /// **'Naira, Cedi & CFA wallets'**
  String get nairaCediCfaWallets;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @startWithYourMobileNumberWe.
  ///
  /// In en, this message translates to:
  /// **'Start with your mobile number. We\'\'ll send a one-time code to verify it.'**
  String get startWithYourMobileNumberWe;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumber;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @byContinuingYouAgreeToJarina.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to Jarina\'\'s Terms of Service and Privacy Policy.'**
  String get byContinuingYouAgreeToJarina;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @countryCode.
  ///
  /// In en, this message translates to:
  /// **'Country code'**
  String get countryCode;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @logInWithYourMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Log in with your mobile number.'**
  String get logInWithYourMobileNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @verifyYourNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get verifyYourNumber;

  /// No description provided for @enterThe6DigitCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent by SMS to +234 801 234 5678.'**
  String get enterThe6DigitCodeSent;

  /// No description provided for @resendCodeIn028.
  ///
  /// In en, this message translates to:
  /// **'Resend code in 0:28'**
  String get resendCodeIn028;

  /// No description provided for @callMeInstead.
  ///
  /// In en, this message translates to:
  /// **'Call me instead'**
  String get callMeInstead;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @twoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication'**
  String get twoFactorAuthentication;

  /// No description provided for @openYourAuthenticatorAppAndEnter.
  ///
  /// In en, this message translates to:
  /// **'Open your authenticator app and enter the 6-digit code for Jarina.'**
  String get openYourAuthenticatorAppAndEnter;

  /// No description provided for @newDeviceDetectedThisLoginIs.
  ///
  /// In en, this message translates to:
  /// **'New device detected. This login is protected by 2FA.'**
  String get newDeviceDetectedThisLoginIs;

  /// No description provided for @useABackupCodeInstead.
  ///
  /// In en, this message translates to:
  /// **'Use a backup code instead'**
  String get useABackupCodeInstead;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @step1Of6.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 6'**
  String get step1Of6;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal details'**
  String get personalDetails;

  /// No description provided for @enterYourNameExactlyAsIt.
  ///
  /// In en, this message translates to:
  /// **'Enter your name exactly as it appears on your ID.'**
  String get enterYourNameExactlyAsIt;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @middleNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Middle name (optional)'**
  String get middleNameOptional;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get dateOfBirth;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @ddMmYyyy.
  ///
  /// In en, this message translates to:
  /// **'DD / MM / YYYY'**
  String get ddMmYyyy;

  /// No description provided for @youExampleCom.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get youExampleCom;

  /// No description provided for @verifyYourIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get verifyYourIdentity;

  /// No description provided for @nigerianResidentsVerifyWithBvnOr.
  ///
  /// In en, this message translates to:
  /// **'Nigerian residents verify with BVN or NIN. Your details are checked against the official registry.'**
  String get nigerianResidentsVerifyWithBvnOr;

  /// No description provided for @passport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get passport;

  /// No description provided for @bankVerificationNumberBvn.
  ///
  /// In en, this message translates to:
  /// **'Bank Verification Number (BVN)'**
  String get bankVerificationNumberBvn;

  /// No description provided for @dial5650OnYourRegistered.
  ///
  /// In en, this message translates to:
  /// **'Dial *565*0# on your registered line to get your BVN. We never see your bank balance.'**
  String get dial5650OnYourRegistered;

  /// No description provided for @s11Digits.
  ///
  /// In en, this message translates to:
  /// **'11 digits'**
  String get s11Digits;

  /// No description provided for @nationalIdentificationNumberNin.
  ///
  /// In en, this message translates to:
  /// **'National Identification Number (NIN)'**
  String get nationalIdentificationNumberNin;

  /// No description provided for @passportNumber2.
  ///
  /// In en, this message translates to:
  /// **'Passport number'**
  String get passportNumber2;

  /// No description provided for @frontOfId.
  ///
  /// In en, this message translates to:
  /// **'Front of ID'**
  String get frontOfId;

  /// No description provided for @useYourCameraAvoidGlare.
  ///
  /// In en, this message translates to:
  /// **'Use your camera — avoid glare'**
  String get useYourCameraAvoidGlare;

  /// No description provided for @backOfId.
  ///
  /// In en, this message translates to:
  /// **'Back of ID'**
  String get backOfId;

  /// No description provided for @capturedTapToRetake.
  ///
  /// In en, this message translates to:
  /// **'Captured · tap to retake'**
  String get capturedTapToRetake;

  /// No description provided for @useAGovernmentIssuedIdFrom.
  ///
  /// In en, this message translates to:
  /// **'Use a government-issued ID from your country of residence.'**
  String get useAGovernmentIssuedIdFrom;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @voterCard.
  ///
  /// In en, this message translates to:
  /// **'Voter card'**
  String get voterCard;

  /// No description provided for @nationalIdNumber2.
  ///
  /// In en, this message translates to:
  /// **'National ID number'**
  String get nationalIdNumber2;

  /// No description provided for @voterCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Voter card number'**
  String get voterCardNumber;

  /// No description provided for @livenessCheck.
  ///
  /// In en, this message translates to:
  /// **'Liveness check'**
  String get livenessCheck;

  /// No description provided for @takeAQuickSelfieSoWe.
  ///
  /// In en, this message translates to:
  /// **'Take a quick selfie so we can confirm it\'\'s really you and match it to your ID.'**
  String get takeAQuickSelfieSoWe;

  /// No description provided for @goodLightNoHatOrGlasses.
  ///
  /// In en, this message translates to:
  /// **'Good light · no hat or glasses · slowly turn your head left, then right'**
  String get goodLightNoHatOrGlasses;

  /// No description provided for @livenessConfirmedFaceMatchedToYour.
  ///
  /// In en, this message translates to:
  /// **'Liveness confirmed. Face matched to your ID.'**
  String get livenessConfirmedFaceMatchedToYour;

  /// No description provided for @startCamera.
  ///
  /// In en, this message translates to:
  /// **'Start camera'**
  String get startCamera;

  /// No description provided for @homeAddress.
  ///
  /// In en, this message translates to:
  /// **'Home address'**
  String get homeAddress;

  /// No description provided for @requiredByRegulationYouMayBe.
  ///
  /// In en, this message translates to:
  /// **'Required by regulation. You may be asked for a utility bill for higher limits.'**
  String get requiredByRegulationYouMayBe;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street address'**
  String get streetAddress;

  /// No description provided for @cityTown.
  ///
  /// In en, this message translates to:
  /// **'City / Town'**
  String get cityTown;

  /// No description provided for @stateRegion.
  ///
  /// In en, this message translates to:
  /// **'State / Region'**
  String get stateRegion;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @employed.
  ///
  /// In en, this message translates to:
  /// **'Employed'**
  String get employed;

  /// No description provided for @selfEmployed.
  ///
  /// In en, this message translates to:
  /// **'Self-employed'**
  String get selfEmployed;

  /// No description provided for @trader.
  ///
  /// In en, this message translates to:
  /// **'Trader'**
  String get trader;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @no12ZooRoad.
  ///
  /// In en, this message translates to:
  /// **'No. 12 Zoo Road'**
  String get no12ZooRoad;

  /// No description provided for @kanoState.
  ///
  /// In en, this message translates to:
  /// **'Kano State'**
  String get kanoState;

  /// No description provided for @createATransactionPin.
  ///
  /// In en, this message translates to:
  /// **'Create a transaction PIN'**
  String get createATransactionPin;

  /// No description provided for @youLlUseThis6Digit.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ll use this 6-digit PIN to approve every trade, transfer and bill payment.'**
  String get youLlUseThis6Digit;

  /// No description provided for @avoidBirthdaysAndRepeatedDigitsLike.
  ///
  /// In en, this message translates to:
  /// **'Avoid birthdays and repeated digits like 111111.'**
  String get avoidBirthdaysAndRepeatedDigitsLike;

  /// No description provided for @confirmYourPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get confirmYourPin;

  /// No description provided for @pinsDonTMatchTryAgain.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'\'t match — try again'**
  String get pinsDonTMatchTryAgain;

  /// No description provided for @turnOnTwoFactorAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Turn on two-factor authentication'**
  String get turnOnTwoFactorAuthentication;

  /// No description provided for @s2faProtectsLoginsOnNewDevices.
  ///
  /// In en, this message translates to:
  /// **'2FA protects logins on new devices and every withdrawal. Jarina uses an authenticator app only — SMS codes can be stolen through SIM-swap.'**
  String get s2faProtectsLoginsOnNewDevices;

  /// No description provided for @scanWithGoogleAuthenticatorMicrosoftAuthenticator.
  ///
  /// In en, this message translates to:
  /// **'Scan with Google Authenticator, Microsoft Authenticator, Authy or 1Password — or enter this key:'**
  String get scanWithGoogleAuthenticatorMicrosoftAuthenticator;

  /// No description provided for @copyKey.
  ///
  /// In en, this message translates to:
  /// **'Copy key'**
  String get copyKey;

  /// No description provided for @keyCopied2.
  ///
  /// In en, this message translates to:
  /// **'Key copied'**
  String get keyCopied2;

  /// No description provided for @enterThe6DigitCodeFrom.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code from your app'**
  String get enterThe6DigitCodeFrom;

  /// No description provided for @backupCodes.
  ///
  /// In en, this message translates to:
  /// **'Backup codes'**
  String get backupCodes;

  /// No description provided for @saveThese8OneTimeCodes.
  ///
  /// In en, this message translates to:
  /// **'Save these 8 one-time codes somewhere safe. You\'\'ll need one if you lose your phone.'**
  String get saveThese8OneTimeCodes;

  /// No description provided for @verifyTurnOn2fa.
  ///
  /// In en, this message translates to:
  /// **'Verify & turn on 2FA'**
  String get verifyTurnOn2fa;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR code'**
  String get qrCode;

  /// No description provided for @youReVerified.
  ///
  /// In en, this message translates to:
  /// **'You\'\'re verified'**
  String get youReVerified;

  /// No description provided for @identityConfirmedAnd2faIsOn.
  ///
  /// In en, this message translates to:
  /// **'Identity confirmed and 2FA is on. Your account is Tier 2.'**
  String get identityConfirmedAnd2faIsOn;

  /// No description provided for @tier1.
  ///
  /// In en, this message translates to:
  /// **'Tier 1'**
  String get tier1;

  /// No description provided for @s50000Daily.
  ///
  /// In en, this message translates to:
  /// **'₦50,000 daily'**
  String get s50000Daily;

  /// No description provided for @higherLimits.
  ///
  /// In en, this message translates to:
  /// **'Higher limits'**
  String get higherLimits;

  /// No description provided for @phoneBvnNin.
  ///
  /// In en, this message translates to:
  /// **'Phone + BVN/NIN'**
  String get phoneBvnNin;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @idLivenessAddress.
  ///
  /// In en, this message translates to:
  /// **'ID + liveness + address'**
  String get idLivenessAddress;

  /// No description provided for @proofOfAddressIncome.
  ///
  /// In en, this message translates to:
  /// **'Proof of address + income'**
  String get proofOfAddressIncome;

  /// No description provided for @sampleLimitsForThePrototypeFinal.
  ///
  /// In en, this message translates to:
  /// **'Sample limits for the prototype — final limits follow the licensing regulator in each country.'**
  String get sampleLimitsForThePrototypeFinal;

  /// No description provided for @goToJarina.
  ///
  /// In en, this message translates to:
  /// **'Go to Jarina'**
  String get goToJarina;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get goodMorning;

  /// No description provided for @tier2.
  ///
  /// In en, this message translates to:
  /// **'Tier 2'**
  String get tier2;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total balance'**
  String get totalBalance;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @today2.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today2;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @stocks.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get stocks;

  /// No description provided for @crypto.
  ///
  /// In en, this message translates to:
  /// **'Crypto'**
  String get crypto;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add money'**
  String get addMoney;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @payBills.
  ///
  /// In en, this message translates to:
  /// **'Pay bills'**
  String get payBills;

  /// No description provided for @naira.
  ///
  /// In en, this message translates to:
  /// **'Naira'**
  String get naira;

  /// No description provided for @cedi.
  ///
  /// In en, this message translates to:
  /// **'Cedi'**
  String get cedi;

  /// No description provided for @westAfrica.
  ///
  /// In en, this message translates to:
  /// **'West Africa'**
  String get westAfrica;

  /// No description provided for @centralAfrica.
  ///
  /// In en, this message translates to:
  /// **'Central Africa'**
  String get centralAfrica;

  /// No description provided for @convert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get convert;

  /// No description provided for @betweenWallets.
  ///
  /// In en, this message translates to:
  /// **'Between wallets'**
  String get betweenWallets;

  /// No description provided for @yourAssets.
  ///
  /// In en, this message translates to:
  /// **'Your assets'**
  String get yourAssets;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @boughtGtco.
  ///
  /// In en, this message translates to:
  /// **'Bought GTCO'**
  String get boughtGtco;

  /// No description provided for @soldGtco.
  ///
  /// In en, this message translates to:
  /// **'Sold GTCO'**
  String get soldGtco;

  /// No description provided for @s300Shares.
  ///
  /// In en, this message translates to:
  /// **'300 shares'**
  String get s300Shares;

  /// No description provided for @sentToHalimaIssoufou.
  ///
  /// In en, this message translates to:
  /// **'Sent to Halima Issoufou'**
  String get sentToHalimaIssoufou;

  /// No description provided for @receivedFromKwameMensah.
  ///
  /// In en, this message translates to:
  /// **'Received from Kwame Mensah'**
  String get receivedFromKwameMensah;

  /// No description provided for @requestedFromZainabYusuf.
  ///
  /// In en, this message translates to:
  /// **'Requested from Zainab Yusuf'**
  String get requestedFromZainabYusuf;

  /// No description provided for @pending2.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get pending2;

  /// No description provided for @s27Sep.
  ///
  /// In en, this message translates to:
  /// **'27 Sep'**
  String get s27Sep;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @sendReceive.
  ///
  /// In en, this message translates to:
  /// **'Send/Receive'**
  String get sendReceive;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @priceAlerts.
  ///
  /// In en, this message translates to:
  /// **'Price alerts'**
  String get priceAlerts;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @priceChartSampleData.
  ///
  /// In en, this message translates to:
  /// **'Price chart, sample data'**
  String get priceChartSampleData;

  /// No description provided for @hideBalance.
  ///
  /// In en, this message translates to:
  /// **'Hide balance'**
  String get hideBalance;

  /// No description provided for @chartRange.
  ///
  /// In en, this message translates to:
  /// **'Chart range'**
  String get chartRange;

  /// No description provided for @displayCurrency2.
  ///
  /// In en, this message translates to:
  /// **'Display currency'**
  String get displayCurrency2;

  /// No description provided for @mainMenu.
  ///
  /// In en, this message translates to:
  /// **'Main menu'**
  String get mainMenu;

  /// No description provided for @ngxOpen2.
  ///
  /// In en, this message translates to:
  /// **'NGX open'**
  String get ngxOpen2;

  /// No description provided for @delayed15Min.
  ///
  /// In en, this message translates to:
  /// **'delayed 15 min'**
  String get delayed15Min;

  /// No description provided for @stockPortfolioValue.
  ///
  /// In en, this message translates to:
  /// **'Stock portfolio value'**
  String get stockPortfolioValue;

  /// No description provided for @s441009Today.
  ///
  /// In en, this message translates to:
  /// **'−₦441 (-0.09%) today'**
  String get s441009Today;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sell;

  /// No description provided for @yourHoldings.
  ///
  /// In en, this message translates to:
  /// **'Your holdings'**
  String get yourHoldings;

  /// No description provided for @s4Stocks.
  ///
  /// In en, this message translates to:
  /// **'4 stocks'**
  String get s4Stocks;

  /// No description provided for @s2Coins.
  ///
  /// In en, this message translates to:
  /// **'2 coins'**
  String get s2Coins;

  /// No description provided for @autopilot.
  ///
  /// In en, this message translates to:
  /// **'Autopilot'**
  String get autopilot;

  /// No description provided for @autoBuyDipsAndAutoSell.
  ///
  /// In en, this message translates to:
  /// **'Auto-buy dips and auto-sell targets'**
  String get autoBuyDipsAndAutoSell;

  /// No description provided for @s2ActiveRules.
  ///
  /// In en, this message translates to:
  /// **'2 active rules'**
  String get s2ActiveRules;

  /// No description provided for @s1ActiveRule.
  ///
  /// In en, this message translates to:
  /// **'1 active rule'**
  String get s1ActiveRule;

  /// No description provided for @xxRemoved.
  ///
  /// In en, this message translates to:
  /// **'XX_REMOVED'**
  String get xxRemoved;

  /// No description provided for @nigerianStocksNgx.
  ///
  /// In en, this message translates to:
  /// **'Nigerian stocks (NGX)'**
  String get nigerianStocksNgx;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @banking.
  ///
  /// In en, this message translates to:
  /// **'Banking'**
  String get banking;

  /// No description provided for @financial.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get financial;

  /// No description provided for @insurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get insurance;

  /// No description provided for @ictTelecoms.
  ///
  /// In en, this message translates to:
  /// **'ICT & Telecoms'**
  String get ictTelecoms;

  /// No description provided for @industrial.
  ///
  /// In en, this message translates to:
  /// **'Industrial'**
  String get industrial;

  /// No description provided for @consumer.
  ///
  /// In en, this message translates to:
  /// **'Consumer'**
  String get consumer;

  /// No description provided for @oilGas.
  ///
  /// In en, this message translates to:
  /// **'Oil & Gas'**
  String get oilGas;

  /// No description provided for @agriculture.
  ///
  /// In en, this message translates to:
  /// **'Agriculture'**
  String get agriculture;

  /// No description provided for @utilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get utilities;

  /// No description provided for @healthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get healthcare;

  /// No description provided for @realEstate.
  ///
  /// In en, this message translates to:
  /// **'Real estate'**
  String get realEstate;

  /// No description provided for @conglomerate.
  ///
  /// In en, this message translates to:
  /// **'Conglomerate'**
  String get conglomerate;

  /// No description provided for @naturalResources.
  ///
  /// In en, this message translates to:
  /// **'Natural resources'**
  String get naturalResources;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @pricesNgxDailyOfficialListClose.
  ///
  /// In en, this message translates to:
  /// **'Prices: NGX Daily Official List, close of 25 Sep 2026. A live NGX data feed is needed for production.'**
  String get pricesNgxDailyOfficialListClose;

  /// No description provided for @searchCompanyOrTicker.
  ///
  /// In en, this message translates to:
  /// **'Search company or ticker'**
  String get searchCompanyOrTicker;

  /// No description provided for @search2.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search2;

  /// No description provided for @trading247.
  ///
  /// In en, this message translates to:
  /// **'Trading 24/7'**
  String get trading247;

  /// No description provided for @cryptoPortfolioValue.
  ///
  /// In en, this message translates to:
  /// **'Crypto portfolio value'**
  String get cryptoPortfolioValue;

  /// No description provided for @allCrypto.
  ///
  /// In en, this message translates to:
  /// **'All crypto'**
  String get allCrypto;

  /// No description provided for @cryptoPricesAreSampleValuesA.
  ///
  /// In en, this message translates to:
  /// **'Crypto prices are sample values. A live price feed is needed for production.'**
  String get cryptoPricesAreSampleValuesA;

  /// No description provided for @searchCoin.
  ///
  /// In en, this message translates to:
  /// **'Search coin'**
  String get searchCoin;

  /// No description provided for @balance184200.
  ///
  /// In en, this message translates to:
  /// **'Balance ₦184,200'**
  String get balance184200;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @scanToPay.
  ///
  /// In en, this message translates to:
  /// **'Scan to pay'**
  String get scanToPay;

  /// No description provided for @moreThanYourBalanceOf184.
  ///
  /// In en, this message translates to:
  /// **'More than your balance of ₦184,200'**
  String get moreThanYourBalanceOf184;

  /// No description provided for @enterAnAmountFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount first'**
  String get enterAnAmountFirst;

  /// No description provided for @amountIsMoreThanYourBalance2.
  ///
  /// In en, this message translates to:
  /// **'Amount is more than your balance'**
  String get amountIsMoreThanYourBalance2;

  /// No description provided for @transfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfers;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @electricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get electricity;

  /// No description provided for @prepaidToken.
  ///
  /// In en, this message translates to:
  /// **'Prepaid token'**
  String get prepaidToken;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get bankTransfer;

  /// No description provided for @fromYourAccount.
  ///
  /// In en, this message translates to:
  /// **'From your account'**
  String get fromYourAccount;

  /// No description provided for @receivedUsdt.
  ///
  /// In en, this message translates to:
  /// **'Received USDT'**
  String get receivedUsdt;

  /// No description provided for @airtime.
  ///
  /// In en, this message translates to:
  /// **'Airtime'**
  String get airtime;

  /// No description provided for @boughtDangcem.
  ///
  /// In en, this message translates to:
  /// **'Bought DANGCEM'**
  String get boughtDangcem;

  /// No description provided for @boughtBtc.
  ///
  /// In en, this message translates to:
  /// **'Bought BTC'**
  String get boughtBtc;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @cableTv.
  ///
  /// In en, this message translates to:
  /// **'Cable TV'**
  String get cableTv;

  /// No description provided for @tradingTools.
  ///
  /// In en, this message translates to:
  /// **'Trading tools'**
  String get tradingTools;

  /// No description provided for @stockAutopilot.
  ///
  /// In en, this message translates to:
  /// **'Stock Autopilot'**
  String get stockAutopilot;

  /// No description provided for @cryptoAutopilot.
  ///
  /// In en, this message translates to:
  /// **'Crypto Autopilot'**
  String get cryptoAutopilot;

  /// No description provided for @assetLogos.
  ///
  /// In en, this message translates to:
  /// **'Asset logos'**
  String get assetLogos;

  /// No description provided for @s0Added.
  ///
  /// In en, this message translates to:
  /// **'0 added'**
  String get s0Added;

  /// No description provided for @accountProfile.
  ///
  /// In en, this message translates to:
  /// **'Account & profile'**
  String get accountProfile;

  /// No description provided for @security2fa.
  ///
  /// In en, this message translates to:
  /// **'Security & 2FA'**
  String get security2fa;

  /// No description provided for @onLabel.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get onLabel;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get lightMode;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & support'**
  String get helpSupport;

  /// No description provided for @logOut2.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut2;

  /// No description provided for @logOut3.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get logOut3;

  /// No description provided for @jarinaPrototype.
  ///
  /// In en, this message translates to:
  /// **'Jarina prototype'**
  String get jarinaPrototype;

  /// No description provided for @allFiguresAreSampleData.
  ///
  /// In en, this message translates to:
  /// **'all figures are sample data'**
  String get allFiguresAreSampleData;

  /// No description provided for @sampleData.
  ///
  /// In en, this message translates to:
  /// **'sample data'**
  String get sampleData;

  /// No description provided for @ngx.
  ///
  /// In en, this message translates to:
  /// **'NGX'**
  String get ngx;

  /// No description provided for @s013Today.
  ///
  /// In en, this message translates to:
  /// **'−0.13% · today'**
  String get s013Today;

  /// No description provided for @setAlert.
  ///
  /// In en, this message translates to:
  /// **'Set alert'**
  String get setAlert;

  /// No description provided for @whenMtnnFallsBelow78000.
  ///
  /// In en, this message translates to:
  /// **'When MTNN falls below ₦780.00, sell 50% of my shares.'**
  String get whenMtnnFallsBelow78000;

  /// No description provided for @whenBtcFallsBelow920002.
  ///
  /// In en, this message translates to:
  /// **'When BTC falls below ₦92,000,000, buy ₦50,000 worth.'**
  String get whenBtcFallsBelow920002;

  /// No description provided for @whenDangcemTradesBetween960And.
  ///
  /// In en, this message translates to:
  /// **'When DANGCEM trades between ₦960 and ₦1,040, buy ₦100,000 worth.'**
  String get whenDangcemTradesBetween960And;

  /// No description provided for @whenDangcemRisesAbove1200.
  ///
  /// In en, this message translates to:
  /// **'When DANGCEM rises above ₦1,200, sell 20 shares.'**
  String get whenDangcemRisesAbove1200;

  /// No description provided for @whenDangcemFallsBelow960Buy.
  ///
  /// In en, this message translates to:
  /// **'When DANGCEM falls below ₦960, buy 100,000 shares.'**
  String get whenDangcemFallsBelow960Buy;

  /// No description provided for @whenDangcemRisesAbove960Buy.
  ///
  /// In en, this message translates to:
  /// **'When DANGCEM rises above ₦960, buy ₦100,000 worth.'**
  String get whenDangcemRisesAbove960Buy;

  /// No description provided for @whenDangcemFallsBelow960Sell.
  ///
  /// In en, this message translates to:
  /// **'When DANGCEM falls below ₦960, sell 100 shares.'**
  String get whenDangcemFallsBelow960Sell;

  /// No description provided for @whenBtcFallsBelow920003.
  ///
  /// In en, this message translates to:
  /// **'When BTC falls below ₦92,000,000, sell 0.001 BTC.'**
  String get whenBtcFallsBelow920003;

  /// No description provided for @whenBtcRisesAbove92000.
  ///
  /// In en, this message translates to:
  /// **'When BTC rises above ₦92,000,000, sell 0.001 BTC.'**
  String get whenBtcRisesAbove92000;

  /// No description provided for @whenBtcFallsBelow920004.
  ///
  /// In en, this message translates to:
  /// **'When BTC falls below ₦92,000,000, sell 50% of my BTC.'**
  String get whenBtcFallsBelow920004;

  /// No description provided for @whenBtcTradesBetween960And.
  ///
  /// In en, this message translates to:
  /// **'When BTC trades between ₦960 and ₦1,040, buy ₦100,000 worth.'**
  String get whenBtcTradesBetween960And;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @alertWhenPriceGoesAbove900.
  ///
  /// In en, this message translates to:
  /// **'Alert when price goes above ₦900.00'**
  String get alertWhenPriceGoesAbove900;

  /// No description provided for @alertWhenPriceGoesBelow900.
  ///
  /// In en, this message translates to:
  /// **'Alert when price goes below ₦900.00'**
  String get alertWhenPriceGoesBelow900;

  /// No description provided for @yourPosition.
  ///
  /// In en, this message translates to:
  /// **'Your position'**
  String get yourPosition;

  /// No description provided for @dayHigh.
  ///
  /// In en, this message translates to:
  /// **'Day high'**
  String get dayHigh;

  /// No description provided for @dayLow.
  ///
  /// In en, this message translates to:
  /// **'Day low'**
  String get dayLow;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @mtnNigeriaCommunicationsPlcIsA.
  ///
  /// In en, this message translates to:
  /// **'MTN Nigeria Communications Plc is a mobile telecommunications operator listed on the Nigerian Exchange (NGX).'**
  String get mtnNigeriaCommunicationsPlcIsA;

  /// No description provided for @dangoteCementPlcIsACement.
  ///
  /// In en, this message translates to:
  /// **'Dangote Cement Plc is a cement manufacturer with operations across Africa, listed on the NGX.'**
  String get dangoteCementPlcIsACement;

  /// No description provided for @guarantyTrustHoldingCompanyPlcIs.
  ///
  /// In en, this message translates to:
  /// **'Guaranty Trust Holding Company Plc is a financial services group listed on the NGX.'**
  String get guarantyTrustHoldingCompanyPlcIs;

  /// No description provided for @zenithBankPlcIsANigerian.
  ///
  /// In en, this message translates to:
  /// **'Zenith Bank Plc is a Nigerian commercial bank listed on the NGX.'**
  String get zenithBankPlcIsANigerian;

  /// No description provided for @bitcoinIsADecentralisedDigitalCurrency.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin is a decentralised digital currency that runs on a public, peer-to-peer network.'**
  String get bitcoinIsADecentralisedDigitalCurrency;

  /// No description provided for @ethereumIsAProgrammableBlockchainEth.
  ///
  /// In en, this message translates to:
  /// **'Ethereum is a programmable blockchain. ETH is its native asset, used to pay network fees.'**
  String get ethereumIsAProgrammableBlockchainEth;

  /// No description provided for @tetherUsdtIsAStablecoinDesigned.
  ///
  /// In en, this message translates to:
  /// **'Tether (USDT) is a stablecoin designed to track the US dollar. Jarina uses stablecoins to settle cross-border transfers.'**
  String get tetherUsdtIsAStablecoinDesigned;

  /// No description provided for @seplatEnergyIsListedOnThe.
  ///
  /// In en, this message translates to:
  /// **'Seplat Energy is listed on the Nigerian Exchange (NGX) in the oil & gas sector.'**
  String get seplatEnergyIsListedOnThe;

  /// No description provided for @solanaIsADigitalAssetAvailable.
  ///
  /// In en, this message translates to:
  /// **'Solana is a digital asset available to trade on Jarina.'**
  String get solanaIsADigitalAssetAvailable;

  /// No description provided for @addToWatchlist2.
  ///
  /// In en, this message translates to:
  /// **'Add to watchlist'**
  String get addToWatchlist2;

  /// No description provided for @buyMtnn.
  ///
  /// In en, this message translates to:
  /// **'Buy MTNN'**
  String get buyMtnn;

  /// No description provided for @sellMtnn.
  ///
  /// In en, this message translates to:
  /// **'Sell MTNN'**
  String get sellMtnn;

  /// No description provided for @s86190PerShare.
  ///
  /// In en, this message translates to:
  /// **'₦861.90 per share'**
  String get s86190PerShare;

  /// No description provided for @s98000000PerBtc.
  ///
  /// In en, this message translates to:
  /// **'₦98,000,000 per BTC'**
  String get s98000000PerBtc;

  /// No description provided for @s232Shares.
  ///
  /// In en, this message translates to:
  /// **'≈ 23.2 shares'**
  String get s232Shares;

  /// No description provided for @s232Shares2.
  ///
  /// In en, this message translates to:
  /// **'23.2 shares'**
  String get s232Shares2;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @youHold400Shares.
  ///
  /// In en, this message translates to:
  /// **'You hold 400 shares'**
  String get youHold400Shares;

  /// No description provided for @youHold00042Btc.
  ///
  /// In en, this message translates to:
  /// **'You hold 0.0042 BTC'**
  String get youHold00042Btc;

  /// No description provided for @cashAvailable184200.
  ///
  /// In en, this message translates to:
  /// **'Cash available ₦184,200'**
  String get cashAvailable184200;

  /// No description provided for @exceedsYourAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Exceeds your available balance'**
  String get exceedsYourAvailableBalance;

  /// No description provided for @estQuantity.
  ///
  /// In en, this message translates to:
  /// **'Est. quantity'**
  String get estQuantity;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @executedBy.
  ///
  /// In en, this message translates to:
  /// **'Executed by'**
  String get executedBy;

  /// No description provided for @licensedPartnerBroker.
  ///
  /// In en, this message translates to:
  /// **'Licensed partner broker'**
  String get licensedPartnerBroker;

  /// No description provided for @youLlConfirmWithYourTransaction.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ll confirm with your transaction PIN. Prices can move before your order fills. Investments can go down as well as up.'**
  String get youLlConfirmWithYourTransaction;

  /// No description provided for @youLlConfirmWithYourTransaction2.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ll confirm with your transaction PIN.'**
  String get youLlConfirmWithYourTransaction2;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @jarinaCustodial.
  ///
  /// In en, this message translates to:
  /// **'Jarina (custodial)'**
  String get jarinaCustodial;

  /// No description provided for @youLlConfirmWithYourPin.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ll confirm with your PIN and a 2FA code. Prices can move before your order fills. Investments can go down as well as up.'**
  String get youLlConfirmWithYourPin;

  /// No description provided for @youLlConfirmWithYourPin2.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ll confirm with your PIN and a 2FA code.'**
  String get youLlConfirmWithYourPin2;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @touchTheSensorTo.
  ///
  /// In en, this message translates to:
  /// **'Touch the sensor to'**
  String get touchTheSensorTo;

  /// No description provided for @verifyThisTransaction.
  ///
  /// In en, this message translates to:
  /// **'verify this transaction'**
  String get verifyThisTransaction;

  /// No description provided for @useTouchIdOrFaceId.
  ///
  /// In en, this message translates to:
  /// **'Use Touch ID or Face ID to confirm your identity. Tap the red sensor to continue.'**
  String get useTouchIdOrFaceId;

  /// No description provided for @useTouchIdOrFaceId2.
  ///
  /// In en, this message translates to:
  /// **'Use Touch ID or Face ID to confirm your identity, then enter your 2FA code. Tap the red sensor to continue.'**
  String get useTouchIdOrFaceId2;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get pinCode;

  /// No description provided for @verifyWithFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Verify with fingerprint'**
  String get verifyWithFingerprint;

  /// No description provided for @enterPinCode.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN code'**
  String get enterPinCode;

  /// No description provided for @pleaseEnterYourPinCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter your PIN code'**
  String get pleaseEnterYourPinCode;

  /// No description provided for @your6DigitPinApprovesThis.
  ///
  /// In en, this message translates to:
  /// **'Your 6-digit PIN approves this transaction'**
  String get your6DigitPinApprovesThis;

  /// No description provided for @authoriseAutopilotToTradeForYou.
  ///
  /// In en, this message translates to:
  /// **'Authorise Autopilot to trade for you when your conditions are met'**
  String get authoriseAutopilotToTradeForYou;

  /// No description provided for @step1Of2ThenYour.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2 · then your 2FA code'**
  String get step1Of2ThenYour;

  /// No description provided for @twoFactorCode.
  ///
  /// In en, this message translates to:
  /// **'Two-factor code'**
  String get twoFactorCode;

  /// No description provided for @step2Of2EnterThe.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2 · Enter the 6-digit code from your authenticator app to release this payment.'**
  String get step2Of2EnterThe;

  /// No description provided for @withdrawalsAndSellsAlwaysRequire2fa.
  ///
  /// In en, this message translates to:
  /// **'Withdrawals and sells always require 2FA.'**
  String get withdrawalsAndSellsAlwaysRequire2fa;

  /// No description provided for @yourOrderHasBeenSentTo.
  ///
  /// In en, this message translates to:
  /// **'Your order has been sent to the market. We\'\'ll notify you when it fills.'**
  String get yourOrderHasBeenSentTo;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View receipt'**
  String get viewReceipt;

  /// No description provided for @sellOrderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Sell order placed'**
  String get sellOrderPlaced;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccessful;

  /// No description provided for @yourPrepaidTokenIsReadyIt.
  ///
  /// In en, this message translates to:
  /// **'Your prepaid token is ready. It has also been sent by SMS.'**
  String get yourPrepaidTokenIsReadyIt;

  /// No description provided for @token.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get token;

  /// No description provided for @prepaid.
  ///
  /// In en, this message translates to:
  /// **'Prepaid'**
  String get prepaid;

  /// No description provided for @postpaid.
  ///
  /// In en, this message translates to:
  /// **'Postpaid'**
  String get postpaid;

  /// No description provided for @airtimeDeliveredTo08012345678.
  ///
  /// In en, this message translates to:
  /// **'Airtime delivered to 0801 234 5678.'**
  String get airtimeDeliveredTo08012345678;

  /// No description provided for @dataDeliveredTo08012345678.
  ///
  /// In en, this message translates to:
  /// **'Data delivered to 0801 234 5678.'**
  String get dataDeliveredTo08012345678;

  /// No description provided for @cableTvDeliveredTo70234567.
  ///
  /// In en, this message translates to:
  /// **'Cable TV delivered to 7023 4567 89.'**
  String get cableTvDeliveredTo70234567;

  /// No description provided for @usuallyArrivesWithinAFewMinutes.
  ///
  /// In en, this message translates to:
  /// **'Usually arrives within a few minutes.'**
  String get usuallyArrivesWithinAFewMinutes;

  /// No description provided for @sellStocks.
  ///
  /// In en, this message translates to:
  /// **'Sell stocks'**
  String get sellStocks;

  /// No description provided for @sellCrypto.
  ///
  /// In en, this message translates to:
  /// **'Sell crypto'**
  String get sellCrypto;

  /// No description provided for @chooseWhatYouWantToBuy.
  ///
  /// In en, this message translates to:
  /// **'Choose what you want to buy.'**
  String get chooseWhatYouWantToBuy;

  /// No description provided for @chooseAHoldingToSell.
  ///
  /// In en, this message translates to:
  /// **'Choose a holding to sell.'**
  String get chooseAHoldingToSell;

  /// No description provided for @newStockRule.
  ///
  /// In en, this message translates to:
  /// **'New stock rule'**
  String get newStockRule;

  /// No description provided for @newCryptoRule.
  ///
  /// In en, this message translates to:
  /// **'New crypto rule'**
  String get newCryptoRule;

  /// No description provided for @chooseAnAsset.
  ///
  /// In en, this message translates to:
  /// **'Choose an asset.'**
  String get chooseAnAsset;

  /// No description provided for @newPriceAlert.
  ///
  /// In en, this message translates to:
  /// **'New price alert'**
  String get newPriceAlert;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @setYourPriceForNgxShares.
  ///
  /// In en, this message translates to:
  /// **'Set your price for NGX shares — Jarina buys the dip or takes profit during market hours.'**
  String get setYourPriceForNgxShares;

  /// No description provided for @setYourPriceForCryptoJarina.
  ///
  /// In en, this message translates to:
  /// **'Set your price for crypto — Jarina buys the dip or takes profit for you, 24/7.'**
  String get setYourPriceForCryptoJarina;

  /// No description provided for @yourStockRules.
  ///
  /// In en, this message translates to:
  /// **'Your stock rules'**
  String get yourStockRules;

  /// No description provided for @yourCryptoRules.
  ///
  /// In en, this message translates to:
  /// **'Your crypto rules'**
  String get yourCryptoRules;

  /// No description provided for @autoBuy.
  ///
  /// In en, this message translates to:
  /// **'Auto-buy'**
  String get autoBuy;

  /// No description provided for @autoSell.
  ///
  /// In en, this message translates to:
  /// **'Auto-sell'**
  String get autoSell;

  /// No description provided for @s25Away.
  ///
  /// In en, this message translates to:
  /// **'2.5% away'**
  String get s25Away;

  /// No description provided for @conditionMet.
  ///
  /// In en, this message translates to:
  /// **'Condition met'**
  String get conditionMet;

  /// No description provided for @runsOnce2.
  ///
  /// In en, this message translates to:
  /// **'Runs once'**
  String get runsOnce2;

  /// No description provided for @repeatsEveryTime2.
  ///
  /// In en, this message translates to:
  /// **'Repeats every time'**
  String get repeatsEveryTime2;

  /// No description provided for @expiresIn30Days.
  ///
  /// In en, this message translates to:
  /// **'Expires in 30 days'**
  String get expiresIn30Days;

  /// No description provided for @expiresIn7Days.
  ///
  /// In en, this message translates to:
  /// **'Expires in 7 days'**
  String get expiresIn7Days;

  /// No description provided for @untilCancelled.
  ///
  /// In en, this message translates to:
  /// **'Until cancelled'**
  String get untilCancelled;

  /// No description provided for @now1067.
  ///
  /// In en, this message translates to:
  /// **'Now ₦1,067'**
  String get now1067;

  /// No description provided for @autopilotPlacesOrdersAtMarketConditions.
  ///
  /// In en, this message translates to:
  /// **'Autopilot places orders at market conditions you set. Prices can gap past your range, so fills may differ slightly. Investments can go down as well as up.'**
  String get autopilotPlacesOrdersAtMarketConditions;

  /// No description provided for @ruleOn2.
  ///
  /// In en, this message translates to:
  /// **'Rule on'**
  String get ruleOn2;

  /// No description provided for @deleteRule2.
  ///
  /// In en, this message translates to:
  /// **'Delete rule'**
  String get deleteRule2;

  /// No description provided for @rulePaused.
  ///
  /// In en, this message translates to:
  /// **'Rule paused'**
  String get rulePaused;

  /// No description provided for @ruleResumed.
  ///
  /// In en, this message translates to:
  /// **'Rule resumed'**
  String get ruleResumed;

  /// No description provided for @ruleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Rule deleted'**
  String get ruleDeleted;

  /// No description provided for @autopilotRuleIsLive.
  ///
  /// In en, this message translates to:
  /// **'Autopilot rule is live'**
  String get autopilotRuleIsLive;

  /// No description provided for @noRulesYetTapNewTo.
  ///
  /// In en, this message translates to:
  /// **'No rules yet — tap New to create one.'**
  String get noRulesYetTapNewTo;

  /// No description provided for @activeAlerts.
  ///
  /// In en, this message translates to:
  /// **'Active alerts'**
  String get activeAlerts;

  /// No description provided for @mtnnAbove90000.
  ///
  /// In en, this message translates to:
  /// **'MTNN above ₦900.00'**
  String get mtnnAbove90000;

  /// No description provided for @btcBelow95000000.
  ///
  /// In en, this message translates to:
  /// **'BTC below ₦95,000,000'**
  String get btcBelow95000000;

  /// No description provided for @push.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get push;

  /// No description provided for @recentNotifications.
  ///
  /// In en, this message translates to:
  /// **'Recent notifications'**
  String get recentNotifications;

  /// No description provided for @mtnnRoseAbove44800.
  ///
  /// In en, this message translates to:
  /// **'MTNN rose above ₦448.00'**
  String get mtnnRoseAbove44800;

  /// No description provided for @s2HoursAgo.
  ///
  /// In en, this message translates to:
  /// **'2 hours ago'**
  String get s2HoursAgo;

  /// No description provided for @btcFell3In1Hour.
  ///
  /// In en, this message translates to:
  /// **'BTC fell 3% in 1 hour'**
  String get btcFell3In1Hour;

  /// No description provided for @autopilotBought25DangcemAt480.
  ///
  /// In en, this message translates to:
  /// **'Autopilot bought 25 DANGCEM at ₦480.00'**
  String get autopilotBought25DangcemAt480;

  /// No description provided for @s22Sep.
  ///
  /// In en, this message translates to:
  /// **'22 Sep'**
  String get s22Sep;

  /// No description provided for @alertOn2.
  ///
  /// In en, this message translates to:
  /// **'Alert on'**
  String get alertOn2;

  /// No description provided for @alertSet.
  ///
  /// In en, this message translates to:
  /// **'Alert set'**
  String get alertSet;

  /// No description provided for @noAlertsYet2.
  ///
  /// In en, this message translates to:
  /// **'No alerts yet'**
  String get noAlertsYet2;

  /// No description provided for @stablecoin.
  ///
  /// In en, this message translates to:
  /// **'stablecoin'**
  String get stablecoin;

  /// No description provided for @networks.
  ///
  /// In en, this message translates to:
  /// **'Networks'**
  String get networks;

  /// No description provided for @withdrawalFee1Usdt.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal fee 1 USDT'**
  String get withdrawalFee1Usdt;

  /// No description provided for @depositsFree.
  ///
  /// In en, this message translates to:
  /// **'deposits free'**
  String get depositsFree;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @addressBook.
  ///
  /// In en, this message translates to:
  /// **'Address book'**
  String get addressBook;

  /// No description provided for @s2Saved.
  ///
  /// In en, this message translates to:
  /// **'2 saved'**
  String get s2Saved;

  /// No description provided for @addressWhitelist.
  ///
  /// In en, this message translates to:
  /// **'Address whitelist'**
  String get addressWhitelist;

  /// No description provided for @onlyAllowWithdrawalsToSavedAddresses.
  ///
  /// In en, this message translates to:
  /// **'Only allow withdrawals to saved addresses. New addresses wait 24 hours.'**
  String get onlyAllowWithdrawalsToSavedAddresses;

  /// No description provided for @usdtActivity.
  ///
  /// In en, this message translates to:
  /// **'USDT activity'**
  String get usdtActivity;

  /// No description provided for @noUsdtActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No USDT activity yet'**
  String get noUsdtActivityYet;

  /// No description provided for @networkFeesAreSampleValues.
  ///
  /// In en, this message translates to:
  /// **'Network fees are sample values.'**
  String get networkFeesAreSampleValues;

  /// No description provided for @recipientAddress.
  ///
  /// In en, this message translates to:
  /// **'Recipient address'**
  String get recipientAddress;

  /// No description provided for @savedMyBinanceWallet.
  ///
  /// In en, this message translates to:
  /// **'Saved: My Binance wallet'**
  String get savedMyBinanceWallet;

  /// No description provided for @available32000Usdt.
  ///
  /// In en, this message translates to:
  /// **'Available 320.00 USDT'**
  String get available32000Usdt;

  /// No description provided for @amountExceedsYourUsdtBalance.
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds your USDT balance.'**
  String get amountExceedsYourUsdtBalance;

  /// No description provided for @toAddress.
  ///
  /// In en, this message translates to:
  /// **'To address'**
  String get toAddress;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'≈ value'**
  String get value;

  /// No description provided for @cryptoWithdrawalsCanTBeReversed.
  ///
  /// In en, this message translates to:
  /// **'Crypto withdrawals can\'\'t be reversed. Check the address and network. You\'\'ll confirm with your PIN and a 2FA code.'**
  String get cryptoWithdrawalsCanTBeReversed;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get provider;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneNumber;

  /// No description provided for @bundle.
  ///
  /// In en, this message translates to:
  /// **'Bundle'**
  String get bundle;

  /// No description provided for @smartcardIucNumber.
  ///
  /// In en, this message translates to:
  /// **'Smartcard / IUC number'**
  String get smartcardIucNumber;

  /// No description provided for @package.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get package;

  /// No description provided for @basic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basic;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @compact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get compact;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @meterNumber.
  ///
  /// In en, this message translates to:
  /// **'Meter number'**
  String get meterNumber;

  /// No description provided for @meterType.
  ///
  /// In en, this message translates to:
  /// **'Meter type'**
  String get meterType;

  /// No description provided for @numberVerified.
  ///
  /// In en, this message translates to:
  /// **'Number verified'**
  String get numberVerified;

  /// No description provided for @customerAminuBello.
  ///
  /// In en, this message translates to:
  /// **'Customer: AMINU BELLO'**
  String get customerAminuBello;

  /// No description provided for @payFrom.
  ///
  /// In en, this message translates to:
  /// **'Pay from'**
  String get payFrom;

  /// No description provided for @bvnNin.
  ///
  /// In en, this message translates to:
  /// **'BVN / NIN'**
  String get bvnNin;

  /// No description provided for @livenessFaceMatch.
  ///
  /// In en, this message translates to:
  /// **'Liveness & face match'**
  String get livenessFaceMatch;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @proofOfAddressTier3.
  ///
  /// In en, this message translates to:
  /// **'Proof of address (Tier 3)'**
  String get proofOfAddressTier3;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @authenticatorApp.
  ///
  /// In en, this message translates to:
  /// **'Authenticator app'**
  String get authenticatorApp;

  /// No description provided for @requiredForNewDevicesSellsAnd.
  ///
  /// In en, this message translates to:
  /// **'required for new devices, sells and withdrawals'**
  String get requiredForNewDevicesSellsAnd;

  /// No description provided for @s2faCanTBeTurnedOff.
  ///
  /// In en, this message translates to:
  /// **'2FA can\'\'t be turned off on a Tier 2 account'**
  String get s2faCanTBeTurnedOff;

  /// No description provided for @faceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// No description provided for @useInsteadOfPinForSmall.
  ///
  /// In en, this message translates to:
  /// **'Use instead of PIN for small payments'**
  String get useInsteadOfPinForSmall;

  /// No description provided for @changeTransactionPin.
  ///
  /// In en, this message translates to:
  /// **'Change transaction PIN'**
  String get changeTransactionPin;

  /// No description provided for @s8Left.
  ///
  /// In en, this message translates to:
  /// **'8 left'**
  String get s8Left;

  /// No description provided for @trustedDevices.
  ///
  /// In en, this message translates to:
  /// **'Trusted devices'**
  String get trustedDevices;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @easierOnTheEyesAtNight.
  ///
  /// In en, this message translates to:
  /// **'Easier on the eyes at night'**
  String get easierOnTheEyesAtNight;

  /// No description provided for @franAis.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get franAis;

  /// No description provided for @s0Of150Assets.
  ///
  /// In en, this message translates to:
  /// **'0 of 150 assets'**
  String get s0Of150Assets;

  /// No description provided for @logos.
  ///
  /// In en, this message translates to:
  /// **'Logos'**
  String get logos;

  /// No description provided for @addOfficialLogoFilesYouHave.
  ///
  /// In en, this message translates to:
  /// **'Add official logo files you have permission to use. Name each file by its ticker (MTNN.png, DANGCEM.svg, BTC.png) to add many at once. Jarina picks the main colour of each logo and blends it into that asset\'\'s tile.'**
  String get addOfficialLogoFilesYouHave;

  /// No description provided for @addLogoFiles.
  ///
  /// In en, this message translates to:
  /// **'Add logo files'**
  String get addLogoFiles;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @showing60SearchToFindOthers.
  ///
  /// In en, this message translates to:
  /// **'Showing 60 — search to find others'**
  String get showing60SearchToFindOthers;

  /// No description provided for @searchTickerOrCompany.
  ///
  /// In en, this message translates to:
  /// **'Search ticker or company'**
  String get searchTickerOrCompany;

  /// No description provided for @nigerianNaira.
  ///
  /// In en, this message translates to:
  /// **'Nigerian naira'**
  String get nigerianNaira;

  /// No description provided for @nigeria.
  ///
  /// In en, this message translates to:
  /// **'Nigeria'**
  String get nigeria;

  /// No description provided for @receive.
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get receive;

  /// No description provided for @usedIn.
  ///
  /// In en, this message translates to:
  /// **'Used in'**
  String get usedIn;

  /// No description provided for @fundWith2.
  ///
  /// In en, this message translates to:
  /// **'Fund with:'**
  String get fundWith2;

  /// No description provided for @bankTransferNip.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer (NIP)'**
  String get bankTransferNip;

  /// No description provided for @ussd.
  ///
  /// In en, this message translates to:
  /// **'USSD'**
  String get ussd;

  /// No description provided for @agentCashIn.
  ///
  /// In en, this message translates to:
  /// **'Agent cash-in'**
  String get agentCashIn;

  /// No description provided for @mobileMoneyMomo.
  ///
  /// In en, this message translates to:
  /// **'Mobile money (MoMo)'**
  String get mobileMoneyMomo;

  /// No description provided for @bankTransferGhipss.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer (GhIPSS)'**
  String get bankTransferGhipss;

  /// No description provided for @otherWallets.
  ///
  /// In en, this message translates to:
  /// **'Other wallets'**
  String get otherWallets;

  /// No description provided for @ghanaianCedi.
  ///
  /// In en, this message translates to:
  /// **'Ghanaian cedi'**
  String get ghanaianCedi;

  /// No description provided for @westAfricanCfaFranc.
  ///
  /// In en, this message translates to:
  /// **'West African CFA franc'**
  String get westAfricanCfaFranc;

  /// No description provided for @centralAfricanCfaFranc.
  ///
  /// In en, this message translates to:
  /// **'Central African CFA franc'**
  String get centralAfricanCfaFranc;

  /// No description provided for @exchangeRatesAreSampleValues.
  ///
  /// In en, this message translates to:
  /// **'Exchange rates are sample values.'**
  String get exchangeRatesAreSampleValues;

  /// No description provided for @ghana.
  ///
  /// In en, this message translates to:
  /// **'Ghana'**
  String get ghana;

  /// No description provided for @niger.
  ///
  /// In en, this message translates to:
  /// **'Niger'**
  String get niger;

  /// No description provided for @mali.
  ///
  /// In en, this message translates to:
  /// **'Mali'**
  String get mali;

  /// No description provided for @senegal.
  ///
  /// In en, this message translates to:
  /// **'Senegal'**
  String get senegal;

  /// No description provided for @cTeDIvoire.
  ///
  /// In en, this message translates to:
  /// **'Côte d’Ivoire'**
  String get cTeDIvoire;

  /// No description provided for @cameroon.
  ///
  /// In en, this message translates to:
  /// **'Cameroon'**
  String get cameroon;

  /// No description provided for @chad.
  ///
  /// In en, this message translates to:
  /// **'Chad'**
  String get chad;

  /// No description provided for @addGhs.
  ///
  /// In en, this message translates to:
  /// **'Add GHS'**
  String get addGhs;

  /// No description provided for @addNgn.
  ///
  /// In en, this message translates to:
  /// **'Add NGN'**
  String get addNgn;

  /// No description provided for @addXof.
  ///
  /// In en, this message translates to:
  /// **'Add XOF'**
  String get addXof;

  /// No description provided for @addXaf.
  ///
  /// In en, this message translates to:
  /// **'Add XAF'**
  String get addXaf;

  /// No description provided for @fundYourCediWalletFromGhana.
  ///
  /// In en, this message translates to:
  /// **'Fund your Cedi wallet from Ghana using mobile money (momo), bank transfer (ghipss), agent cash-in.'**
  String get fundYourCediWalletFromGhana;

  /// No description provided for @fundYourNairaWalletFromNigeria.
  ///
  /// In en, this message translates to:
  /// **'Fund your Naira wallet from Nigeria using bank transfer (nip), ussd, agent cash-in.'**
  String get fundYourNairaWalletFromNigeria;

  /// No description provided for @fundYourCfaXafWalletFrom.
  ///
  /// In en, this message translates to:
  /// **'Fund your CFA · XAF wallet from Cameroon · Chad using mobile money, bank transfer, agent cash-in.'**
  String get fundYourCfaXafWalletFrom;

  /// No description provided for @fundYourCfaXofWalletFrom.
  ///
  /// In en, this message translates to:
  /// **'Fund your CFA · XOF wallet from Niger · Mali · Senegal · Côte d’Ivoire using mobile money, bank transfer, agent cash-in.'**
  String get fundYourCfaXofWalletFrom;

  /// No description provided for @mobileMoneyNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile money number'**
  String get mobileMoneyNumber;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountName;

  /// No description provided for @reference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get reference;

  /// No description provided for @sampleDetailsForThePrototypeDeposits.
  ///
  /// In en, this message translates to:
  /// **'Sample details for the prototype. Deposits from accounts in your own name only. Local partners per country to be confirmed.'**
  String get sampleDetailsForThePrototypeDeposits;

  /// No description provided for @simulateADeposit.
  ///
  /// In en, this message translates to:
  /// **'Simulate a deposit'**
  String get simulateADeposit;

  /// No description provided for @demoDepositReceived.
  ///
  /// In en, this message translates to:
  /// **'Demo deposit received'**
  String get demoDepositReceived;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get accountNumber;

  /// No description provided for @accountNumberCopied.
  ///
  /// In en, this message translates to:
  /// **'Account number copied'**
  String get accountNumberCopied;

  /// No description provided for @mobileMoneyNumberCopied.
  ///
  /// In en, this message translates to:
  /// **'Mobile money number copied'**
  String get mobileMoneyNumberCopied;

  /// No description provided for @accountNameCopied.
  ///
  /// In en, this message translates to:
  /// **'Account name copied'**
  String get accountNameCopied;

  /// No description provided for @referenceCopied.
  ///
  /// In en, this message translates to:
  /// **'Reference copied'**
  String get referenceCopied;

  /// No description provided for @partnerBank.
  ///
  /// In en, this message translates to:
  /// **'[Partner bank]'**
  String get partnerBank;

  /// No description provided for @fromBalance184200.
  ///
  /// In en, this message translates to:
  /// **'From · balance ₦184,200'**
  String get fromBalance184200;

  /// No description provided for @rate1Ngn00074Ghs.
  ///
  /// In en, this message translates to:
  /// **'Rate 1 NGN = 0.0074 GHS'**
  String get rate1Ngn00074Ghs;

  /// No description provided for @fee05.
  ///
  /// In en, this message translates to:
  /// **'fee 0.5%'**
  String get fee05;

  /// No description provided for @sampleRates.
  ///
  /// In en, this message translates to:
  /// **'sample rates'**
  String get sampleRates;

  /// No description provided for @exceedsBalance2.
  ///
  /// In en, this message translates to:
  /// **'exceeds balance'**
  String get exceedsBalance2;

  /// No description provided for @convertedNgnGhs.
  ///
  /// In en, this message translates to:
  /// **'Converted NGN → GHS'**
  String get convertedNgnGhs;

  /// No description provided for @convertedToGh10000.
  ///
  /// In en, this message translates to:
  /// **'Converted to GH₵100.00'**
  String get convertedToGh10000;

  /// No description provided for @send5000.
  ///
  /// In en, this message translates to:
  /// **'Send ₦5,000'**
  String get send5000;

  /// No description provided for @onJarina.
  ///
  /// In en, this message translates to:
  /// **'On Jarina'**
  String get onJarina;

  /// No description provided for @freeInstant2.
  ///
  /// In en, this message translates to:
  /// **'free & instant'**
  String get freeInstant2;

  /// No description provided for @crossBorder.
  ///
  /// In en, this message translates to:
  /// **'Cross-border'**
  String get crossBorder;

  /// No description provided for @arrivesInMinutes.
  ///
  /// In en, this message translates to:
  /// **'arrives in minutes'**
  String get arrivesInMinutes;

  /// No description provided for @sendToAnyNigerianBank.
  ///
  /// In en, this message translates to:
  /// **'Send to any Nigerian bank'**
  String get sendToAnyNigerianBank;

  /// No description provided for @accountNumberBank.
  ///
  /// In en, this message translates to:
  /// **'Account number + bank'**
  String get accountNumberBank;

  /// No description provided for @nameTagPhoneOrAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Name, @tag, phone or account number'**
  String get nameTagPhoneOrAccountNumber;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get searchPeople;

  /// No description provided for @request5000.
  ///
  /// In en, this message translates to:
  /// **'Request ₦5,000'**
  String get request5000;

  /// No description provided for @maradi.
  ///
  /// In en, this message translates to:
  /// **'Maradi'**
  String get maradi;

  /// No description provided for @fee300.
  ///
  /// In en, this message translates to:
  /// **'fee ₦300'**
  String get fee300;

  /// No description provided for @free3.
  ///
  /// In en, this message translates to:
  /// **'free'**
  String get free3;

  /// No description provided for @halimaGetsXof1950.
  ///
  /// In en, this message translates to:
  /// **'Halima gets XOF 1,950'**
  String get halimaGetsXof1950;

  /// No description provided for @rate1Ngn039Xof.
  ///
  /// In en, this message translates to:
  /// **'rate 1 NGN = 0.39 XOF'**
  String get rate1Ngn039Xof;

  /// No description provided for @whatSItFor.
  ///
  /// In en, this message translates to:
  /// **'What\'\'s it for?'**
  String get whatSItFor;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @rent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get rent;

  /// No description provided for @schoolFees.
  ///
  /// In en, this message translates to:
  /// **'School fees'**
  String get schoolFees;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @gift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get gift;

  /// No description provided for @slideToSend5000.
  ///
  /// In en, this message translates to:
  /// **'Slide to send ₦5,000'**
  String get slideToSend5000;

  /// No description provided for @slideTheButtonToSend.
  ///
  /// In en, this message translates to:
  /// **'Slide the button to send'**
  String get slideTheButtonToSend;

  /// No description provided for @addANote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get addANote;

  /// No description provided for @slideToSend5000To.
  ///
  /// In en, this message translates to:
  /// **'Slide to send ₦5,000 to Halima Issoufou. Press Enter to send.'**
  String get slideToSend5000To;

  /// No description provided for @youReRequesting.
  ///
  /// In en, this message translates to:
  /// **'You\'\'re requesting'**
  String get youReRequesting;

  /// No description provided for @bankAccount4821.
  ///
  /// In en, this message translates to:
  /// **'Bank account ••4821'**
  String get bankAccount4821;

  /// No description provided for @anyoneOnJarinaCanScanTo.
  ///
  /// In en, this message translates to:
  /// **'Anyone on Jarina can scan to pay you — free and instant'**
  String get anyoneOnJarinaCanScanTo;

  /// No description provided for @shareMyTag.
  ///
  /// In en, this message translates to:
  /// **'Share my tag'**
  String get shareMyTag;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @shareSheetOpened.
  ///
  /// In en, this message translates to:
  /// **'Share sheet opened'**
  String get shareSheetOpened;

  /// No description provided for @paymentLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Payment link copied'**
  String get paymentLinkCopied;

  /// No description provided for @requestsForYou.
  ///
  /// In en, this message translates to:
  /// **'Requests for you'**
  String get requestsForYou;

  /// No description provided for @zainabYusufRequested3000.
  ///
  /// In en, this message translates to:
  /// **'Zainab Yusuf requested ₦3,000'**
  String get zainabYusufRequested3000;

  /// No description provided for @suyaOnFriday.
  ///
  /// In en, this message translates to:
  /// **'Suya on Friday'**
  String get suyaOnFriday;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @requestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get requestDeclined;

  /// No description provided for @dataBundle.
  ///
  /// In en, this message translates to:
  /// **'Data bundle'**
  String get dataBundle;

  /// No description provided for @nairaBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Naira (bank transfer)'**
  String get nairaBankTransfer;

  /// No description provided for @cryptoDeposit.
  ///
  /// In en, this message translates to:
  /// **'Crypto deposit'**
  String get cryptoDeposit;

  /// No description provided for @transferFromAnyNigerianBankApp.
  ///
  /// In en, this message translates to:
  /// **'Transfer from any Nigerian bank app. Deposits arrive instantly and are free. Only transfers from accounts in your name are accepted.'**
  String get transferFromAnyNigerianBankApp;

  /// No description provided for @yourUsdtAddress.
  ///
  /// In en, this message translates to:
  /// **'Your USDT address'**
  String get yourUsdtAddress;

  /// No description provided for @copyAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy address'**
  String get copyAddress;

  /// No description provided for @onlySendUsdtOnTronTrc.
  ///
  /// In en, this message translates to:
  /// **'Only send USDT on TRON (TRC-20) to this address. Other coins or networks will be lost.'**
  String get onlySendUsdtOnTronTrc;

  /// No description provided for @onlySendBtcOnBitcoinTo.
  ///
  /// In en, this message translates to:
  /// **'Only send BTC on Bitcoin to this address. Other coins or networks will be lost.'**
  String get onlySendBtcOnBitcoinTo;

  /// No description provided for @autopilotRule.
  ///
  /// In en, this message translates to:
  /// **'Autopilot rule'**
  String get autopilotRule;

  /// No description provided for @whenThePrice2.
  ///
  /// In en, this message translates to:
  /// **'When the price…'**
  String get whenThePrice2;

  /// No description provided for @fallsIntoARange.
  ///
  /// In en, this message translates to:
  /// **'Falls into a range'**
  String get fallsIntoARange;

  /// No description provided for @fallsBelow.
  ///
  /// In en, this message translates to:
  /// **'Falls below'**
  String get fallsBelow;

  /// No description provided for @from2.
  ///
  /// In en, this message translates to:
  /// **'From (₦)'**
  String get from2;

  /// No description provided for @to2.
  ///
  /// In en, this message translates to:
  /// **'To (₦)'**
  String get to2;

  /// No description provided for @amount2.
  ///
  /// In en, this message translates to:
  /// **'Amount (₦)'**
  String get amount2;

  /// No description provided for @shares.
  ///
  /// In en, this message translates to:
  /// **'Shares'**
  String get shares;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @s99SharesAtYourTriggerPrice.
  ///
  /// In en, this message translates to:
  /// **'≈ 99 shares at your trigger price'**
  String get s99SharesAtYourTriggerPrice;

  /// No description provided for @s96000000AtYourTrigger.
  ///
  /// In en, this message translates to:
  /// **'≈ ₦96,000,000 at your trigger price'**
  String get s96000000AtYourTrigger;

  /// No description provided for @s25000SharesOf25Held.
  ///
  /// In en, this message translates to:
  /// **'≈ 25,000 shares of 25 held'**
  String get s25000SharesOf25Held;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @runOnce.
  ///
  /// In en, this message translates to:
  /// **'Run once'**
  String get runOnce;

  /// No description provided for @everyTime.
  ///
  /// In en, this message translates to:
  /// **'Every time'**
  String get everyTime;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @enterAPriceAndAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a price and amount.'**
  String get enterAPriceAndAmount;

  /// No description provided for @fundsComeFromYourNairaWallet2.
  ///
  /// In en, this message translates to:
  /// **'Funds come from your Naira wallet when the rule triggers. If there isn\'\'t enough cash, the rule is skipped and we notify you.'**
  String get fundsComeFromYourNairaWallet2;

  /// No description provided for @stockRulesRunOnlyDuringNgx.
  ///
  /// In en, this message translates to:
  /// **'Stock rules run only during NGX trading hours, as limit orders through our partner broker.'**
  String get stockRulesRunOnlyDuringNgx;

  /// No description provided for @cryptoRulesRun247.
  ///
  /// In en, this message translates to:
  /// **'Crypto rules run 24/7.'**
  String get cryptoRulesRun247;

  /// No description provided for @saveAuthoriseWithPin.
  ///
  /// In en, this message translates to:
  /// **'Save & authorise with PIN'**
  String get saveAuthoriseWithPin;

  /// No description provided for @risesAbove.
  ///
  /// In en, this message translates to:
  /// **'Rises above'**
  String get risesAbove;

  /// No description provided for @fallsBelowStopLoss.
  ///
  /// In en, this message translates to:
  /// **'Falls below (stop-loss)'**
  String get fallsBelowStopLoss;

  /// No description provided for @risesAbovePerShare.
  ///
  /// In en, this message translates to:
  /// **'Rises above (₦ per share)'**
  String get risesAbovePerShare;

  /// No description provided for @fallsBelowPerShare.
  ///
  /// In en, this message translates to:
  /// **'Falls below (₦ per share)'**
  String get fallsBelowPerShare;

  /// No description provided for @risesAbovePerBtc.
  ///
  /// In en, this message translates to:
  /// **'Rises above (₦ per BTC)'**
  String get risesAbovePerBtc;

  /// No description provided for @fallsBelowPerBtc.
  ///
  /// In en, this message translates to:
  /// **'Falls below (₦ per BTC)'**
  String get fallsBelowPerBtc;

  /// No description provided for @ofHolding.
  ///
  /// In en, this message translates to:
  /// **'% of holding'**
  String get ofHolding;

  /// No description provided for @ifYouHoldFewerSharesThan.
  ///
  /// In en, this message translates to:
  /// **'If you hold fewer shares than set, we sell what you have.'**
  String get ifYouHoldFewerSharesThan;

  /// No description provided for @ifYouHoldFewerBtcThan.
  ///
  /// In en, this message translates to:
  /// **'If you hold fewer BTC than set, we sell what you have.'**
  String get ifYouHoldFewerBtcThan;

  /// No description provided for @createAnAlert.
  ///
  /// In en, this message translates to:
  /// **'Create an alert'**
  String get createAnAlert;

  /// No description provided for @createAnAlertPrice.
  ///
  /// In en, this message translates to:
  /// **'Create an alert price'**
  String get createAnAlertPrice;

  /// No description provided for @getNotifiedOnAllYourDevices.
  ///
  /// In en, this message translates to:
  /// **'Get notified on all your devices when MTNN reaches your price.'**
  String get getNotifiedOnAllYourDevices;

  /// No description provided for @now86190.
  ///
  /// In en, this message translates to:
  /// **'Now ₦861.90'**
  String get now86190;

  /// No description provided for @alertMeWhenThePrice.
  ///
  /// In en, this message translates to:
  /// **'Alert me when the price'**
  String get alertMeWhenThePrice;

  /// No description provided for @goesAbove.
  ///
  /// In en, this message translates to:
  /// **'Goes above'**
  String get goesAbove;

  /// No description provided for @goesBelow.
  ///
  /// In en, this message translates to:
  /// **'Goes below'**
  String get goesBelow;

  /// No description provided for @targetPrice.
  ///
  /// In en, this message translates to:
  /// **'Target price (₦)'**
  String get targetPrice;

  /// No description provided for @targetPrice2.
  ///
  /// In en, this message translates to:
  /// **'Target price'**
  String get targetPrice2;

  /// No description provided for @s50FromTheCurrentPrice.
  ///
  /// In en, this message translates to:
  /// **'+5.0% from the current price'**
  String get s50FromTheCurrentPrice;

  /// No description provided for @notifyMeBy.
  ///
  /// In en, this message translates to:
  /// **'Notify me by'**
  String get notifyMeBy;

  /// No description provided for @sms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get sms;

  /// No description provided for @weLlNotifyYouByPush.
  ///
  /// In en, this message translates to:
  /// **'We\'\'ll notify you by Push when'**
  String get weLlNotifyYouByPush;

  /// No description provided for @weLlNotifyYouByPush2.
  ///
  /// In en, this message translates to:
  /// **'We\'\'ll notify you by Push, SMS when'**
  String get weLlNotifyYouByPush2;

  /// No description provided for @goesAbove2.
  ///
  /// In en, this message translates to:
  /// **'goes above'**
  String get goesAbove2;

  /// No description provided for @goesBelow2.
  ///
  /// In en, this message translates to:
  /// **'goes below'**
  String get goesBelow2;

  /// No description provided for @pickAPriceAndAtLeast.
  ///
  /// In en, this message translates to:
  /// **'Pick a price and at least one channel.'**
  String get pickAPriceAndAtLeast;

  /// No description provided for @wantJarinaToTradeAutomaticallyInstead.
  ///
  /// In en, this message translates to:
  /// **'Want Jarina to trade automatically instead? Use Autopilot'**
  String get wantJarinaToTradeAutomaticallyInstead;

  /// No description provided for @sending5000.
  ///
  /// In en, this message translates to:
  /// **'Sending ₦5,000'**
  String get sending5000;

  /// No description provided for @toHalimaIssoufou.
  ///
  /// In en, this message translates to:
  /// **'to Halima Issoufou'**
  String get toHalimaIssoufou;

  /// No description provided for @securingWith256BitEncryption.
  ///
  /// In en, this message translates to:
  /// **'securing with 256-bit encryption'**
  String get securingWith256BitEncryption;

  /// No description provided for @sentToHalima.
  ///
  /// In en, this message translates to:
  /// **'Sent to Halima'**
  String get sentToHalima;

  /// No description provided for @arrivingInMaradiNigerWithinMinutes.
  ///
  /// In en, this message translates to:
  /// **'Arriving in Maradi, Niger within minutes.'**
  String get arrivingInMaradiNigerWithinMinutes;

  /// No description provided for @deliveredInstantly.
  ///
  /// In en, this message translates to:
  /// **'Delivered instantly.'**
  String get deliveredInstantly;

  /// No description provided for @s10JarinaPoints.
  ///
  /// In en, this message translates to:
  /// **'+10 Jarina points'**
  String get s10JarinaPoints;

  /// No description provided for @s240Total.
  ///
  /// In en, this message translates to:
  /// **'240 total'**
  String get s240Total;

  /// No description provided for @s3WeekSendingStreak.
  ///
  /// In en, this message translates to:
  /// **'3-week sending streak'**
  String get s3WeekSendingStreak;

  /// No description provided for @requestSentToZainab.
  ///
  /// In en, this message translates to:
  /// **'Request sent to Zainab'**
  String get requestSentToZainab;

  /// No description provided for @weLlLetYouKnowWhen.
  ///
  /// In en, this message translates to:
  /// **'We\'\'ll let you know when Zainab pays.'**
  String get weLlLetYouKnowWhen;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @transactionSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Transaction successful'**
  String get transactionSuccessful;

  /// No description provided for @pending3.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending3;

  /// No description provided for @transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionId;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get dateTime;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @moneyIn.
  ///
  /// In en, this message translates to:
  /// **'Money in'**
  String get moneyIn;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @channel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channel;

  /// No description provided for @jarinaMobileApp.
  ///
  /// In en, this message translates to:
  /// **'Jarina mobile app'**
  String get jarinaMobileApp;

  /// No description provided for @scanToVerifyThisReceiptIn.
  ///
  /// In en, this message translates to:
  /// **'Scan to verify this receipt in Jarina'**
  String get scanToVerifyThisReceiptIn;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @reportAnIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportAnIssue;

  /// No description provided for @shareReceipt2.
  ///
  /// In en, this message translates to:
  /// **'Share receipt'**
  String get shareReceipt2;

  /// No description provided for @receiptShared.
  ///
  /// In en, this message translates to:
  /// **'Receipt shared'**
  String get receiptShared;

  /// No description provided for @pdfReceiptSaved.
  ///
  /// In en, this message translates to:
  /// **'PDF receipt saved'**
  String get pdfReceiptSaved;

  /// No description provided for @supportTicketOpenedFor261004352978025.
  ///
  /// In en, this message translates to:
  /// **'Support ticket opened for 261004352978025'**
  String get supportTicketOpenedFor261004352978025;

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipient;

  /// No description provided for @amountSent.
  ///
  /// In en, this message translates to:
  /// **'Amount sent'**
  String get amountSent;

  /// No description provided for @exchangeRate.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate'**
  String get exchangeRate;

  /// No description provided for @totalDebited.
  ///
  /// In en, this message translates to:
  /// **'Total debited'**
  String get totalDebited;

  /// No description provided for @netCredited.
  ///
  /// In en, this message translates to:
  /// **'Net credited'**
  String get netCredited;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @asset.
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get asset;

  /// No description provided for @side.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get side;

  /// No description provided for @buyMarket.
  ///
  /// In en, this message translates to:
  /// **'Buy (market)'**
  String get buyMarket;

  /// No description provided for @sellMarket.
  ///
  /// In en, this message translates to:
  /// **'Sell (market)'**
  String get sellMarket;

  /// No description provided for @quantity2.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity2;

  /// No description provided for @sendReceive2.
  ///
  /// In en, this message translates to:
  /// **'Send & Receive'**
  String get sendReceive2;

  /// No description provided for @lastLoggedInToday941.
  ///
  /// In en, this message translates to:
  /// **'Last logged in today, 9:41'**
  String get lastLoggedInToday941;

  /// No description provided for @closeMenu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get closeMenu;

  /// No description provided for @watchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlist;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @logosWillResetWhenThisPage.
  ///
  /// In en, this message translates to:
  /// **'Logos will reset when this page closes'**
  String get logosWillResetWhenThisPage;

  /// No description provided for @mtnnLogoRemoved.
  ///
  /// In en, this message translates to:
  /// **'MTNN logo removed'**
  String get mtnnLogoRemoved;

  /// No description provided for @s3LogosAdded.
  ///
  /// In en, this message translates to:
  /// **'3 logos added'**
  String get s3LogosAdded;

  /// No description provided for @s1LogoAdded.
  ///
  /// In en, this message translates to:
  /// **'1 logo added'**
  String get s1LogoAdded;

  /// No description provided for @livenessCheckPassed.
  ///
  /// In en, this message translates to:
  /// **'Liveness check passed'**
  String get livenessCheckPassed;

  /// No description provided for @receivePayment.
  ///
  /// In en, this message translates to:
  /// **'Receive Payment'**
  String get receivePayment;

  /// No description provided for @tier.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get tier;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'daily'**
  String get daily;

  /// No description provided for @shares2.
  ///
  /// In en, this message translates to:
  /// **'shares'**
  String get shares2;

  /// No description provided for @investmentMadeEasy.
  ///
  /// In en, this message translates to:
  /// **'Investment Made Easy'**
  String get investmentMadeEasy;

  /// No description provided for @jarinaCryptoStockTrainingApp.
  ///
  /// In en, this message translates to:
  /// **'Jarina — Crypto & Stock Training App'**
  String get jarinaCryptoStockTrainingApp;

  /// No description provided for @convertedTo13433.
  ///
  /// In en, this message translates to:
  /// **'Converted to ₦13,433'**
  String get convertedTo13433;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @s1Usdt1550.
  ///
  /// In en, this message translates to:
  /// **'1 USDT ≈ ₦1,550'**
  String get s1Usdt1550;

  /// No description provided for @electricityKedco.
  ///
  /// In en, this message translates to:
  /// **'Electricity · KEDCO'**
  String get electricityKedco;

  /// No description provided for @depositMobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Deposit · Mobile money'**
  String get depositMobileMoney;

  /// No description provided for @depositBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Deposit · Bank transfer'**
  String get depositBankTransfer;

  /// No description provided for @airtimeMtn.
  ///
  /// In en, this message translates to:
  /// **'Airtime · MTN'**
  String get airtimeMtn;

  /// No description provided for @rate1Ghs1350000Ngn.
  ///
  /// In en, this message translates to:
  /// **'Rate 1 GHS = 135.0000 NGN'**
  String get rate1Ghs1350000Ngn;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @arrives.
  ///
  /// In en, this message translates to:
  /// **'Arrives'**
  String get arrives;

  /// No description provided for @withinMinutes.
  ///
  /// In en, this message translates to:
  /// **'Within minutes'**
  String get withinMinutes;

  /// No description provided for @theyReceive.
  ///
  /// In en, this message translates to:
  /// **'They receive'**
  String get theyReceive;

  /// No description provided for @rateLocked10Min.
  ///
  /// In en, this message translates to:
  /// **'Rate (locked 10 min)'**
  String get rateLocked10Min;

  /// No description provided for @bitcoin.
  ///
  /// In en, this message translates to:
  /// **'Bitcoin'**
  String get bitcoin;

  /// No description provided for @ratesAreSampleValues.
  ///
  /// In en, this message translates to:
  /// **'Rates are sample values.'**
  String get ratesAreSampleValues;

  /// No description provided for @s2Active.
  ///
  /// In en, this message translates to:
  /// **'2 active'**
  String get s2Active;

  /// No description provided for @now10672.
  ///
  /// In en, this message translates to:
  /// **'Now ₦1,067 ·'**
  String get now10672;

  /// No description provided for @fundsComeFromYourNairaWallet3.
  ///
  /// In en, this message translates to:
  /// **'Funds come from your Naira wallet when the rule triggers. If there isn\'\'t enough cash, the rule is skipped and we notify you. Stock rules run only during NGX trading hours, as limit orders through our partner broker.'**
  String get fundsComeFromYourNairaWallet3;

  /// No description provided for @fundsComeFromYourNairaWallet4.
  ///
  /// In en, this message translates to:
  /// **'Funds come from your Naira wallet when the rule triggers. If there isn\'\'t enough cash, the rule is skipped and we notify you. Crypto rules run 24/7.'**
  String get fundsComeFromYourNairaWallet4;

  /// No description provided for @ifYouHoldFewerSharesThan2.
  ///
  /// In en, this message translates to:
  /// **'If you hold fewer shares than set, we sell what you have. Stock rules run only during NGX trading hours, as limit orders through our partner broker.'**
  String get ifYouHoldFewerSharesThan2;

  /// No description provided for @ifYouHoldFewerBtcThan2.
  ///
  /// In en, this message translates to:
  /// **'If you hold fewer BTC than set, we sell what you have. Crypto rules run 24/7.'**
  String get ifYouHoldFewerBtcThan2;

  /// No description provided for @s20Sep2026.
  ///
  /// In en, this message translates to:
  /// **'20 Sep 2026'**
  String get s20Sep2026;

  /// No description provided for @s04Oct2026.
  ///
  /// In en, this message translates to:
  /// **'04 Oct 2026'**
  String get s04Oct2026;

  /// No description provided for @s04Nov2026.
  ///
  /// In en, this message translates to:
  /// **'04 Nov 2026'**
  String get s04Nov2026;

  /// No description provided for @s04Dec2026.
  ///
  /// In en, this message translates to:
  /// **'04 Dec 2026'**
  String get s04Dec2026;

  /// No description provided for @s04Oct.
  ///
  /// In en, this message translates to:
  /// **'04 Oct'**
  String get s04Oct;

  /// No description provided for @stepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String stepOf(String step, String total);

  /// No description provided for @stepOfSection.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total} · {section}'**
  String stepOfSection(String step, String total, String section);

  /// No description provided for @yourCountry.
  ///
  /// In en, this message translates to:
  /// **'Your country'**
  String get yourCountry;

  /// No description provided for @yourAccount.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get yourAccount;

  /// No description provided for @verifyLabel.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyLabel;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to your WhatsApp on {phone}.'**
  String otpSentTo(String phone);

  /// No description provided for @otpSentBySms.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent by SMS to {phone}.'**
  String otpSentBySms(String phone);

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {time}'**
  String resendCodeIn(String time);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'New code sent'**
  String get codeResent;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your {digits}-digit WhatsApp number, e.g. {sample}'**
  String phoneHint(String digits, String sample);

  /// No description provided for @usernameAvailable.
  ///
  /// In en, this message translates to:
  /// **'@{handle} is available'**
  String usernameAvailable(String handle);

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'@{handle} is taken. Try a suggestion.'**
  String usernameTaken(String handle);

  /// No description provided for @usernameChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get usernameChecking;

  /// No description provided for @claimHandle.
  ///
  /// In en, this message translates to:
  /// **'Claim @{handle}'**
  String claimHandle(String handle);

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'yourname'**
  String get yourName;

  /// No description provided for @errRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get errRequired;

  /// No description provided for @errTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get errTooShort;

  /// No description provided for @errTooLong.
  ///
  /// In en, this message translates to:
  /// **'Too long'**
  String get errTooLong;

  /// No description provided for @errPhoneShort.
  ///
  /// In en, this message translates to:
  /// **'Number is too short'**
  String get errPhoneShort;

  /// No description provided for @errPhoneLong.
  ///
  /// In en, this message translates to:
  /// **'Number is too long'**
  String get errPhoneLong;

  /// No description provided for @errInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Check this and try again'**
  String get errInvalidFormat;

  /// No description provided for @errNameChars.
  ///
  /// In en, this message translates to:
  /// **'Use letters only, as on your ID'**
  String get errNameChars;

  /// No description provided for @errEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get errEmail;

  /// No description provided for @errUsernameStart.
  ///
  /// In en, this message translates to:
  /// **'Must start with a letter'**
  String get errUsernameStart;

  /// No description provided for @errUsernameChars.
  ///
  /// In en, this message translates to:
  /// **'Use only letters, numbers, _ or .'**
  String get errUsernameChars;

  /// No description provided for @errReserved.
  ///
  /// In en, this message translates to:
  /// **'This username is reserved'**
  String get errReserved;

  /// No description provided for @errUnderage.
  ///
  /// In en, this message translates to:
  /// **'You must be 18 or older'**
  String get errUnderage;

  /// No description provided for @errInvalidDate.
  ///
  /// In en, this message translates to:
  /// **'Enter a real date as DD / MM / YYYY'**
  String get errInvalidDate;

  /// No description provided for @errWeakPin.
  ///
  /// In en, this message translates to:
  /// **'Too easy to guess. Avoid birthdays and repeated digits.'**
  String get errWeakPin;

  /// No description provided for @errPinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs don\'\'t match. Create it again.'**
  String get errPinMismatch;

  /// No description provided for @errWrongCode.
  ///
  /// In en, this message translates to:
  /// **'That code isn\'\'t right. Try again.'**
  String get errWrongCode;

  /// No description provided for @errCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired. Request a new one.'**
  String get errCodeExpired;

  /// No description provided for @errNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get errNetwork;

  /// No description provided for @errGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errGeneric;

  /// No description provided for @errTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in {minutes} min.'**
  String errTooManyAttempts(String minutes);

  /// No description provided for @errIdNotVerified.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'\'t verify this number. Check it and try again.'**
  String get errIdNotVerified;

  /// No description provided for @errLogin.
  ///
  /// In en, this message translates to:
  /// **'Wrong number or password.'**
  String get errLogin;

  /// No description provided for @signInComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{provider} sign-in is coming soon.'**
  String signInComingSoon(String provider);

  /// No description provided for @keyCopied.
  ///
  /// In en, this message translates to:
  /// **'Key copied'**
  String get keyCopied;

  /// No description provided for @copyCodes.
  ///
  /// In en, this message translates to:
  /// **'Copy codes'**
  String get copyCodes;

  /// No description provided for @codesCopied.
  ///
  /// In en, this message translates to:
  /// **'Backup codes copied'**
  String get codesCopied;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @skip2faWarning.
  ///
  /// In en, this message translates to:
  /// **'2FA is optional during sign-up, but your account stays disabled until you turn it on.'**
  String get skip2faWarning;

  /// No description provided for @livenessHold.
  ///
  /// In en, this message translates to:
  /// **'Hold still…'**
  String get livenessHold;

  /// No description provided for @livenessDone.
  ///
  /// In en, this message translates to:
  /// **'Selfie captured'**
  String get livenessDone;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @idHintNin.
  ///
  /// In en, this message translates to:
  /// **'Your 11-digit National Identification Number.'**
  String get idHintNin;

  /// No description provided for @idHintPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport number as printed on the photo page.'**
  String get idHintPassport;

  /// No description provided for @idHintNationalId.
  ///
  /// In en, this message translates to:
  /// **'Number as printed on your card.'**
  String get idHintNationalId;

  /// No description provided for @idOtherCountries.
  ///
  /// In en, this message translates to:
  /// **'Verify with your national ID, passport or voter card. Your details are checked against the official registry.'**
  String get idOtherCountries;

  /// No description provided for @nationalIdNumber.
  ///
  /// In en, this message translates to:
  /// **'National Identification Number (NIN)'**
  String get nationalIdNumber;

  /// No description provided for @passportNumber.
  ///
  /// In en, this message translates to:
  /// **'Passport number'**
  String get passportNumber;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get cardNumber;

  /// No description provided for @digitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} digits'**
  String digitsCount(String count);

  /// No description provided for @dobHint.
  ///
  /// In en, this message translates to:
  /// **'DD / MM / YYYY'**
  String get dobHint;

  /// No description provided for @regionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} regions'**
  String regionsCount(String count);

  /// No description provided for @statesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} states'**
  String statesCount(String count);

  /// No description provided for @departmentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} departments'**
  String departmentsCount(String count);

  /// No description provided for @selectRegion.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get selectRegion;

  /// No description provided for @selectDepartment.
  ///
  /// In en, this message translates to:
  /// **'Select department'**
  String get selectDepartment;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @countryNG.
  ///
  /// In en, this message translates to:
  /// **'Nigeria'**
  String get countryNG;

  /// No description provided for @countryNE.
  ///
  /// In en, this message translates to:
  /// **'Niger'**
  String get countryNE;

  /// No description provided for @countryGH.
  ///
  /// In en, this message translates to:
  /// **'Ghana'**
  String get countryGH;

  /// No description provided for @countryCM.
  ///
  /// In en, this message translates to:
  /// **'Cameroon'**
  String get countryCM;

  /// No description provided for @countryBJ.
  ///
  /// In en, this message translates to:
  /// **'Benin Republic'**
  String get countryBJ;

  /// No description provided for @countryTG.
  ///
  /// In en, this message translates to:
  /// **'Togo'**
  String get countryTG;

  /// No description provided for @demoCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Test build: use code {code}'**
  String demoCodeHint(String code);

  /// No description provided for @pinCreateStep.
  ///
  /// In en, this message translates to:
  /// **'1 · Create'**
  String get pinCreateStep;

  /// No description provided for @pinConfirmStep.
  ///
  /// In en, this message translates to:
  /// **'2 · Confirm'**
  String get pinConfirmStep;

  /// No description provided for @enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get enterCode;

  /// No description provided for @backupCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Backup code'**
  String get backupCodeHint;

  /// No description provided for @useAuthenticatorInstead.
  ///
  /// In en, this message translates to:
  /// **'Use authenticator code instead'**
  String get useAuthenticatorInstead;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get passwordHint;

  /// No description provided for @forgotPasswordSoon.
  ///
  /// In en, this message translates to:
  /// **'Password reset is coming soon. Contact support for help.'**
  String get forgotPasswordSoon;

  /// No description provided for @helpSoon.
  ///
  /// In en, this message translates to:
  /// **'Support chat opens after sign-up.'**
  String get helpSoon;

  /// No description provided for @rotatingHeadline.
  ///
  /// In en, this message translates to:
  /// **'Stocks, crypto and cross-border money — in one place.'**
  String get rotatingHeadline;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'NGX shares · Bitcoin & stablecoins · Naira, Cedi & CFA wallets'**
  String get welcomeTagline;

  /// No description provided for @tier3.
  ///
  /// In en, this message translates to:
  /// **'Tier 3'**
  String get tier3;

  /// No description provided for @btcUsdt.
  ///
  /// In en, this message translates to:
  /// **'BTC, USDT…'**
  String get btcUsdt;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @selfieCaptured.
  ///
  /// In en, this message translates to:
  /// **'Selfie captured. We\'\'ll match it to your ID.'**
  String get selfieCaptured;

  /// No description provided for @continueLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get continueLabelShort;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @p2pTransfer.
  ///
  /// In en, this message translates to:
  /// **'P2P transfer'**
  String get p2pTransfer;

  /// No description provided for @p2pTransferSub.
  ///
  /// In en, this message translates to:
  /// **'Send any wallet to a Jarina user by @username — free'**
  String get p2pTransferSub;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @fundWith.
  ///
  /// In en, this message translates to:
  /// **'Fund with: {rails}'**
  String fundWith(String rails);

  /// No description provided for @lastLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Last logged in {time}'**
  String lastLoggedIn(String time);

  /// No description provided for @enterYourPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your transaction PIN'**
  String get enterYourPin;

  /// No description provided for @pinToApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve {action}'**
  String pinToApprove(String action);

  /// No description provided for @errWrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN. {left} attempts left.'**
  String errWrongPin(String left);

  /// No description provided for @errPinLocked.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong PINs. Try again in 15 minutes.'**
  String get errPinLocked;

  /// No description provided for @exceedsBalance.
  ///
  /// In en, this message translates to:
  /// **'Exceeds your balance'**
  String get exceedsBalance;

  /// No description provided for @convertRateLine.
  ///
  /// In en, this message translates to:
  /// **'Rate 1 {from} = {rate} {to} · fee {fee}'**
  String convertRateLine(String from, String rate, String to, String fee);

  /// No description provided for @youReceive.
  ///
  /// In en, this message translates to:
  /// **'You receive'**
  String get youReceive;

  /// No description provided for @fromBalance.
  ///
  /// In en, this message translates to:
  /// **'From · balance {balance}'**
  String fromBalance(String balance);

  /// No description provided for @convertedTitle.
  ///
  /// In en, this message translates to:
  /// **'Converted {from} to {to}'**
  String convertedTitle(String from, String to);

  /// No description provided for @requestedAmount.
  ///
  /// In en, this message translates to:
  /// **'{name} requested {amount}'**
  String requestedAmount(String name, String amount);

  /// No description provided for @payTagText.
  ///
  /// In en, this message translates to:
  /// **'Pay me on Jarina: {link}'**
  String payTagText(String link);

  /// No description provided for @shareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share receipt'**
  String get shareReceipt;

  /// No description provided for @depositSimulated.
  ///
  /// In en, this message translates to:
  /// **'Test deposit added'**
  String get depositSimulated;

  /// No description provided for @testBuildOnly.
  ///
  /// In en, this message translates to:
  /// **'Test build only'**
  String get testBuildOnly;

  /// No description provided for @fundingNote.
  ///
  /// In en, this message translates to:
  /// **'Deposits from accounts in your own name only. Money usually lands within minutes.'**
  String get fundingNote;

  /// No description provided for @addCurrency.
  ///
  /// In en, this message translates to:
  /// **'Add {currency}'**
  String addCurrency(String currency);

  /// No description provided for @fundCurrencyFrom.
  ///
  /// In en, this message translates to:
  /// **'Fund your {wallet} from {country} using {rails}.'**
  String fundCurrencyFrom(String wallet, String country, String rails);

  /// No description provided for @walletOf.
  ///
  /// In en, this message translates to:
  /// **'{name} wallet'**
  String walletOf(String name);

  /// No description provided for @nWallets.
  ///
  /// In en, this message translates to:
  /// **'{count} wallets'**
  String nWallets(String count);

  /// No description provided for @hideBalances.
  ///
  /// In en, this message translates to:
  /// **'Hide balances'**
  String get hideBalances;

  /// No description provided for @showBalances.
  ///
  /// In en, this message translates to:
  /// **'Show balances'**
  String get showBalances;

  /// No description provided for @displayCurrency.
  ///
  /// In en, this message translates to:
  /// **'Show balances in'**
  String get displayCurrency;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @currencyConversion.
  ///
  /// In en, this message translates to:
  /// **'Currency conversion'**
  String get currencyConversion;

  /// No description provided for @deposit.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get deposit;

  /// No description provided for @billPayment.
  ///
  /// In en, this message translates to:
  /// **'Bill payment'**
  String get billPayment;

  /// No description provided for @cryptoTrade.
  ///
  /// In en, this message translates to:
  /// **'Crypto trade'**
  String get cryptoTrade;

  /// No description provided for @p2pPayment.
  ///
  /// In en, this message translates to:
  /// **'P2P payment'**
  String get p2pPayment;

  /// No description provided for @receiptNotFound.
  ///
  /// In en, this message translates to:
  /// **'Receipt not found'**
  String get receiptNotFound;

  /// No description provided for @youGet.
  ///
  /// In en, this message translates to:
  /// **'You get'**
  String get youGet;

  /// No description provided for @youSell.
  ///
  /// In en, this message translates to:
  /// **'You sell'**
  String get youSell;

  /// No description provided for @livePrice.
  ///
  /// In en, this message translates to:
  /// **'Live price'**
  String get livePrice;

  /// No description provided for @balanceOf.
  ///
  /// In en, this message translates to:
  /// **'Balance {amount}'**
  String balanceOf(String amount);

  /// No description provided for @youHold.
  ///
  /// In en, this message translates to:
  /// **'You hold {amount}'**
  String youHold(String amount);

  /// No description provided for @slideToBuy.
  ///
  /// In en, this message translates to:
  /// **'Slide to buy'**
  String get slideToBuy;

  /// No description provided for @slideToSell.
  ///
  /// In en, this message translates to:
  /// **'Slide to sell'**
  String get slideToSell;

  /// No description provided for @enterAnAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get enterAnAmount;

  /// No description provided for @ngxOpen.
  ///
  /// In en, this message translates to:
  /// **'NGX open · delayed 15 min'**
  String get ngxOpen;

  /// No description provided for @ngxClosed.
  ///
  /// In en, this message translates to:
  /// **'NGX closed · opens {when}'**
  String ngxClosed(String when);

  /// No description provided for @ngxClosedOrderNote.
  ///
  /// In en, this message translates to:
  /// **'The market is closed. Your order will be sent when NGX opens ({when}) at the price then.'**
  String ngxClosedOrderNote(String when);

  /// No description provided for @walletLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletLabel;

  /// No description provided for @notEnoughBalance.
  ///
  /// In en, this message translates to:
  /// **'Not enough balance'**
  String get notEnoughBalance;

  /// No description provided for @notEnoughShares.
  ///
  /// In en, this message translates to:
  /// **'You don\'\'t hold that many shares'**
  String get notEnoughShares;

  /// No description provided for @minOneShare.
  ///
  /// In en, this message translates to:
  /// **'Enough for at least 1 share ({price})'**
  String minOneShare(String price);

  /// No description provided for @sharesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} shares'**
  String sharesCount(String count);

  /// No description provided for @feeAmount.
  ///
  /// In en, this message translates to:
  /// **'fee {amount}'**
  String feeAmount(String amount);

  /// No description provided for @pricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'1 {asset} = {price}'**
  String pricePerUnit(String asset, String price);

  /// No description provided for @pricePerShare.
  ///
  /// In en, this message translates to:
  /// **'{price} per share'**
  String pricePerShare(String price);

  /// No description provided for @buyAsset.
  ///
  /// In en, this message translates to:
  /// **'Buy {asset}'**
  String buyAsset(String asset);

  /// No description provided for @sellAsset.
  ///
  /// In en, this message translates to:
  /// **'Sell {asset}'**
  String sellAsset(String asset);

  /// No description provided for @boughtAsset.
  ///
  /// In en, this message translates to:
  /// **'Bought {asset}'**
  String boughtAsset(String asset);

  /// No description provided for @soldAsset.
  ///
  /// In en, this message translates to:
  /// **'Sold {asset}'**
  String soldAsset(String asset);

  /// No description provided for @orderQueued.
  ///
  /// In en, this message translates to:
  /// **'Order queued'**
  String get orderQueued;

  /// No description provided for @orderQueuedBody.
  ///
  /// In en, this message translates to:
  /// **'NGX is closed. We\'\'ll send your order when the market opens and notify you when it fills.'**
  String get orderQueuedBody;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @youReceiveEst.
  ///
  /// In en, this message translates to:
  /// **'You receive (est.)'**
  String get youReceiveEst;

  /// No description provided for @stocksCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stocks'**
  String stocksCount(String count);

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String activeCount(String count);

  /// No description provided for @addToWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Add to watchlist'**
  String get addToWatchlist;

  /// No description provided for @removeFromWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Remove from watchlist'**
  String get removeFromWatchlist;

  /// No description provided for @rangeDay.
  ///
  /// In en, this message translates to:
  /// **'1D'**
  String get rangeDay;

  /// No description provided for @rangeWeek.
  ///
  /// In en, this message translates to:
  /// **'1W'**
  String get rangeWeek;

  /// No description provided for @rangeMonth.
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get rangeMonth;

  /// No description provided for @rangeYear.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get rangeYear;

  /// No description provided for @rangeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get rangeAll;

  /// No description provided for @todaySuffix.
  ///
  /// In en, this message translates to:
  /// **'{change} · today'**
  String todaySuffix(String change);

  /// No description provided for @noHoldings.
  ///
  /// In en, this message translates to:
  /// **'You don\'\'t hold any yet'**
  String get noHoldings;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @priceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Price updated. Check the new total and confirm.'**
  String get priceUpdated;

  /// No description provided for @popularPairs.
  ///
  /// In en, this message translates to:
  /// **'Popular pairs'**
  String get popularPairs;

  /// No description provided for @slideToSwap.
  ///
  /// In en, this message translates to:
  /// **'Slide to swap'**
  String get slideToSwap;

  /// No description provided for @swapNote.
  ///
  /// In en, this message translates to:
  /// **'Rates refresh every 15 seconds. Nothing moves until you slide to swap and confirm with your PIN.'**
  String get swapNote;

  /// No description provided for @memoTag.
  ///
  /// In en, this message translates to:
  /// **'Memo / tag'**
  String get memoTag;

  /// No description provided for @memoRequiredNote.
  ///
  /// In en, this message translates to:
  /// **'Include this memo/tag or your deposit can\'\'t be credited.'**
  String get memoRequiredNote;

  /// No description provided for @sendOnlyOn.
  ///
  /// In en, this message translates to:
  /// **'Send only {coin} on {network} to this address. Deposits are credited after network confirmations.'**
  String sendOnlyOn(String coin, String network);

  /// No description provided for @addressCopied.
  ///
  /// In en, this message translates to:
  /// **'Address copied'**
  String get addressCopied;

  /// No description provided for @errInvalidAddress.
  ///
  /// In en, this message translates to:
  /// **'This isn\'\'t a valid {network} address'**
  String errInvalidAddress(String network);

  /// No description provided for @errUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No Jarina user with that @username'**
  String get errUserNotFound;

  /// No description provided for @errAmountBelowFee.
  ///
  /// In en, this message translates to:
  /// **'Amount must be more than the network fee'**
  String get errAmountBelowFee;

  /// No description provided for @errMinCashOut.
  ///
  /// In en, this message translates to:
  /// **'Minimum cash out is {amount}'**
  String errMinCashOut(String amount);

  /// No description provided for @availableAmount.
  ///
  /// In en, this message translates to:
  /// **'Available {amount}'**
  String availableAmount(String amount);

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free · instant'**
  String get free;

  /// No description provided for @transferFee.
  ///
  /// In en, this message translates to:
  /// **'Transfer fee'**
  String get transferFee;

  /// No description provided for @withdrawCoin.
  ///
  /// In en, this message translates to:
  /// **'Withdraw {coin}'**
  String withdrawCoin(String coin);

  /// No description provided for @withdrawalSent.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal submitted. It\'\'ll be broadcast shortly.'**
  String get withdrawalSent;

  /// No description provided for @sentToUser.
  ///
  /// In en, this message translates to:
  /// **'Sent to @{user}'**
  String sentToUser(String user);

  /// No description provided for @confirmationsOf.
  ///
  /// In en, this message translates to:
  /// **'{n} of {m} network confirmations'**
  String confirmationsOf(String n, String m);

  /// No description provided for @percentFilled.
  ///
  /// In en, this message translates to:
  /// **'{pct}% filled'**
  String percentFilled(String pct);

  /// No description provided for @partiallyFilled.
  ///
  /// In en, this message translates to:
  /// **'Partially filled'**
  String get partiallyFilled;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order cancelled'**
  String get orderCancelled;

  /// No description provided for @withdrawalCancelled.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal cancelled · funds returned'**
  String get withdrawalCancelled;

  /// No description provided for @buyCoin.
  ///
  /// In en, this message translates to:
  /// **'Buy {coin}'**
  String buyCoin(String coin);

  /// No description provided for @sellCoin.
  ///
  /// In en, this message translates to:
  /// **'Sell {coin}'**
  String sellCoin(String coin);

  /// No description provided for @yourCoinWallet.
  ///
  /// In en, this message translates to:
  /// **'Your {coin} wallet'**
  String yourCoinWallet(String coin);

  /// No description provided for @purchaseLimits.
  ///
  /// In en, this message translates to:
  /// **'Limits {min} – {max} per purchase'**
  String purchaseLimits(String min, String max);

  /// No description provided for @oneTimeAccount.
  ///
  /// In en, this message translates to:
  /// **'Pay into this one-time account'**
  String get oneTimeAccount;

  /// No description provided for @oneTimeAccountNote.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ll get a one-time account to pay into. Crypto is credited as soon as your transfer lands.'**
  String get oneTimeAccountNote;

  /// No description provided for @simulatePayment.
  ///
  /// In en, this message translates to:
  /// **'Simulate payment · test build'**
  String get simulatePayment;

  /// No description provided for @cashOutIntro.
  ///
  /// In en, this message translates to:
  /// **'Sell crypto and receive Naira in any Nigerian bank account, usually within minutes.'**
  String get cashOutIntro;

  /// No description provided for @bankLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bankLabel;

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'Account name: {name}'**
  String accountVerified(String name);

  /// No description provided for @loanIntro.
  ///
  /// In en, this message translates to:
  /// **'Get Naira without selling your crypto. Your coins are held as collateral and returned when you repay.'**
  String get loanIntro;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'{rate} per month'**
  String perMonth(String rate);

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{n} days'**
  String daysCount(String n);

  /// No description provided for @autoSwapIntro.
  ///
  /// In en, this message translates to:
  /// **'Automatically convert crypto you receive, so volatile coins become stable value the moment they land.'**
  String get autoSwapIntro;

  /// No description provided for @autoSwapNote.
  ///
  /// In en, this message translates to:
  /// **'Conversions use the instant-swap rate at the moment each deposit confirms. Each one gets its own receipt.'**
  String get autoSwapNote;

  /// No description provided for @convertTo.
  ///
  /// In en, this message translates to:
  /// **'Convert to'**
  String get convertTo;

  /// No description provided for @cryptoPortfolioChange.
  ///
  /// In en, this message translates to:
  /// **'{change} today'**
  String cryptoPortfolioChange(String change);

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'{n} pending'**
  String pendingCount(String n);

  /// No description provided for @newCount.
  ///
  /// In en, this message translates to:
  /// **'{n} new'**
  String newCount(String n);

  /// No description provided for @offLabel.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get offLabel;

  /// No description provided for @coinsCount.
  ///
  /// In en, this message translates to:
  /// **'{n} coins'**
  String coinsCount(String n);

  /// No description provided for @candles.
  ///
  /// In en, this message translates to:
  /// **'{n} candles'**
  String candles(String n);

  /// No description provided for @dragToInspect.
  ///
  /// In en, this message translates to:
  /// **'Drag across the chart to inspect · tap a price in the book to use it'**
  String get dragToInspect;

  /// No description provided for @buyCoinShort.
  ///
  /// In en, this message translates to:
  /// **'Buy {coin}'**
  String buyCoinShort(String coin);

  /// No description provided for @orderPlacedShort.
  ///
  /// In en, this message translates to:
  /// **'Order placed'**
  String get orderPlacedShort;

  /// No description provided for @orderFilled.
  ///
  /// In en, this message translates to:
  /// **'Order filled'**
  String get orderFilled;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Vol'**
  String get volume;

  /// No description provided for @loanTaken.
  ///
  /// In en, this message translates to:
  /// **'Loan sent to your Naira wallet'**
  String get loanTaken;

  /// No description provided for @autoSwapOn.
  ///
  /// In en, this message translates to:
  /// **'Auto-swap on · to {target}'**
  String autoSwapOn(String target);

  /// No description provided for @enterAmountToSendOrRequest.
  ///
  /// In en, this message translates to:
  /// **'Enter amount to send or request'**
  String get enterAmountToSendOrRequest;

  /// No description provided for @transferTo.
  ///
  /// In en, this message translates to:
  /// **'Transfer to'**
  String get transferTo;

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get bankAccount;

  /// No description provided for @askToBePaid.
  ///
  /// In en, this message translates to:
  /// **'Ask to be paid'**
  String get askToBePaid;

  /// No description provided for @beneficiaries.
  ///
  /// In en, this message translates to:
  /// **'Beneficiaries'**
  String get beneficiaries;

  /// No description provided for @lastSent.
  ///
  /// In en, this message translates to:
  /// **'Last sent'**
  String get lastSent;

  /// No description provided for @onJarinaFree.
  ///
  /// In en, this message translates to:
  /// **'On Jarina · free & instant'**
  String get onJarinaFree;

  /// No description provided for @crossBorderMinutes.
  ///
  /// In en, this message translates to:
  /// **'Cross-border · arrives in minutes'**
  String get crossBorderMinutes;

  /// No description provided for @sendToJarinaUser.
  ///
  /// In en, this message translates to:
  /// **'Send to a Jarina user'**
  String get sendToJarinaUser;

  /// No description provided for @jarinaP2p.
  ///
  /// In en, this message translates to:
  /// **'Jarina P2P'**
  String get jarinaP2p;

  /// No description provided for @p2pHeaderSub.
  ///
  /// In en, this message translates to:
  /// **'Send or request from any Jarina user · you are @{handle}'**
  String p2pHeaderSub(String handle);

  /// No description provided for @instant.
  ///
  /// In en, this message translates to:
  /// **'Instant'**
  String get instant;

  /// No description provided for @zeroFees.
  ///
  /// In en, this message translates to:
  /// **'0 fees'**
  String get zeroFees;

  /// No description provided for @cashCryptoStocks.
  ///
  /// In en, this message translates to:
  /// **'Cash, crypto & stocks'**
  String get cashCryptoStocks;

  /// No description provided for @sendTo.
  ///
  /// In en, this message translates to:
  /// **'Send to'**
  String get sendTo;

  /// No description provided for @requestFrom.
  ///
  /// In en, this message translates to:
  /// **'Request from'**
  String get requestFrom;

  /// No description provided for @jarinaUsername.
  ///
  /// In en, this message translates to:
  /// **'Jarina username'**
  String get jarinaUsername;

  /// No description provided for @youSend.
  ///
  /// In en, this message translates to:
  /// **'You send'**
  String get youSend;

  /// No description provided for @youRequest.
  ///
  /// In en, this message translates to:
  /// **'You request'**
  String get youRequest;

  /// No description provided for @sameAsset.
  ///
  /// In en, this message translates to:
  /// **'Same asset'**
  String get sameAsset;

  /// No description provided for @addANoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get addANoteOptional;

  /// No description provided for @chooseJarinaUser.
  ///
  /// In en, this message translates to:
  /// **'Choose a Jarina user'**
  String get chooseJarinaUser;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSent;

  /// No description provided for @p2pNote.
  ///
  /// In en, this message translates to:
  /// **'P2P transfers between Jarina users are free and arrive instantly. You\'\'ll confirm with your PIN. Stock transfers move shares between Jarina accounts with our partner broker.'**
  String get p2pNote;

  /// No description provided for @slideToSendAmount.
  ///
  /// In en, this message translates to:
  /// **'Slide to send {amount}'**
  String slideToSendAmount(String amount);

  /// No description provided for @slideToRequestAmount.
  ///
  /// In en, this message translates to:
  /// **'Slide to request {amount}'**
  String slideToRequestAmount(String amount);

  /// No description provided for @sendAmount.
  ///
  /// In en, this message translates to:
  /// **'Send {amount}'**
  String sendAmount(String amount);

  /// No description provided for @toSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name, @tag, phone or account number'**
  String get toSearchHint;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @fromWalletFee.
  ///
  /// In en, this message translates to:
  /// **'From {wallet} · fee {fee}'**
  String fromWalletFee(String wallet, String fee);

  /// No description provided for @recipientGetsFx.
  ///
  /// In en, this message translates to:
  /// **'{name} gets {amount} · rate 1 NGN = {rate} {currency}'**
  String recipientGetsFx(String name, String amount, String rate, String currency);

  /// No description provided for @rateLocked.
  ///
  /// In en, this message translates to:
  /// **'Rate locked for 10 minutes'**
  String get rateLocked;

  /// No description provided for @sentTo.
  ///
  /// In en, this message translates to:
  /// **'{amount} sent to {name}'**
  String sentTo(String amount, String name);

  /// No description provided for @sentToSub.
  ///
  /// In en, this message translates to:
  /// **'It\'\'s on its way. We\'\'ll notify you when it\'\'s delivered.'**
  String get sentToSub;

  /// No description provided for @sentInstantSub.
  ///
  /// In en, this message translates to:
  /// **'Delivered instantly. Free.'**
  String get sentInstantSub;

  /// No description provided for @requestSentTo.
  ///
  /// In en, this message translates to:
  /// **'You asked @{handle} for {amount}'**
  String requestSentTo(String handle, String amount);

  /// No description provided for @selectBank.
  ///
  /// In en, this message translates to:
  /// **'Select bank'**
  String get selectBank;

  /// No description provided for @addBankRecipient.
  ///
  /// In en, this message translates to:
  /// **'Send to a bank account'**
  String get addBankRecipient;

  /// No description provided for @nipFee.
  ///
  /// In en, this message translates to:
  /// **'NIP · {fee} fee'**
  String nipFee(String fee);

  /// No description provided for @countriesCount.
  ///
  /// In en, this message translates to:
  /// **'{n} countries'**
  String countriesCount(String n);

  /// No description provided for @p2pFreeInstant.
  ///
  /// In en, this message translates to:
  /// **'P2P · free · instant'**
  String get p2pFreeInstant;

  /// No description provided for @jarinaUserTag.
  ///
  /// In en, this message translates to:
  /// **'Jarina user · @{handle}'**
  String jarinaUserTag(String handle);

  /// No description provided for @bankAccountMasked.
  ///
  /// In en, this message translates to:
  /// **'Bank account ••{last4}'**
  String bankAccountMasked(String last4);

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get verifying;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer: {name}'**
  String customerName(String name);

  /// No description provided for @errPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter an 11-digit phone number'**
  String get errPhone;

  /// No description provided for @errMeter.
  ///
  /// In en, this message translates to:
  /// **'Check the number and try again'**
  String get errMeter;

  /// No description provided for @billMinMax.
  ///
  /// In en, this message translates to:
  /// **'Between {min} and {max}'**
  String billMinMax(String min, String max);

  /// No description provided for @payBill.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String payBill(String amount);

  /// No description provided for @electricityToken.
  ///
  /// In en, this message translates to:
  /// **'Electricity token'**
  String get electricityToken;

  /// No description provided for @tokenCopied.
  ///
  /// In en, this message translates to:
  /// **'Token copied'**
  String get tokenCopied;

  /// No description provided for @billPaid.
  ///
  /// In en, this message translates to:
  /// **'Bill paid'**
  String get billPaid;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get sending;

  /// No description provided for @receiveMoneySub.
  ///
  /// In en, this message translates to:
  /// **'Your @username, QR and account details'**
  String get receiveMoneySub;

  /// No description provided for @noRecipients.
  ///
  /// In en, this message translates to:
  /// **'No one matches. Check the @username, phone or account number.'**
  String get noRecipients;

  /// No description provided for @lookingUp.
  ///
  /// In en, this message translates to:
  /// **'Looking up @{handle}…'**
  String lookingUp(String handle);

  /// No description provided for @userFound.
  ///
  /// In en, this message translates to:
  /// **'{name} · @{handle}'**
  String userFound(String name, String handle);

  /// No description provided for @whenThePrice.
  ///
  /// In en, this message translates to:
  /// **'When the price'**
  String get whenThePrice;

  /// No description provided for @thenBuyWith.
  ///
  /// In en, this message translates to:
  /// **'Then buy with'**
  String get thenBuyWith;

  /// No description provided for @thenSell.
  ///
  /// In en, this message translates to:
  /// **'Then sell'**
  String get thenSell;

  /// No description provided for @atTriggerFeeIncluded.
  ///
  /// In en, this message translates to:
  /// **'At your trigger price · {fee} fee included'**
  String atTriggerFeeIncluded(String fee);

  /// No description provided for @watching.
  ///
  /// In en, this message translates to:
  /// **'Watching'**
  String get watching;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @enterTriggerAndAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a trigger price and amount.'**
  String get enterTriggerAndAmount;

  /// No description provided for @enterPriceAndAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a price and amount'**
  String get enterPriceAndAmount;

  /// No description provided for @yourShares.
  ///
  /// In en, this message translates to:
  /// **'Your shares'**
  String get yourShares;

  /// No description provided for @ruleWhenRange.
  ///
  /// In en, this message translates to:
  /// **'When {asset} trades between {low} and {high}'**
  String ruleWhenRange(String asset, String low, String high);

  /// No description provided for @ruleWhenBelow.
  ///
  /// In en, this message translates to:
  /// **'When {asset} falls below {price}'**
  String ruleWhenBelow(String asset, String price);

  /// No description provided for @ruleWhenAbove.
  ///
  /// In en, this message translates to:
  /// **'When {asset} rises above {price}'**
  String ruleWhenAbove(String asset, String price);

  /// No description provided for @ruleSentenceBuy.
  ///
  /// In en, this message translates to:
  /// **'{when}, buy {amount}.'**
  String ruleSentenceBuy(String when, String amount);

  /// No description provided for @ruleSentenceSell.
  ///
  /// In en, this message translates to:
  /// **'{when}, sell {amount}.'**
  String ruleSentenceSell(String when, String amount);

  /// No description provided for @amountWorth.
  ///
  /// In en, this message translates to:
  /// **'{amount} worth'**
  String amountWorth(String amount);

  /// No description provided for @percentOfMy.
  ///
  /// In en, this message translates to:
  /// **'{pct}% of my {unit}'**
  String percentOfMy(String pct, String unit);

  /// No description provided for @runsOnce.
  ///
  /// In en, this message translates to:
  /// **'Runs once'**
  String get runsOnce;

  /// No description provided for @repeatsEveryTime.
  ///
  /// In en, this message translates to:
  /// **'Repeats every time'**
  String get repeatsEveryTime;

  /// No description provided for @expiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {period}'**
  String expiresIn(String period);

  /// No description provided for @nowPrice.
  ///
  /// In en, this message translates to:
  /// **'Now {price}'**
  String nowPrice(String price);

  /// No description provided for @fromNairaWallet.
  ///
  /// In en, this message translates to:
  /// **'From Naira wallet'**
  String get fromNairaWallet;

  /// No description provided for @toNairaWallet.
  ///
  /// In en, this message translates to:
  /// **'To Naira wallet'**
  String get toNairaWallet;

  /// No description provided for @percentAway.
  ///
  /// In en, this message translates to:
  /// **'{pct}% away'**
  String percentAway(String pct);

  /// No description provided for @vsNow.
  ///
  /// In en, this message translates to:
  /// **'{pct} vs now'**
  String vsNow(String pct);

  /// No description provided for @moreThanYouHaveRule.
  ///
  /// In en, this message translates to:
  /// **'More than you have today. The rule will be skipped if there isn\'\'t enough when it triggers.'**
  String get moreThanYouHaveRule;

  /// No description provided for @proceedsGoToNaira.
  ///
  /// In en, this message translates to:
  /// **'Proceeds go to your Naira wallet. If you hold fewer than set, we sell what you have.'**
  String get proceedsGoToNaira;

  /// No description provided for @slideToSaveBuyRule.
  ///
  /// In en, this message translates to:
  /// **'Slide to save auto-buy rule'**
  String get slideToSaveBuyRule;

  /// No description provided for @slideToSaveSellRule.
  ///
  /// In en, this message translates to:
  /// **'Slide to save auto-sell rule'**
  String get slideToSaveSellRule;

  /// No description provided for @authoriseAutopilot.
  ///
  /// In en, this message translates to:
  /// **'Authorise Autopilot to trade for you when your conditions are met'**
  String get authoriseAutopilot;

  /// No description provided for @switchBuySell.
  ///
  /// In en, this message translates to:
  /// **'Switch auto-buy / auto-sell'**
  String get switchBuySell;

  /// No description provided for @alertTitleAbove.
  ///
  /// In en, this message translates to:
  /// **'{asset} above {price}'**
  String alertTitleAbove(String asset, String price);

  /// No description provided for @alertTitleBelow.
  ///
  /// In en, this message translates to:
  /// **'{asset} below {price}'**
  String alertTitleBelow(String asset, String price);

  /// No description provided for @alertSummaryAbove.
  ///
  /// In en, this message translates to:
  /// **'We\'\'ll notify you by {channels} when {asset} goes above {price}.'**
  String alertSummaryAbove(String channels, String asset, String price);

  /// No description provided for @alertSummaryBelow.
  ///
  /// In en, this message translates to:
  /// **'We\'\'ll notify you by {channels} when {asset} goes below {price}.'**
  String alertSummaryBelow(String channels, String asset, String price);

  /// No description provided for @pickPriceAndChannel.
  ///
  /// In en, this message translates to:
  /// **'Pick a price and at least one channel.'**
  String get pickPriceAndChannel;

  /// No description provided for @fromCurrentPrice.
  ///
  /// In en, this message translates to:
  /// **'{pct} from the current price'**
  String fromCurrentPrice(String pct);

  /// No description provided for @alertNotifyBody.
  ///
  /// In en, this message translates to:
  /// **'Get notified on all your devices when {asset} reaches your price.'**
  String alertNotifyBody(String asset);

  /// No description provided for @noAlertsYet.
  ///
  /// In en, this message translates to:
  /// **'No alerts yet'**
  String get noAlertsYet;

  /// No description provided for @alertOn.
  ///
  /// In en, this message translates to:
  /// **'Alert on'**
  String get alertOn;

  /// No description provided for @ruleOn.
  ///
  /// In en, this message translates to:
  /// **'Rule on'**
  String get ruleOn;

  /// No description provided for @deleteRule.
  ///
  /// In en, this message translates to:
  /// **'Delete rule'**
  String get deleteRule;

  /// No description provided for @deleteAlert.
  ///
  /// In en, this message translates to:
  /// **'Delete alert'**
  String get deleteAlert;

  /// No description provided for @alertDeleted.
  ///
  /// In en, this message translates to:
  /// **'Alert deleted'**
  String get alertDeleted;

  /// No description provided for @eventRoseAbove.
  ///
  /// In en, this message translates to:
  /// **'{asset} rose above {price}'**
  String eventRoseAbove(String asset, String price);

  /// No description provided for @eventFellBelow.
  ///
  /// In en, this message translates to:
  /// **'{asset} fell below {price}'**
  String eventFellBelow(String asset, String price);

  /// No description provided for @eventAutopilotBought.
  ///
  /// In en, this message translates to:
  /// **'Autopilot bought {qty} {asset} at {price}'**
  String eventAutopilotBought(String qty, String asset, String price);

  /// No description provided for @eventAutopilotSold.
  ///
  /// In en, this message translates to:
  /// **'Autopilot sold {qty} {asset} at {price}'**
  String eventAutopilotSold(String qty, String asset, String price);

  /// No description provided for @eventAutopilotSkipped.
  ///
  /// In en, this message translates to:
  /// **'Autopilot skipped {asset}: not enough balance'**
  String eventAutopilotSkipped(String asset);

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @transactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String transactionsCount(String count);

  /// No description provided for @walletsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} wallets'**
  String walletsCount(String count);

  /// No description provided for @p2pRowTitle.
  ///
  /// In en, this message translates to:
  /// **'P2P · Send to a Jarina user'**
  String get p2pRowTitle;

  /// No description provided for @p2pRowSub.
  ///
  /// In en, this message translates to:
  /// **'Cash, crypto or stocks by @username · free & instant'**
  String get p2pRowSub;

  /// No description provided for @accountWithPhone.
  ///
  /// In en, this message translates to:
  /// **'Account · {phone}'**
  String accountWithPhone(String phone);

  /// No description provided for @verifiedTier.
  ///
  /// In en, this message translates to:
  /// **'Verified · Tier {tier}'**
  String verifiedTier(String tier);

  /// No description provided for @logOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutQuestion;

  /// No description provided for @logOutBody.
  ///
  /// In en, this message translates to:
  /// **'You\'\'ll need your WhatsApp number and 2FA code to log in again.'**
  String get logOutBody;

  /// No description provided for @twofaRequiredSub.
  ///
  /// In en, this message translates to:
  /// **'Authenticator app · required for new devices, sells and withdrawals'**
  String get twofaRequiredSub;

  /// No description provided for @backupLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String backupLeft(String count);

  /// No description provided for @enterCurrentPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get enterCurrentPin;

  /// No description provided for @createNewPin.
  ///
  /// In en, this message translates to:
  /// **'Create a new PIN'**
  String get createNewPin;

  /// No description provided for @confirmNewPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm your new PIN'**
  String get confirmNewPin;

  /// No description provided for @pinChanged.
  ///
  /// In en, this message translates to:
  /// **'PIN changed'**
  String get pinChanged;

  /// No description provided for @backupCodesBody.
  ///
  /// In en, this message translates to:
  /// **'Each code works once if you lose your authenticator. Keep them somewhere safe, offline.'**
  String get backupCodesBody;

  /// No description provided for @generateNewCodes.
  ///
  /// In en, this message translates to:
  /// **'Generate new codes'**
  String get generateNewCodes;

  /// No description provided for @newCodesReplaceOld.
  ///
  /// In en, this message translates to:
  /// **'New codes replace your old ones.'**
  String get newCodesReplaceOld;

  /// No description provided for @copyAll.
  ///
  /// In en, this message translates to:
  /// **'Copy all'**
  String get copyAll;

  /// No description provided for @thisPhone.
  ///
  /// In en, this message translates to:
  /// **'This phone'**
  String get thisPhone;

  /// No description provided for @lastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active {date}'**
  String lastActive(String date);

  /// No description provided for @deviceRemoved.
  ///
  /// In en, this message translates to:
  /// **'Device signed out'**
  String get deviceRemoved;

  /// No description provided for @devicesBody.
  ///
  /// In en, this message translates to:
  /// **'Phones signed in to your account. Remove any you don\'\'t recognise.'**
  String get devicesBody;

  /// No description provided for @tier3Body.
  ///
  /// In en, this message translates to:
  /// **'Upload a utility bill or bank statement from the last 3 months to raise your limits. Tier 3 opens soon.'**
  String get tier3Body;

  /// No description provided for @perDayTier.
  ///
  /// In en, this message translates to:
  /// **'{amount} per day · Tier {tier}'**
  String perDayTier(String amount, String tier);

  /// No description provided for @faceIdOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Uses this phone\'\'s face or fingerprint unlock'**
  String get faceIdOnDevice;

  /// No description provided for @attachScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Attach a screenshot or receipt'**
  String get attachScreenshot;

  /// No description provided for @messageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageLabel;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendMessage;

  /// No description provided for @agentTyping.
  ///
  /// In en, this message translates to:
  /// **'Agent is typing'**
  String get agentTyping;

  /// No description provided for @unlockSub.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to unlock Jarina'**
  String get unlockSub;

  /// No description provided for @notYouLogOut.
  ///
  /// In en, this message translates to:
  /// **'Not you? Log out'**
  String get notYouLogOut;

  /// No description provided for @lockedOutLogInAgain.
  ///
  /// In en, this message translates to:
  /// **'Too many wrong PINs. Log in again with WhatsApp.'**
  String get lockedOutLogInAgain;

  /// No description provided for @compromisedTitle.
  ///
  /// In en, this message translates to:
  /// **'This phone may be rooted or jailbroken'**
  String get compromisedTitle;

  /// No description provided for @compromisedBody.
  ///
  /// In en, this message translates to:
  /// **'Apps on a modified phone can read what\'\'s on your screen. You can keep using Jarina, but we may limit withdrawals to protect your money.'**
  String get compromisedBody;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get understood;

  /// No description provided for @errorScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'This screen couldn\'\'t load'**
  String get errorScreenTitle;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get goHome;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr', 'ha'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ha':
      return AppLocalizationsHa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
