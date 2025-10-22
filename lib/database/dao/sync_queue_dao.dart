import '../database_schema.dart';
import '../../models/sync_queue_entry.dart';
import 'base_dao.dart';

/// Data Access Object for SyncQueue table
class SyncQueueDao extends BaseDao<SyncQueueEntry> {
  @override
  String get tableName => DatabaseSchema.tableSyncQueue;

  @override
  SyncQueueEntry fromMap(Map<String, dynamic> map) {
    return SyncQueueEntry(
      id: map[DatabaseSchema.syncQueueId] as String,
      transactionId: map[DatabaseSchema.syncQueueTransactionId] as String,
      operation: map[DatabaseSchema.syncQueueOperation] as String,
      retryCount: map[DatabaseSchema.syncQueueRetryCount] as int,
      lastError: map[DatabaseSchema.syncQueueLastError] as String?,
      createdAt: map[DatabaseSchema.syncQueueCreatedAt] as int,
    );
  }

  @override
  Map<String, dynamic> toMap(SyncQueueEntry item) {
    return {
      DatabaseSchema.syncQueueId: item.id,
      DatabaseSchema.syncQueueTransactionId: item.transactionId,
      DatabaseSchema.syncQueueOperation: item.operation,
      DatabaseSchema.syncQueueRetryCount: item.retryCount,
      DatabaseSchema.syncQueueLastError: item.lastError,
      DatabaseSchema.syncQueueCreatedAt: item.createdAt,
    };
  }

  /// Get all pending sync entries ordered by creation time (oldest first)
  Future<List<SyncQueueEntry>> getAllPending() async {
    return await getWhere(orderBy: '${DatabaseSchema.syncQueueCreatedAt} ASC');
  }

  /// Get sync entries for a specific transaction
  Future<List<SyncQueueEntry>> getByTransactionId(String transactionId) async {
    return await getWhere(
      where: '${DatabaseSchema.syncQueueTransactionId} = ?',
      whereArgs: [transactionId],
    );
  }

  /// Update retry count and last error for an entry
  Future<int> updateRetryInfo(
    String id,
    int retryCount,
    String? lastError,
  ) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        DatabaseSchema.syncQueueRetryCount: retryCount,
        DatabaseSchema.syncQueueLastError: lastError,
      },
      where: '${DatabaseSchema.syncQueueId} = ?',
      whereArgs: [id],
    );
  }

  /// Delete all sync entries for a transaction
  Future<int> deleteByTransactionId(String transactionId) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: '${DatabaseSchema.syncQueueTransactionId} = ?',
      whereArgs: [transactionId],
    );
  }

  /// Get count of pending sync entries
  Future<int> getPendingCount() async {
    return await count();
  }

  /// Check if a transaction has pending sync operations
  Future<bool> hasPendingSync(String transactionId) async {
    final count = await this.count(
      where: '${DatabaseSchema.syncQueueTransactionId} = ?',
      whereArgs: [transactionId],
    );
    return count > 0;
  }

  /// Get sync entries with retry count less than max retries
  Future<List<SyncQueueEntry>> getRetryableEntries({int maxRetries = 5}) async {
    return await getWhere(
      where: '${DatabaseSchema.syncQueueRetryCount} < ?',
      whereArgs: [maxRetries],
      orderBy: '${DatabaseSchema.syncQueueCreatedAt} ASC',
    );
  }

  /// Clear all sync queue entries (use with caution)
  Future<int> clearAll() async {
    return await clear();
  }
}
