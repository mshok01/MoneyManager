# Transaction Sync - Quick Reference Guide

## Files Created

### Models
- `lib/models/sync_queue_entry.dart` - Data model for sync queue entries

### Database
- `lib/database/dao/sync_queue_dao.dart` - Data access object for sync queue

### Services
- `lib/services/sync_service.dart` - Core sync service

## Files Modified

### Database
- `lib/database/database_schema.dart` - Added sync queue table schema
- `lib/database/database_helper.dart` - Added sync queue table creation
- `lib/database/database_service.dart` - Added SyncQueueDao initialization

### Services
- `lib/services/transaction_api_service.dart` - Modified to throw exceptions
- `lib/services/transaction_service.dart` - Added sync queue integration
- `lib/main.dart` - Initialize SyncService and schedule sync

## Key Classes & Methods

### SyncService
```dart
// Initialize
await SyncService.instance.initialize();

// Add to queue
await SyncService.instance.addToSyncQueue(
  transactionId: 'txn-123',
  operation: SyncOperation.create,
  lastError: 'Network timeout',
);

// Sync pending
await SyncService.instance.syncPendingTransactions();

// Get pending count
int count = await SyncService.instance.getPendingCount();

// Get pending entries
List<SyncQueueEntry> entries = 
  await SyncService.instance.getPendingEntries();
```

### SyncQueueEntry
```dart
// Create entry
final entry = SyncQueueEntry(
  id: 'sync-123',
  transactionId: 'txn-123',
  operation: SyncOperation.create,
  retryCount: 0,
  lastError: null,
  createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
);

// Check validity
if (entry.isValid) { ... }

// Get created date
DateTime created = entry.createdDateTime;
```

### SyncOperation
```dart
// Operation types
SyncOperation.create   // 'CREATE'
SyncOperation.update   // 'UPDATE'
SyncOperation.delete   // 'DELETE'

// Validate
if (SyncOperation.isValid('CREATE')) { ... }
```

## Database Schema

### sync_queue Table
```sql
CREATE TABLE sync_queue (
  id TEXT PRIMARY KEY,
  transaction_id TEXT NOT NULL,
  operation TEXT NOT NULL,
  retry_count INTEGER NOT NULL DEFAULT 0,
  last_error TEXT,
  created_at INTEGER NOT NULL,
  FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE
)
```

### Indexes
- `idx_sync_queue_transaction_id` - Fast lookup by transaction
- `idx_sync_queue_created_at` - Ordering by creation time

## Workflow

### 1. User Creates Transaction (Offline)
```
TransactionService.createTransaction()
  ↓
Save to SQLite ✅
  ↓
Attempt API call (async)
  ├─ Success → Done ✅
  └─ Failure → Add to SyncQueue
```

### 2. App Opens (Next Time)
```
main.dart
  ↓
Initialize all services
  ↓
After 2-second delay
  ↓
SyncService.syncPendingTransactions()
  ↓
Fetch all pending entries
  ↓
For each entry:
  ├─ Get transaction from DB
  ├─ Attempt API call
  ├─ Success → Remove from queue ✅
  └─ Failure → Increment retry_count
```

## Logging

All sync operations are logged with the logger key: `'SyncService'`

```dart
// View logs
final log = LoggingService.getLogger('SyncService');

// Log levels
log.d('Debug message');      // Debug
log.i('Info message');       // Info
log.w('Warning message');    // Warning
log.e('Error message');      // Error
```

## Testing Checklist

- [ ] Create transaction while offline
- [ ] Verify transaction saved locally
- [ ] Restart app
- [ ] Verify sync happens automatically
- [ ] Check logs for sync operations
- [ ] Verify entry removed from SyncQueue after sync
- [ ] Create multiple transactions offline
- [ ] Verify all sync on app restart
- [ ] Simulate API failure
- [ ] Verify retry on next app open

## Troubleshooting

### Sync not happening
1. Check if SyncService is initialized in main.dart
2. Check if 2-second delay is sufficient
3. Check logs for errors

### Entries not being removed
1. Check if API call is actually succeeding
2. Check database for orphaned entries
3. Verify SyncQueueDao.delete() is working

### High retry count
1. Check API endpoint availability
2. Check network connectivity
3. Review error messages in last_error column

## Performance Notes

- Sync runs in parallel (fire and forget)
- No blocking of UI thread
- 2-second delay allows app to fully initialize
- Entries processed in order of creation (oldest first)
- Each entry processed independently

## Security Notes

- Transactions are already validated before sync
- API calls use existing authentication (X-API-Key)
- No sensitive data stored in sync queue
- Entries automatically deleted on transaction deletion

## Future Enhancements

See `SYNC_IMPLEMENTATION_SUMMARY.md` for Phase 3 enhancements

