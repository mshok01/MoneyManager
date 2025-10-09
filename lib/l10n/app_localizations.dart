import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Money Manager'**
  String get appTitle;

  /// Skip button text in intro screen
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Title of the first intro page
  ///
  /// In en, this message translates to:
  /// **'Welcome to Money Manager'**
  String get welcomeToMoneyManager;

  /// Description of the first intro page
  ///
  /// In en, this message translates to:
  /// **'Take control of your finances with our comprehensive money tracking app. Monitor your income and expenses effortlessly.'**
  String get welcomeDescription;

  /// Title of the second intro page
  ///
  /// In en, this message translates to:
  /// **'Track Income & Expenses'**
  String get trackIncomeExpenses;

  /// Description of the second intro page
  ///
  /// In en, this message translates to:
  /// **'Log all your financial transactions easily. Keep track of every penny that comes in and goes out of your accounts.'**
  String get trackIncomeExpensesDescription;

  /// Title of the third intro page
  ///
  /// In en, this message translates to:
  /// **'Multiple Accounts'**
  String get multipleAccounts;

  /// Description of the third intro page
  ///
  /// In en, this message translates to:
  /// **'Manage different accounts like Home, Office, Apartment, and more. Keep your finances organized across all your accounts.'**
  String get multipleAccountsDescription;

  /// Title of the fourth intro page
  ///
  /// In en, this message translates to:
  /// **'Custom Categories'**
  String get customCategories;

  /// Description of the fourth intro page
  ///
  /// In en, this message translates to:
  /// **'Use default categories or create your own custom categories for income and expenses to better organize your transactions.'**
  String get customCategoriesDescription;

  /// Welcome message on home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Money Manager!'**
  String get welcomeToMoneyManagerHome;

  /// Subtitle message on home screen
  ///
  /// In en, this message translates to:
  /// **'Your financial tracking journey starts here.'**
  String get financialTrackingJourney;

  /// Tooltip for the floating action button
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// Subtitle on authentication choice screen
  ///
  /// In en, this message translates to:
  /// **'Take control of your finances today'**
  String get authChoiceSubtitle;

  /// Primary button text on authentication choice screen
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Divider text between options
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Secondary button text on authentication choice screen
  ///
  /// In en, this message translates to:
  /// **'I have an account'**
  String get iHaveAnAccount;

  /// Title of currency selection screen
  ///
  /// In en, this message translates to:
  /// **'Choose Your Currency'**
  String get chooseCurrency;

  /// Placeholder text for currency search field
  ///
  /// In en, this message translates to:
  /// **'Search currency...'**
  String get searchCurrency;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Text for save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Title of backup account screen
  ///
  /// In en, this message translates to:
  /// **'Secure Your Data'**
  String get secureYourData;

  /// Description on backup account screen
  ///
  /// In en, this message translates to:
  /// **'Add a backup account to sync across devices'**
  String get backupAccountDescription;

  /// Google sign-in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Apple sign-in button text
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// Skip button text on backup account screen
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// Helper text on backup account screen
  ///
  /// In en, this message translates to:
  /// **'You can add this later in Settings'**
  String get addBackupLaterInSettings;

  /// Title of sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// Description on sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to restore your data'**
  String get signInToRestoreData;

  /// Subtitle for Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Restore your data'**
  String get restoreYourData;

  /// Subtitle for Apple sign-in button
  ///
  /// In en, this message translates to:
  /// **'Secure & private'**
  String get secureAndPrivate;

  /// Start fresh button text on sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Start Fresh'**
  String get startFresh;

  /// Helper text on sign-in screen
  ///
  /// In en, this message translates to:
  /// **'Not you? Sign in with different account'**
  String get notYouSignInDifferent;
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
