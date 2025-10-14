# User Management System

The Money Manager app includes a comprehensive user management system that handles user creation, authentication, and data persistence. This document outlines the architecture, implementation, and usage of the user management features.

## Overview

The user management system consists of several key components:

- **User Model**: Data structure for user information
- **UserService**: Service layer for user operations
- **PreferencesService**: Persistent storage for user data
- **UserUtils**: Utility functions for common user operations
- **Device Integration**: Links users with device records

## User Model

The `User` model represents a user in the system with the following fields:

```dart
class User {
  final String id;          // UUID string
  final int createdAt;      // milliseconds since epoch in UTC
  final int updatedAt;      // milliseconds since epoch in UTC
  final int isActive;       // 1 for active, 0 for inactive
  final String email;       // user email address
  final String name;        // user display name
  final String profilePic;  // profile picture URL or path
  final String currencyCode; // currency code (e.g., 'USD', 'EUR')
  final String currencyName; // currency name (e.g., 'US Dollar', 'Euro')
}
```

**Important**: All timestamps are stored in UTC milliseconds since epoch. When displaying dates/times in the UI, they should be converted to local timezone using the provided utility methods.

### Key Features

- **JSON Serialization**: Full support for `toJson()` and `fromJson()`
- **Validation**: Built-in validation for email format, required fields
- **Immutability**: Uses `copyWith()` pattern for updates
- **Timestamps**: Automatic timestamp management

### Usage Examples

```dart
// Create a new user (timestamps in UTC)
final user = User(
  id: 'uuid-string',
  createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
  updatedAt: DateTime.now().toUtc().millisecondsSinceEpoch,
  isActive: 1,
  email: 'user@example.com',
  name: 'John Doe',
  profilePic: '',
  currencyCode: 'USD',
  currencyName: 'US Dollar',
);

// Update user
final updatedUser = user.copyWith(
  name: 'Jane Doe',
  email: 'jane@example.com',
);

// Validate user
if (user.isValid) {
  print('User is valid');
}
```

## UserService

The `UserService` is a singleton service that manages all user operations:

### Initialization

```dart
// Initialize the service (called in main.dart)
await UserService.instance.initialize();
```

### User Creation

```dart
// Create anonymous user
final user = await UserService.instance.createUser();

// Create user with details
final user = await UserService.instance.createUser(
  email: 'user@example.com',
  name: 'John Doe',
  profilePic: 'https://example.com/profile.jpg',
  currencyCode: 'USD',
  currencyName: 'US Dollar',
);
```

### User Operations

```dart
final userService = UserService.instance;

// Check if user exists
if (userService.hasUser) {
  print('User exists');
}

// Get current user
final user = userService.currentUser;

// Update user
final updatedUser = await userService.updateUser(
  email: 'new@example.com',
  name: 'New Name',
  currencyCode: 'EUR',
  currencyName: 'Euro',
);

// Update only currency
final userWithNewCurrency = await userService.updateUser(
  currencyCode: 'GBP',
  currencyName: 'British Pound',
);

// Get currency information
String currencyCode = userService.getUserCurrencyCode();
String currencyName = userService.getUserCurrencyName();
bool hasCurrency = userService.hasUserCurrency();

// Delete user
await userService.deleteUser();
```

## UserUtils

Utility class providing convenient methods for common user operations:

### User Existence and Status

```dart
// Check if user exists
bool exists = UserUtils.userExists();
bool isFirstTime = UserUtils.isFirstTimeUser();

// Check user status
bool isActive = UserUtils.isCurrentUserActive();
bool hasValidEmail = UserUtils.currentUserHasValidEmail();
bool isAnonymous = UserUtils.isAnonymousUser();
```

### User Information

```dart
// Get user details with fallbacks
String name = UserUtils.getUserDisplayName(fallback: 'Guest');
String email = UserUtils.getUserEmail(fallback: 'No email');

// Get currency information with fallbacks
String currencyCode = UserUtils.getUserCurrencyCode(fallback: 'USD');
String currencyName = UserUtils.getUserCurrencyName(fallback: 'US Dollar');
bool hasCurrency = UserUtils.hasUserCurrency();

// Get user dates (automatically converted to local timezone for UI)
DateTime? creationDate = UserUtils.getUserCreationDate(); // Local time
DateTime? updateDate = UserUtils.getUserLastUpdateDate(); // Local time

// Get formatted dates for UI display
String formattedDate = UserUtils.getFormattedCreationDate(); // yyyy-MM-dd
String formattedDateTime = UserUtils.getFormattedCreationDateTime(); // yyyy-MM-dd HH:mm
String formattedUpdateTime = UserUtils.getFormattedLastUpdateDateTime();

// Get UTC dates for internal calculations
DateTime? creationDateUtc = UserUtils.getUserCreationDateUtc(); // UTC time
DateTime? updateDateUtc = UserUtils.getUserLastUpdateDateUtc(); // UTC time

// Date calculations
int ageInDays = UserUtils.getUserAgeInDays(); // Uses UTC for accuracy
bool createdToday = UserUtils.wasUserCreatedToday(); // Uses local timezone
```

### User Operations

```dart
// Create anonymous user
final user = await UserUtils.createAnonymousUser();

// Update user info
await UserUtils.updateUserInfo(
  email: 'new@example.com',
  name: 'New Name',
  currencyCode: 'EUR',
  currencyName: 'Euro',
);

// Update only currency
await UserUtils.updateUserCurrency(
  currencyCode: 'GBP',
  currencyName: 'British Pound',
);

// User status management
await UserUtils.deactivateUser();
await UserUtils.reactivateUser();
await UserUtils.deleteCurrentUser();
```

## App Flow Integration

### App Initialization

The app determines the initial screen based on user existence:

```dart
// In main.dart
Widget _getInitialScreen() {
  final userService = UserService.instance;
  
  // If user exists, go to home screen
  if (userService.hasUser) {
    return const HomeScreen();
  }
  
  // Otherwise, start with intro screen
  return const IntroScreen();
}
```

### User Creation Flow

1. **User sees intro screens** → Navigate to auth choice
2. **User taps "Get Started"** → Create anonymous user and link to device
3. **User selects currency** → Continue to backup options
4. **User completes onboarding** → Mark onboarding complete and go to home

### Code Example: Get Started Button

```dart
Future<void> _onGetStarted(BuildContext context) async {
  try {
    // Show loading
    showDialog(context: context, builder: (_) => CircularProgressIndicator());

    // Create new user
    final userService = UserService.instance;
    final user = await userService.createUser();

    // Update device record with user ID
    final deviceService = DeviceRecordService.instance;
    await deviceService.updateUserId(user.id);

    // Navigate to currency selection
    Navigator.of(context).pushNamed('/currency-selection');
  } catch (e) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create user: $e')),
    );
  }
}
```

## Timestamp Handling

The user management system uses UTC timestamps for all stored dates to ensure consistency across timezones:

### Storage
- All timestamps are stored as UTC milliseconds since epoch
- `createdAt` and `updatedAt` fields use `DateTime.now().toUtc().millisecondsSinceEpoch`

### UI Display
- Use `UserUtils.getUserCreationDate()` - automatically converts to local timezone
- Use `UserUtils.getFormattedCreationDateTime()` - formatted local time for display
- Use `UserUtils.getFormattedLastUpdateDateTime()` - formatted local time for display

### Internal Calculations
- Use `UserUtils.getUserCreationDateUtc()` - keeps UTC for accurate calculations
- Use `UserUtils.getUserAgeInDays()` - calculates using UTC for accuracy

### Example Usage

```dart
// For UI display (local timezone)
final displayDate = UserUtils.getFormattedCreationDateTime();
Text('Created: $displayDate'); // Shows: "Created: 2024-01-15 14:30"

// For calculations (UTC)
final ageInDays = UserUtils.getUserAgeInDays(); // Accurate across timezones

// For debugging
final summary = UserUtils.getUserSummary();
print('Created (local): ${summary['createdAt']}');
print('Created (UTC): ${summary['createdAtUtc']}');
```

## Data Persistence

User data is persisted using `SharedPreferences` through the `PreferencesService`:

### Storage Methods

```dart
final prefsService = await PreferencesService.getInstance();

// Store user
await prefsService.setUserRecord(user);

// Retrieve user
final user = prefsService.getUserRecord();

// Check if user exists
bool hasUser = prefsService.hasUserRecord();

// Clear user data
await prefsService.clearUserRecord();
```

## Device Integration

Users are linked to device records for analytics and support:

```dart
// Update device record with user ID
await DeviceRecordService.instance.updateUserId(userId);

// Clear user ID from device
await DeviceRecordService.instance.clearUserId();
```

## Error Handling

The system includes comprehensive error handling:

- **Service Initialization**: Graceful fallback if initialization fails
- **User Creation**: Proper error messages for creation failures
- **Data Persistence**: Automatic cleanup of corrupted data
- **Validation**: Built-in validation with clear error messages

## Testing

Comprehensive test coverage includes:

- **Unit Tests**: User model, UserService, UserUtils
- **Integration Tests**: Complete user creation flow
- **Mock Data**: SharedPreferences mocking for isolated testing

### Running Tests

```bash
# Run all user-related tests
flutter test test/user_model_test.dart
flutter test test/user_service_test.dart
flutter test test/user_utils_test.dart
```

## Best Practices

1. **Always initialize services** before using them
2. **Use UserUtils** for common operations instead of direct service calls
3. **Handle errors gracefully** with user-friendly messages
4. **Validate user input** before creating or updating users
5. **Use the singleton pattern** correctly for services
6. **Test thoroughly** with various user states and edge cases

## Future Enhancements

- **Authentication Integration**: Firebase Auth, Google Sign-in, Apple Sign-in
- **User Profiles**: Extended profile information and settings
- **Data Sync**: Cloud synchronization of user data
- **Multi-Account**: Support for multiple user accounts
- **Privacy Controls**: Enhanced privacy and data management options
