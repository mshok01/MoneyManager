import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/services/data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DataService Tests', () {
    late DataService dataService;

    setUp(() {
      dataService = DataService.instance;
      dataService.reset(); // Reset for each test
    });

    test('DataService should initialize successfully', () async {
      expect(dataService.isInitialized, false);

      await dataService.initialize();

      expect(dataService.isInitialized, true);
    });

    test('DataService should load default income categories', () async {
      await dataService.initialize();

      final incomeCategories = dataService.defaultIncomeCategories;

      expect(incomeCategories.isNotEmpty, true);
      expect(incomeCategories.length, 6); // We have 6 income categories

      // Check for specific categories
      final salaryCategory = incomeCategories.firstWhere(
        (cat) => cat.id == 'income_salary',
      );
      expect(salaryCategory.name, 'Salary');
      expect(salaryCategory.isDefault, true);
    });

    test('DataService should load default expense categories', () async {
      await dataService.initialize();

      final expenseCategories = dataService.defaultExpenseCategories;

      expect(expenseCategories.isNotEmpty, true);
      expect(expenseCategories.length, 9); // We have 9 expense categories

      // Check for specific categories
      final foodCategory = expenseCategories.firstWhere(
        (cat) => cat.id == 'expense_food',
      );
      expect(foodCategory.name, 'Food & Dining');
      expect(foodCategory.isDefault, true);
    });

    test('DataService should load default payment sources', () async {
      await dataService.initialize();

      final paymentSources = dataService.defaultPaymentSources;

      expect(paymentSources.isNotEmpty, true);
      expect(paymentSources.length, 7); // We have 7 payment sources

      // Check for specific payment source
      final creditCardSource = paymentSources.firstWhere(
        (source) => source.id == 'credit_card',
      );
      expect(creditCardSource.name, 'Credit Card');
      expect(creditCardSource.isDefault, true);
    });

    test('DataService should find categories by ID', () async {
      await dataService.initialize();

      final salaryCategory = dataService.findCategoryById('income_salary');
      expect(salaryCategory, isNotNull);
      expect(salaryCategory!.name, 'Salary');

      final nonExistentCategory = dataService.findCategoryById('non_existent');
      expect(nonExistentCategory, isNull);
    });

    test('DataService should find payment sources by ID', () async {
      await dataService.initialize();

      final creditCardSource = dataService.findPaymentSourceById('credit_card');
      expect(creditCardSource, isNotNull);
      expect(creditCardSource!.name, 'Credit Card');

      final nonExistentSource = dataService.findPaymentSourceById(
        'non_existent',
      );
      expect(nonExistentSource, isNull);
    });

    test(
      'DataService should identify default categories and payment sources',
      () async {
        await dataService.initialize();

        expect(dataService.isDefaultCategory('income_salary'), true);
        expect(dataService.isDefaultCategory('custom_category'), false);

        expect(dataService.isDefaultPaymentSource('credit_card'), true);
        expect(dataService.isDefaultPaymentSource('custom_source'), false);
      },
    );

    test(
      'DataService should provide copies of data for modification',
      () async {
        await dataService.initialize();

        final incomeCategories = dataService.getIncomeCategories();
        final expenseCategories = dataService.getExpenseCategories();
        final paymentSources = dataService.getPaymentSources();

        expect(
          incomeCategories.length,
          dataService.defaultIncomeCategories.length,
        );
        expect(
          expenseCategories.length,
          dataService.defaultExpenseCategories.length,
        );
        expect(paymentSources.length, dataService.defaultPaymentSources.length);

        // Modifying the returned lists should not affect the original data
        incomeCategories.clear();
        expect(dataService.defaultIncomeCategories.isNotEmpty, true);
      },
    );
  });
}
