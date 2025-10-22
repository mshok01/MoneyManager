# Payment Sources API Integration - Client Side

## Overview

The Flutter client has been integrated with the backend Payment Sources APIs. The implementation follows the same architecture as the Categories APIs with an offline-first approach.

## Architecture

### Three-Layer Architecture

1. **API Service Layer** (`payment_source_api_service.dart`)
   - Handles all HTTP requests to the backend
   - Manages JWT authentication
   - Converts responses to PaymentSource models

2. **Service Layer** (`payment_source_service.dart`)
   - Manages local SQLite database operations
   - Coordinates with API service for backend sync
   - Implements offline-first pattern

3. **Model Layer** (`payment_source.dart`)
   - Defines PaymentSource data structure
   - Handles JSON serialization/deserialization
   - Provides icon and color conversion utilities

## Files Modified/Created

### New Files
- `lib/services/payment_source_api_service.dart` - API service for backend communication

### Modified Files
- `lib/services/payment_source_service.dart` - Added backend sync integration
- `lib/models/payment_source.dart` - Made helper methods public for service layer

## API Methods Implemented

### PaymentSourceApiService

#### Get Payment Sources
```dart
Future<List<PaymentSource>> getPaymentSources()
```
- Requires JWT authentication
- Returns all payment sources accessible to the user

#### Create Payment Source
```dart
Future<PaymentSource> createPaymentSource({
  required String name,
  required String description,
  required String icon,
  required String color,
  required String createdBy,
  List<String>? accessTo,
})
```
- Requires JWT authentication
- Creates a new payment source on the backend

#### Bulk Create Payment Sources
```dart
Future<Map<String, dynamic>> bulkCreatePaymentSources({
  required List<Map<String, dynamic>> paymentSources,
})
```
- Requires JWT authentication
- Creates multiple payment sources in a single request
- Returns response with created count, failed count, and errors

#### Delete Payment Source
```dart
Future<void> deletePaymentSource({
  required String paymentSourceId,
  required String userId,
})
```
- Requires JWT authentication
- Deletes a payment source from the backend

#### Update Payment Source Fields
- `updatePaymentSourceName()` - Update name
- `updatePaymentSourceDescription()` - Update description
- `updatePaymentSourceIcon()` - Update icon
- `updatePaymentSourceColor()` - Update color
- `updatePaymentSourceAccessTo()` - Update access list

All update methods require JWT authentication.

## Offline-First Pattern

### Create Payment Source
1. Save to local SQLite database immediately
2. Return to UI (instant feedback)
3. Sync to backend asynchronously in background
4. If sync fails, add to sync queue for retry

### Delete Payment Source
1. Delete from local SQLite database immediately
2. Return to UI (instant feedback)
3. Sync deletion to backend asynchronously
4. If sync fails, add to sync queue for retry

## Integration with PaymentSourceService

The `PaymentSourceService` now:
- Saves payment sources locally first
- Triggers async sync to backend via `PaymentSourceApiService`
- Uses `SyncService` to queue failed operations
- Provides logging for debugging

### Example Usage

```dart
// Create a payment source (offline-first)
final paymentSource = await PaymentSourceService.instance.createPaymentSource(
  name: 'Credit Card',
  description: 'My Visa Card',
  icon: Icons.credit_card,
  color: Colors.blue,
  createdBy: userId,
);
// Returns immediately, syncs in background

// Delete a payment source (offline-first)
await PaymentSourceService.instance.deletePaymentSource(paymentSourceId);
// Returns immediately, syncs in background
```

## Authentication

All API endpoints (except GetDefaultPaymentSources on backend) use JWT authentication:
- JWT token obtained from Firebase Authentication
- Passed in Authorization header: `Bearer <token>`
- Automatically handled by `PaymentSourceApiService`

## Error Handling

- Network timeouts: 30 seconds
- Failed requests: Added to sync queue for retry
- Logging: All operations logged via `LoggingService`
- Exceptions: Propagated to caller for UI error handling

## Sync Queue Integration

Failed API calls are automatically added to the sync queue:
- Retried when network becomes available
- Tracked with operation type (create, delete, update)
- Includes error details for debugging

## Testing

To test the integration:

1. **Create Payment Source**
   ```dart
   await PaymentSourceService.instance.createPaymentSource(
     name: 'Test Source',
     description: 'Test',
     icon: Icons.wallet,
     color: Colors.green,
     createdBy: userId,
   );
   ```

2. **Get Payment Sources**
   ```dart
   final sources = await PaymentSourceService.instance.getAllPaymentSources();
   ```

3. **Delete Payment Source**
   ```dart
   await PaymentSourceService.instance.deletePaymentSource(paymentSourceId);
   ```

## Configuration

Backend URL is configured in `PaymentSourceApiService`:
```dart
static const String _baseUrl = 'http://192.168.1.4:8080/api/v1';
```

Update this to match your backend environment.

## Next Steps

1. Test all API endpoints with the backend
2. Verify sync queue handles failures correctly
3. Test offline scenarios
4. Monitor logs for any issues

