import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/main.dart';
import 'package:money_manager/database/database_service.dart';
import 'package:money_manager/models/user.dart';
import 'package:money_manager/models/account.dart';
import 'package:money_manager/services/user_service.dart';
import 'package:money_manager/services/account_service.dart';
import 'package:money_manager/services/preferences_service.dart';
import 'package:money_manager/providers/account_providers.dart';
import 'package:money_manager/providers/transaction_providers.dart';
import 'package:money_manager/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    
    // Initialize DatabaseService once for the entire suite
    if (!DatabaseService.instance.isInitialized) {
      // FFI database file gets reused, so we ensure it's clean before starting the suite
      // But we can't reliably delete the DB if it was already initialized, 
      // so we just initialize it and rely on DAOs clear
      await DatabaseService.instance.initialize();
    }
  });

  group('Category Management Tests', () {
    late Account globalAccount;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PreferencesService.getInstance();
      await prefs.clearAll();

      // Clear DAOs manually piece by piece to avoid DatabaseService.clearAllData()
      // which has a known deadlock bug when executing db.delete within a transaction
      await DatabaseService.instance.paymentSourceDao.clear();
      await DatabaseService.instance.categoryDao.clear();
      await DatabaseService.instance.accountDao.clear();
      await DatabaseService.instance.userDao.clear();

      await UserService.instance.initialize();
      await UserService.instance.clearUserData();

      final userId = getUniqueId();
      final user = User(
        id: userId,
        email: 'test@example.com',
        name: 'Test User',
        profilePic: '',
        createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
        isActive: 1,
        currencyCode: 'USD',
        currencyName: 'US Dollar',
      );
      await DatabaseService.instance.userDao.insert(user);
      await UserService.instance.refreshUser();

      final account = Account(
        id: getUniqueId(),
        name: 'Test Account',
        description: 'Test Account',
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
      globalAccount = account;
      await DatabaseService.instance.accountDao.insert(account);
      await AccountService.instance.initialize();
    });

    testWidgets('Categories option appears in settings screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          accountHasTransactionsProvider(globalAccount.id).overrideWith((ref) => Future.value(false)),
        ],
        child: const MoneyManagerApp(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Categories'), findsAtLeastNWidgets(1));
      expect(find.text('Manage Categories'), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('Categories option navigates to category screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          accountHasTransactionsProvider(globalAccount.id).overrideWith((ref) => Future.value(false)),
        ],
        child: const MoneyManagerApp(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();

      expect(find.text('Categories'), findsAtLeastNWidgets(1));
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expenses'), findsOneWidget);
    });

    testWidgets('Category screen shows default categories', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          accountHasTransactionsProvider(globalAccount.id).overrideWith((ref) => Future.value(false)),
        ],
        child: const MoneyManagerApp(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();

      expect(find.text('Categories'), findsAtLeastNWidgets(1));

      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('Freelance'), findsOneWidget);
      expect(find.text('Business'), findsOneWidget);
      expect(find.text('Investment Returns'), findsOneWidget);
      expect(find.text('Gifts Received'), findsOneWidget);
      expect(find.text('Other Income'), findsOneWidget);

      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();

      expect(find.text('Food & Dining'), findsOneWidget);
      expect(find.text('Transportation'), findsOneWidget);
      expect(find.text('Utilities'), findsOneWidget);
      expect(find.text('Housing'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text('Healthcare'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Financial'), findsOneWidget);
      expect(find.text('Other Expenses'), findsOneWidget);
    });

    testWidgets('Category screen has add button in app bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          accountHasTransactionsProvider(globalAccount.id).overrideWith((ref) => Future.value(false)),
        ],
        child: const MoneyManagerApp(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Add Category'), findsOneWidget);
      expect(find.text('Category Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Category Type'), findsOneWidget);
      expect(find.text('Income'), findsAtLeastNWidgets(1));
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Can add a new category', (WidgetTester tester) async {
      await tester.pumpWidget(ProviderScope(
        overrides: [
          accountHasTransactionsProvider(globalAccount.id).overrideWith((ref) => Future.value(false)),
        ],
        child: const MoneyManagerApp(),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await tester.tap(find.byIcon(Icons.category));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'Test Category');
      await tester.enterText(
        find.byType(TextFormField).last,
        'Test Description',
      );

      await tester.tap(find.text('Expense'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
        find.text("Category 'Test Category' added successfully"),
        findsOneWidget,
      );

      await tester.tap(find.text('Expenses'));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Test Category'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
    });
  });
}
