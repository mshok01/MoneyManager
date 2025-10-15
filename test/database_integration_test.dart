import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../lib/database/database_service.dart';
import '../lib/models/user.dart';
import '../lib/models/account.dart';
import '../lib/models/category_item.dart';
import '../lib/models/payment_source.dart';
import '../lib/services/user_service.dart';
import '../lib/services/account_service.dart';
import '../lib/services/category_service.dart';
import '../lib/services/payment_source_service.dart';

void main() {
  group('Database Integration Tests', () {
    late DatabaseService databaseService;
    final uuid = const Uuid();

    setUpAll(() async {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Use in-memory database for testing
      databaseService = DatabaseService.instance;
      await databaseService.initialize();
    });

    tearDown(() async {
      // Clean up after each test
      await databaseService.userDao.clear();
      await databaseService.accountDao.clear();
      await databaseService.categoryDao.clear();
      await databaseService.paymentSourceDao.clear();
    });

    test('Database initialization should work', () async {
      expect(databaseService.isInitialized, true);

      // Test that all DAOs are accessible
      expect(databaseService.userDao, isNotNull);
      expect(databaseService.accountDao, isNotNull);
      expect(databaseService.categoryDao, isNotNull);
      expect(databaseService.paymentSourceDao, isNotNull);
    });

    test('User CRUD operations should work', () async {
      final user = User(
        id: uuid.v4(),
        email: 'test@example.com',
        name: 'Test User',
        profilePic: '',
        createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        isActive: 1,
        currencyCode: 'USD',
        currencyName: 'US Dollar',
      );

      // Test insert
      await databaseService.userDao.insert(user);

      // Test get by ID
      final retrievedUser = await databaseService.userDao.getById(user.id);
      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.email, user.email);
      expect(retrievedUser.name, user.name);

      // Test update
      final updatedUser = user.copyWith(name: 'Updated Name');
      await databaseService.userDao.update(updatedUser, user.id);

      final retrievedUpdatedUser = await databaseService.userDao.getById(
        user.id,
      );
      expect(retrievedUpdatedUser!.name, 'Updated Name');

      // Test delete
      await databaseService.userDao.delete(user.id);
      final deletedUser = await databaseService.userDao.getById(user.id);
      expect(deletedUser, isNull);
    });

    test('Account CRUD operations should work', () async {
      final userId = uuid.v4();
      final account = Account(
        id: uuid.v4(),
        name: 'Test Account',
        description: 'Test Description',
        pic: '',
        createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        isActive: 1,
        createdBy: userId,
        members: [userId],
        admins: [userId],
        baseCurrency: 'USD',
        baseCurrencyName: 'US Dollar',
      );

      // Test insert
      await databaseService.accountDao.insert(account);

      // Test get by ID
      final retrievedAccount = await databaseService.accountDao.getById(
        account.id,
      );
      expect(retrievedAccount, isNotNull);
      expect(retrievedAccount!.name, account.name);
      expect(retrievedAccount.members, contains(userId));
      expect(retrievedAccount.admins, contains(userId));

      // Test get accounts for user
      final userAccounts = await databaseService.accountDao.getAccountsForUser(
        userId,
      );
      expect(userAccounts.length, 1);
      expect(userAccounts.first.id, account.id);
    });

    test('Service integration should work', () async {
      // Initialize services
      await UserService.instance.initialize();
      await AccountService.instance.initialize();
      await CategoryService.instance.initialize();
      await PaymentSourceService.instance.initialize();

      expect(UserService.instance.isInitialized, true);
      expect(AccountService.instance.isInitialized, true);
      expect(CategoryService.instance.isInitialized, true);
      expect(PaymentSourceService.instance.isInitialized, true);
    });

    test('Default data migration should work', () async {
      // Check if default categories exist after initialization
      final incomeCategories = await CategoryService.instance
          .getIncomeCategories();
      final expenseCategories = await CategoryService.instance
          .getExpenseCategories();
      final paymentSources = await PaymentSourceService.instance
          .getAllPaymentSources();

      // We should have some default data after migration
      expect(incomeCategories.isNotEmpty, true);
      expect(expenseCategories.isNotEmpty, true);
      expect(paymentSources.isNotEmpty, true);

      // Check that default categories are marked as default
      final defaultIncomeCategories = incomeCategories
          .where((cat) => cat.isDefault)
          .toList();
      expect(defaultIncomeCategories.isNotEmpty, true);
    });

    test('User service should persist data to database', () async {
      await UserService.instance.initialize();

      // Create a user through the service
      final user = await UserService.instance.createUser(
        email: 'service@example.com',
        name: 'Service User',
        currencyCode: 'EUR',
        currencyName: 'Euro',
      );

      expect(user, isNotNull);
      expect(UserService.instance.hasUser, true);

      // Verify the user was saved to database
      final dbUser = await databaseService.userDao.getById(user.id);
      expect(dbUser, isNotNull);
      expect(dbUser!.email, 'service@example.com');
      expect(dbUser.name, 'Service User');
      expect(dbUser.currencyCode, 'EUR');
    });

    test('Account service should persist data to database', () async {
      await UserService.instance.initialize();
      await AccountService.instance.initialize();

      // Create a user first
      final user = await UserService.instance.createUser(
        email: 'account@example.com',
        name: 'Account User',
        currencyCode: 'USD',
        currencyName: 'US Dollar',
      );

      // Create an account through the service
      final account = await AccountService.instance.createAccount(
        name: 'Service Account',
        description: 'Created through service',
        createdBy: user.id,
      );

      expect(account, isNotNull);
      expect(account.name, 'Service Account');

      // Verify the account was saved to database
      final dbAccount = await databaseService.accountDao.getById(account.id);
      expect(dbAccount, isNotNull);
      expect(dbAccount!.name, 'Service Account');
      expect(dbAccount.createdBy, user.id);
      expect(dbAccount.members, contains(user.id));
      expect(dbAccount.admins, contains(user.id));
    });

    test('Database statistics should work', () async {
      // Add some test data
      final userId = uuid.v4();
      final user = User(
        id: userId,
        email: 'stats@example.com',
        name: 'Stats User',
        profilePic: '',
        createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        isActive: 1,
        currencyCode: 'USD',
        currencyName: 'US Dollar',
      );
      await databaseService.userDao.insert(user);

      final account = Account(
        id: uuid.v4(),
        name: 'Stats Account',
        description: '',
        pic: '',
        createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        isActive: 1,
        createdBy: userId,
        members: [userId],
        admins: [userId],
        baseCurrency: 'USD',
        baseCurrencyName: 'US Dollar',
      );
      await databaseService.accountDao.insert(account);

      // Get database statistics
      final stats = await databaseService.getDatabaseStats();

      expect(stats['userCount'], greaterThanOrEqualTo(1));
      expect(stats['accountCount'], greaterThanOrEqualTo(1));
      expect(stats['categoryCount'], greaterThanOrEqualTo(0));
      expect(stats['paymentSourceCount'], greaterThanOrEqualTo(0));
    });

    test('Database integrity validation should work', () async {
      final isValid = await databaseService.validateDatabaseIntegrity();
      expect(isValid, true);
    });
  });
}
