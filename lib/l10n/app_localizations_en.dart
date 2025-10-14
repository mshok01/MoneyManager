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

  @override
  String get categories => 'Categories';

  @override
  String get manageCategories => 'Manage Categories';

  @override
  String get addCategory => 'Add Category';

  @override
  String get categoryTitle => 'Category Title';

  @override
  String get categoryDescription => 'Description';

  @override
  String get categoryType => 'Category Type';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get pleaseEnterTitle => 'Please enter a category title';

  @override
  String get pleaseEnterDescription => 'Please enter a description';

  @override
  String categoryAdded(String categoryName) {
    return 'Category \'$categoryName\' added successfully';
  }

  @override
  String get accountUpdatedSuccessfully => 'Account updated successfully';

  @override
  String failedToUpdateAccount(String error) {
    return 'Failed to update account: $error';
  }

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String deleteAccountConfirmation(String accountName) {
    return 'Are you sure you want to delete \"$accountName\"? This action cannot be undone.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get accountDeletedSuccessfully => 'Account deleted successfully';

  @override
  String failedToDeleteAccount(String error) {
    return 'Failed to delete account: $error';
  }

  @override
  String get exitAccount => 'Exit Account';

  @override
  String get cannotExitAccount => 'Cannot Exit Account';

  @override
  String get cannotExitAccountMessage =>
      'You are the only admin of this account. Please make another member an admin before exiting.';

  @override
  String get ok => 'OK';

  @override
  String exitAccountConfirmation(String accountName) {
    return 'Are you sure you want to exit \"$accountName\"? You will no longer have access to this account.';
  }

  @override
  String get exit => 'Exit';

  @override
  String get successfullyExitedAccount => 'Successfully exited account';

  @override
  String failedToExitAccount(String error) {
    return 'Failed to exit account: $error';
  }

  @override
  String get edit => 'Edit';

  @override
  String get accountName => 'Account Name';

  @override
  String get accountNameRequired => 'Account name is required';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String members(int count) {
    return 'Members ($count)';
  }

  @override
  String get you => 'You';

  @override
  String get member => 'Member';

  @override
  String get creator => 'CREATOR';

  @override
  String get admin => 'ADMIN';

  @override
  String get addMember => 'Add member';

  @override
  String get addMemberComingSoon => 'Add member functionality coming soon!';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get actions => 'Actions';

  @override
  String get exitAccountAction => 'EXIT ACCOUNT';

  @override
  String get addNewAccount => 'Add New Account';

  @override
  String get chooseProfilePicture => 'Choose Profile Picture';

  @override
  String get tapToSelectPicture => 'Tap to select picture';

  @override
  String get accountNameStar => 'Account Name *';

  @override
  String get required => 'Required';

  @override
  String get accountNameMinLength =>
      'Account name must be at least 2 characters';

  @override
  String get description => 'Description';

  @override
  String get optionalDescription => 'Optional - Add a brief description';

  @override
  String get create => 'Create';

  @override
  String get accountCreatedSuccessfully => 'Account created successfully';

  @override
  String failedToCreateAccount(String error) {
    return 'Failed to create account: $error';
  }

  @override
  String get noUserLoggedIn => 'No user logged in';

  @override
  String get remove => 'Remove';

  @override
  String get done => 'Done';

  @override
  String get wallet => 'Wallet';

  @override
  String get home => 'Home';

  @override
  String get business => 'Business';

  @override
  String get savings => 'Savings';

  @override
  String get credit => 'Credit';

  @override
  String get bank => 'Bank';

  @override
  String get shopping => 'Shopping';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get manageAccounts => 'Manage Accounts';

  @override
  String failedToLoadAccounts(String error) {
    return 'Failed to load accounts: $error';
  }

  @override
  String get primaryAccountUpdated => 'Primary account updated';

  @override
  String failedToUpdatePrimaryAccount(String error) {
    return 'Failed to update primary account: $error';
  }

  @override
  String accountsCount(int count, String plural) {
    return '$count Account$plural';
  }

  @override
  String get tapAccountToEdit => 'Tap an account to edit details';

  @override
  String get addAccount => 'Add Account';

  @override
  String get noAccounts => 'No Accounts';

  @override
  String get createFirstAccount => 'Create your first account to get started';

  @override
  String get primary => 'PRIMARY';

  @override
  String membersCount(int count, String plural) {
    return '$count member$plural';
  }

  @override
  String get setAsPrimary => 'Set as primary';

  @override
  String get paymentSources => 'Payment Sources';

  @override
  String failedToLoadPaymentSources(String error) {
    return 'Failed to load payment sources: $error';
  }

  @override
  String get deletePaymentSource => 'Delete Payment Source';

  @override
  String deletePaymentSourceConfirmation(String sourceName) {
    return 'Are you sure you want to delete \"$sourceName\"?';
  }

  @override
  String get noPaymentSourcesAvailable => 'No payment sources available';

  @override
  String get defaultSource => 'Default';

  @override
  String get addPaymentSource => 'Add Payment Source';

  @override
  String get editPaymentSource => 'Edit Payment Source';

  @override
  String get name => 'Name';

  @override
  String get nameHint => 'e.g., PayPal, Venmo';

  @override
  String get descriptionHint => 'Optional description';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get update => 'Update';

  @override
  String get add => 'Add';

  @override
  String get accountRenameComingSoon => 'Account rename feature coming soon!';

  @override
  String get noAccount => 'No Account';

  @override
  String get selectAccount => 'Select Account';

  @override
  String get addNewAccountAction => 'Add New Account';

  @override
  String get addAccountComingSoon => 'Add account feature coming soon!';

  @override
  String get manageAccountsAction => 'Manage Accounts';

  @override
  String get manageAccountsComingSoon => 'Manage accounts feature coming soon!';

  @override
  String get readyToTrackFinances => 'Ready to track your finances!';

  @override
  String get startByAddingTransaction =>
      'Start by adding your first transaction';

  @override
  String get addTransactionComingSoon => 'Add transaction feature coming soon!';

  @override
  String get incomeTab => 'Income';

  @override
  String get expensesTab => 'Expenses';

  @override
  String failedToLoadCategories(String error) {
    return 'Failed to load categories: $error';
  }

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String deleteCategoryConfirmation(String categoryName) {
    return 'Are you sure you want to delete \"$categoryName\"?';
  }

  @override
  String editCategoryComingSoon(String categoryName) {
    return 'Edit $categoryName functionality coming soon!';
  }

  @override
  String deleteCategoryComingSoon(String categoryName) {
    return 'Delete $categoryName functionality coming soon!';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get accounts => 'Accounts';

  @override
  String get manageAccountsSubtitle => 'Add, edit, and organize accounts';

  @override
  String get paymentSourcesSubtitle => 'Manage sources';

  @override
  String get dataPrivacy => 'Data & Privacy';

  @override
  String get notConnected => 'Not connected';

  @override
  String currencyChangedTo(String currency) {
    return 'Currency changed to $currency';
  }

  @override
  String failedToUpdateCurrency(String error) {
    return 'Failed to update currency: $error';
  }

  @override
  String comingSoon(String feature) {
    return '$feature is coming soon!';
  }

  @override
  String get googleSignInImplementation =>
      'Google Sign-in will be implemented with Firebase Auth';

  @override
  String get appleSignInImplementation =>
      'Apple Sign-in will be implemented with Firebase Auth';
}
