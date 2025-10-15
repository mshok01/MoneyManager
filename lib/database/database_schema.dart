/// Database schema constants and utilities for Money Manager app
class DatabaseSchema {
  // Database configuration
  static const String databaseName = 'money_manager.db';
  static const int databaseVersion = 3;

  // Table names
  static const String tableUsers = 'users';
  static const String tableAccounts = 'accounts';
  static const String tableCategories = 'categories';
  static const String tablePaymentSources = 'payment_sources';
  static const String tableTransactions = 'transactions';

  // Users table columns
  static const String usersId = 'id';
  static const String usersCreatedAt = 'created_at';
  static const String usersUpdatedAt = 'updated_at';
  static const String usersIsActive = 'is_active';
  static const String usersEmail = 'email';
  static const String usersName = 'name';
  static const String usersProfilePic = 'profile_pic';
  static const String usersCurrencyCode = 'currency_code';
  static const String usersCurrencyName = 'currency_name';

  // Accounts table columns
  static const String accountsId = 'id';
  static const String accountsName = 'name';
  static const String accountsDescription = 'description';
  static const String accountsPic = 'pic';
  static const String accountsCreatedAt = 'created_at';
  static const String accountsUpdatedAt = 'updated_at';
  static const String accountsIsActive = 'is_active';
  static const String accountsCreatedBy = 'created_by';
  static const String accountsMembers = 'members';
  static const String accountsAdmins = 'admins';
  static const String accountsBaseCurrency = 'baseCurrency';
  static const String accountsBaseCurrencyName = 'baseCurrencyName';

  // Categories table columns
  static const String categoriesId = 'id';
  static const String categoriesName = 'name';
  static const String categoriesDescription = 'description';
  static const String categoriesIcon = 'icon';
  static const String categoriesColor = 'color';
  static const String categoriesIsDefault = 'is_default';
  static const String categoriesCreatedBy = 'created_by';
  static const String categoriesCreatedAt = 'created_at';
  static const String categoriesUpdatedAt = 'updated_at';
  static const String categoriesAccessTo = 'access_to';
  static const String categoriesCategoryType = 'category_type';

  // Payment sources table columns
  static const String paymentSourcesId = 'id';
  static const String paymentSourcesName = 'name';
  static const String paymentSourcesDescription = 'description';
  static const String paymentSourcesIcon = 'icon';
  static const String paymentSourcesColor = 'color';
  static const String paymentSourcesIsDefault = 'is_default';
  static const String paymentSourcesCreatedBy = 'created_by';
  static const String paymentSourcesCreatedAt = 'created_at';
  static const String paymentSourcesUpdatedAt = 'updated_at';
  static const String paymentSourcesAccessTo = 'access_to';

  // Transactions table columns
  static const String transactionsId = 'id';
  static const String transactionsAccountId = 'account_id';
  static const String transactionsCategoryId = 'category_id';
  static const String transactionsPaymentSourceId = 'payment_source_id';
  static const String transactionsAmount = 'amount';
  static const String transactionsDescription = 'description';
  static const String transactionsType = 'type';
  static const String transactionsTransactionDate = 'transaction_date';
  static const String transactionsCreatedAt = 'created_at';
  static const String transactionsUpdatedAt = 'updated_at';
  static const String transactionsIsActive = 'is_active';
  static const String transactionsCreatedBy = 'created_by';

  // Category types
  static const String categoryTypeIncome = 'income';
  static const String categoryTypeExpense = 'expense';

  // Transaction types
  static const String transactionTypeIncome = 'income';
  static const String transactionTypeExpense = 'expense';

  /// Get all table names
  static List<String> get allTables => [
    tableUsers,
    tableAccounts,
    tableCategories,
    tablePaymentSources,
    tableTransactions,
  ];

  /// Get users table columns
  static List<String> get usersColumns => [
    usersId,
    usersCreatedAt,
    usersUpdatedAt,
    usersIsActive,
    usersEmail,
    usersName,
    usersProfilePic,
    usersCurrencyCode,
    usersCurrencyName,
  ];

  /// Get accounts table columns
  static List<String> get accountsColumns => [
    accountsId,
    accountsName,
    accountsDescription,
    accountsPic,
    accountsCreatedAt,
    accountsUpdatedAt,
    accountsIsActive,
    accountsCreatedBy,
    accountsMembers,
    accountsAdmins,
    accountsBaseCurrency,
    accountsBaseCurrencyName,
  ];

  /// Get categories table columns
  static List<String> get categoriesColumns => [
    categoriesId,
    categoriesName,
    categoriesDescription,
    categoriesIcon,
    categoriesColor,
    categoriesIsDefault,
    categoriesCreatedBy,
    categoriesCreatedAt,
    categoriesUpdatedAt,
    categoriesAccessTo,
    categoriesCategoryType,
  ];

  /// Get payment sources table columns
  static List<String> get paymentSourcesColumns => [
    paymentSourcesId,
    paymentSourcesName,
    paymentSourcesDescription,
    paymentSourcesIcon,
    paymentSourcesColor,
    paymentSourcesIsDefault,
    paymentSourcesCreatedBy,
    paymentSourcesCreatedAt,
    paymentSourcesUpdatedAt,
    paymentSourcesAccessTo,
  ];

  /// Get transactions table columns
  static List<String> get transactionsColumns => [
    transactionsId,
    transactionsAccountId,
    transactionsCategoryId,
    transactionsPaymentSourceId,
    transactionsAmount,
    transactionsDescription,
    transactionsType,
    transactionsTransactionDate,
    transactionsCreatedAt,
    transactionsUpdatedAt,
    transactionsIsActive,
    transactionsCreatedBy,
  ];

  /// Validate table name
  static bool isValidTable(String tableName) {
    return allTables.contains(tableName);
  }

  /// Validate category type
  static bool isValidCategoryType(String categoryType) {
    return categoryType == categoryTypeIncome ||
        categoryType == categoryTypeExpense;
  }

  /// Get CREATE TABLE statement for users
  static String get createUsersTable =>
      '''
    CREATE TABLE $tableUsers (
      $usersId TEXT PRIMARY KEY,
      $usersCreatedAt INTEGER NOT NULL,
      $usersUpdatedAt INTEGER NOT NULL,
      $usersIsActive INTEGER NOT NULL DEFAULT 1,
      $usersEmail TEXT NOT NULL,
      $usersName TEXT NOT NULL,
      $usersProfilePic TEXT NOT NULL DEFAULT '',
      $usersCurrencyCode TEXT NOT NULL,
      $usersCurrencyName TEXT NOT NULL
    )
  ''';

  /// Get CREATE TABLE statement for accounts
  static String get createAccountsTable =>
      '''
    CREATE TABLE $tableAccounts (
      $accountsId TEXT PRIMARY KEY,
      $accountsName TEXT NOT NULL,
      $accountsDescription TEXT NOT NULL DEFAULT '',
      $accountsPic TEXT NOT NULL DEFAULT '',
      $accountsCreatedAt INTEGER NOT NULL,
      $accountsUpdatedAt INTEGER NOT NULL,
      $accountsIsActive INTEGER NOT NULL DEFAULT 1,
      $accountsCreatedBy TEXT NOT NULL,
      $accountsMembers TEXT NOT NULL DEFAULT '[]',
      $accountsAdmins TEXT NOT NULL DEFAULT '[]',
      $accountsBaseCurrency TEXT NOT NULL DEFAULT '',
      $accountsBaseCurrencyName TEXT NOT NULL DEFAULT '',
      FOREIGN KEY ($accountsCreatedBy) REFERENCES $tableUsers ($usersId) ON DELETE CASCADE
    )
  ''';

  /// Get CREATE TABLE statement for categories
  static String get createCategoriesTable =>
      '''
    CREATE TABLE $tableCategories (
      $categoriesId TEXT PRIMARY KEY,
      $categoriesName TEXT NOT NULL,
      $categoriesDescription TEXT NOT NULL DEFAULT '',
      $categoriesIcon TEXT NOT NULL,
      $categoriesColor TEXT NOT NULL,
      $categoriesIsDefault INTEGER NOT NULL DEFAULT 0,
      $categoriesCreatedBy TEXT NOT NULL,
      $categoriesCreatedAt INTEGER NOT NULL,
      $categoriesUpdatedAt INTEGER NOT NULL,
      $categoriesAccessTo TEXT NOT NULL DEFAULT '[]',
      $categoriesCategoryType TEXT NOT NULL CHECK ($categoriesCategoryType IN ('$categoryTypeIncome', '$categoryTypeExpense'))
    )
  ''';

  /// Get CREATE TABLE statement for payment sources
  static String get createPaymentSourcesTable =>
      '''
    CREATE TABLE $tablePaymentSources (
      $paymentSourcesId TEXT PRIMARY KEY,
      $paymentSourcesName TEXT NOT NULL,
      $paymentSourcesDescription TEXT NOT NULL DEFAULT '',
      $paymentSourcesIcon TEXT NOT NULL,
      $paymentSourcesColor TEXT NOT NULL,
      $paymentSourcesIsDefault INTEGER NOT NULL DEFAULT 0,
      $paymentSourcesCreatedBy TEXT NOT NULL,
      $paymentSourcesCreatedAt INTEGER NOT NULL,
      $paymentSourcesUpdatedAt INTEGER NOT NULL,
      $paymentSourcesAccessTo TEXT NOT NULL DEFAULT '[]'
    )
  ''';

  /// Get CREATE TABLE statement for transactions
  static String get createTransactionsTable =>
      '''
    CREATE TABLE $tableTransactions (
      $transactionsId TEXT PRIMARY KEY,
      $transactionsAccountId TEXT NOT NULL,
      $transactionsCategoryId TEXT NOT NULL,
      $transactionsPaymentSourceId TEXT NOT NULL,
      $transactionsAmount REAL NOT NULL,
      $transactionsDescription TEXT NOT NULL DEFAULT '',
      $transactionsType TEXT NOT NULL CHECK ($transactionsType IN ('$transactionTypeIncome', '$transactionTypeExpense')),
      $transactionsTransactionDate INTEGER NOT NULL,
      $transactionsCreatedAt INTEGER NOT NULL,
      $transactionsUpdatedAt INTEGER NOT NULL,
      $transactionsIsActive INTEGER NOT NULL DEFAULT 1,
      $transactionsCreatedBy TEXT NOT NULL,
      FOREIGN KEY ($transactionsAccountId) REFERENCES $tableAccounts ($accountsId) ON DELETE CASCADE,
      FOREIGN KEY ($transactionsCategoryId) REFERENCES $tableCategories ($categoriesId) ON DELETE CASCADE,
      FOREIGN KEY ($transactionsPaymentSourceId) REFERENCES $tablePaymentSources ($paymentSourcesId) ON DELETE CASCADE,
      FOREIGN KEY ($transactionsCreatedBy) REFERENCES $tableUsers ($usersId) ON DELETE CASCADE
    )
  ''';

  /// Get all CREATE INDEX statements
  static List<String> get createIndexStatements => [
    // Users indexes
    'CREATE INDEX idx_users_email ON $tableUsers ($usersEmail)',
    'CREATE INDEX idx_users_is_active ON $tableUsers ($usersIsActive)',

    // Accounts indexes
    'CREATE INDEX idx_accounts_created_by ON $tableAccounts ($accountsCreatedBy)',
    'CREATE INDEX idx_accounts_is_active ON $tableAccounts ($accountsIsActive)',
    'CREATE INDEX idx_accounts_name ON $tableAccounts ($accountsName)',

    // Categories indexes
    'CREATE INDEX idx_categories_created_by ON $tableCategories ($categoriesCreatedBy)',
    'CREATE INDEX idx_categories_is_default ON $tableCategories ($categoriesIsDefault)',
    'CREATE INDEX idx_categories_type ON $tableCategories ($categoriesCategoryType)',

    // Payment sources indexes
    'CREATE INDEX idx_payment_sources_created_by ON $tablePaymentSources ($paymentSourcesCreatedBy)',
    'CREATE INDEX idx_payment_sources_is_default ON $tablePaymentSources ($paymentSourcesIsDefault)',

    // Transactions indexes
    'CREATE INDEX idx_transactions_account_id ON $tableTransactions ($transactionsAccountId)',
    'CREATE INDEX idx_transactions_category_id ON $tableTransactions ($transactionsCategoryId)',
    'CREATE INDEX idx_transactions_payment_source_id ON $tableTransactions ($transactionsPaymentSourceId)',
    'CREATE INDEX idx_transactions_created_by ON $tableTransactions ($transactionsCreatedBy)',
    'CREATE INDEX idx_transactions_type ON $tableTransactions ($transactionsType)',
    'CREATE INDEX idx_transactions_date ON $tableTransactions ($transactionsTransactionDate)',
    'CREATE INDEX idx_transactions_is_active ON $tableTransactions ($transactionsIsActive)',
    'CREATE INDEX idx_transactions_account_date ON $tableTransactions ($transactionsAccountId, $transactionsTransactionDate)',
  ];

  /// Get all DROP TABLE statements
  static List<String> get dropTableStatements => [
    'DROP TABLE IF EXISTS $tableTransactions',
    'DROP TABLE IF EXISTS $tablePaymentSources',
    'DROP TABLE IF EXISTS $tableCategories',
    'DROP TABLE IF EXISTS $tableAccounts',
    'DROP TABLE IF EXISTS $tableUsers',
  ];
}
