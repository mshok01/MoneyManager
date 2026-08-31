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
      'Protect your data by linking a backup account. Your financial data will be securely backed up and can be restored if needed.';

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
  String get editCategory => 'Edit Category';

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
  String get noAccount => 'No Account';

  @override
  String get quickStats => 'Quick Stats';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisYear => 'This Year';

  @override
  String transactionsCount(int count) {
    return '$count transactions';
  }

  @override
  String get balance => 'Balance';

  @override
  String get monthlyBreakdown => 'Monthly Breakdown';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get addTransactionsToSeeAnalytics =>
      'Add some transactions to see monthly analytics';

  @override
  String failedToLoadAnalytics(String error) {
    return 'Failed to load analytics: $error';
  }

  @override
  String get pleaseSelectAccountFirst => 'Please select an account first';

  @override
  String get accountBalance => 'Account Balance';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get viewAll => 'View All';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get addFirstTransactionToGetStarted =>
      'Add your first transaction to get started';

  @override
  String get transaction => 'Transaction';

  @override
  String failedToCreateUserAccount(String error) {
    return 'Failed to create user account: $error';
  }

  @override
  String get googleSignInComingSoon =>
      'Google Sign-in will be implemented with Firebase Auth';

  @override
  String get appleSignInComingSoon =>
      'Apple Sign-in will be implemented with Firebase Auth';

  @override
  String errorLoadingTransactions(String error) {
    return 'Error loading transactions: $error';
  }

  @override
  String get dailyTransactions => 'Daily Transactions';

  @override
  String get noTransactionsForThisDay => 'No transactions for this day';

  @override
  String get tryAdjustingSearchOrFilters =>
      'Try adjusting your search or filters';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get all => 'All';

  @override
  String get noAccountSelected => 'No account selected';

  @override
  String get allTransactions => 'All Transactions';

  @override
  String get incomeOnly => 'Income Only';

  @override
  String get expensesOnly => 'Expenses Only';

  @override
  String get noMatchingDays => 'No matching days';

  @override
  String get noDaysWithTransactions => 'No days with transactions';

  @override
  String get addTransactionsToSeeDailySummaries =>
      'Add transactions to see daily summaries';

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
  String get paymentSourceCreatedSuccessfully =>
      'Payment source created successfully';

  @override
  String get paymentSourceUpdatedSuccessfully =>
      'Payment source updated successfully';

  @override
  String get paymentSourceDeleted => 'Payment source deleted successfully';

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
  String get history => 'History';

  @override
  String get analytics => 'Analytics';

  @override
  String get accountRenameComingSoon => 'Account rename feature coming soon!';

  @override
  String get selectAccount => 'Select Account';

  @override
  String get searchTransactions => 'Search transactions...';

  @override
  String get allTime => 'All Time';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get noTransactionsFound => 'No transactions found';

  @override
  String get tryDifferentTimePeriod => 'Try selecting a different time period';

  @override
  String get unknownCategory => 'Unknown Category';

  @override
  String get unknownSource => 'Unknown Source';

  @override
  String get unknown => 'Unknown';

  @override
  String get showingTopResults => 'Showing top 5 results';

  @override
  String failedToLoadHistory(String error) {
    return 'Failed to load history: $error';
  }

  @override
  String accountHistory(String accountName) {
    return '$accountName History';
  }

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
  String get connected => 'Connected';

  @override
  String get addBackupAccount => 'Add backup account';

  @override
  String backupAccountEmail(String email) {
    return 'Backup account: $email';
  }

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

  @override
  String get linkingAccount => 'Linking your account...';

  @override
  String get accountLinkedSuccessfully => 'Account linked successfully!';

  @override
  String get linkingFailed => 'Account linking failed';

  @override
  String get accountAlreadyExists => 'Account Already Exists';

  @override
  String get accountAlreadyExistsMessage =>
      'This Google account already has some data in Money Manager. To restore your previous data, you need to:\n\n1. Logout from your current account\n2. Login with this Google account\n\nYour existing data in the current account will be lost. Do you want to proceed?';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get proceedWithoutRestore => 'Proceed Without Restore';

  @override
  String get failedToAddRecoveryAccount => 'Failed to Add Recovery Account';

  @override
  String get failedToAddRecoveryAccountMessage =>
      'We encountered an error while trying to add your recovery account. Please try again later or contact support if the problem persists.';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get welcomeToMoneyManagerEmoji => '🎉 Welcome to Money Manager!';

  @override
  String accountCreatedMessage(String accountName) {
    return 'We\'ve created a \"$accountName\" for you to get started quickly.';
  }

  @override
  String get mainAccount => 'Main Account';

  @override
  String get accountSwitchInstructions =>
      'Tap the account name in the header to switch between accounts, or visit Settings to customize your currency and preferences.';

  @override
  String get gotItThanks => 'Got it, thanks!';

  @override
  String get mainAccountDescription =>
      'Your primary account for tracking expenses and income';

  @override
  String get transactionDetails => 'Transaction Details';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get deleteTransactionConfirmation =>
      'Are you sure you want to delete this transaction? This action cannot be undone.';

  @override
  String get enabled => 'Enabled';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get deleteTransactionTooltip => 'Delete Transaction';

  @override
  String get transactionDeletedSuccessfully =>
      'Transaction deleted successfully';

  @override
  String failedToDeleteTransaction(String error) {
    return 'Failed to delete transaction: $error';
  }

  @override
  String get category => 'Category';

  @override
  String get paymentSource => 'Payment Source';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get editTransactionTitle => 'Edit Transaction';

  @override
  String get transactionType => 'Transaction Type';

  @override
  String amount(String currencySymbol) {
    return 'Amount ($currencySymbol)';
  }

  @override
  String get amountHint => '0.00';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseEnterValidAmount =>
      'Please enter a valid amount greater than 0';

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Milk, Eggs etc';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get pleaseSelectPaymentSource => 'Please select a payment source';

  @override
  String get transactionCreatedSuccessfully =>
      'Transaction created successfully';

  @override
  String get transactionUpdatedSuccessfully =>
      'Transaction updated successfully';

  @override
  String failedToSaveTransaction(String error) {
    return 'Failed to save transaction: $error';
  }

  @override
  String failedToLoadData(String error) {
    return 'Failed to load data: $error';
  }

  @override
  String noCategoriesAvailable(String transactionType) {
    return 'No categories available for $transactionType';
  }

  @override
  String get selectCategory => 'Select a category';

  @override
  String get selectPaymentSource => 'Select a payment source';

  @override
  String get usd => 'USD';

  @override
  String get paymentSourcesTitle => 'Payment Sources';

  @override
  String get searchTransactionsTitle => 'Search Transactions';

  @override
  String get searchTransactionsHint =>
      'Search transactions, categories, amounts...';

  @override
  String get search => 'Search';

  @override
  String get searchYourTransactions => 'Search your transactions';

  @override
  String get searchInstructions =>
      'Enter keywords to find transactions by description, category, payment source, or amount';

  @override
  String get tryDifferentKeywords =>
      'Try different keywords or adjust your filters';

  @override
  String get transactions => 'Transactions';

  @override
  String get viewAllTransactions => 'View All Transactions';

  @override
  String previousPeriod(String period) {
    return 'Previous $period';
  }

  @override
  String nextPeriod(String period) {
    return 'Next $period';
  }

  @override
  String get noMonthsFound => 'No months found';

  @override
  String get noTransactionsThisYear => 'No transactions this year';

  @override
  String get addTransactionsToSeeMonthly =>
      'Add transactions to see monthly summaries';

  @override
  String get noDaysFound => 'No days found';

  @override
  String get noTransactionsThisMonth => 'No transactions this month';

  @override
  String noTransactionsForPeriod(String period) {
    return 'No transactions for $period';
  }

  @override
  String get addTransactionToGetStarted => 'Add a transaction to get started';

  @override
  String get noTransactionsText => 'No transactions';

  @override
  String accountTransactions(String accountName) {
    return '$accountName Transactions';
  }

  @override
  String accountYearlyTransactions(String accountName, int year) {
    return '$accountName - $year';
  }

  @override
  String noTransactionsInYear(int year) {
    return 'No transactions in $year';
  }

  @override
  String get searchCategories => 'Search categories...';

  @override
  String get noCategoriesFound => 'No categories found';

  @override
  String get errorLoadingSummary => 'Error loading summary';

  @override
  String get summary => 'Summary';

  @override
  String get newAccountDetected => 'New Account Detected';

  @override
  String get noAssociatedDetailsMessage =>
      'You don\'t have any associated details with Money Manager. Would you like to create an account with your Google details?';

  @override
  String get createAccount => 'Create Account';

  @override
  String get fetchingUserDetails => 'Fetching your details...';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get signInFailed => 'Sign in failed';

  @override
  String get accountCreationFailed => 'Account creation failed';

  @override
  String get failedToRemoveUser => 'Failed to remove user account';

  @override
  String get signOutFailed => 'Sign out failed';

  @override
  String get syncCategories => 'Sync Categories';

  @override
  String get syncCompleted => 'Categories synced successfully';

  @override
  String failedToSync(String error) {
    return 'Failed to sync categories: $error';
  }

  @override
  String get syncPaymentSources => 'Sync Payment Sources';

  @override
  String get paymentSourcesSyncCompleted =>
      'Payment sources synced successfully';

  @override
  String failedToSyncPaymentSources(String error) {
    return 'Failed to sync payment sources: $error';
  }

  @override
  String get profile => 'Profile';

  @override
  String get userProfile => 'User Profile';

  @override
  String get email => 'Email';

  @override
  String get preferences => 'Preferences';

  @override
  String get currencyTheme => 'Currency and theme settings';

  @override
  String get management => 'Management';

  @override
  String get accountsCategoriesPayment =>
      'Accounts, categories, and payment sources';

  @override
  String get backupRestore => 'Backup and restore your data';

  @override
  String get backupAccountSubtitle => 'Backup and sync your data';

  @override
  String get appVersion => 'View app information';

  @override
  String get accountAndSecurity => 'Account & Security';

  @override
  String get userProfileAndBackup => 'User profile and backup settings';

  @override
  String get viewUserDetails => 'View your profile information';

  @override
  String get backupAccountConnected => 'Backup account connected';

  @override
  String get yourDataIsSecure => 'Your data is secure and backed up';

  @override
  String get logout => 'Logout';

  @override
  String get logoutConfirmation =>
      'Are you sure you want to logout? You can sign in again anytime.';

  @override
  String get deleteAccountWarning =>
      'Deleting your account will remove all your data. This action cannot be undone. Are you sure?';

  @override
  String get deleteAccountConfirm => 'Confirm Account Deletion';

  @override
  String get deleteAccountConfirmMessage =>
      'This will permanently delete your account and all associated data. This action cannot be reversed.';

  @override
  String get deleteAccountPermanently => 'Delete Permanently';

  @override
  String get deletingAccount => 'Deleting account...';

  @override
  String get deleteAccountFailed => 'Failed to delete account';

  @override
  String get editUserProfile => 'Edit Profile';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get saving => 'Saving...';

  @override
  String get error => 'Error';

  @override
  String get editName => 'Edit Name';

  @override
  String get enterName => 'Enter your name';

  @override
  String get nameUpdatedSuccessfully => 'Name updated successfully';

  @override
  String get failedToUpdateName => 'Failed to update name';

  @override
  String get yourName => 'Your Name';

  @override
  String get analyticsComingSoon => 'Analytics coming soon!';

  @override
  String get noTransactions => 'No transactions';
}
