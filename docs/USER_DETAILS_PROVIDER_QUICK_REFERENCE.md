# User Details Provider - Quick Reference

## Setup

### 1. Import the Provider
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_details_provider.dart';
```

### 2. Use ConsumerWidget or ConsumerStatefulWidget
```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Your code here
  }
}
```

## Reading User Data

### Get Current User Object
```dart
final currentUser = ref.watch(currentUserProvider);
if (currentUser != null) {
  print('User: ${currentUser.name}');
}
```

### Get Specific User Properties
```dart
final userId = ref.watch(userIdProvider);
final email = ref.watch(userEmailProvider);
final name = ref.watch(userNameProvider);
final profilePic = ref.watch(userProfilePicProvider);
final currencyCode = ref.watch(userCurrencyCodeProvider);
final currencyName = ref.watch(userCurrencyNameProvider);
```

### Check User Status
```dart
final isLoggedIn = ref.watch(isUserLoggedInProvider);
final isActive = ref.watch(isUserActiveProvider);
final hasValidEmail = ref.watch(hasValidEmailProvider);
final hasName = ref.watch(hasUserNameProvider);
final isValid = ref.watch(isCurrentUserValidProvider);
final hasCurrency = ref.watch(hasUserCurrencyProvider);
```

## Modifying User Data

### Create a New User
```dart
try {
  final newUser = await ref.read(createUserProvider((
    email: 'user@example.com',
    name: 'John Doe',
    profilePic: 'https://example.com/pic.jpg',
    currencyCode: 'USD',
    currencyName: 'US Dollar',
  )).future);
  print('User created: ${newUser.id}');
} catch (e) {
  print('Error creating user: $e');
}
```

### Update User
```dart
try {
  final updatedUser = await ref.read(updateUserProvider((
    name: 'Jane Doe',
    email: 'jane@example.com',
    currencyCode: 'EUR',
  )).future);
  print('User updated');
} catch (e) {
  print('Error updating user: $e');
}
```

### Delete User
```dart
try {
  await ref.read(deleteUserProvider.future);
  print('User deleted');
} catch (e) {
  print('Error deleting user: $e');
}
```

### Refresh User Data
```dart
try {
  await ref.read(refreshUserProvider.future);
  print('User data refreshed');
} catch (e) {
  print('Error refreshing user: $e');
}
```

### Save User from API Response
```dart
try {
  final userFromApi = User(...); // From API response
  await ref.read(saveUserFromResponseProvider(userFromApi).future);
  print('User saved from API');
} catch (e) {
  print('Error saving user: $e');
}
```

### Update User from API Response
```dart
try {
  final userFromApi = User(...); // From API response
  await ref.read(updateCurrentUserProvider(userFromApi).future);
  print('User updated from API');
} catch (e) {
  print('Error updating user: $e');
}
```

## Listening to Changes

### Watch for User Changes
```dart
ref.listen(currentUserProvider, (previous, next) {
  if (previous != next) {
    print('User changed!');
    // Perform actions when user changes
  }
});
```

### Conditional Rendering Based on User
```dart
final currentUser = ref.watch(currentUserProvider);

return currentUser == null
    ? const LoginScreen()
    : const HomeScreen();
```

## Common Patterns

### Display User Profile
```dart
final currentUser = ref.watch(currentUserProvider);

if (currentUser == null) {
  return const Text('No user logged in');
}

return Column(
  children: [
    Text(currentUser.name),
    Text(currentUser.email),
    Text('Currency: ${currentUser.currencyCode}'),
  ],
);
```

### Conditional UI Based on User Status
```dart
final isLoggedIn = ref.watch(isUserLoggedInProvider);
final hasValidEmail = ref.watch(hasValidEmailProvider);

if (!isLoggedIn) {
  return const Text('Please log in');
}

if (!hasValidEmail) {
  return const Text('Please verify your email');
}

return const Text('Welcome!');
```

### Handle User Operations with Loading State
```dart
final deleteUserAsync = ref.watch(deleteUserProvider);

return deleteUserAsync.when(
  data: (_) => const Text('User deleted'),
  loading: () => const CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

## Tips & Best Practices

1. **Always use `ref.watch()` in build methods** to get reactive updates
2. **Use `ref.read()` for one-time operations** like button clicks
3. **Handle errors appropriately** with try-catch blocks
4. **Use `.future` suffix** when reading FutureProviders
5. **Invalidate providers after mutations** (automatically done by action providers)
6. **Prefer specific providers** over `currentUserProvider` when you only need one field
7. **Use `ref.listen()` for side effects** like navigation or notifications

## Migration from UserService

### Before (Direct Service Access)
```dart
final currentUser = UserService.instance.currentUser;
final email = currentUser?.email ?? '';
```

### After (Provider-Based)
```dart
final currentUser = ref.watch(currentUserProvider);
final email = ref.watch(userEmailProvider);
```

## Troubleshooting

### User data not updating?
- Make sure you're using `ref.watch()` not `ref.read()`
- Check that the widget is a `ConsumerWidget` or `ConsumerStatefulWidget`

### Getting null values?
- Check if user is logged in with `ref.watch(isUserLoggedInProvider)`
- Use null-coalescing operator: `currentUser?.name ?? 'Unknown'`

### Errors during operations?
- Wrap operations in try-catch blocks
- Check the error message for details
- Ensure UserService is initialized before using providers

