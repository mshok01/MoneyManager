import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/screens/category_screen.dart';

void main() {
  group('CategoryItem Tests', () {
    test('CategoryItem should have all required fields', () {
      final nowMillis = DateTime.now().millisecondsSinceEpoch;
      final category = CategoryItem(
        id: 'test_id',
        name: 'Test Category',
        description: 'Test Description',
        icon: Icons.category,
        color: Colors.blue,
        isDefault: true,
        createdBy: 'test_user',
        createdAt: nowMillis,
        updatedAt: nowMillis,
        accessTo: ['user1', 'user2'],
      );

      expect(category.id, equals('test_id'));
      expect(category.name, equals('Test Category'));
      expect(category.description, equals('Test Description'));
      expect(category.icon, equals(Icons.category));
      expect(category.color, equals(Colors.blue));
      expect(category.isDefault, equals(true));
      expect(category.createdBy, equals('test_user'));
      expect(category.createdAt, equals(nowMillis));
      expect(category.updatedAt, equals(nowMillis));
      expect(category.accessTo, equals(['user1', 'user2']));
    });

    test(
      'CategoryItem should allow empty createdBy for default categories',
      () {
        final nowMillis = DateTime.now().millisecondsSinceEpoch;
        final category = CategoryItem(
          id: 'test_id',
          name: 'Test Category',
          description: 'Test Description',
          icon: Icons.category,
          color: Colors.blue,
          isDefault: true,
          createdBy: '', // Empty for default categories
          createdAt: nowMillis,
          updatedAt: nowMillis,
          accessTo: [], // Empty for default categories
        );

        expect(category.createdBy, equals(''));
        expect(category.isDefault, isTrue);
      },
    );

    test('Default categories should have isDefault set to true', () {
      const jan1st2025 = 1735669800000; // January 1st, 2025
      final defaultCategory = CategoryItem(
        id: 'income_salary',
        name: 'Salary',
        description: 'Regular employment income, wages',
        icon: Icons.work,
        color: Colors.green,
        isDefault: true,
        createdBy: '', // Empty for default categories
        createdAt: jan1st2025,
        updatedAt: jan1st2025,
        accessTo: [], // Empty for default categories
      );

      expect(defaultCategory.isDefault, isTrue);
      expect(defaultCategory.createdBy, equals(''));
      expect(defaultCategory.createdAt, equals(jan1st2025));
      expect(defaultCategory.updatedAt, equals(jan1st2025));
    });

    test('Custom categories should have isDefault set to false', () {
      final nowMillis = DateTime.now().millisecondsSinceEpoch;
      final customCategory = CategoryItem(
        id: 'custom_123456789',
        name: 'Custom Category',
        description: 'User created category',
        icon: Icons.category,
        color: Colors.purple,
        isDefault: false,
        createdBy: 'user123', // Non-empty for custom categories
        createdAt: nowMillis,
        updatedAt: nowMillis,
        accessTo: [
          'user123',
          'user456',
        ], // List of user IDs for custom categories
      );

      expect(customCategory.isDefault, isFalse);
      expect(customCategory.createdBy, equals('user123'));
    });

    test(
      'createdBy should be empty for default categories and non-empty for custom',
      () {
        const jan1st2025 = 1735669800000;

        // Default category
        final defaultCategory = CategoryItem(
          id: 'expense_food',
          name: 'Food & Dining',
          description: 'Groceries, restaurants, takeout',
          icon: Icons.restaurant,
          color: Colors.red,
          isDefault: true,
          createdBy: '',
          createdAt: jan1st2025,
          updatedAt: jan1st2025,
          accessTo: [], // Empty for default categories
        );

        // Custom category
        final customCategory = CategoryItem(
          id: 'custom_987654321',
          name: 'Custom Expense',
          description: 'User defined expense category',
          icon: Icons.category,
          color: Colors.orange,
          isDefault: false,
          createdBy: 'user456',
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          accessTo: ['user456'], // List of user IDs for custom categories
        );

        expect(defaultCategory.createdBy, isEmpty);
        expect(defaultCategory.isDefault, isTrue);
        expect(
          defaultCategory.accessTo,
          isEmpty,
        ); // Default categories have empty accessTo
        expect(customCategory.createdBy, isNotEmpty);
        expect(customCategory.createdBy, equals('user456'));
        expect(customCategory.isDefault, isFalse);
        expect(
          customCategory.accessTo,
          isNotEmpty,
        ); // Custom categories have user IDs
        expect(customCategory.accessTo, equals(['user456']));
      },
    );

    test(
      'accessTo should be empty for default categories and contain user IDs for custom',
      () {
        const jan1st2025 = 1735669800000;

        // Default category
        final defaultCategory = CategoryItem(
          id: 'income_salary',
          name: 'Salary',
          description: 'Regular employment income, wages',
          icon: Icons.work,
          color: Colors.green,
          isDefault: true,
          createdBy: '',
          createdAt: jan1st2025,
          updatedAt: jan1st2025,
          accessTo: [], // Empty for default categories
        );

        // Custom category with multiple users
        final customCategory = CategoryItem(
          id: 'custom_multi_user',
          name: 'Multi User Category',
          description: 'Category accessible by multiple users',
          icon: Icons.category,
          color: Colors.blue,
          isDefault: false,
          createdBy: 'user1',
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          accessTo: ['user1', 'user2', 'user3'], // Multiple user IDs
        );

        expect(defaultCategory.accessTo, isEmpty);
        expect(defaultCategory.isDefault, isTrue);
        expect(customCategory.accessTo, isNotEmpty);
        expect(customCategory.accessTo, hasLength(3));
        expect(
          customCategory.accessTo,
          containsAll(['user1', 'user2', 'user3']),
        );
        expect(customCategory.isDefault, isFalse);
      },
    );
  });
}
