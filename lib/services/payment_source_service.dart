import 'package:flutter/material.dart';
import 'package:money_manager/utils/utils.dart';
import '../models/payment_source.dart';
import '../database/database_service.dart';
import 'payment_source_api_service.dart';
import 'sync_service.dart';
import 'logging_service.dart';

/// Service to manage payment sources with SQLite persistence
class PaymentSourceService {
  static PaymentSourceService? _instance;
  static PaymentSourceService get instance {
    _instance ??= PaymentSourceService._();
    return _instance!;
  }

  PaymentSourceService._();

  static final _log = LoggingService.getLogger('PaymentSourceService');
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

  /// Create a new custom payment source (offline-first)
  /// Saves locally first, then syncs to backend asynchronously
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

    // Save to local database first
    await DatabaseService.instance.paymentSourceDao.insert(paymentSource);

    // Sync to backend asynchronously (don't wait for response)
    // This allows the UI to respond immediately while the API call happens in the background
    _syncPaymentSourceAsync(
      paymentSourceId: paymentSource.id,
      operation: 'create',
      syncFn: () => PaymentSourceApiService.instance.createPaymentSource(
        name: name,
        description: description,
        icon: PaymentSource.iconToString(icon),
        color: PaymentSource.colorToString(color),
        createdBy: createdBy,
        accessTo: accessTo,
        id: paymentSource.id,
      ),
    );

    return paymentSource;
  }

  /// Update an existing payment source (offline-first)
  /// Saves locally first, then syncs to backend asynchronously
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

    // Update local database first
    await DatabaseService.instance.paymentSourceDao.updatePaymentSourceDetails(
      paymentSourceId,
      name: name,
      description: description,
      icon: icon,
      color: color,
    );

    // Sync to backend asynchronously (don't wait for response)
    // This allows the UI to respond immediately while the API call happens in the background
    final userId = currentPaymentSource.createdBy;

    _syncPaymentSourceUpdateAsync(
      paymentSourceId: paymentSourceId,
      userId: userId,
      operation: 'update',
      syncFn: () => PaymentSourceApiService.instance.updatePaymentSource(
        paymentSourceId: paymentSourceId,
        userId: userId,
        name: name,
        description: description,
        icon: icon != null ? PaymentSource.iconToString(icon) : null,
        color: color != null ? PaymentSource.colorToString(color) : null,
      ),
    );

    // Return updated payment source
    final updatedPaymentSource = await getPaymentSourceById(paymentSourceId);
    if (updatedPaymentSource == null) {
      throw Exception('Payment source not found after update');
    }

    return updatedPaymentSource;
  }

  /// Delete a custom payment source (offline-first)
  /// Deletes locally first, then syncs to backend asynchronously
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

    // Delete from local database first
    await DatabaseService.instance.paymentSourceDao.delete(paymentSourceId);

    // Sync to backend asynchronously (don't wait for response)
    // This allows the UI to respond immediately while the API call happens in the background
    _syncPaymentSourceAsync(
      paymentSourceId: paymentSourceId,
      operation: 'delete',
      syncFn: () => PaymentSourceApiService.instance.deletePaymentSource(
        paymentSourceId: paymentSourceId,
        userId: paymentSource.createdBy,
      ),
    );
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

  /// Helper method to sync payment source asynchronously
  /// Attempts to sync, and adds to queue if it fails
  void _syncPaymentSourceAsync({
    required String paymentSourceId,
    required String operation,
    required Future<void> Function() syncFn,
  }) {
    // Fire and forget - don't block the caller
    Future.microtask(() async {
      try {
        await syncFn();
        _log.d(
          'Successfully synced payment source $paymentSourceId with operation $operation',
        );
      } catch (e) {
        // Add to sync queue on failure
        _log.w(
          'Failed to sync payment source $paymentSourceId, adding to queue',
          error: e,
        );
        await SyncService.instance.addToSyncQueue(
          transactionId: paymentSourceId,
          operation: operation,
          lastError: e.toString(),
        );
      }
    });
  }

  /// Helper method to sync payment source updates asynchronously
  /// Similar to _syncPaymentSourceAsync but for update operations
  void _syncPaymentSourceUpdateAsync({
    required String paymentSourceId,
    required String userId,
    required String operation,
    required Future<PaymentSource> Function() syncFn,
  }) {
    // Fire and forget - don't block the caller
    Future.microtask(() async {
      try {
        _log.d(
          'Starting async sync for payment source $paymentSourceId with operation $operation',
        );
        await syncFn();
        _log.i(
          'Successfully synced payment source $paymentSourceId with operation $operation to backend',
        );
      } catch (e) {
        // Add to sync queue on failure
        _log.e(
          'Failed to sync payment source $paymentSourceId with operation $operation, adding to queue',
          error: e,
        );
        await SyncService.instance.addToSyncQueue(
          transactionId: paymentSourceId,
          operation: operation,
          lastError: e.toString(),
        );
      }
    });
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

  /// Fetch payment sources from backend API and sync with local database
  /// Uses JWT authentication
  Future<List<PaymentSource>> fetchPaymentSourcesFromBackend() async {
    _ensureInitialized();
    try {
      final apiService = PaymentSourceApiService.instance;
      final paymentSources = await apiService.getPaymentSources();

      // Sync with local database
      for (final paymentSource in paymentSources) {
        final existing = await getPaymentSourceById(paymentSource.id);
        if (existing == null) {
          // Insert new payment source
          await DatabaseService.instance.paymentSourceDao.insert(paymentSource);
        } else if (paymentSource.updatedAt > existing.updatedAt) {
          // Update if backend version is newer
          await DatabaseService.instance.paymentSourceDao.update(
            paymentSource,
            paymentSource.id,
          );
        }
      }

      return paymentSources;
    } catch (e) {
      debugPrint('Error fetching payment sources from backend: $e');
      rethrow;
    }
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
