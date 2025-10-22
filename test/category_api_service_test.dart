import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/models/category_item.dart';
import 'package:money_manager/services/category_api_service.dart';

void main() {
  group('CategoryApiService Tests', () {
    test('CategoryApiService singleton is accessible', () {
      final categoryApiService = CategoryApiService.instance;
      expect(categoryApiService, isNotNull);
    });

    test('CategoryApiService singleton returns same instance', () {
      final instance1 = CategoryApiService.instance;
      final instance2 = CategoryApiService.instance;
      expect(identical(instance1, instance2), isTrue);
    });
  });

  group('CategoryItem Helper Methods Tests', () {
    test('iconToString converts IconData to string', () {
      expect(CategoryItem.iconToString(Icons.work), equals('work'));
      expect(CategoryItem.iconToString(Icons.restaurant), equals('restaurant'));
      expect(CategoryItem.iconToString(Icons.home), equals('home'));
      expect(
        CategoryItem.iconToString(Icons.directions_car),
        equals('directions_car'),
      );
    });

    test('iconFromString converts string to IconData', () {
      expect(CategoryItem.iconFromString('work'), equals(Icons.work));
      expect(
        CategoryItem.iconFromString('restaurant'),
        equals(Icons.restaurant),
      );
      expect(CategoryItem.iconFromString('home'), equals(Icons.home));
      expect(
        CategoryItem.iconFromString('directions_car'),
        equals(Icons.directions_car),
      );
    });

    test('colorToString converts Color to string', () {
      expect(CategoryItem.colorToString(Colors.green), equals('green'));
      expect(CategoryItem.colorToString(Colors.blue), equals('blue'));
      expect(CategoryItem.colorToString(Colors.orange), equals('orange'));
      expect(CategoryItem.colorToString(Colors.purple), equals('purple'));
    });

    test('colorFromString converts string to Color', () {
      expect(CategoryItem.colorFromString('green'), equals(Colors.green));
      expect(CategoryItem.colorFromString('blue'), equals(Colors.blue));
      expect(CategoryItem.colorFromString('orange'), equals(Colors.orange));
      expect(CategoryItem.colorFromString('purple'), equals(Colors.purple));
    });

    test('icon conversion round-trip works correctly', () {
      const originalIcon = Icons.work;
      final iconString = CategoryItem.iconToString(originalIcon);
      final convertedIcon = CategoryItem.iconFromString(iconString);
      expect(convertedIcon, equals(originalIcon));
    });

    test('color conversion round-trip works correctly', () {
      const originalColor = Colors.green;
      final colorString = CategoryItem.colorToString(originalColor);
      final convertedColor = CategoryItem.colorFromString(colorString);
      expect(convertedColor, equals(originalColor));
    });
  });
}
