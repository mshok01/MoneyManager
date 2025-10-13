import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/category_item.dart';
import '../models/payment_source.dart';

class DataService {
  static DataService? _instance;
  
  List<CategoryItem> _defaultIncomeCategories = [];
  List<CategoryItem> _defaultExpenseCategories = [];
  List<PaymentSource> _defaultPaymentSources = [];
  
  bool _isInitialized = false;

  static DataService get instance {
    _instance ??= DataService._();
    return _instance!;
  }

  DataService._();

  // Getters for default data
  List<CategoryItem> get defaultIncomeCategories => List.unmodifiable(_defaultIncomeCategories);
  List<CategoryItem> get defaultExpenseCategories => List.unmodifiable(_defaultExpenseCategories);
  List<PaymentSource> get defaultPaymentSources => List.unmodifiable(_defaultPaymentSources);
  
  bool get isInitialized => _isInitialized;

  /// Initialize the data service by loading default data from JSON files
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadDefaultCategories();
      await _loadDefaultPaymentSources();
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize DataService: $e');
    }
  }

  /// Load default categories from JSON file
  Future<void> _loadDefaultCategories() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/default_categories.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Load income categories
      final List<dynamic> incomeData = jsonData['income_categories'] as List<dynamic>;
      _defaultIncomeCategories = incomeData
          .map((item) => CategoryItem.fromJson(item as Map<String, dynamic>))
          .toList();

      // Load expense categories
      final List<dynamic> expenseData = jsonData['expense_categories'] as List<dynamic>;
      _defaultExpenseCategories = expenseData
          .map((item) => CategoryItem.fromJson(item as Map<String, dynamic>))
          .toList();

    } catch (e) {
      throw Exception('Failed to load default categories: $e');
    }
  }

  /// Load default payment sources from JSON file
  Future<void> _loadDefaultPaymentSources() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/default_payment_sources.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Load payment sources
      final List<dynamic> paymentSourcesData = jsonData['payment_sources'] as List<dynamic>;
      _defaultPaymentSources = paymentSourcesData
          .map((item) => PaymentSource.fromJson(item as Map<String, dynamic>))
          .toList();

    } catch (e) {
      throw Exception('Failed to load default payment sources: $e');
    }
  }

  /// Get a copy of default income categories (for modification)
  List<CategoryItem> getIncomeCategories() {
    return _defaultIncomeCategories.map((category) => category).toList();
  }

  /// Get a copy of default expense categories (for modification)
  List<CategoryItem> getExpenseCategories() {
    return _defaultExpenseCategories.map((category) => category).toList();
  }

  /// Get a copy of default payment sources (for modification)
  List<PaymentSource> getPaymentSources() {
    return _defaultPaymentSources.map((source) => source).toList();
  }

  /// Find a category by ID
  CategoryItem? findCategoryById(String id) {
    // Search in income categories
    for (final category in _defaultIncomeCategories) {
      if (category.id == id) return category;
    }
    
    // Search in expense categories
    for (final category in _defaultExpenseCategories) {
      if (category.id == id) return category;
    }
    
    return null;
  }

  /// Find a payment source by ID
  PaymentSource? findPaymentSourceById(String id) {
    for (final source in _defaultPaymentSources) {
      if (source.id == id) return source;
    }
    return null;
  }

  /// Check if a category is a default category
  bool isDefaultCategory(String id) {
    return findCategoryById(id)?.isDefault ?? false;
  }

  /// Check if a payment source is a default payment source
  bool isDefaultPaymentSource(String id) {
    return findPaymentSourceById(id)?.isDefault ?? false;
  }

  /// Reset the service (useful for testing)
  void reset() {
    _defaultIncomeCategories.clear();
    _defaultExpenseCategories.clear();
    _defaultPaymentSources.clear();
    _isInitialized = false;
  }
}
