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

  /// Settings screen title and menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Currency setting label
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Notifications setting label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Backup setting label
  ///
  /// In en, this message translates to:
  /// **'Backup & Sync'**
  String get backup;

  /// About setting label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Message shown when theme is changed
  ///
  /// In en, this message translates to:
  /// **'Theme changed to {themeName}'**
  String themeChangedTo(String themeName);

  /// Categories setting label and screen title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Manage categories setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// Add category dialog title and button text
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// Edit category screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// Category title input field label
  ///
  /// In en, this message translates to:
  /// **'Category Title'**
  String get categoryTitle;

  /// Category description input field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get categoryDescription;

  /// Category type selection label
  ///
  /// In en, this message translates to:
  /// **'Category Type'**
  String get categoryType;

  /// Income category type
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Expense category type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// Validation message for empty category title
  ///
  /// In en, this message translates to:
  /// **'Please enter a category title'**
  String get pleaseEnterTitle;

  /// Validation message for empty category description
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// Success message when category is added
  ///
  /// In en, this message translates to:
  /// **'Category \'{categoryName}\' added successfully'**
  String categoryAdded(String categoryName);

  /// Success message when account is updated
  ///
  /// In en, this message translates to:
  /// **'Account updated successfully'**
  String get accountUpdatedSuccessfully;

  /// Error message when account update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update account: {error}'**
  String failedToUpdateAccount(String error);

  /// Delete account dialog title and tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{accountName}\"? This action cannot be undone.'**
  String deleteAccountConfirmation(String accountName);

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Success message when account is deleted
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccessfully;

  /// Error message when account deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {error}'**
  String failedToDeleteAccount(String error);

  /// Exit account dialog title and tooltip
  ///
  /// In en, this message translates to:
  /// **'Exit Account'**
  String get exitAccount;

  /// Cannot exit account dialog title
  ///
  /// In en, this message translates to:
  /// **'Cannot Exit Account'**
  String get cannotExitAccount;

  /// Cannot exit account dialog message
  ///
  /// In en, this message translates to:
  /// **'You are the only admin of this account. Please make another member an admin before exiting.'**
  String get cannotExitAccountMessage;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Exit account confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit \"{accountName}\"? You will no longer have access to this account.'**
  String exitAccountConfirmation(String accountName);

  /// Exit button text
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// Success message when exiting account
  ///
  /// In en, this message translates to:
  /// **'Successfully exited account'**
  String get successfullyExitedAccount;

  /// Error message when exiting account fails
  ///
  /// In en, this message translates to:
  /// **'Failed to exit account: {error}'**
  String failedToExitAccount(String error);

  /// Edit button tooltip
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Account name input field label
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountName;

  /// Validation message for empty account name
  ///
  /// In en, this message translates to:
  /// **'Account name is required'**
  String get accountNameRequired;

  /// Account description input field label
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// Members section title
  ///
  /// In en, this message translates to:
  /// **'Members ({count})'**
  String members(int count);

  /// Label for current user in members list
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Label for other members in members list
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// Creator role badge text
  ///
  /// In en, this message translates to:
  /// **'CREATOR'**
  String get creator;

  /// Admin role badge text
  ///
  /// In en, this message translates to:
  /// **'ADMIN'**
  String get admin;

  /// Add member button text
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get addMember;

  /// Placeholder message for add member functionality
  ///
  /// In en, this message translates to:
  /// **'Add member functionality coming soon!'**
  String get addMemberComingSoon;

  /// Account settings section title
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Actions section title
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// Exit account action button text
  ///
  /// In en, this message translates to:
  /// **'EXIT ACCOUNT'**
  String get exitAccountAction;

  /// Add account screen title and button text
  ///
  /// In en, this message translates to:
  /// **'Add New Account'**
  String get addNewAccount;

  /// Profile picture selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Profile Picture'**
  String get chooseProfilePicture;

  /// Helper text for profile picture selection
  ///
  /// In en, this message translates to:
  /// **'Tap to select picture'**
  String get tapToSelectPicture;

  /// Account name field label with required indicator
  ///
  /// In en, this message translates to:
  /// **'Account Name *'**
  String get accountNameStar;

  /// Helper text for required fields
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Validation message for account name minimum length
  ///
  /// In en, this message translates to:
  /// **'Account name must be at least 2 characters'**
  String get accountNameMinLength;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Helper text for optional description field
  ///
  /// In en, this message translates to:
  /// **'Optional - Add a brief description'**
  String get optionalDescription;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Success message when account is created
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreatedSuccessfully;

  /// Error message when account creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create account: {error}'**
  String failedToCreateAccount(String error);

  /// Error message when no user is logged in
  ///
  /// In en, this message translates to:
  /// **'No user logged in'**
  String get noUserLoggedIn;

  /// Remove button text
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Done button text
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Wallet profile picture option
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// Home profile picture option
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Business profile picture option
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// Savings profile picture option
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get savings;

  /// Credit profile picture option
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// Bank profile picture option
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// Shopping profile picture option
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// Vehicle profile picture option
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// Manage accounts screen title and menu item
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get manageAccounts;

  /// Error message when loading accounts fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load accounts: {error}'**
  String failedToLoadAccounts(String error);

  /// Success message when primary account is updated
  ///
  /// In en, this message translates to:
  /// **'Primary account updated'**
  String get primaryAccountUpdated;

  /// Error message when updating primary account fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update primary account: {error}'**
  String failedToUpdatePrimaryAccount(String error);

  /// Number of accounts display
  ///
  /// In en, this message translates to:
  /// **'{count} Account{plural}'**
  String accountsCount(int count, String plural);

  /// Helper text for account list
  ///
  /// In en, this message translates to:
  /// **'Tap an account to edit details'**
  String get tapAccountToEdit;

  /// Add account button text
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// Empty state title when no accounts exist
  ///
  /// In en, this message translates to:
  /// **'No Accounts'**
  String get noAccounts;

  /// Text shown when no account is selected
  ///
  /// In en, this message translates to:
  /// **'No Account'**
  String get noAccount;

  /// Quick stats section title in analytics
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quickStats;

  /// This month label in analytics
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// This year label in analytics
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// Transactions count label
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String transactionsCount(int count);

  /// Balance label
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// Monthly breakdown section title
  ///
  /// In en, this message translates to:
  /// **'Monthly Breakdown'**
  String get monthlyBreakdown;

  /// Message when no data is available
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// Message encouraging users to add transactions
  ///
  /// In en, this message translates to:
  /// **'Add some transactions to see monthly analytics'**
  String get addTransactionsToSeeAnalytics;

  /// Error message when analytics loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load analytics: {error}'**
  String failedToLoadAnalytics(String error);

  /// Message shown when user tries to navigate without selecting an account
  ///
  /// In en, this message translates to:
  /// **'Please select an account first'**
  String get pleaseSelectAccountFirst;

  /// Account balance section title
  ///
  /// In en, this message translates to:
  /// **'Account Balance'**
  String get accountBalance;

  /// Current balance label
  ///
  /// In en, this message translates to:
  /// **'Current Balance'**
  String get currentBalance;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// View all button label
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Recent transactions section title
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// Message when no transactions exist
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// Encouragement message for first transaction
  ///
  /// In en, this message translates to:
  /// **'Add your first transaction to get started'**
  String get addFirstTransactionToGetStarted;

  /// Default transaction description
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get transaction;

  /// Error message when user account creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create user account: {error}'**
  String failedToCreateUserAccount(String error);

  /// Message shown when Google Sign-in is not yet implemented
  ///
  /// In en, this message translates to:
  /// **'Google Sign-in will be implemented with Firebase Auth'**
  String get googleSignInComingSoon;

  /// Message shown when Apple Sign-in is not yet implemented
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-in will be implemented with Firebase Auth'**
  String get appleSignInComingSoon;

  /// Error message when transactions fail to load
  ///
  /// In en, this message translates to:
  /// **'Error loading transactions: {error}'**
  String errorLoadingTransactions(String error);

  /// Title for daily transactions screen
  ///
  /// In en, this message translates to:
  /// **'Daily Transactions'**
  String get dailyTransactions;

  /// Message when no transactions exist for the selected day
  ///
  /// In en, this message translates to:
  /// **'No transactions for this day'**
  String get noTransactionsForThisDay;

  /// Suggestion when no transactions found with filters
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingSearchOrFilters;

  /// Month name
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// Month name
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// Month name
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// Month name
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// Month name
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// Month name
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// Month name
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// Month name
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// Month name
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// Month name
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// Month name
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// Month name
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// Filter option to show all items
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Empty state title when no account is selected
  ///
  /// In en, this message translates to:
  /// **'No account selected'**
  String get noAccountSelected;

  /// Filter option to show all transactions
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// Filter option to show income transactions only
  ///
  /// In en, this message translates to:
  /// **'Income Only'**
  String get incomeOnly;

  /// Filter option to show expense transactions only
  ///
  /// In en, this message translates to:
  /// **'Expenses Only'**
  String get expensesOnly;

  /// Empty state message when no days match search/filter
  ///
  /// In en, this message translates to:
  /// **'No matching days'**
  String get noMatchingDays;

  /// Empty state message when no days have transactions
  ///
  /// In en, this message translates to:
  /// **'No days with transactions'**
  String get noDaysWithTransactions;

  /// Empty state hint to add transactions for daily summaries
  ///
  /// In en, this message translates to:
  /// **'Add transactions to see daily summaries'**
  String get addTransactionsToSeeDailySummaries;

  /// Empty state description when no accounts exist
  ///
  /// In en, this message translates to:
  /// **'Create your first account to get started'**
  String get createFirstAccount;

  /// Primary account badge text
  ///
  /// In en, this message translates to:
  /// **'PRIMARY'**
  String get primary;

  /// Number of members display
  ///
  /// In en, this message translates to:
  /// **'{count} member{plural}'**
  String membersCount(int count, String plural);

  /// Set as primary account action text
  ///
  /// In en, this message translates to:
  /// **'Set as primary'**
  String get setAsPrimary;

  /// Payment sources screen title and menu item
  ///
  /// In en, this message translates to:
  /// **'Payment Sources'**
  String get paymentSources;

  /// Error message when loading payment sources fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load payment sources: {error}'**
  String failedToLoadPaymentSources(String error);

  /// Delete payment source dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Payment Source'**
  String get deletePaymentSource;

  /// Delete payment source confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{sourceName}\"?'**
  String deletePaymentSourceConfirmation(String sourceName);

  /// Empty state message when no payment sources exist
  ///
  /// In en, this message translates to:
  /// **'No payment sources available'**
  String get noPaymentSourcesAvailable;

  /// Default payment source badge text
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultSource;

  /// Add payment source tooltip and dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Payment Source'**
  String get addPaymentSource;

  /// Edit payment source dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Payment Source'**
  String get editPaymentSource;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Name field hint text
  ///
  /// In en, this message translates to:
  /// **'e.g., PayPal, Venmo'**
  String get nameHint;

  /// Description field hint text
  ///
  /// In en, this message translates to:
  /// **'Optional description'**
  String get descriptionHint;

  /// Validation message for empty name field
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// Update button text
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// History navigation option in bottom bar
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Analytics navigation option in bottom bar
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Coming soon message for account rename feature
  ///
  /// In en, this message translates to:
  /// **'Account rename feature coming soon!'**
  String get accountRenameComingSoon;

  /// Header text for account selection modal
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccount;

  /// Hint text for transaction search field
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// Period filter option for all time
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// Period filter option for week
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// Period filter option for month
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// Period filter option for year
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// Today date label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday date label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Message when no transactions are found
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get noTransactionsFound;

  /// Suggestion when no transactions are found
  ///
  /// In en, this message translates to:
  /// **'Try selecting a different time period'**
  String get tryDifferentTimePeriod;

  /// Fallback text for unknown category
  ///
  /// In en, this message translates to:
  /// **'Unknown Category'**
  String get unknownCategory;

  /// Fallback text for unknown payment source
  ///
  /// In en, this message translates to:
  /// **'Unknown Source'**
  String get unknownSource;

  /// Generic fallback text for unknown items
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Text shown when search results are limited to top 5
  ///
  /// In en, this message translates to:
  /// **'Showing top 5 results'**
  String get showingTopResults;

  /// Error message when history fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load history: {error}'**
  String failedToLoadHistory(String error);

  /// History screen title with account name
  ///
  /// In en, this message translates to:
  /// **'{accountName} History'**
  String accountHistory(String accountName);

  /// Add new account action in account selector
  ///
  /// In en, this message translates to:
  /// **'Add New Account'**
  String get addNewAccountAction;

  /// Coming soon message for add account feature
  ///
  /// In en, this message translates to:
  /// **'Add account feature coming soon!'**
  String get addAccountComingSoon;

  /// Manage accounts action in account selector
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get manageAccountsAction;

  /// Coming soon message for manage accounts feature
  ///
  /// In en, this message translates to:
  /// **'Manage accounts feature coming soon!'**
  String get manageAccountsComingSoon;

  /// Empty state title on home screen
  ///
  /// In en, this message translates to:
  /// **'Ready to track your finances!'**
  String get readyToTrackFinances;

  /// Empty state description on home screen
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first transaction'**
  String get startByAddingTransaction;

  /// Coming soon message for add transaction feature
  ///
  /// In en, this message translates to:
  /// **'Add transaction feature coming soon!'**
  String get addTransactionComingSoon;

  /// Income tab label in categories screen
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeTab;

  /// Expenses tab label in categories screen
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTab;

  /// Error message when loading categories fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories: {error}'**
  String failedToLoadCategories(String error);

  /// Delete category dialog title and menu item
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// Delete category confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{categoryName}\"?'**
  String deleteCategoryConfirmation(String categoryName);

  /// Coming soon message for edit category feature
  ///
  /// In en, this message translates to:
  /// **'Edit {categoryName} functionality coming soon!'**
  String editCategoryComingSoon(String categoryName);

  /// Coming soon message for delete category feature
  ///
  /// In en, this message translates to:
  /// **'Delete {categoryName} functionality coming soon!'**
  String deleteCategoryComingSoon(String categoryName);

  /// Appearance section header in settings
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Accounts section header in settings
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// Manage accounts setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Add, edit, and organize accounts'**
  String get manageAccountsSubtitle;

  /// Payment sources setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage sources'**
  String get paymentSourcesSubtitle;

  /// Data & Privacy section header in settings
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataPrivacy;

  /// Backup status when not connected
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// Backup status when connected
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Button text to add backup account
  ///
  /// In en, this message translates to:
  /// **'Add Backup Account'**
  String get addBackupAccount;

  /// Display backup account email
  ///
  /// In en, this message translates to:
  /// **'Backup account: {email}'**
  String backupAccountEmail(String email);

  /// Success message when currency is changed
  ///
  /// In en, this message translates to:
  /// **'Currency changed to {currency}'**
  String currencyChangedTo(String currency);

  /// Error message when currency update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update currency: {error}'**
  String failedToUpdateCurrency(String error);

  /// Generic coming soon message
  ///
  /// In en, this message translates to:
  /// **'{feature} is coming soon!'**
  String comingSoon(String feature);

  /// Implementation note for Google Sign-in
  ///
  /// In en, this message translates to:
  /// **'Google Sign-in will be implemented with Firebase Auth'**
  String get googleSignInImplementation;

  /// Implementation note for Apple Sign-in
  ///
  /// In en, this message translates to:
  /// **'Apple Sign-in will be implemented with Firebase Auth'**
  String get appleSignInImplementation;

  /// Loading message while linking account
  ///
  /// In en, this message translates to:
  /// **'Linking your account...'**
  String get linkingAccount;

  /// Success message when account linking is complete
  ///
  /// In en, this message translates to:
  /// **'Account linked successfully!'**
  String get accountLinkedSuccessfully;

  /// Error message when account linking fails
  ///
  /// In en, this message translates to:
  /// **'Account linking failed'**
  String get linkingFailed;

  /// Dialog title when Google account already has data
  ///
  /// In en, this message translates to:
  /// **'Account Already Exists'**
  String get accountAlreadyExists;

  /// Dialog message explaining account already exists scenario
  ///
  /// In en, this message translates to:
  /// **'This Google account already has some data in Money Manager. To restore your previous data, you need to:\n\n1. Logout from your current account\n2. Login with this Google account\n\nYour existing data in the current account will be lost. Do you want to proceed?'**
  String get accountAlreadyExistsMessage;

  /// Button to restore data from existing Google account
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// Button to skip restoring data and continue with current account
  ///
  /// In en, this message translates to:
  /// **'Proceed Without Restore'**
  String get proceedWithoutRestore;

  /// Dialog title when adding recovery account fails
  ///
  /// In en, this message translates to:
  /// **'Failed to Add Recovery Account'**
  String get failedToAddRecoveryAccount;

  /// Dialog message when adding recovery account fails
  ///
  /// In en, this message translates to:
  /// **'We encountered an error while trying to add your recovery account. Please try again later or contact support if the problem persists.'**
  String get failedToAddRecoveryAccountMessage;

  /// Button to retry an action
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Welcome message with emoji in welcome nudge card
  ///
  /// In en, this message translates to:
  /// **'🎉 Welcome to Money Manager!'**
  String get welcomeToMoneyManagerEmoji;

  /// Message explaining the auto-created account
  ///
  /// In en, this message translates to:
  /// **'We\'ve created a \"{accountName}\" for you to get started quickly.'**
  String accountCreatedMessage(String accountName);

  /// Default account name
  ///
  /// In en, this message translates to:
  /// **'Main Account'**
  String get mainAccount;

  /// Instructions for switching accounts and accessing settings
  ///
  /// In en, this message translates to:
  /// **'Tap the account name in the header to switch between accounts, or visit Settings to customize your currency and preferences.'**
  String get accountSwitchInstructions;

  /// Dismissal button text in welcome nudge
  ///
  /// In en, this message translates to:
  /// **'Got it, thanks!'**
  String get gotItThanks;

  /// Default description for the main account
  ///
  /// In en, this message translates to:
  /// **'Your primary account for tracking expenses and income'**
  String get mainAccountDescription;

  /// Screen title and section header for transaction details
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails;

  /// Delete transaction dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// Delete transaction confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction? This action cannot be undone.'**
  String get deleteTransactionConfirmation;

  /// Enabled status text
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Edit transaction tooltip and screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// Delete transaction tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransactionTooltip;

  /// Success message when transaction is deleted
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully'**
  String get transactionDeletedSuccessfully;

  /// Error message when transaction deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete transaction: {error}'**
  String failedToDeleteTransaction(String error);

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Payment source field label
  ///
  /// In en, this message translates to:
  /// **'Payment Source'**
  String get paymentSource;

  /// Date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Time field label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Edit transaction screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransactionTitle;

  /// Transaction type field label
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get transactionType;

  /// Amount field label with currency symbol
  ///
  /// In en, this message translates to:
  /// **'Amount ({currencySymbol})'**
  String amount(String currencySymbol);

  /// Amount field placeholder
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get amountHint;

  /// Amount field validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// Amount field validation message for invalid values
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount greater than 0'**
  String get pleaseEnterValidAmount;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Notes field placeholder
  ///
  /// In en, this message translates to:
  /// **'Milk, Eggs etc'**
  String get notesHint;

  /// Category selection validation message
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get pleaseSelectCategory;

  /// Payment source selection validation message
  ///
  /// In en, this message translates to:
  /// **'Please select a payment source'**
  String get pleaseSelectPaymentSource;

  /// Success message when transaction is created
  ///
  /// In en, this message translates to:
  /// **'Transaction created successfully'**
  String get transactionCreatedSuccessfully;

  /// Success message when transaction is updated
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully'**
  String get transactionUpdatedSuccessfully;

  /// Error message when transaction save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save transaction: {error}'**
  String failedToSaveTransaction(String error);

  /// Error message when data loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load data: {error}'**
  String failedToLoadData(String error);

  /// Message when no categories are available
  ///
  /// In en, this message translates to:
  /// **'No categories available for {transactionType}'**
  String noCategoriesAvailable(String transactionType);

  /// Category selection placeholder
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// Payment source selection placeholder
  ///
  /// In en, this message translates to:
  /// **'Select a payment source'**
  String get selectPaymentSource;

  /// USD currency fallback
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get usd;

  /// Payment sources screen title
  ///
  /// In en, this message translates to:
  /// **'Payment Sources'**
  String get paymentSourcesTitle;

  /// Search transactions screen title
  ///
  /// In en, this message translates to:
  /// **'Search Transactions'**
  String get searchTransactionsTitle;

  /// Search field hint text for comprehensive search
  ///
  /// In en, this message translates to:
  /// **'Search transactions, categories, amounts...'**
  String get searchTransactionsHint;

  /// Search button text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Empty state title on search screen
  ///
  /// In en, this message translates to:
  /// **'Search your transactions'**
  String get searchYourTransactions;

  /// Empty state instructions on search screen
  ///
  /// In en, this message translates to:
  /// **'Enter keywords to find transactions by description, category, payment source, or amount'**
  String get searchInstructions;

  /// No search results suggestion
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or adjust your filters'**
  String get tryDifferentKeywords;

  /// Transactions screen title
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// Tooltip for view all transactions button
  ///
  /// In en, this message translates to:
  /// **'View All Transactions'**
  String get viewAllTransactions;

  /// Tooltip for previous period navigation
  ///
  /// In en, this message translates to:
  /// **'Previous {period}'**
  String previousPeriod(String period);

  /// Tooltip for next period navigation
  ///
  /// In en, this message translates to:
  /// **'Next {period}'**
  String nextPeriod(String period);

  /// Empty state when no months match filters
  ///
  /// In en, this message translates to:
  /// **'No months found'**
  String get noMonthsFound;

  /// Empty state when no transactions exist for the year
  ///
  /// In en, this message translates to:
  /// **'No transactions this year'**
  String get noTransactionsThisYear;

  /// Empty state hint to add transactions for monthly summaries
  ///
  /// In en, this message translates to:
  /// **'Add transactions to see monthly summaries'**
  String get addTransactionsToSeeMonthly;

  /// Empty state when no days match filters
  ///
  /// In en, this message translates to:
  /// **'No days found'**
  String get noDaysFound;

  /// Empty state when no transactions exist for the month
  ///
  /// In en, this message translates to:
  /// **'No transactions this month'**
  String get noTransactionsThisMonth;

  /// Empty state when no transactions exist for the period
  ///
  /// In en, this message translates to:
  /// **'No transactions for {period}'**
  String noTransactionsForPeriod(String period);

  /// Empty state hint to add first transaction
  ///
  /// In en, this message translates to:
  /// **'Add a transaction to get started'**
  String get addTransactionToGetStarted;

  /// Text shown when there are no transactions
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactionsText;

  /// Transaction list screen title with account name
  ///
  /// In en, this message translates to:
  /// **'{accountName} Transactions'**
  String accountTransactions(String accountName);

  /// Yearly transactions screen title with account name and year
  ///
  /// In en, this message translates to:
  /// **'{accountName} - {year}'**
  String accountYearlyTransactions(String accountName, int year);

  /// Message shown when no transactions exist for a specific year
  ///
  /// In en, this message translates to:
  /// **'No transactions in {year}'**
  String noTransactionsInYear(int year);

  /// Hint text for category search field
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get searchCategories;

  /// Message shown when no categories match search criteria
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;

  /// Error message when transaction summary fails to load
  ///
  /// In en, this message translates to:
  /// **'Error loading summary'**
  String get errorLoadingSummary;

  /// Summary section title
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// Title for new account dialog
  ///
  /// In en, this message translates to:
  /// **'New Account Detected'**
  String get newAccountDetected;

  /// Message shown when new Google user is detected
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any associated details with Money Manager. Would you like to create an account with your Google details?'**
  String get noAssociatedDetailsMessage;

  /// Button to create account for new Google user
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Loading message while fetching user details from backend
  ///
  /// In en, this message translates to:
  /// **'Fetching your details...'**
  String get fetchingUserDetails;

  /// Loading message while signing in
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// Error message when sign in fails
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get signInFailed;

  /// Error message when account creation fails
  ///
  /// In en, this message translates to:
  /// **'Account creation failed'**
  String get accountCreationFailed;

  /// Error message when removing user account fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove user account'**
  String get failedToRemoveUser;

  /// Error message when sign out fails
  ///
  /// In en, this message translates to:
  /// **'Sign out failed'**
  String get signOutFailed;

  /// Tooltip for sync categories button
  ///
  /// In en, this message translates to:
  /// **'Sync Categories'**
  String get syncCategories;

  /// Success message when category sync is completed
  ///
  /// In en, this message translates to:
  /// **'Categories synced successfully'**
  String get syncCompleted;

  /// Error message when category sync fails
  ///
  /// In en, this message translates to:
  /// **'Failed to sync categories: {error}'**
  String failedToSync(String error);
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
