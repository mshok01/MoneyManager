# Category Offline-First Sync Implementation

## Overview
Categories now follow the same offline-first pattern as transactions:
1. **Save locally first** - Category is saved to SQLite immediately
2. **Sync asynchronously** - Backend API call happens in the background (non-blocking)
3. **Handle failures gracefully** - Failed syncs are queued for retry on next app open

## How It Works

### When User Creates a Category
```
1. User fills form and clicks Save
2. Form validation runs
3. CategoryService.createCategory() is called
   ├─ Category saved to local SQLite database ✅
   ├─ UI responds immediately (dialog closes)
   ├─ Provider is invalidated (UI refreshes with new category)
   ├─ Success message shown
   └─ Backend API call starts asynchronously in background
      ├─ If success → Done ✅
      └─ If failure → Entry added to SyncQueue for retry
```

### When User Deletes a Category
```
1. User confirms deletion
2. CategoryService.deleteCategory() is called
   ├─ Category deleted from local SQLite database ✅
   ├─ UI responds immediately
   ├─ Success message shown
   └─ Backend API call starts asynchronously in background
      ├─ If success → Done ✅
      └─ If failure → Entry added to SyncQueue for retry
```

### When App Opens (Next Time)
```
1. App initializes normally (no blocking)
2. After 2-second delay → SyncService starts
3. SyncService fetches all pending entries from SyncQueue
4. For each category entry:
   ├─ Retrieves category from database
   ├─ Attempts API call (CREATE/DELETE)
   ├─ If successful → removes from SyncQueue ✅
   └─ If failed → increments retry_count, logs error
5. All entries processed in parallel (fire and forget)
6. App remains responsive throughout
```

## Implementation Details

### CategoryService Changes
**File**: `lib/services/category_service.dart`

#### createCategory()
- Saves category to local SQLite first
- Calls `_syncCategoryAsync()` to handle backend sync
- Returns immediately to UI (non-blocking)
- Converts icon/color to strings for API

#### deleteCategory()
- Deletes category from local SQLite first
- Calls `_syncCategoryAsync()` to handle backend sync
- Returns immediately to UI (non-blocking)

#### _syncCategoryAsync() (New Helper)
```dart
void _syncCategoryAsync({
  required String categoryId,
  required String operation,
  required Future<void> Function() syncFn,
})
```
- Uses `Future.microtask()` for fire-and-forget execution
- Attempts API call via provided `syncFn`
- On failure: adds entry to SyncQueue via `SyncService.addToSyncQueue()`
- Logs all operations for debugging

### CategoryScreen Changes
**File**: `lib/screens/category_screen.dart`

#### _saveNewCategory()
- Simplified to just call `CategoryService.createCategory()`
- Service handles all offline-first logic
- UI invalidates provider to refresh data
- Shows success/error messages

## Key Features

✅ **Offline Compatible** - Works without internet connection
✅ **Non-Blocking UI** - Backend sync doesn't freeze the app
✅ **Automatic Retry** - Failed syncs retry on next app open
✅ **Consistent Pattern** - Same as transaction sync system
✅ **Logging** - All operations logged for debugging
✅ **Error Handling** - Graceful failure with user feedback

## Database Integration

Uses existing `SyncQueue` table:
- Stores pending category operations
- Tracks retry count and error messages
- Processed by `SyncService.syncPendingTransactions()`

Note: Currently uses `transactionId` field for category IDs (can be refactored later)

## API Integration

Uses `CategoryApiService`:
- `createCategory()` - Creates category on backend
- `deleteCategory()` - Deletes category on backend
- Throws exceptions on failure (caught by sync helper)

## Testing Recommendations

1. **Create category offline** - Turn off internet, create category, verify it appears locally
2. **Sync on reconnect** - Turn internet back on, open app, verify sync happens
3. **Failed sync retry** - Mock API failure, verify entry in SyncQueue, verify retry on next open
4. **Multiple operations** - Create/delete multiple categories offline, verify all sync correctly

## Future Enhancements

- [ ] Support category updates (currently only create/delete)
- [ ] Separate SyncQueue for categories (currently shares with transactions)
- [ ] UI indicator for pending syncs
- [ ] Manual retry button for failed syncs
- [ ] Sync progress notifications

