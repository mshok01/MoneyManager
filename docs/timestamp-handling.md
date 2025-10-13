# UTC Timestamp Handling

This document explains how timestamps are handled in the Money Manager app's user management system.

## Overview

All user timestamps are stored in UTC (Coordinated Universal Time) to ensure consistency across different timezones and devices. When displaying dates/times in the UI, they are automatically converted to the user's local timezone.

## Storage Format

- **Format**: Milliseconds since Unix epoch (January 1, 1970, 00:00:00 UTC)
- **Type**: `int` (64-bit integer)
- **Timezone**: Always UTC

```dart
// Example timestamp storage
final utcTimestamp = DateTime.now().toUtc().millisecondsSinceEpoch;
// Result: 1697123456789 (UTC milliseconds)
```

## Implementation Details

### User Model

The `User` model stores timestamps in UTC:

```dart
class User {
  final int createdAt;  // UTC milliseconds since epoch
  final int updatedAt;  // UTC milliseconds since epoch
  // ... other fields
}
```

### UserService

All timestamp generation uses UTC:

```dart
// User creation
final now = DateTime.now().toUtc().millisecondsSinceEpoch;
final user = User(
  createdAt: now,
  updatedAt: now,
  // ... other fields
);

// User updates
final updatedUser = currentUser.copyWith(
  updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
);
```

### UserUtils - Display Methods

For UI display, timestamps are automatically converted to local timezone:

```dart
// Returns DateTime in local timezone
DateTime? getUserCreationDate() {
  final user = getCurrentUser();
  if (user == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(
    user.createdAt, 
    isUtc: true
  ).toLocal();
}

// Returns formatted string in local timezone
String getFormattedCreationDateTime() {
  final date = getUserCreationDate(); // Already local
  // Format: "2024-01-15 14:30"
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
         '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
```

### UserUtils - Calculation Methods

For internal calculations, UTC is used for accuracy:

```dart
// Returns DateTime in UTC for accurate calculations
DateTime? getUserCreationDateUtc() {
  final user = getCurrentUser();
  if (user == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(user.createdAt, isUtc: true);
}

// Age calculation uses UTC to avoid timezone issues
int getUserAgeInDays() {
  final creationDateUtc = getUserCreationDateUtc();
  if (creationDateUtc == null) return 0;
  
  final nowUtc = DateTime.now().toUtc();
  return nowUtc.difference(creationDateUtc).inDays;
}
```

## Usage Examples

### For UI Display

```dart
// Display creation date in user's local timezone
final creationDate = UserUtils.getFormattedCreationDateTime();
Text('Account created: $creationDate');
// Shows: "Account created: 2024-01-15 14:30" (local time)

// Display last update
final lastUpdate = UserUtils.getFormattedLastUpdateDateTime();
Text('Last updated: $lastUpdate');
// Shows: "Last updated: 2024-01-16 09:15" (local time)
```

### For Calculations

```dart
// Calculate user age accurately across timezones
final ageInDays = UserUtils.getUserAgeInDays();
Text('Account age: $ageInDays days');

// Check if created today (uses local timezone for user experience)
final createdToday = UserUtils.wasUserCreatedToday();
if (createdToday) {
  Text('Welcome! Your account was created today.');
}
```

### For Debugging

```dart
// Get comprehensive timestamp information
final summary = UserUtils.getUserSummary();
print('Created (local): ${summary['createdAt']}');        // Local time
print('Created (UTC): ${summary['createdAtUtc']}');       // UTC time
print('Formatted: ${summary['createdAtFormatted']}');     // Formatted local
```

## Benefits of UTC Storage

1. **Consistency**: Same timestamp value regardless of device timezone
2. **Accuracy**: Calculations work correctly across timezone changes
3. **Portability**: Data can be moved between devices/servers without issues
4. **Future-proof**: Handles daylight saving time changes automatically

## Best Practices

### ✅ Do

- Use `UserUtils.getUserCreationDate()` for UI display (auto-converts to local)
- Use `UserUtils.getFormattedCreationDateTime()` for formatted display
- Use `UserUtils.getUserAgeInDays()` for age calculations (uses UTC internally)
- Store all new timestamps using `DateTime.now().toUtc().millisecondsSinceEpoch`

### ❌ Don't

- Use `DateTime.now().millisecondsSinceEpoch` (local timezone)
- Convert UTC timestamps to local for calculations
- Assume timestamps are in local timezone when reading from storage
- Mix UTC and local timestamps in the same calculation

## Migration Notes

If you have existing timestamps in local timezone:

```dart
// Convert existing local timestamp to UTC
final localTimestamp = 1697123456789; // Existing local timestamp
final localDateTime = DateTime.fromMillisecondsSinceEpoch(localTimestamp);
final utcTimestamp = localDateTime.toUtc().millisecondsSinceEpoch;
```

## Testing

The timestamp handling is thoroughly tested:

```bash
# Run timestamp-related tests
flutter test test/user_model_test.dart
flutter test test/user_service_test.dart  
flutter test test/user_utils_test.dart
```

All tests verify that:
- Timestamps are stored in UTC
- Display methods convert to local timezone
- Calculation methods use UTC for accuracy
- Edge cases (timezone changes, DST) are handled correctly

## Timezone Examples

### User in New York (EST/EDT)

```dart
// UTC storage: 1697123456789 (2023-10-12 14:30:56 UTC)
// Local display: "2023-10-12 10:30" (EDT, UTC-4)
// Age calculation: Uses UTC for accuracy
```

### User in Tokyo (JST)

```dart
// UTC storage: 1697123456789 (2023-10-12 14:30:56 UTC)  
// Local display: "2023-10-12 23:30" (JST, UTC+9)
// Age calculation: Same result as New York user
```

### User Travels

```dart
// User creates account in New York: UTC timestamp stored
// User travels to Tokyo: Display automatically adjusts to JST
// Age calculation: Remains accurate regardless of current timezone
```

This approach ensures a consistent and reliable user experience across all timezones and devices.
