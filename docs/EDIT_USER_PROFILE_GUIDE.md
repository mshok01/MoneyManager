# Edit User Profile Guide

## Overview

The Money Manager app now provides comprehensive ways to edit user profile information including name and profile picture. This guide covers all available methods and implementation details.

## 📱 User Interface Methods

### Method 1: Edit Button in User Profile Screen

**Location**: User Profile Screen (accessible from Settings)

**Steps**:
1. Navigate to **Settings** → **User Profile**
2. Click the **Edit** button (pencil icon) in the top-right corner of the AppBar
3. The Edit Profile Screen will open

**What You Can Edit**:
- ✏️ User Name
- 🖼️ Profile Picture

### Method 2: Edit Profile Screen

**Location**: `lib/screens/edit_user_profile_screen.dart`

**Features**:
- **Profile Picture Selection**: Tap the profile picture to choose from 10 predefined icons
- **Name Input**: Text field to update your name
- **Save Button**: Saves changes and returns to User Profile Screen
- **Loading State**: Shows progress indicator while saving
- **Error Handling**: Displays error messages if update fails

**Profile Picture Options**:
- 💼 Wallet
- 🏠 Home
- 🏢 Business
- 💰 Savings
- 💳 Credit Card
- 🏦 Bank
- 🛒 Shopping
- 🚗 Vehicle
- 👤 Avatar
- ⭐ Star

## 🔧 Implementation Details

### Edit User Profile Screen Component

```dart
class EditUserProfileScreen extends ConsumerStatefulWidget {
  final User user;
  
  const EditUserProfileScreen({
    super.key,
    required this.user,
  });
}
```

**Key Features**:
- Receives current user data as parameter
- Pre-fills form with existing user information
- Validates input before saving
- Shows loading state during save operation
- Handles errors gracefully

### State Management

The edit screen uses the **User Details Provider** for state management:

```dart
// Update user with new data
await ref.read(updateUserProvider((
  email: null,
  name: _nameController.text.trim(),
  profilePic: _selectedProfilePic,
  isActive: null,
  currencyCode: null,
  currencyName: null,
)).future);
```

**Provider Behavior**:
- Automatically invalidates `currentUserProvider` after update
- Ensures UI reflects changes immediately
- Handles offline-first pattern (saves locally, syncs to backend)

### Navigation

```dart
// From User Profile Screen
static void _navigateToEditProfile(BuildContext context, WidgetRef ref) {
  final currentUser = ref.read(currentUserProvider);
  if (currentUser != null) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditUserProfileScreen(user: currentUser),
      ),
    );
  }
}
```

## 📋 Validation Rules

### Name Field
- ✅ **Required**: Cannot be empty
- ✅ **Trimmed**: Leading/trailing whitespace removed
- ✅ **Min Length**: At least 1 character (after trim)

### Profile Picture
- ✅ **Optional**: Can be empty
- ✅ **Predefined Options**: Choose from 10 icon options
- ✅ **Removable**: Can clear selection

## 🎨 UI Components

### Profile Picture Selector

**Modal Bottom Sheet** with:
- Grid of 10 icon options (4 columns)
- Visual selection indicator (border highlight)
- Remove button to clear selection
- Done button to confirm

**Features**:
- Smooth animations
- Color-coded icons
- Touch-friendly sizing
- Responsive layout

### Name Input Field

**Material TextField** with:
- Label: "Name"
- Hint: "e.g., John Doe"
- Prefix Icon: Person icon
- Outline border
- Validation feedback

### Save Button

**Elevated Button** with:
- Icon: Save icon (or loading spinner)
- Label: "Save" or "Saving..."
- Disabled state during save
- Full width layout

## 🔄 Data Flow

```
User Profile Screen
        ↓
    [Edit Button]
        ↓
Edit User Profile Screen
        ↓
    [Select Picture] → Profile Picture Selector
        ↓
    [Enter Name]
        ↓
    [Save Button]
        ↓
updateUserProvider
        ↓
UserService.updateUser()
        ↓
Backend API
        ↓
currentUserProvider (invalidated)
        ↓
User Profile Screen (updated)
```

## 💾 Offline-First Pattern

The edit functionality follows the offline-first architecture:

1. **Local Save**: Changes saved to local database immediately
2. **Async Sync**: Backend API called asynchronously
3. **Retry Logic**: Failed operations retried when app reopens
4. **No UI Blocking**: User can continue using app during sync

## 🛠️ Developer Usage

### Programmatic Navigation

```dart
// Navigate to edit profile from any screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => EditUserProfileScreen(user: currentUser),
  ),
);
```

### Listening to Profile Changes

```dart
// In any ConsumerWidget
ref.listen(currentUserProvider, (previous, next) {
  if (previous != next) {
    print('User profile updated!');
    // Perform actions on profile change
  }
});
```

### Accessing Updated User Data

```dart
// Watch for changes
final currentUser = ref.watch(currentUserProvider);

// Get specific fields
final userName = ref.watch(userNameProvider);
final profilePic = ref.watch(userProfilePicProvider);
```

## 📝 Localization

All UI strings are localized in `lib/l10n/app_en.arb`:

- `editUserProfile`: "Edit Profile"
- `profileUpdatedSuccessfully`: "Profile updated successfully"
- `saving`: "Saving..."
- `error`: "Error"
- `chooseProfilePicture`: "Choose Profile Picture"
- `tapToSelectPicture`: "Tap to select picture"
- `name`: "Name"
- `nameHint`: "e.g., PayPal, Venmo"
- `pleaseEnterName`: "Please enter a name"
- `save`: "Save"
- `done`: "Done"
- `remove`: "Remove"
- `edit`: "Edit"

## ⚠️ Error Handling

### Validation Errors

```dart
if (_nameController.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.pleaseEnterName)),
  );
  return;
}
```

### Update Errors

```dart
try {
  await ref.read(updateUserProvider(...).future);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('${l10n.error}: $e')),
  );
}
```

## 🧪 Testing

### Unit Tests

```dart
test('Edit profile with valid name', () async {
  // Test name update
});

test('Edit profile with profile picture', () async {
  // Test profile picture update
});

test('Validation prevents empty name', () async {
  // Test validation
});
```

### Widget Tests

```dart
testWidgets('Edit button navigates to edit screen', (tester) async {
  // Test navigation
});

testWidgets('Profile picture selector works', (tester) async {
  // Test picture selection
});
```

## 🚀 Future Enhancements

Potential improvements for future versions:

1. **Image Upload**: Allow uploading custom profile pictures
2. **Camera Capture**: Take photo directly from camera
3. **Email Editing**: Allow users to change email
4. **Currency Update**: Change currency from profile screen
5. **Undo Changes**: Revert to previous values
6. **Batch Updates**: Update multiple fields at once
7. **Profile Validation**: Email verification on change
8. **Change History**: Track profile changes over time

## 📚 Related Documentation

- **User Details Provider**: `docs/USER_DETAILS_PROVIDER_README.md`
- **User Profile Screen**: `lib/screens/user_profile_screen.dart`
- **Edit User Profile Screen**: `lib/screens/edit_user_profile_screen.dart`
- **User Service**: `lib/services/user_service.dart`
- **Localization**: `lib/l10n/app_en.arb`

## 🎯 Quick Reference

| Task | Location | Method |
|------|----------|--------|
| Edit Name | Edit Profile Screen | Text Input Field |
| Edit Picture | Edit Profile Screen | Tap Picture + Modal |
| Save Changes | Edit Profile Screen | Save Button |
| Navigate to Edit | User Profile Screen | Edit Button (AppBar) |
| View Changes | User Profile Screen | Auto-updates |

---

**Last Updated**: 2025-10-23  
**Status**: ✅ Complete and Production Ready

