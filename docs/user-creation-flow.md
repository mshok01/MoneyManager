# User Creation Flow

This document describes the complete user creation flow in the Money Manager app, from first launch to home screen.

## Flow Overview

```
App Launch → Check User Exists → Route to Appropriate Screen
    ↓
    ├─ User Exists → Home Screen
    └─ No User → Intro Screens → Auth Choice → Create User → Currency Selection → Backup Options → Home Screen
```

## Detailed Flow

### 1. App Launch (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize all services
  await ThemeService.instance.initialize();
  await DataService.instance.initialize();
  await DeviceRecordService.instance.initialize();
  await UserService.instance.initialize();  // ← User service initialization
  
  runApp(const MoneyManagerApp());
}
```

### 2. Initial Screen Determination

```dart
Widget _getInitialScreen() {
  final userService = UserService.instance;
  
  // If user exists, go directly to home
  if (userService.hasUser) {
    return const HomeScreen();
  }
  
  // Otherwise, start onboarding
  return const IntroScreen();
}
```

### 3. Intro Screens

- User sees 4 intro pages explaining app features
- Can skip or navigate through pages
- Ends with navigation to `/auth-choice`

### 4. Auth Choice Screen

Two main options:
- **"Get Started"** → Creates new anonymous user
- **"I have an account"** → Future: Sign in with existing account

#### Get Started Implementation

```dart
Future<void> _onGetStarted(BuildContext context) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Create new user
    final userService = UserService.instance;
    final user = await userService.createUser();

    // Update device record with user ID
    final deviceService = DeviceRecordService.instance;
    await deviceService.updateUserId(user.id);

    // Close loading and navigate
    if (context.mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed('/currency-selection');
    }
  } catch (e) {
    // Handle errors gracefully
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create user account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
```

### 5. Currency Selection

- User selects preferred currency
- Currency is saved to preferences
- Navigates to `/backup-account`

### 6. Backup Account Screen

Three options:
- **Google Sign-in** → Future: Link account with Google
- **Apple Sign-in** → Future: Link account with Apple  
- **Skip** → Continue without backup

All options currently lead to completing onboarding:

```dart
Future<void> _completeOnboarding(BuildContext context) async {
  try {
    final prefsService = await PreferencesService.getInstance();
    await prefsService.setOnboardingComplete(true);
    
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  } catch (e) {
    // Still navigate to home even if onboarding flag fails
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }
}
```

### 7. Home Screen

- User reaches the main app interface
- Can access all app features
- User data is persisted and available

## Data Flow

### User Creation

```dart
// UserService.createUser() creates:
User {
  id: "uuid-v4-string",           // Generated UUID
  createdAt: 1697123456789,       // Current UTC timestamp
  updatedAt: 1697123456789,       // Current UTC timestamp
  isActive: 1,                    // Active by default
  email: "",                      // Empty for anonymous users
  name: "User",                   // Default name
  profilePic: "",                 // Empty initially
}
```

**Note**: All timestamps are stored in UTC milliseconds since epoch for consistency across timezones.

### Device Record Update

```dart
// DeviceRecordService.updateUserId() updates:
Device {
  // ... existing fields
  userId: "user-uuid-string",     // Links user to device
  updatedAt: 1697123456789,       // Updated timestamp
}
```

### Persistence

Both user and device records are stored in `SharedPreferences`:

```dart
// User record stored as JSON string
"user_record": "{\"id\":\"uuid\",\"createdAt\":1697123456789,...}"

// Device record stored as JSON string  
"device_record": "{\"id\":\"device-uuid\",\"userId\":\"user-uuid\",...}"
```

## State Management

### App Launch States

1. **Fresh Install**: No user, no device → Full onboarding
2. **Returning User**: User exists → Direct to home
3. **Corrupted Data**: Handle gracefully with fallbacks

### Error Scenarios

1. **User Creation Fails**: Show error, stay on auth choice
2. **Device Update Fails**: Log error but continue flow
3. **Navigation Fails**: Fallback to home screen
4. **Storage Fails**: Continue with in-memory data

## Testing the Flow

### Manual Testing

1. **Fresh Install**:
   ```bash
   flutter clean
   flutter run
   # Should show intro screens
   ```

2. **Returning User**:
   ```bash
   # Complete onboarding once, then restart app
   # Should go directly to home screen
   ```

3. **Reset User Data**:
   ```dart
   // In debug mode, clear preferences
   await UserService.instance.clearUserData();
   await DeviceRecordService.instance.clearDeviceRecord();
   ```

### Automated Testing

```dart
// Test user creation flow
testWidgets('should create user on get started', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Navigate through intro
  await tester.tap(find.text('Get Started'));
  await tester.pumpAndSettle();
  
  // Verify user was created
  expect(UserService.instance.hasUser, true);
  expect(UserService.instance.currentUser?.id, isNotEmpty);
});
```

## Debugging

### Check User State

```dart
// Get user summary for debugging
final summary = UserUtils.getUserSummary();
print('User Summary: $summary');
```

### Check Device State

```dart
// Get device record for debugging
final deviceRecord = DeviceRecordService.instance.currentDeviceRecord;
print('Device Record: ${deviceRecord?.toJson()}');
```

### Clear All Data

```dart
// Reset everything for testing
await UserService.instance.clearUserData();
await DeviceRecordService.instance.clearDeviceRecord();
await PreferencesService.getInstance().then((prefs) => prefs.clearAll());
```

## Common Issues

1. **User not persisting**: Check SharedPreferences initialization
2. **Navigation loops**: Verify user existence checks
3. **Device not linked**: Ensure updateUserId is called after user creation
4. **Onboarding repeating**: Check onboarding completion flag

## Next Steps

After implementing this flow, consider:

1. **Authentication**: Add Firebase Auth integration
2. **Profile Setup**: Extended user profile creation
3. **Data Migration**: Handle app updates and data migrations
4. **Analytics**: Track user creation and onboarding completion
5. **A/B Testing**: Test different onboarding flows
