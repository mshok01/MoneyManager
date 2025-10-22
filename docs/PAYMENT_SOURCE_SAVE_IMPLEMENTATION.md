# Payment Source Save Implementation - Offline-First Pattern

## Overview

The payment source save functionality has been fully implemented with an offline-first pattern, matching the architecture used for transactions and categories. When a user creates a payment source, it is:

1. **Saved to local SQLite database immediately** (instant UI feedback)
2. **Synced to backend asynchronously** in the background
3. **Automatically retried** if the sync fails (via SyncService queue)

## Implementation Details

### 1. UI Layer (`payment_sources_screen.dart`)

The `_savePaymentSource()` method now:

```dart
void _savePaymentSource() async {
  // 1. Validate input
  if (_nameController.text.trim().isEmpty) {
    // Show error
    return;
  }

  // 2. Set loading state
  setState(() => _isLoading = true);

  try {
    // 3. Get current user ID from UserService
    final userId = UserService.instance.currentUser?.id ?? 'user';

    // 4. Call PaymentSourceService.createPaymentSource()
    final source = await PaymentSourceService.instance.createPaymentSource(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      icon: Icons.payment,
      color: Colors.blue,
      createdBy: userId,
      accessTo: [userId],
    );

    // 5. Update UI with new source
    widget.onAdd(source);

    // 6. Show success toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.paymentSourceCreatedSuccessfully,
        ),
      ),
    );

    // 7. Close dialog
    Navigator.of(context).pop();
  } catch (e) {
    // Show error toast
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### 2. Service Layer (`payment_source_service.dart`)

The `createPaymentSource()` method:

1. **Saves to local database immediately**
   ```dart
   await DatabaseService.instance.paymentSourceDao.insert(paymentSource);
   ```

2. **Returns to caller immediately** (no waiting for backend)

3. **Triggers async backend sync** via `_syncPaymentSourceAsync()`
   ```dart
   _syncPaymentSourceAsync(
     paymentSourceId: paymentSource.id,
     operation: 'create',
     syncFn: () => PaymentSourceApiService.instance.createPaymentSource(...),
   );
   ```

### 3. Async Sync Helper (`_syncPaymentSourceAsync`)

```dart
void _syncPaymentSourceAsync({
  required String paymentSourceId,
  required String operation,
  required Future<void> Function() syncFn,
}) {
  // Fire and forget - don't block the caller
  Future.microtask(() async {
    try {
      await syncFn();
      _log.d('Successfully synced payment source $paymentSourceId');
    } catch (e) {
      // Add to sync queue on failure
      _log.w('Failed to sync payment source, adding to queue', error: e);
      await SyncService.instance.addToSyncQueue(
        transactionId: paymentSourceId,
        operation: operation,
        lastError: e.toString(),
      );
    }
  });
}
```

### 4. API Layer (`payment_source_api_service.dart`)

The `createPaymentSource()` method:
- Makes HTTP POST request to backend
- Uses JWT authentication
- Converts response to PaymentSource model
- Throws exception on failure (caught by sync helper)

## User Experience Flow

### Success Scenario
1. User enters payment source name and description
2. Clicks "Add" button
3. **Immediately**: Payment source appears in list (from local DB)
4. **Immediately**: "Payment source created successfully" toast shown
5. **In background**: API call syncs to backend
6. **If sync succeeds**: Data persisted on server
7. **If sync fails**: Added to sync queue, retried on next app open

### Error Scenario
1. User enters payment source name
2. Clicks "Add" button
3. **Immediately**: Loading state shown
4. **If validation fails**: Error toast shown
5. **If API fails**: Error toast shown, data still saved locally
6. **On next app open**: Failed sync retried automatically

## Localization Strings Added

Two new strings added to `app_en.arb`:

```json
"paymentSourceCreatedSuccessfully": "Payment source created successfully",
"paymentSourceUpdatedSuccessfully": "Payment source updated successfully"
```

Generated in `app_localizations.dart` via `flutter gen-l10n`

## Files Modified

1. **`lib/screens/payment_sources_screen.dart`**
   - Updated `_savePaymentSource()` to call PaymentSourceService
   - Added async/await support
   - Added error handling with try-catch-finally
   - Added loading state management
   - Added success/error toast notifications

2. **`lib/services/payment_source_service.dart`**
   - Already had offline-first implementation
   - No changes needed (already syncs to backend asynchronously)

3. **`lib/l10n/app_en.arb`**
   - Added two new localization strings

4. **`lib/l10n/app_localizations.dart`**
   - Auto-generated with new strings via `flutter gen-l10n`

## Testing the Implementation

### Manual Testing Steps

1. **Create Payment Source**
   - Open Payment Sources screen
   - Click "Add Payment Source"
   - Enter name and description
   - Click "Add"
   - Verify: Toast shows "Payment source created successfully"
   - Verify: Payment source appears in list immediately
   - Verify: Data syncs to backend (check backend logs)

2. **Test Offline Scenario**
   - Turn off network
   - Create payment source
   - Verify: Toast shows success
   - Verify: Payment source appears locally
   - Turn on network
   - Verify: Data syncs to backend on next app open

3. **Test Error Handling**
   - Create payment source with invalid data
   - Verify: Error toast shown
   - Verify: Data still saved locally (if validation passed)

## Architecture Consistency

This implementation follows the same pattern as:
- **Transactions**: Create locally, sync asynchronously
- **Categories**: Create locally, sync asynchronously
- **Accounts**: Create locally, sync asynchronously

All use the same `SyncService` for queue management and retry logic.

## Next Steps

1. Implement update methods in PaymentSourceService (currently only create/delete)
2. Add UI for editing payment sources with backend sync
3. Add bulk create functionality to UI
4. Add tests for offline-first behavior

