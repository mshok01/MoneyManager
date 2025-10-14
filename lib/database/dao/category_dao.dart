import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../models/category_item.dart';
import '../database_schema.dart';
import 'base_dao.dart';

/// Data Access Object for Category operations
class CategoryDao extends BaseDao<CategoryItem> {
  @override
  String get tableName => DatabaseSchema.tableCategories;

  @override
  CategoryItem fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      id: map[DatabaseSchema.categoriesId] as String,
      name: map[DatabaseSchema.categoriesName] as String,
      description: map[DatabaseSchema.categoriesDescription] as String,
      icon: _iconFromString(map[DatabaseSchema.categoriesIcon] as String),
      color: _colorFromString(map[DatabaseSchema.categoriesColor] as String),
      isDefault: (map[DatabaseSchema.categoriesIsDefault] as int) == 1,
      createdBy: map[DatabaseSchema.categoriesCreatedBy] as String,
      createdAt: map[DatabaseSchema.categoriesCreatedAt] as int,
      updatedAt: map[DatabaseSchema.categoriesUpdatedAt] as int,
      accessTo: _parseStringList(
        map[DatabaseSchema.categoriesAccessTo] as String,
      ),
    );
  }

  @override
  Map<String, dynamic> toMap(CategoryItem category) {
    return {
      DatabaseSchema.categoriesId: category.id,
      DatabaseSchema.categoriesName: category.name,
      DatabaseSchema.categoriesDescription: category.description,
      DatabaseSchema.categoriesIcon: _iconToString(category.icon),
      DatabaseSchema.categoriesColor: _colorToString(category.color),
      DatabaseSchema.categoriesIsDefault: category.isDefault ? 1 : 0,
      DatabaseSchema.categoriesCreatedBy: category.createdBy,
      DatabaseSchema.categoriesCreatedAt: category.createdAt,
      DatabaseSchema.categoriesUpdatedAt: category.updatedAt,
      DatabaseSchema.categoriesAccessTo: _stringifyList(category.accessTo),
      DatabaseSchema.categoriesCategoryType: _getCategoryType(category),
    };
  }

  /// Parse JSON string to List<String>
  List<String> _parseStringList(String jsonString) {
    try {
      final List<dynamic> list = json.decode(jsonString);
      return list.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Convert List<String> to JSON string
  String _stringifyList(List<String> list) {
    return json.encode(list);
  }

  /// Convert string to IconData
  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'person_outline':
        return Icons.person_outline;
      case 'business':
        return Icons.business;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'attach_money':
        return Icons.attach_money;
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'home':
        return Icons.home;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'account_balance':
        return Icons.account_balance;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'category':
        return Icons.category;
      default:
        return Icons.category;
    }
  }

  /// Convert IconData to string
  String _iconToString(IconData icon) {
    if (icon == Icons.work) return 'work';
    if (icon == Icons.person_outline) return 'person_outline';
    if (icon == Icons.business) return 'business';
    if (icon == Icons.trending_up) return 'trending_up';
    if (icon == Icons.card_giftcard) return 'card_giftcard';
    if (icon == Icons.attach_money) return 'attach_money';
    if (icon == Icons.restaurant) return 'restaurant';
    if (icon == Icons.directions_car) return 'directions_car';
    if (icon == Icons.electrical_services) return 'electrical_services';
    if (icon == Icons.home) return 'home';
    if (icon == Icons.movie) return 'movie';
    if (icon == Icons.local_hospital) return 'local_hospital';
    if (icon == Icons.shopping_bag) return 'shopping_bag';
    if (icon == Icons.account_balance) return 'account_balance';
    if (icon == Icons.more_horiz) return 'more_horiz';
    return 'category';
  }

  /// Convert string to Color
  Color _colorFromString(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'lightGreen':
        return Colors.lightGreen;
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      case 'red':
        return Colors.red;
      case 'amber':
        return Colors.amber;
      case 'brown':
        return Colors.brown;
      case 'pink':
        return Colors.pink;
      case 'indigo':
        return Colors.indigo;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  /// Convert Color to string
  String _colorToString(Color color) {
    if (color == Colors.green) return 'green';
    if (color == Colors.lightGreen) return 'lightGreen';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.teal) return 'teal';
    if (color == Colors.red) return 'red';
    if (color == Colors.amber) return 'amber';
    if (color == Colors.brown) return 'brown';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.indigo) return 'indigo';
    if (color == Colors.grey) return 'grey';
    return 'blue';
  }

  /// Determine category type based on ID prefix (income_ or expense_)
  String _getCategoryType(CategoryItem category) {
    if (category.id.startsWith('income_')) {
      return DatabaseSchema.categoryTypeIncome;
    } else if (category.id.startsWith('expense_')) {
      return DatabaseSchema.categoryTypeExpense;
    }
    // For custom categories, we'll need to determine based on usage or default to expense
    return DatabaseSchema.categoryTypeExpense;
  }

  /// Get income categories
  Future<List<CategoryItem>> getIncomeCategories() async {
    return await getWhere(
      where: '${DatabaseSchema.categoriesCategoryType} = ?',
      whereArgs: [DatabaseSchema.categoryTypeIncome],
      orderBy:
          '${DatabaseSchema.categoriesIsDefault} DESC, ${DatabaseSchema.categoriesName} ASC',
    );
  }

  /// Get expense categories
  Future<List<CategoryItem>> getExpenseCategories() async {
    return await getWhere(
      where: '${DatabaseSchema.categoriesCategoryType} = ?',
      whereArgs: [DatabaseSchema.categoryTypeExpense],
      orderBy:
          '${DatabaseSchema.categoriesIsDefault} DESC, ${DatabaseSchema.categoriesName} ASC',
    );
  }

  /// Get default categories
  Future<List<CategoryItem>> getDefaultCategories() async {
    return await getWhere(
      where: '${DatabaseSchema.categoriesIsDefault} = ?',
      whereArgs: [1],
      orderBy:
          '${DatabaseSchema.categoriesCategoryType}, ${DatabaseSchema.categoriesName} ASC',
    );
  }

  /// Get custom categories (non-default)
  Future<List<CategoryItem>> getCustomCategories() async {
    return await getWhere(
      where: '${DatabaseSchema.categoriesIsDefault} = ?',
      whereArgs: [0],
      orderBy:
          '${DatabaseSchema.categoriesCategoryType}, ${DatabaseSchema.categoriesName} ASC',
    );
  }

  /// Get categories created by user
  Future<List<CategoryItem>> getCategoriesCreatedBy(String userId) async {
    return await getWhere(
      where: '${DatabaseSchema.categoriesCreatedBy} = ?',
      whereArgs: [userId],
      orderBy:
          '${DatabaseSchema.categoriesCategoryType}, ${DatabaseSchema.categoriesName} ASC',
    );
  }

  /// Get categories accessible to user
  Future<List<CategoryItem>> getCategoriesAccessibleTo(String userId) async {
    return await getWhere(
      where:
          '${DatabaseSchema.categoriesIsDefault} = ? OR ${DatabaseSchema.categoriesCreatedBy} = ? OR ${DatabaseSchema.categoriesAccessTo} LIKE ?',
      whereArgs: [1, userId, '%"$userId"%'],
      orderBy:
          '${DatabaseSchema.categoriesIsDefault} DESC, ${DatabaseSchema.categoriesCategoryType}, ${DatabaseSchema.categoriesName} ASC',
    );
  }

  /// Search categories by name
  Future<List<CategoryItem>> searchCategories(
    String query, {
    String? categoryType,
  }) async {
    final searchQuery = '%$query%';
    String where = '${DatabaseSchema.categoriesName} LIKE ?';
    List<dynamic> whereArgs = [searchQuery];

    if (categoryType != null) {
      where += ' AND ${DatabaseSchema.categoriesCategoryType} = ?';
      whereArgs.add(categoryType);
    }

    return await getWhere(
      where: where,
      whereArgs: whereArgs,
      orderBy:
          '${DatabaseSchema.categoriesIsDefault} DESC, ${DatabaseSchema.categoriesName} ASC',
    );
  }

  /// Update category details
  Future<int> updateCategoryDetails(
    String categoryId, {
    String? name,
    String? description,
    IconData? icon,
    Color? color,
  }) async {
    final Map<String, dynamic> updates = {
      DatabaseSchema.categoriesUpdatedAt: DateTime.now()
          .toUtc()
          .millisecondsSinceEpoch,
    };

    if (name != null) updates[DatabaseSchema.categoriesName] = name;
    if (description != null) {
      updates[DatabaseSchema.categoriesDescription] = description;
    }
    if (icon != null) {
      updates[DatabaseSchema.categoriesIcon] = _iconToString(icon);
    }
    if (color != null) {
      updates[DatabaseSchema.categoriesColor] = _colorToString(color);
    }

    if (updates.length == 1) return 0; // Only timestamp was added

    final db = await database;
    return await db.update(
      tableName,
      updates,
      where: '${DatabaseSchema.categoriesId} = ?',
      whereArgs: [categoryId],
    );
  }

  /// Add user access to category
  Future<int> addUserAccess(String categoryId, String userId) async {
    final category = await getById(categoryId);
    if (category == null) return 0;

    final accessTo = List<String>.from(category.accessTo);
    if (!accessTo.contains(userId)) {
      accessTo.add(userId);

      final db = await database;
      return await db.update(
        tableName,
        {
          DatabaseSchema.categoriesAccessTo: _stringifyList(accessTo),
          DatabaseSchema.categoriesUpdatedAt: DateTime.now()
              .toUtc()
              .millisecondsSinceEpoch,
        },
        where: '${DatabaseSchema.categoriesId} = ?',
        whereArgs: [categoryId],
      );
    }
    return 0;
  }

  /// Remove user access from category
  Future<int> removeUserAccess(String categoryId, String userId) async {
    final category = await getById(categoryId);
    if (category == null) return 0;

    final accessTo = List<String>.from(category.accessTo);
    if (accessTo.contains(userId)) {
      accessTo.remove(userId);

      final db = await database;
      return await db.update(
        tableName,
        {
          DatabaseSchema.categoriesAccessTo: _stringifyList(accessTo),
          DatabaseSchema.categoriesUpdatedAt: DateTime.now()
              .toUtc()
              .millisecondsSinceEpoch,
        },
        where: '${DatabaseSchema.categoriesId} = ?',
        whereArgs: [categoryId],
      );
    }
    return 0;
  }

  /// Check if user can access category
  Future<bool> canUserAccessCategory(String userId, String categoryId) async {
    final category = await getById(categoryId);
    if (category == null) return false;

    return category.isDefault ||
        category.createdBy == userId ||
        category.accessTo.contains(userId);
  }

  /// Get category statistics
  Future<Map<String, dynamic>> getCategoryStats() async {
    final db = await database;

    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as total FROM $tableName',
    );
    final defaultResult = await db.rawQuery(
      'SELECT COUNT(*) as default_count FROM $tableName WHERE ${DatabaseSchema.categoriesIsDefault} = 1',
    );
    final incomeResult = await db.rawQuery(
      'SELECT COUNT(*) as income FROM $tableName WHERE ${DatabaseSchema.categoriesCategoryType} = ?',
      [DatabaseSchema.categoryTypeIncome],
    );
    final expenseResult = await db.rawQuery(
      'SELECT COUNT(*) as expense FROM $tableName WHERE ${DatabaseSchema.categoriesCategoryType} = ?',
      [DatabaseSchema.categoryTypeExpense],
    );

    return {
      'total': totalResult.first['total'] as int,
      'default': defaultResult.first['default_count'] as int,
      'custom':
          (totalResult.first['total'] as int) -
          (defaultResult.first['default_count'] as int),
      'income': incomeResult.first['income'] as int,
      'expense': expenseResult.first['expense'] as int,
    };
  }

  /// Update category timestamp
  Future<int> updateTimestamp(String categoryId) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        DatabaseSchema.categoriesUpdatedAt: DateTime.now()
            .toUtc()
            .millisecondsSinceEpoch,
      },
      where: '${DatabaseSchema.categoriesId} = ?',
      whereArgs: [categoryId],
    );
  }

  /// Insert category with specific type
  Future<String> insertWithType(
    CategoryItem category,
    String categoryType,
  ) async {
    final db = await database;
    final map = toMap(category);
    map[DatabaseSchema.categoriesCategoryType] = categoryType;

    await db.insert(
      tableName,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return map['id'] as String;
  }
}
