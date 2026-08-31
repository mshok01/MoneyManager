# Google Account Linking - Implementation Summary

## Overview
Changed the Google account linking flow to show appropriate dialogs based on the error type:
- **Account Already Exists Dialog**: When linking fails with `credential-already-in-use` or `email-already-in-use` errors
- **Failed to Add Recovery Account Dialog**: For all other errors

## Changes Made

### 1. **Updated Exception Class** (`lib/services/firebase_auth_linking_service.dart`)
Added `errorCode` field to `GoogleAccountAlreadyExistsException` to track the Firebase error code:

```dart
class GoogleAccountAlreadyExistsException implements Exception {
  final String message;
  final String? googleEmail;
  final String? googleUserId;
  final String? errorCode; // Firebase error code

  GoogleAccountAlreadyExistsException({
    required this.message,
    this.googleEmail,
    this.googleUserId,
    this.errorCode,
  });
}
```

### 2. **Updated `FirebaseUserDetails` Model** (`lib/models/firebase_user_details.dart`)
Added `errorCode` property to store Firebase error codes:

```dart
class FirebaseUserDetails {
  // ... existing properties
  String? errorCode; // Firebase error code when linking fails
}
```

### 3. **Updated `_linkAuthCredential()` Method** (`lib/services/firebase_auth_linking_service.dart`)
Modified to capture and store error codes when specific Firebase errors occur:

```dart
case "credential-already-in-use":
case "email-already-in-use":
  // ... existing logic
  personDetails.errorCode = ex.code; // Store the error code
  return personDetails;
```

### 4. **Updated `linkNewGoogleAccount()` Method** (`lib/services/firebase_auth_linking_service.dart`)
Modified to pass error code to exception:

```dart
throw GoogleAccountAlreadyExistsException(
  message: 'This Google account already has data in Money Manager',
  googleEmail: newUserDetails.email,
  googleUserId: newUserDetails.firebaseUserUids.isNotEmpty
      ? newUserDetails.firebaseUserUids.first
      : null,
  errorCode: newUserDetails.errorCode, // Pass error code
);
```

### 5. **Updated `_onGoogleSignIn()` Method** (`lib/screens/backup_account_screen.dart`)
Changed to check error code and show appropriate dialog:

```dart
on GoogleAccountAlreadyExistsException catch (e) {
  if (_isAccountExistsError(e.errorCode)) {
    // Show account exists dialog
    _showAccountExistsDialog(context, e);
  } else {
    // Show failed dialog for other errors
    _showFailedToAddRecoveryAccountDialog(context);
  }
}
```

### 6. **New Helper Method** (`lib/screens/backup_account_screen.dart`)
Added `_isAccountExistsError()` to check if error is account-related:

```dart
bool _isAccountExistsError(String? errorCode) {
  return errorCode == 'credential-already-in-use' ||
      errorCode == 'email-already-in-use';
}
```

### 7. **New Failed Dialog Method** (`lib/screens/backup_account_screen.dart`)
Added `_showFailedToAddRecoveryAccountDialog()` for generic errors:
- Title: "Failed to Add Recovery Account"
- Message: Generic error message
- Two buttons:
  - "Skip" - Skip recovery account and continue
  - "Try Again" - Retry the Google sign-in process

### 8. **New Localization Strings** (`lib/l10n/app_en.arb`)
Added three new strings:
- `failedToAddRecoveryAccount`: "Failed to Add Recovery Account"
- `failedToAddRecoveryAccountMessage`: Generic error message
- `tryAgain`: "Try Again"

## Error Handling Flow

```
User clicks "Sign in with Google"
    ↓
Google authentication succeeds
    ↓
System attempts to link account
    ↓
Error occurs?
    ├─ credential-already-in-use OR email-already-in-use
    │   ↓
    │   Show "Account Already Exists" Dialog
    │   ├─ "Proceed Without Restore" → Complete onboarding
    │   └─ "Restore Data" → Restore data from Google account
    │
    └─ Other errors
        ↓
        Show "Failed to Add Recovery Account" Dialog
        ├─ "Skip" → Complete onboarding
        └─ "Try Again" → Retry Google sign-in
```

## Benefits

✅ **Specific Error Handling**: Different dialogs for different error scenarios
✅ **User Control**: Users can choose to restore data or skip recovery account
✅ **Clear Communication**: Appropriate messages for each error type
✅ **Retry Capability**: Users can retry failed operations
✅ **Better UX**: Explicit dialogs instead of automatic behavior
✅ **Maintainability**: Error codes tracked for debugging and analytics

## Files Modified

1. `lib/services/firebase_auth_linking_service.dart` - Added errorCode to exception and updated linking logic
2. `lib/models/firebase_user_details.dart` - Added errorCode property
3. `lib/screens/backup_account_screen.dart` - Updated UI flow with error checking and new dialog
4. `lib/l10n/app_en.arb` - Added new localization strings

