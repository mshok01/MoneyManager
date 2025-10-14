import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/category_item.dart';
import '../models/payment_source.dart';
import 'database_service.dart';
import 'database_schema.dart';

/// Service to handle migration of default data from JSON files to SQLite database
class DefaultDataMigration {
  static DefaultDataMigration? _instance;
  static DefaultDataMigration get instance {
    _instance ??= DefaultDataMigration._();
    return _instance!;
  }

  DefaultDataMigration._();

  static const String _migrationCompleteKey = 'default_data_migration_complete';
  static const String _categoriesAssetPath =
      'assets/data/default_categories.json';
  static const String _paymentSourcesAssetPath =
      'assets/data/default_payment_sources.json';

  /// Check if default data migration has been completed
  Future<bool> isMigrationComplete() async {
    try {
      final db = await DatabaseService.instance.database;

      // Check if we have any default categories or payment sources
      final categoryCount = await DatabaseService.instance.categoryDao.count(
        where: '${DatabaseSchema.categoriesIsDefault} = ?',
        whereArgs: [1],
      );

      final paymentSourceCount = await DatabaseService.instance.paymentSourceDao
          .count(
            where: '${DatabaseSchema.paymentSourcesIsDefault} = ?',
            whereArgs: [1],
          );

      return categoryCount > 0 && paymentSourceCount > 0;
    } catch (e) {
      return false;
    }
  }

  /// Perform default data migration if not already completed
  Future<void> migrateIfNeeded() async {
    if (await isMigrationComplete()) {
      return; // Migration already completed
    }

    await _performMigration();
  }

  /// Force migration (useful for testing or data reset)
  Future<void> forceMigration() async {
    await _performMigration();
  }

  /// Perform the actual migration
  Future<void> _performMigration() async {
    try {
      // Clear existing default data
      await _clearExistingDefaultData();

      // Load and insert default categories
      await _loadDefaultCategories();

      // Load and insert default payment sources
      await _loadDefaultPaymentSources();
    } catch (e) {
      throw Exception('Failed to perform default data migration: $e');
    }
  }

  /// Clear existing default data
  Future<void> _clearExistingDefaultData() async {
    // Remove existing default categories
    await DatabaseService.instance.rawExecute(
      'DELETE FROM ${DatabaseSchema.tableCategories} WHERE ${DatabaseSchema.categoriesIsDefault} = ?',
      [1],
    );

    // Remove existing default payment sources
    await DatabaseService.instance.rawExecute(
      'DELETE FROM ${DatabaseSchema.tablePaymentSources} WHERE ${DatabaseSchema.paymentSourcesIsDefault} = ?',
      [1],
    );
  }

  /// Load default categories from JSON and insert into database
  Future<void> _loadDefaultCategories() async {
    try {
      // Load JSON data
      final jsonString = await rootBundle.loadString(_categoriesAssetPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Parse income categories
      final incomeCategories = <CategoryItem>[];
      if (jsonData['income_categories'] != null) {
        final incomeCategoryMaps = List<Map<String, dynamic>>.from(
          jsonData['income_categories'],
        );
        for (final categoryMap in incomeCategoryMaps) {
          final category = CategoryItem.fromJson(categoryMap);
          incomeCategories.add(category);
        }
      }

      // Parse expense categories
      final expenseCategories = <CategoryItem>[];
      if (jsonData['expense_categories'] != null) {
        final expenseCategoryMaps = List<Map<String, dynamic>>.from(
          jsonData['expense_categories'],
        );
        for (final categoryMap in expenseCategoryMaps) {
          final category = CategoryItem.fromJson(categoryMap);
          expenseCategories.add(category);
        }
      }

      // Insert income categories
      for (final category in incomeCategories) {
        await DatabaseService.instance.categoryDao.insertWithType(
          category,
          DatabaseSchema.categoryTypeIncome,
        );
      }

      // Insert expense categories
      for (final category in expenseCategories) {
        await DatabaseService.instance.categoryDao.insertWithType(
          category,
          DatabaseSchema.categoryTypeExpense,
        );
      }
    } catch (e) {
      throw Exception('Failed to load default categories: $e');
    }
  }

  /// Load default payment sources from JSON and insert into database
  Future<void> _loadDefaultPaymentSources() async {
    try {
      // Load JSON data
      final jsonString = await rootBundle.loadString(_paymentSourcesAssetPath);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      // Parse payment sources
      final paymentSources = <PaymentSource>[];
      if (jsonData['payment_sources'] != null) {
        final paymentSourceMaps = List<Map<String, dynamic>>.from(
          jsonData['payment_sources'],
        );
        for (final paymentSourceMap in paymentSourceMaps) {
          final paymentSource = PaymentSource.fromJson(paymentSourceMap);
          paymentSources.add(paymentSource);
        }
      }

      // Insert payment sources
      await DatabaseService.instance.paymentSourceDao.insertBatch(
        paymentSources,
      );
    } catch (e) {
      throw Exception('Failed to load default payment sources: $e');
    }
  }

  /// Get migration status and statistics
  Future<Map<String, dynamic>> getMigrationStatus() async {
    try {
      final isComplete = await isMigrationComplete();

      final categoryCount = await DatabaseService.instance.categoryDao.count(
        where: '${DatabaseSchema.categoriesIsDefault} = ?',
        whereArgs: [1],
      );

      final paymentSourceCount = await DatabaseService.instance.paymentSourceDao
          .count(
            where: '${DatabaseSchema.paymentSourcesIsDefault} = ?',
            whereArgs: [1],
          );

      final incomeCategories = await DatabaseService.instance.categoryDao
          .getIncomeCategories();
      final expenseCategories = await DatabaseService.instance.categoryDao
          .getExpenseCategories();
      final defaultPaymentSources = await DatabaseService
          .instance
          .paymentSourceDao
          .getDefaultPaymentSources();

      return {
        'isComplete': isComplete,
        'defaultCategoryCount': categoryCount,
        'defaultPaymentSourceCount': paymentSourceCount,
        'incomeCategoryCount': incomeCategories
            .where((c) => c.isDefault)
            .length,
        'expenseCategoryCount': expenseCategories
            .where((c) => c.isDefault)
            .length,
        'defaultPaymentSources': defaultPaymentSources.length,
        'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
      };
    } catch (e) {
      return {
        'isComplete': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
      };
    }
  }

  /// Validate that all expected default data is present
  Future<Map<String, dynamic>> validateDefaultData() async {
    try {
      final issues = <String>[];

      // Check for expected income categories
      final incomeCategories = await DatabaseService.instance.categoryDao
          .getIncomeCategories();
      final defaultIncomeCategories = incomeCategories
          .where((c) => c.isDefault)
          .toList();

      final expectedIncomeIds = [
        'income_salary',
        'income_freelance',
        'income_business',
        'income_investment',
        'income_gifts',
        'income_other',
      ];

      for (final expectedId in expectedIncomeIds) {
        if (!defaultIncomeCategories.any((c) => c.id == expectedId)) {
          issues.add('Missing default income category: $expectedId');
        }
      }

      // Check for expected expense categories
      final expenseCategories = await DatabaseService.instance.categoryDao
          .getExpenseCategories();
      final defaultExpenseCategories = expenseCategories
          .where((c) => c.isDefault)
          .toList();

      final expectedExpenseIds = [
        'expense_food',
        'expense_transport',
        'expense_utilities',
        'expense_housing',
        'expense_entertainment',
        'expense_healthcare',
        'expense_shopping',
        'expense_financial',
        'expense_other',
      ];

      for (final expectedId in expectedExpenseIds) {
        if (!defaultExpenseCategories.any((c) => c.id == expectedId)) {
          issues.add('Missing default expense category: $expectedId');
        }
      }

      // Check for expected payment sources
      final paymentSources = await DatabaseService.instance.paymentSourceDao
          .getDefaultPaymentSources();

      final expectedPaymentSourceIds = [
        'credit_card',
        'debit_card',
        'upi',
        'cash',
        'bank_transfer',
        'wallet',
        'other',
      ];

      for (final expectedId in expectedPaymentSourceIds) {
        if (!paymentSources.any((p) => p.id == expectedId)) {
          issues.add('Missing default payment source: $expectedId');
        }
      }

      return {
        'isValid': issues.isEmpty,
        'issues': issues,
        'defaultIncomeCategories': defaultIncomeCategories.length,
        'defaultExpenseCategories': defaultExpenseCategories.length,
        'defaultPaymentSources': paymentSources.length,
        'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
      };
    } catch (e) {
      return {
        'isValid': false,
        'error': e.toString(),
        'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
      };
    }
  }

  /// Reset default data (clear and reload)
  Future<void> resetDefaultData() async {
    await _clearExistingDefaultData();
    await _performMigration();
  }
}
