// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Money Manager';

  @override
  String get skip => 'Skip';

  @override
  String get welcomeToMoneyManager => 'Welcome to Money Manager';

  @override
  String get welcomeDescription =>
      'Take control of your finances with our comprehensive money tracking app. Monitor your income and expenses effortlessly.';

  @override
  String get trackIncomeExpenses => 'Track Income & Expenses';

  @override
  String get trackIncomeExpensesDescription =>
      'Log all your financial transactions easily. Keep track of every penny that comes in and goes out of your accounts.';

  @override
  String get multipleAccounts => 'Multiple Accounts';

  @override
  String get multipleAccountsDescription =>
      'Manage different accounts like Home, Office, Apartment, and more. Keep your finances organized across all your accounts.';

  @override
  String get customCategories => 'Custom Categories';

  @override
  String get customCategoriesDescription =>
      'Use default categories or create your own custom categories for income and expenses to better organize your transactions.';

  @override
  String get welcomeToMoneyManagerHome => 'Welcome to Money Manager!';

  @override
  String get financialTrackingJourney =>
      'Your financial tracking journey starts here.';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get authChoiceSubtitle => 'Take control of your finances today';

  @override
  String get getStarted => 'Get Started';

  @override
  String get or => 'or';

  @override
  String get iHaveAnAccount => 'I have an account';

  @override
  String get chooseCurrency => 'Choose Your Currency';

  @override
  String get searchCurrency => 'Search currency...';

  @override
  String get continueButton => 'Continue';

  @override
  String get save => 'Save';

  @override
  String get secureYourData => 'Secure Your Data';

  @override
  String get backupAccountDescription =>
      'Add a backup account to sync across devices';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get addBackupLaterInSettings => 'You can add this later in Settings';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get signInToRestoreData => 'Sign in to restore your data';

  @override
  String get restoreYourData => 'Restore your data';

  @override
  String get secureAndPrivate => 'Secure & private';

  @override
  String get startFresh => 'Start Fresh';

  @override
  String get notYouSignInDifferent => 'Not you? Sign in with different account';

  @override
  String get settings => 'Settings';

  @override
  String get currency => 'Currency';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get backup => 'Backup & Sync';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get english => 'English';

  @override
  String get cancel => 'Cancel';

  @override
  String themeChangedTo(String themeName) {
    return 'Theme changed to $themeName';
  }
}
