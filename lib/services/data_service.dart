import 'package:flutter/foundation.dart';
import '../models/category_item.dart';
import '../models/payment_source.dart';
import '../database/database_service.dart';
import 'category_service.dart';
import 'payment_source_service.dart';

class DataService {
  static DataService? _instance;

  // Cache for default data
  List<CategoryItem>? _cachedIncomeCategories;
  List<CategoryItem>? _cachedExpenseCategories;
  List<PaymentSource>? _cachedPaymentSources;

  bool _isInitialized = false;

  static DataService get instance {
    _instance ??= DataService._();
    return _instance!;
  }

  DataService._();

  // Getters for default data (with caching)
  Future<List<CategoryItem>> get defaultIncomeCategories async {
    if (_cachedIncomeCategories == null) {
      await _loadDefaultCategories();
    }
    return List.unmodifiable(_cachedIncomeCategories!);
  }

  Future<List<CategoryItem>> get defaultExpenseCategories async {
    if (_cachedExpenseCategories == null) {
      await _loadDefaultCategories();
    }
    return List.unmodifiable(_cachedExpenseCategories!);
  }

  Future<List<PaymentSource>> get defaultPaymentSources async {
    if (_cachedPaymentSources == null) {
      await _loadDefaultPaymentSources();
    }
    return List.unmodifiable(_cachedPaymentSources!);
  }

  bool get isInitialized => _isInitialized;

  /// Initialize the data service by ensuring database is ready
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize database service
      await DatabaseService.instance.initialize();

      // Initialize category and payment source services
      await CategoryService.instance.initialize();
      await PaymentSourceService.instance.initialize();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize DataService: $e');
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Load default categories from database
  Future<void> _loadDefaultCategories() async {
    try {
      // Load income categories from database
      _cachedIncomeCategories = await CategoryService.instance
          .getIncomeCategories();

      // Load expense categories from database
      _cachedExpenseCategories = await CategoryService.instance
          .getExpenseCategories();
    } catch (e) {
      debugPrint('Failed to load default categories: $e');
      _cachedIncomeCategories = [];
      _cachedExpenseCategories = [];
    }
  }

  /// Load default payment sources from database
  Future<void> _loadDefaultPaymentSources() async {
    try {
      // Load payment sources from database
      _cachedPaymentSources = await PaymentSourceService.instance
          .getAllPaymentSources();
    } catch (e) {
      debugPrint('Failed to load default payment sources: $e');
      _cachedPaymentSources = [];
    }
  }

  /// Get a copy of default income categories (for modification)
  Future<List<CategoryItem>> getIncomeCategories() async {
    final categories = await defaultIncomeCategories;
    return categories.map((category) => category).toList();
  }

  /// Get a copy of default expense categories (for modification)
  Future<List<CategoryItem>> getExpenseCategories() async {
    final categories = await defaultExpenseCategories;
    return categories.map((category) => category).toList();
  }

  /// Get a copy of default payment sources (for modification)
  Future<List<PaymentSource>> getPaymentSources() async {
    final sources = await defaultPaymentSources;
    return sources.map((source) => source).toList();
  }

  /// Find a category by ID
  Future<CategoryItem?> findCategoryById(String id) async {
    return await CategoryService.instance.findCategoryById(id);
  }

  /// Find a payment source by ID
  Future<PaymentSource?> findPaymentSourceById(String id) async {
    return await PaymentSourceService.instance.findPaymentSourceById(id);
  }

  /// Check if a category is a default category
  Future<bool> isDefaultCategory(String id) async {
    return await CategoryService.instance.isDefaultCategory(id);
  }

  /// Check if a payment source is a default payment source
  Future<bool> isDefaultPaymentSource(String id) async {
    return await PaymentSourceService.instance.isDefaultPaymentSource(id);
  }

  /// Reset the service (useful for testing)
  void reset() {
    _cachedIncomeCategories = null;
    _cachedExpenseCategories = null;
    _cachedPaymentSources = null;
    _isInitialized = false;
  }

  /// Clear cache to force reload from database
  void clearCache() {
    _cachedIncomeCategories = null;
    _cachedExpenseCategories = null;
    _cachedPaymentSources = null;
  }
}
