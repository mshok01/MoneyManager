import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'default_data_migration.dart';
import 'dao/user_dao.dart';
import 'dao/account_dao.dart';
import 'dao/category_dao.dart';
import 'dao/payment_source_dao.dart';
import 'dao/transaction_dao.dart';
import 'dao/sync_queue_dao.dart';

/// Central database service that manages database connections and provides access to DAOs
class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  DatabaseService._();

  // Database helper
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // DAOs
  late final UserDao _userDao;
  late final AccountDao _accountDao;
  late final CategoryDao _categoryDao;
  late final PaymentSourceDao _paymentSourceDao;
  late final TransactionDao _transactionDao;
  late final SyncQueueDao _syncQueueDao;

  bool _isInitialized = false;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Get database instance
  Future<Database> get database async => await _databaseHelper.database;

  /// Get UserDao instance
  UserDao get userDao {
    _ensureInitialized();
    return _userDao;
  }

  /// Get AccountDao instance
  AccountDao get accountDao {
    _ensureInitialized();
    return _accountDao;
  }

  /// Get CategoryDao instance
  CategoryDao get categoryDao {
    _ensureInitialized();
    return _categoryDao;
  }

  /// Get PaymentSourceDao instance
  PaymentSourceDao get paymentSourceDao {
    _ensureInitialized();
    return _paymentSourceDao;
  }

  /// Get TransactionDao instance
  TransactionDao get transactionDao {
    _ensureInitialized();
    return _transactionDao;
  }

  /// Get SyncQueueDao instance
  SyncQueueDao get syncQueueDao {
    _ensureInitialized();
    return _syncQueueDao;
  }

  /// Initialize the database service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize database (this will create tables if they don't exist)
      await _databaseHelper.database;

      // Initialize DAOs
      _userDao = UserDao();
      _accountDao = AccountDao();
      _categoryDao = CategoryDao();
      _paymentSourceDao = PaymentSourceDao();
      _transactionDao = TransactionDao();
      _syncQueueDao = SyncQueueDao();

      _isInitialized = true;

      // Perform default data migration after everything is initialized
      await _performDefaultDataMigration();
    } catch (e) {
      throw Exception('Failed to initialize DatabaseService: $e');
    }
  }

  /// Perform default data migration if needed
  Future<void> _performDefaultDataMigration() async {
    try {
      await DefaultDataMigration.instance.migrateIfNeeded();
    } catch (e) {
      // Log error but don't throw to prevent app crash
      debugPrint('Warning: Failed to load default data: $e');
    }
  }

  /// Ensure the service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'DatabaseService not initialized. Call initialize() first.',
      );
    }
  }

  /// Check if database exists
  Future<bool> databaseExists() async {
    return await _databaseHelper.databaseExists();
  }

  /// Get database path
  Future<String> getDatabasePath() async {
    return await _databaseHelper.getDatabasePath();
  }

  /// Execute operations in a transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    return await _databaseHelper.transaction(action);
  }

  /// Execute raw SQL query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return await _databaseHelper.rawQuery(sql, arguments);
  }

  /// Execute raw SQL command
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]) async {
    return await _databaseHelper.rawExecute(sql, arguments);
  }

  /// Close database connection
  Future<void> close() async {
    await _databaseHelper.close();
    _isInitialized = false;
  }

  /// Delete database (useful for testing)
  Future<void> deleteDatabase() async {
    await _databaseHelper.deleteDatabase();
    _isInitialized = false;
  }

  /// Clear all data from all tables
  Future<void> clearAllData() async {
    _ensureInitialized();

    await transaction((txn) async {
      // Clear in reverse order of dependencies
      await _paymentSourceDao.clear();
      await _categoryDao.clear();
      await _accountDao.clear();
      await _userDao.clear();
    });
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    _ensureInitialized();

    final userStats = await _userDao.getUserStats();
    final accountStats = await _accountDao.getAccountStats();
    final categoryStats = await _categoryDao.getCategoryStats();
    final paymentSourceStats = await _paymentSourceDao.getPaymentSourceStats();

    return {
      'users': userStats,
      'accounts': accountStats,
      'categories': categoryStats,
      'paymentSources': paymentSourceStats,
      'databasePath': await getDatabasePath(),
      'databaseExists': await databaseExists(),
    };
  }

  /// Backup database data to JSON
  Future<Map<String, dynamic>> backupData() async {
    _ensureInitialized();

    final users = await _userDao.getAll();
    final accounts = await _accountDao.getAll();
    final categories = await _categoryDao.getAll();
    final paymentSources = await _paymentSourceDao.getAll();

    return {
      'version': 1,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
      'users': users.map((user) => _userDao.toMap(user)).toList(),
      'accounts': accounts
          .map((account) => _accountDao.toMap(account))
          .toList(),
      'categories': categories
          .map((category) => _categoryDao.toMap(category))
          .toList(),
      'paymentSources': paymentSources
          .map((source) => _paymentSourceDao.toMap(source))
          .toList(),
    };
  }

  /// Restore database data from JSON backup
  Future<void> restoreData(Map<String, dynamic> backupData) async {
    _ensureInitialized();

    await transaction((txn) async {
      // Clear existing data
      await clearAllData();

      // Restore users first (as they are referenced by other tables)
      if (backupData['users'] != null) {
        final userMaps = List<Map<String, dynamic>>.from(backupData['users']);
        final users = userMaps.map((map) => _userDao.fromMap(map)).toList();
        await _userDao.insertBatch(users);
      }

      // Restore accounts
      if (backupData['accounts'] != null) {
        final accountMaps = List<Map<String, dynamic>>.from(
          backupData['accounts'],
        );
        final accounts = accountMaps
            .map((map) => _accountDao.fromMap(map))
            .toList();
        await _accountDao.insertBatch(accounts);
      }

      // Restore categories
      if (backupData['categories'] != null) {
        final categoryMaps = List<Map<String, dynamic>>.from(
          backupData['categories'],
        );
        final categories = categoryMaps
            .map((map) => _categoryDao.fromMap(map))
            .toList();
        await _categoryDao.insertBatch(categories);
      }

      // Restore payment sources
      if (backupData['paymentSources'] != null) {
        final paymentSourceMaps = List<Map<String, dynamic>>.from(
          backupData['paymentSources'],
        );
        final paymentSources = paymentSourceMaps
            .map((map) => _paymentSourceDao.fromMap(map))
            .toList();
        await _paymentSourceDao.insertBatch(paymentSources);
      }
    });
  }

  /// Validate database integrity
  Future<Map<String, dynamic>> validateDatabaseIntegrity() async {
    _ensureInitialized();

    final issues = <String>[];
    final stats = <String, int>{};

    try {
      // Check table existence and basic queries
      final users = await _userDao.getAll();
      stats['users'] = users.length;

      final accounts = await _accountDao.getAll();
      stats['accounts'] = accounts.length;

      final categories = await _categoryDao.getAll();
      stats['categories'] = categories.length;

      final paymentSources = await _paymentSourceDao.getAll();
      stats['paymentSources'] = paymentSources.length;

      // Check for orphaned accounts (accounts with non-existent creators)
      for (final account in accounts) {
        final creator = await _userDao.getById(account.createdBy);
        if (creator == null) {
          issues.add(
            'Account ${account.id} has non-existent creator ${account.createdBy}',
          );
        }
      }

      // Check for orphaned categories (categories with non-existent creators)
      for (final category in categories) {
        if (!category.isDefault) {
          final creator = await _userDao.getById(category.createdBy);
          if (creator == null) {
            issues.add(
              'Category ${category.id} has non-existent creator ${category.createdBy}',
            );
          }
        }
      }

      // Check for orphaned payment sources (payment sources with non-existent creators)
      for (final paymentSource in paymentSources) {
        if (!paymentSource.isDefault) {
          final creator = await _userDao.getById(paymentSource.createdBy);
          if (creator == null) {
            issues.add(
              'PaymentSource ${paymentSource.id} has non-existent creator ${paymentSource.createdBy}',
            );
          }
        }
      }
    } catch (e) {
      issues.add('Database validation error: $e');
    }

    return {
      'isValid': issues.isEmpty,
      'issues': issues,
      'stats': stats,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
    };
  }

  /// Repair database integrity issues
  Future<Map<String, dynamic>> repairDatabaseIntegrity() async {
    _ensureInitialized();

    final repairActions = <String>[];
    int repairedCount = 0;

    try {
      await transaction((txn) async {
        // Remove orphaned accounts
        final accounts = await _accountDao.getAll();
        for (final account in accounts) {
          final creator = await _userDao.getById(account.createdBy);
          if (creator == null) {
            await _accountDao.delete(account.id);
            repairActions.add('Removed orphaned account ${account.id}');
            repairedCount++;
          }
        }

        // Remove orphaned custom categories
        final categories = await _categoryDao.getAll();
        for (final category in categories) {
          if (!category.isDefault) {
            final creator = await _userDao.getById(category.createdBy);
            if (creator == null) {
              await _categoryDao.delete(category.id);
              repairActions.add('Removed orphaned category ${category.id}');
              repairedCount++;
            }
          }
        }

        // Remove orphaned custom payment sources
        final paymentSources = await _paymentSourceDao.getAll();
        for (final paymentSource in paymentSources) {
          if (!paymentSource.isDefault) {
            final creator = await _userDao.getById(paymentSource.createdBy);
            if (creator == null) {
              await _paymentSourceDao.delete(paymentSource.id);
              repairActions.add(
                'Removed orphaned payment source ${paymentSource.id}',
              );
              repairedCount++;
            }
          }
        }
      });
    } catch (e) {
      repairActions.add('Repair error: $e');
    }

    return {
      'success': true,
      'repairedCount': repairedCount,
      'actions': repairActions,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
    };
  }
}
