# Google Account Linking - Test Checklist

## Test Scenarios

### Scenario 1: Successful Google Account Linking
**Precondition**: User is logged in anonymously
**Steps**:
1. Click "Sign in with Google"
2. Select a Google account that has no previous data
3. Verify loading dialog appears
4. Verify success message appears
5. Verify user is redirected to home screen

**Expected Result**: ✅ Account linked successfully, onboarding completed

---

### Scenario 2: Google Account Already Exists (credential-already-in-use)
**Precondition**: User is logged in anonymously, Google account already has data
**Steps**:
1. Click "Sign in with Google"
2. Select a Google account that already has data
3. Verify loading dialog appears
4. Verify "Account Already Exists" dialog appears with:
   - Title: "Account Already Exists"
   - Message explaining the situation
   - "Proceed Without Restore" button
   - "Restore Data" button

**Expected Result**: ✅ Dialog appears with correct message and buttons

---

### Scenario 2a: Proceed Without Restore
**Precondition**: "Account Already Exists" dialog is displayed
**Steps**:
1. Click "Proceed Without Restore" button
2. Verify dialog closes
3. Verify user is redirected to home screen
4. Verify current anonymous account data is preserved

**Expected Result**: ✅ Onboarding completed, current account preserved

---

### Scenario 2b: Restore Data
**Precondition**: "Account Already Exists" dialog is displayed
**Steps**:
1. Click "Restore Data" button
2. Verify dialog closes
3. Verify loading dialog appears
4. Verify success message appears
5. Verify user is redirected to home screen
6. Verify previous Google account data is restored

**Expected Result**: ✅ Data restored from Google account, onboarding completed

---

### Scenario 3: Google Account Already Exists (email-already-in-use)
**Precondition**: User is logged in anonymously, email already linked with different provider
**Steps**:
1. Click "Sign in with Google"
2. Select a Google account with email already linked to another provider
3. Verify "Account Already Exists" dialog appears

**Expected Result**: ✅ Same dialog as Scenario 2 (credential-already-in-use)

---

### Scenario 4: Other Linking Errors
**Precondition**: User is logged in anonymously
**Steps**:
1. Click "Sign in with Google"
2. Simulate a network error or other unexpected error
3. Verify loading dialog appears
4. Verify "Failed to Add Recovery Account" dialog appears with:
   - Title: "Failed to Add Recovery Account"
   - Generic error message
   - "Skip" button
   - "Try Again" button

**Expected Result**: ✅ Failed dialog appears with correct message and buttons

---

### Scenario 4a: Skip Failed Recovery
**Precondition**: "Failed to Add Recovery Account" dialog is displayed
**Steps**:
1. Click "Skip" button
2. Verify dialog closes
3. Verify user is redirected to home screen
4. Verify current anonymous account is preserved

**Expected Result**: ✅ Onboarding completed, current account preserved

---

### Scenario 4b: Retry Failed Recovery
**Precondition**: "Failed to Add Recovery Account" dialog is displayed
**Steps**:
1. Click "Try Again" button
2. Verify dialog closes
3. Verify loading dialog appears
4. Verify Google sign-in flow restarts

**Expected Result**: ✅ Google sign-in flow restarted

---

## Code Coverage

- [ ] `GoogleAccountAlreadyExistsException` class with errorCode field
- [ ] `FirebaseUserDetails.errorCode` property
- [ ] `_linkAuthCredential()` error code capture
- [ ] `linkNewGoogleAccount()` exception throwing with errorCode
- [ ] `_isAccountExistsError()` helper method
- [ ] `_showAccountExistsDialog()` method
- [ ] `_showFailedToAddRecoveryAccountDialog()` method
- [ ] `_onGoogleSignIn()` error handling logic
- [ ] Localization strings generation

## Localization Verification

- [ ] `accountAlreadyExists` string displays correctly
- [ ] `accountAlreadyExistsMessage` string displays correctly
- [ ] `restoreData` button text displays correctly
- [ ] `proceedWithoutRestore` button text displays correctly
- [ ] `failedToAddRecoveryAccount` string displays correctly
- [ ] `failedToAddRecoveryAccountMessage` string displays correctly
- [ ] `tryAgain` button text displays correctly
- [ ] `skip` button text displays correctly (existing string)

## Error Code Verification

- [ ] `credential-already-in-use` error code is captured
- [ ] `email-already-in-use` error code is captured
- [ ] Error codes are passed through exception
- [ ] Error codes are checked in `_isAccountExistsError()`
- [ ] Other error codes show failed dialog

## UI/UX Verification

- [ ] Loading dialogs appear and disappear correctly
- [ ] Dialogs are not dismissible by tapping outside
- [ ] Button styling is consistent with app theme
- [ ] Text is readable and properly formatted
- [ ] Navigation works correctly after each action
- [ ] No console errors or warnings

## Edge Cases

- [ ] User cancels Google sign-in (should not show any dialog)
- [ ] Network error during linking (should show failed dialog)
- [ ] User closes app during linking (should handle gracefully)
- [ ] Multiple rapid clicks on buttons (should not cause issues)
- [ ] Switching between accounts (should work correctly)

