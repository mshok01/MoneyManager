import 'package:flutter/material.dart';
import 'package:money_manager/utils/utils.dart';
import '../models/category_item.dart';
import '../models/sync_queue_entry.dart';
import '../database/database_service.dart';
import '../database/database_schema.dart';
import 'category_api_service.dart';
import 'sync_service.dart';
import 'logging_service.dart';

/// Service to manage categories with SQLite persistence
class CategoryService {
  static CategoryService? _instance;
  static CategoryService get instance {
    _instance ??= CategoryService._();
    return _instance!;
  }

  CategoryService._();

  static final _log = LoggingService.getLogger('CategoryService');
  bool _isInitialized = false;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the category service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize database service
      await DatabaseService.instance.initialize();

      _isInitialized = true;
    } catch (e) {
      debugPrint('CategoryService initialization error: $e');
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Get all categories
  Future<List<CategoryItem>> getAllCategories() async {
    _ensureInitialized();
    return await DatabaseService.instance.categoryDao.getAll();
  }

  /// Get income categories
  Future<List<CategoryItem>> getIncomeCategories() async {
    _ensureInitialized();
    return await DatabaseService.instance.categoryDao.getIncomeCategories();
  }

  /// Get expense categories
  Future<List<CategoryItem>> getExpenseCategories() async {
    _ensureInitialized();
    return await DatabaseService.instance.categoryDao.getExpenseCategories();
  }

  /// Get default categories
  Future<List<CategoryItem>> getDefaultCategories() async {
    _ensureInitialized();
    return await DatabaseService.instance.categoryDao.getDefaultCategories();
  }

  /// Get custom categories (non-default)
  Future<List<CategoryItem>> getCustomCategories() async {
    _ensureInitialized();
    return await DatabaseService.instance.categoryDao.getCustomCategories();
  }

  /// Get categories created by user
  Future<List<CategoryItem>> getCategoriesCreatedBy(String userId) async {
    _ensureInitialized();
    return await DatabaseService.instance.categoryDao.getCategoriesCreatedBy(
      userId,
    );
  }

  /// Get categories accessible to user
  Future<List<CategoryItem>> getCategoriesAccessibleTo(String userId) async {
    _ensureInitialized();
    return await DatabaseService.instance.categoryDao.getCategoriesAccessibleTo(
      userId,
    );
  }

  /// Get category by ID
  Future<CategoryItem?> getCategoryById(String categoryId) async {
    _ensureInitialized();
    return await DatabaseService.instance.categoryDao.getById(categoryId);
  }

  /// Search categories by name
  Future<List<CategoryItem>> searchCategories(
    String query, {
    String? categoryType,
  }) async {
    _ensureInitialized();
    return await DatabaseService.instance.categoryDao.searchCategories(
      query,
      categoryType: categoryType,
    );
  }

  /// Create a new custom category (offline-first)
  /// Saves locally first, then syncs to backend asynchronously
  Future<CategoryItem> createCategory({
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    required String categoryType, // 'income' or 'expense'
    required String createdBy,
    List<String>? accessTo,
  }) async {
    _ensureInitialized();

    if (!DatabaseSchema.isValidCategoryType(categoryType)) {
      throw Exception('Invalid category type: $categoryType');
    }

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    final category = CategoryItem(
      id: getUniqueId(),
      name: name.trim(),
      description: description.trim(),
      icon: icon,
      color: color,
      isDefault: false, // Custom categories are never default
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
      accessTo: accessTo ?? [],
    );

    // Save to local database first
    await DatabaseService.instance.categoryDao.insertWithType(
      category,
      categoryType,
    );

    // Sync to backend asynchronously (don't wait for response)
    // This allows the UI to respond immediately while the API call happens in the background
    _syncCategoryAsync(
      categoryId: category.id,
      operation: SyncOperation.create,
      syncFn: () => CategoryApiService.instance.createCategory(
        name: name,
        description: description,
        icon: _iconToString(icon),
        color: _colorToString(color),
        categoryType: categoryType == 'income' ? 1 : 0,
        createdBy: createdBy,
        accessTo: accessTo,
      ),
    );

    return category;
  }

  /// Update an existing category
  Future<CategoryItem> updateCategory(
    String categoryId, {
    String? name,
    String? description,
    IconData? icon,
    Color? color,
  }) async {
    _ensureInitialized();

    final currentCategory = await getCategoryById(categoryId);
    if (currentCategory == null) {
      throw Exception('Category not found');
    }

    // Don't allow updating default categories
    if (currentCategory.isDefault) {
      throw Exception('Cannot update default categories');
    }

    await DatabaseService.instance.categoryDao.updateCategoryDetails(
      categoryId,
      name: name,
      description: description,
      icon: icon,
      color: color,
    );

    // Return updated category
    final updatedCategory = await getCategoryById(categoryId);
    if (updatedCategory == null) {
      throw Exception('Category not found after update');
    }

    return updatedCategory;
  }

  /// Delete a custom category (offline-first)
  /// Deletes locally first, then syncs to backend asynchronously
  Future<void> deleteCategory(String categoryId) async {
    _ensureInitialized();

    final category = await getCategoryById(categoryId);
    if (category == null) {
      throw Exception('Category not found');
    }

    // Don't allow deleting default categories
    if (category.isDefault) {
      throw Exception('Cannot delete default categories');
    }

    // Delete from local database first
    await DatabaseService.instance.categoryDao.delete(categoryId);

    // Sync to backend asynchronously (don't wait for response)
    // This allows the UI to respond immediately while the API call happens in the background
    _syncCategoryAsync(
      categoryId: categoryId,
      operation: SyncOperation.delete,
      syncFn: () => CategoryApiService.instance.deleteCategory(
        categoryId: categoryId,
        userId: category.createdBy,
      ),
    );
  }

  /// Add user access to category
  Future<void> addUserAccess(String categoryId, String userId) async {
    _ensureInitialized();
    await DatabaseService.instance.categoryDao.addUserAccess(
      categoryId,
      userId,
    );
  }

  /// Remove user access from category
  Future<void> removeUserAccess(String categoryId, String userId) async {
    _ensureInitialized();
    await DatabaseService.instance.categoryDao.removeUserAccess(
      categoryId,
      userId,
    );
  }

  /// Check if user can access category
  Future<bool> canUserAccessCategory(String userId, String categoryId) async {
    _ensureInitialized();
    return await DatabaseService.instance.categoryDao.canUserAccessCategory(
      userId,
      categoryId,
    );
  }

  /// Get category statistics
  Future<Map<String, dynamic>> getCategoryStats() async {
    _ensureInitialized();
    return await DatabaseService.instance.categoryDao.getCategoryStats();
  }

  /// Find a category by ID (for backward compatibility with DataService)
  Future<CategoryItem?> findCategoryById(String id) async {
    return await getCategoryById(id);
  }

  /// Check if a category is a default category
  Future<bool> isDefaultCategory(String id) async {
    final category = await getCategoryById(id);
    return category?.isDefault ?? false;
  }

  /// Get categories by type for backward compatibility
  Future<List<CategoryItem>> getCategoriesByType(String type) async {
    if (type == DatabaseSchema.categoryTypeIncome) {
      return await getIncomeCategories();
    } else if (type == DatabaseSchema.categoryTypeExpense) {
      return await getExpenseCategories();
    } else {
      throw Exception('Invalid category type: $type');
    }
  }

  /// Clear all custom categories (useful for testing)
  Future<void> clearCustomCategories() async {
    _ensureInitialized();

    final customCategories = await getCustomCategories();
    for (final category in customCategories) {
      await DatabaseService.instance.categoryDao.delete(category.id);
    }
  }

  /// Clear all category data (useful for testing)
  Future<void> clearAllCategories() async {
    _ensureInitialized();
    await DatabaseService.instance.categoryDao.clear();
  }

  /// Ensure the service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'CategoryService not initialized. Call initialize() first.',
      );
    }
  }

  /// Get count of categories
  Future<int> getCategoryCount() async {
    _ensureInitialized();
    return await DatabaseService.instance.categoryDao.count();
  }

  /// Get count of categories by type
  Future<int> getCategoryCountByType(String categoryType) async {
    _ensureInitialized();
    final categories = await getCategoriesByType(categoryType);
    return categories.length;
  }

  /// Check if categories exist
  Future<bool> hasCategories() async {
    _ensureInitialized();
    final count = await getCategoryCount();
    return count > 0;
  }

  /// Check if default categories exist
  Future<bool> hasDefaultCategories() async {
    _ensureInitialized();
    final defaultCategories = await getDefaultCategories();
    return defaultCategories.isNotEmpty;
  }

  /// Validate category data
  bool validateCategoryData({
    required String name,
    required String description,
    required String categoryType,
  }) {
    if (name.trim().isEmpty) return false;
    if (!DatabaseSchema.isValidCategoryType(categoryType)) return false;
    return true;
  }

  /// Get popular categories (most recently created custom categories)
  Future<List<CategoryItem>> getPopularCategories({int limit = 10}) async {
    _ensureInitialized();

    final customCategories = await getCustomCategories();
    customCategories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return customCategories.take(limit).toList();
  }

  /// Get recently updated categories
  Future<List<CategoryItem>> getRecentlyUpdatedCategories({
    int limit = 10,
  }) async {
    _ensureInitialized();

    final allCategories = await getAllCategories();
    allCategories.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return allCategories.take(limit).toList();
  }

  // ============================================================================
  // API Integration Methods
  // ============================================================================

  /// Fetch categories from backend API and sync with local database
  /// Uses JWT authentication
  Future<List<CategoryItem>> fetchCategoriesFromBackend() async {
    _ensureInitialized();
    try {
      final apiService = CategoryApiService.instance;
      final categories = await apiService.getCategories();

      // Sync with local database
      for (final category in categories) {
        final existing = await getCategoryById(category.id);
        if (existing == null) {
          // Insert new category
          await DatabaseService.instance.categoryDao.insert(category);
        } else if (category.updatedAt > existing.updatedAt) {
          // Update if backend version is newer
          await DatabaseService.instance.categoryDao.update(
            category,
            category.id,
          );
        }
      }

      return categories;
    } catch (e) {
      debugPrint('Error fetching categories from backend: $e');
      rethrow;
    }
  }

  /// Create a category on the backend and sync to local database
  /// Uses API Key authentication
  Future<CategoryItem> createCategoryOnBackend({
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    required int categoryType, // 0 for expense, 1 for income
    required String createdBy,
    List<String>? accessTo,
  }) async {
    _ensureInitialized();
    try {
      final apiService = CategoryApiService.instance;

      // Convert icon and color to strings for API
      final iconString = _iconToString(icon);
      final colorString = _colorToString(color);

      // Create on backend
      final createdCategory = await apiService.createCategory(
        name: name,
        description: description,
        icon: iconString,
        color: colorString,
        categoryType: categoryType,
        createdBy: createdBy,
        accessTo: accessTo,
      );

      // Sync to local database
      await DatabaseService.instance.categoryDao.insert(createdCategory);

      return createdCategory;
    } catch (e) {
      debugPrint('Error creating category on backend: $e');
      rethrow;
    }
  }

  /// Delete a category from backend and local database
  /// Uses API Key authentication
  Future<void> deleteCategoryFromBackend({
    required String categoryId,
    required String userId,
  }) async {
    _ensureInitialized();
    try {
      final apiService = CategoryApiService.instance;

      // Delete from backend
      await apiService.deleteCategory(categoryId: categoryId, userId: userId);

      // Delete from local database
      await DatabaseService.instance.categoryDao.delete(categoryId);
    } catch (e) {
      debugPrint('Error deleting category from backend: $e');
      rethrow;
    }
  }

  /// Update category name on backend and local database
  /// Uses API Key authentication
  Future<CategoryItem> updateCategoryNameOnBackend({
    required String categoryId,
    required String userId,
    required String name,
  }) async {
    _ensureInitialized();
    try {
      final apiService = CategoryApiService.instance;

      // Update on backend
      final updatedCategory = await apiService.updateCategoryName(
        categoryId: categoryId,
        userId: userId,
        name: name,
      );

      // Update local database
      await DatabaseService.instance.categoryDao.update(
        updatedCategory,
        updatedCategory.id,
      );

      return updatedCategory;
    } catch (e) {
      debugPrint('Error updating category name on backend: $e');
      rethrow;
    }
  }

  /// Update category description on backend and local database
  /// Uses API Key authentication
  Future<CategoryItem> updateCategoryDescriptionOnBackend({
    required String categoryId,
    required String userId,
    required String description,
  }) async {
    _ensureInitialized();
    try {
      final apiService = CategoryApiService.instance;

      // Update on backend
      final updatedCategory = await apiService.updateCategoryDescription(
        categoryId: categoryId,
        userId: userId,
        description: description,
      );

      // Update local database
      await DatabaseService.instance.categoryDao.update(
        updatedCategory,
        updatedCategory.id,
      );

      return updatedCategory;
    } catch (e) {
      debugPrint('Error updating category description on backend: $e');
      rethrow;
    }
  }

  /// Update category icon on backend and local database
  /// Uses API Key authentication
  Future<CategoryItem> updateCategoryIconOnBackend({
    required String categoryId,
    required String userId,
    required IconData icon,
  }) async {
    _ensureInitialized();
    try {
      final apiService = CategoryApiService.instance;
      final iconString = CategoryItem.iconToString(icon);

      // Update on backend
      final updatedCategory = await apiService.updateCategoryIcon(
        categoryId: categoryId,
        userId: userId,
        icon: iconString,
      );

      // Update local database
      await DatabaseService.instance.categoryDao.update(
        updatedCategory,
        updatedCategory.id,
      );

      return updatedCategory;
    } catch (e) {
      debugPrint('Error updating category icon on backend: $e');
      rethrow;
    }
  }

  /// Update category color on backend and local database
  /// Uses API Key authentication
  Future<CategoryItem> updateCategoryColorOnBackend({
    required String categoryId,
    required String userId,
    required Color color,
  }) async {
    _ensureInitialized();
    try {
      final apiService = CategoryApiService.instance;
      final colorString = CategoryItem.colorToString(color);

      // Update on backend
      final updatedCategory = await apiService.updateCategoryColor(
        categoryId: categoryId,
        userId: userId,
        color: colorString,
      );

      // Update local database
      await DatabaseService.instance.categoryDao.update(
        updatedCategory,
        updatedCategory.id,
      );

      return updatedCategory;
    } catch (e) {
      debugPrint('Error updating category color on backend: $e');
      rethrow;
    }
  }

  /// Update category accessTo on backend and local database
  /// Uses API Key authentication
  Future<CategoryItem> updateCategoryAccessToOnBackend({
    required String categoryId,
    required String userId,
    required List<String> accessTo,
  }) async {
    _ensureInitialized();
    try {
      final apiService = CategoryApiService.instance;

      // Update on backend
      final updatedCategory = await apiService.updateCategoryAccessTo(
        categoryId: categoryId,
        userId: userId,
        accessTo: accessTo,
      );

      // Update local database
      await DatabaseService.instance.categoryDao.update(
        updatedCategory,
        updatedCategory.id,
      );

      return updatedCategory;
    } catch (e) {
      debugPrint('Error updating category accessTo on backend: $e');
      rethrow;
    }
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Convert IconData to string representation
  String _iconToString(IconData icon) {
    return CategoryItem.iconToString(icon);
  }

  /// Convert Color to string representation
  String _colorToString(Color color) {
    return CategoryItem.colorToString(color);
  }

  /// Helper method to sync category asynchronously
  /// Attempts to sync, and adds to queue if it fails
  void _syncCategoryAsync({
    required String categoryId,
    required String operation,
    required Future<void> Function() syncFn,
  }) {
    // Fire and forget - don't block the caller
    Future.microtask(() async {
      try {
        await syncFn();
        _log.d(
          'Successfully synced category $categoryId with operation $operation',
        );
      } catch (e) {
        // Add to sync queue on failure
        _log.w(
          'Failed to sync category $categoryId, adding to queue',
          error: e,
        );
        await SyncService.instance.addToSyncQueue(
          transactionId: categoryId,
          operation: operation,
          lastError: e.toString(),
        );
      }
    });
  }
}
