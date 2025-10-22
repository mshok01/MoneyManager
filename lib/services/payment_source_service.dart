import 'package:flutter/material.dart';
import 'package:money_manager/utils/utils.dart';
import '../models/payment_source.dart';
import '../database/database_service.dart';

/// Service to manage payment sources with SQLite persistence
class PaymentSourceService {
  static PaymentSourceService? _instance;
  static PaymentSourceService get instance {
    _instance ??= PaymentSourceService._();
    return _instance!;
  }

  PaymentSourceService._();

  bool _isInitialized = false;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the payment source service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize database service
      await DatabaseService.instance.initialize();

      _isInitialized = true;
    } catch (e) {
      debugPrint('PaymentSourceService initialization error: $e');
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Get all payment sources
  Future<List<PaymentSource>> getAllPaymentSources() async {
    _ensureInitialized();
    return await DatabaseService.instance.paymentSourceDao.getAll();
  }

  /// Get default payment sources
  Future<List<PaymentSource>> getDefaultPaymentSources() async {
    _ensureInitialized();
    return await DatabaseService.instance.paymentSourceDao
        .getDefaultPaymentSources();
  }

  /// Get custom payment sources (non-default)
  Future<List<PaymentSource>> getCustomPaymentSources() async {
    _ensureInitialized();
    return await DatabaseService.instance.paymentSourceDao
        .getCustomPaymentSources();
  }

  /// Get payment sources created by user
  Future<List<PaymentSource>> getPaymentSourcesCreatedBy(String userId) async {
    _ensureInitialized();
    return await DatabaseService.instance.paymentSourceDao
        .getPaymentSourcesCreatedBy(userId);
  }

  /// Get payment sources accessible to user
  Future<List<PaymentSource>> getPaymentSourcesAccessibleTo(
    String userId,
  ) async {
    _ensureInitialized();
    return await DatabaseService.instance.paymentSourceDao
        .getPaymentSourcesAccessibleTo(userId);
  }

  /// Get payment source by ID
  Future<PaymentSource?> getPaymentSourceById(String paymentSourceId) async {
    _ensureInitialized();
    return await DatabaseService.instance.paymentSourceDao.getById(
      paymentSourceId,
    );
  }

  /// Search payment sources by name
  Future<List<PaymentSource>> searchPaymentSources(String query) async {
    _ensureInitialized();
    return await DatabaseService.instance.paymentSourceDao.searchPaymentSources(
      query,
    );
  }

  /// Create a new custom payment source
  Future<PaymentSource> createPaymentSource({
    required String name,
    required String description,
    required IconData icon,
    required Color color,
    required String createdBy,
    List<String>? accessTo,
  }) async {
    _ensureInitialized();

    final now = DateTime.now().toUtc().millisecondsSinceEpoch;

    final paymentSource = PaymentSource(
      id: getUniqueId(),
      name: name.trim(),
      description: description.trim(),
      icon: icon,
      color: color,
      isDefault: false, // Custom payment sources are never default
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
      accessTo: accessTo ?? [],
    );

    await DatabaseService.instance.paymentSourceDao.insert(paymentSource);
    return paymentSource;
  }

  /// Update an existing payment source
  Future<PaymentSource> updatePaymentSource(
    String paymentSourceId, {
    String? name,
    String? description,
    IconData? icon,
    Color? color,
  }) async {
    _ensureInitialized();

    final currentPaymentSource = await getPaymentSourceById(paymentSourceId);
    if (currentPaymentSource == null) {
      throw Exception('Payment source not found');
    }

    // Don't allow updating default payment sources
    if (currentPaymentSource.isDefault) {
      throw Exception('Cannot update default payment sources');
    }

    await DatabaseService.instance.paymentSourceDao.updatePaymentSourceDetails(
      paymentSourceId,
      name: name,
      description: description,
      icon: icon,
      color: color,
    );

    // Return updated payment source
    final updatedPaymentSource = await getPaymentSourceById(paymentSourceId);
    if (updatedPaymentSource == null) {
      throw Exception('Payment source not found after update');
    }

    return updatedPaymentSource;
  }

  /// Delete a custom payment source
  Future<void> deletePaymentSource(String paymentSourceId) async {
    _ensureInitialized();

    final paymentSource = await getPaymentSourceById(paymentSourceId);
    if (paymentSource == null) {
      throw Exception('Payment source not found');
    }

    // Don't allow deleting default payment sources
    if (paymentSource.isDefault) {
      throw Exception('Cannot delete default payment sources');
    }

    await DatabaseService.instance.paymentSourceDao.delete(paymentSourceId);
  }

  /// Add user access to payment source
  Future<void> addUserAccess(String paymentSourceId, String userId) async {
    _ensureInitialized();
    await DatabaseService.instance.paymentSourceDao.addUserAccess(
      paymentSourceId,
      userId,
    );
  }

  /// Remove user access from payment source
  Future<void> removeUserAccess(String paymentSourceId, String userId) async {
    _ensureInitialized();
    await DatabaseService.instance.paymentSourceDao.removeUserAccess(
      paymentSourceId,
      userId,
    );
  }

  /// Check if user can access payment source
  Future<bool> canUserAccessPaymentSource(
    String userId,
    String paymentSourceId,
  ) async {
    _ensureInitialized();
    return await DatabaseService.instance.paymentSourceDao
        .canUserAccessPaymentSource(userId, paymentSourceId);
  }

  /// Get payment source statistics
  Future<Map<String, dynamic>> getPaymentSourceStats() async {
    _ensureInitialized();
    return await DatabaseService.instance.paymentSourceDao
        .getPaymentSourceStats();
  }

  /// Find a payment source by ID (for backward compatibility with DataService)
  Future<PaymentSource?> findPaymentSourceById(String id) async {
    return await getPaymentSourceById(id);
  }

  /// Check if a payment source is a default payment source
  Future<bool> isDefaultPaymentSource(String id) async {
    final paymentSource = await getPaymentSourceById(id);
    return paymentSource?.isDefault ?? false;
  }

  /// Clear all custom payment sources (useful for testing)
  Future<void> clearCustomPaymentSources() async {
    _ensureInitialized();

    final customPaymentSources = await getCustomPaymentSources();
    for (final paymentSource in customPaymentSources) {
      await DatabaseService.instance.paymentSourceDao.delete(paymentSource.id);
    }
  }

  /// Clear all payment source data (useful for testing)
  Future<void> clearAllPaymentSources() async {
    _ensureInitialized();
    await DatabaseService.instance.paymentSourceDao.clear();
  }

  /// Ensure the service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'PaymentSourceService not initialized. Call initialize() first.',
      );
    }
  }

  /// Get count of payment sources
  Future<int> getPaymentSourceCount() async {
    _ensureInitialized();
    return await DatabaseService.instance.paymentSourceDao.count();
  }

  /// Check if payment sources exist
  Future<bool> hasPaymentSources() async {
    _ensureInitialized();
    final count = await getPaymentSourceCount();
    return count > 0;
  }

  /// Check if default payment sources exist
  Future<bool> hasDefaultPaymentSources() async {
    _ensureInitialized();
    final defaultPaymentSources = await getDefaultPaymentSources();
    return defaultPaymentSources.isNotEmpty;
  }

  /// Validate payment source data
  bool validatePaymentSourceData({
    required String name,
    required String description,
  }) {
    if (name.trim().isEmpty) return false;
    return true;
  }

  /// Get popular payment sources (most recently created custom payment sources)
  Future<List<PaymentSource>> getPopularPaymentSources({int limit = 10}) async {
    _ensureInitialized();

    final customPaymentSources = await getCustomPaymentSources();
    customPaymentSources.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return customPaymentSources.take(limit).toList();
  }

  /// Get recently updated payment sources
  Future<List<PaymentSource>> getRecentlyUpdatedPaymentSources({
    int limit = 10,
  }) async {
    _ensureInitialized();

    final allPaymentSources = await getAllPaymentSources();
    allPaymentSources.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return allPaymentSources.take(limit).toList();
  }

  /// Get payment sources by color
  Future<List<PaymentSource>> getPaymentSourcesByColor(Color color) async {
    _ensureInitialized();

    final allPaymentSources = await getAllPaymentSources();
    return allPaymentSources.where((source) => source.color == color).toList();
  }

  /// Get payment sources by icon
  Future<List<PaymentSource>> getPaymentSourcesByIcon(IconData icon) async {
    _ensureInitialized();

    final allPaymentSources = await getAllPaymentSources();
    return allPaymentSources.where((source) => source.icon == icon).toList();
  }

  /// Get available colors for payment sources
  List<Color> getAvailableColors() {
    return [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.brown,
      Colors.indigo,
      Colors.purple,
      Colors.grey,
      Colors.red,
      Colors.teal,
    ];
  }

  /// Get available icons for payment sources
  List<IconData> getAvailableIcons() {
    return [
      Icons.credit_card,
      Icons.credit_card_outlined,
      Icons.qr_code,
      Icons.money,
      Icons.account_balance,
      Icons.wallet,
      Icons.more_horiz,
      Icons.payment,
    ];
  }
}
