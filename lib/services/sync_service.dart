import 'package:money_manager/database/database_service.dart';
import 'package:money_manager/models/sync_queue_entry.dart';
import 'package:money_manager/services/logging_service.dart';
import 'package:money_manager/services/transaction_api_service.dart';
import 'package:money_manager/utils/utils.dart';

/// Service to manage syncing of pending transactions to the backend
class SyncService {
  static final SyncService _instance = SyncService._internal();
  static SyncService get instance => _instance;
  SyncService._internal();

  static final _log = LoggingService.getLogger('SyncService');

  bool _isInitialized = false;
  bool _isSyncing = false;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if sync is currently in progress
  bool get isSyncing => _isSyncing;

  /// Initialize the sync service
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
    _log.i('SyncService initialized');
  }

  /// Add a transaction to the sync queue
  Future<void> addToSyncQueue({
    required String transactionId,
    required String operation,
    String? lastError,
  }) async {
    _ensureInitialized();

    try {
      final entry = SyncQueueEntry(
        id: getUniqueId(),
        transactionId: transactionId,
        operation: operation,
        retryCount: 0,
        lastError: lastError,
        createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
      );

      await DatabaseService.instance.syncQueueDao.insert(entry);
      _log.d(
        'Added transaction $transactionId to sync queue with operation $operation',
      );
    } catch (e) {
      _log.e('Failed to add transaction to sync queue', error: e);
    }
  }

  /// Sync all pending transactions
  /// This method processes all pending sync queue entries
  /// It runs in the background and doesn't block the caller
  Future<void> syncPendingTransactions() async {
    _ensureInitialized();

    if (_isSyncing) {
      _log.d('Sync already in progress, skipping');
      return;
    }

    _isSyncing = true;
    _log.i('Starting sync of pending transactions');

    try {
      final entries =
          await DatabaseService.instance.syncQueueDao.getAllPending();

      if (entries.isEmpty) {
        _log.d('No pending transactions to sync');
        return;
      }

      _log.i('Found ${entries.length} pending transactions to sync');

      // Process each entry in parallel (fire and forget)
      for (final entry in entries) {
        _syncEntry(entry);
      }
    } catch (e) {
      _log.e('Error during sync', error: e);
    } finally {
      _isSyncing = false;
      _log.i('Sync process completed');
    }
  }

  /// Sync a single entry (fire and forget)
  Future<void> _syncEntry(SyncQueueEntry entry) async {
    try {
      _log.d(
        'Syncing entry ${entry.id} for transaction ${entry.transactionId} with operation ${entry.operation}',
      );

      // Get the transaction from the database
      final transaction = await DatabaseService.instance.transactionDao
          .getById(entry.transactionId);

      if (transaction == null) {
        _log.w(
          'Transaction ${entry.transactionId} not found, removing from sync queue',
        );
        // Transaction was deleted, remove from queue
        await DatabaseService.instance.syncQueueDao.delete(entry.id);
        return;
      }

      // Attempt API call based on operation type
      bool success = false;
      String? errorMessage;

      try {
        if (entry.operation == SyncOperation.create) {
          await TransactionApiService.instance
              .addTransaction(transaction: transaction);
          success = true;
        } else if (entry.operation == SyncOperation.update) {
          await TransactionApiService.instance.updateTransaction(
            transactionId: entry.transactionId,
            transaction: transaction,
          );
          success = true;
        } else if (entry.operation == SyncOperation.delete) {
          await TransactionApiService.instance.deleteTransaction(
            transactionId: entry.transactionId,
            createdBy: transaction.createdBy,
          );
          success = true;
        }
      } catch (e) {
        errorMessage = e.toString();
        _log.w(
          'Failed to sync transaction ${entry.transactionId}',
          error: e,
        );
      }

      if (success) {
        // Remove from queue on success
        await DatabaseService.instance.syncQueueDao.delete(entry.id);
        _log.d(
          'Successfully synced transaction ${entry.transactionId}, removed from queue',
        );
      } else {
        // Increment retry count and update error message
        final newRetryCount = entry.retryCount + 1;
        await DatabaseService.instance.syncQueueDao.updateRetryInfo(
          entry.id,
          newRetryCount,
          errorMessage,
        );
        _log.d(
          'Sync failed for transaction ${entry.transactionId}, retry count: $newRetryCount',
        );
      }
    } catch (e) {
      _log.e('Error syncing entry ${entry.id}', error: e);
    }
  }

  /// Get count of pending sync entries
  Future<int> getPendingCount() async {
    _ensureInitialized();
    return await DatabaseService.instance.syncQueueDao.getPendingCount();
  }

  /// Get all pending sync entries
  Future<List<SyncQueueEntry>> getPendingEntries() async {
    _ensureInitialized();
    return await DatabaseService.instance.syncQueueDao.getAllPending();
  }

  /// Clear all sync queue entries (use with caution)
  Future<void> clearAll() async {
    _ensureInitialized();
    await DatabaseService.instance.syncQueueDao.clearAll();
    _log.w('Cleared all sync queue entries');
  }

  /// Ensure the service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'SyncService not initialized. Call initialize() first.',
      );
    }
  }
}

