# Currency Settings Implementation

## Overview

The currency settings in the settings screen now pull from the user record's currency field instead of just preferences. This ensures consistency between the user's profile and the displayed currency.

## Changes Made

### 1. Settings Screen (`lib/screens/settings_screen.dart`)

**Before:**
- Currency was loaded from `PreferencesService.getSelectedCurrency()`
- Only currency code was displayed

**After:**
- Currency is loaded from `UserService.instance.currentUser.currencyCode` and `currencyName`
- Falls back to preferences if user doesn't have currency set
- Displays currency name if available, otherwise currency code
- When currency is changed, updates the user record instead of just preferences

### 2. Currency Selection Screen (`lib/screens/currency_selection_screen.dart`)

**Before:**
- Only saved to preferences
- Returned just currency code when called from settings

**After:**
- Updates both preferences (for backward compatibility) and user record
- Returns both currency code and name when called from settings
- Ensures user record is always in sync with selected currency

### 3. Key Methods Updated

#### Settings Screen
- `_initializePreferences()`: Now gets currency from user record first
- `_changeCurrency()`: Updates user record with both code and name
- UI: Shows currency name instead of just code

#### Currency Selection Screen
- `_updateCurrency()`: New helper method that updates both preferences and user record
- `_onContinue()`, `_onSkip()`, `_onSave()`: All use the new helper method
- Returns structured data `{code: 'USD', name: 'US Dollar'}` for settings

## Manual Testing

### Test 1: New User Flow
1. Start the app fresh (clear app data)
2. Go through onboarding and select a currency (e.g., EUR - Euro)
3. Navigate to Settings
4. Verify that "Euro" is displayed in the currency setting (not just "EUR")

### Test 2: Currency Change from Settings
1. Open Settings
2. Tap on Currency setting
3. Select a different currency (e.g., GBP - British Pound)
4. Tap Save
5. Verify that "British Pound" is now displayed in settings
6. Restart the app and check that the currency persists

### Test 3: User Record Consistency
1. Create a user with a specific currency
2. Check that the settings screen shows the user's currency
3. Change currency from settings
4. Verify that the user record is updated (currency should persist across app restarts)

## Technical Details

### Data Flow
1. **User Creation**: Currency is set in user record during creation
2. **Settings Display**: Currency is read from user record, falls back to preferences
3. **Currency Change**: Updates both user record and preferences
4. **Persistence**: User record is saved to database, preferences to SharedPreferences

### Backward Compatibility
- Preferences are still updated for backward compatibility
- If user record doesn't have currency, falls back to preferences
- Existing users will continue to work without issues

### Error Handling
- If user record update fails, error is shown to user
- Preferences are still updated as fallback
- App continues to function even if database operations fail

## Code Structure

```dart
// Settings Screen - Get currency from user record
final currentUser = UserService.instance.currentUser;
if (currentUser != null) {
  _currentCurrency = currentUser.currencyCode;
  _currentCurrencyName = currentUser.currencyName;
}

// Settings Screen - Update user record
await UserService.instance.updateUser(
  currencyCode: selectedCurrencyCode,
  currencyName: selectedCurrencyName,
);

// Currency Selection - Update both preferences and user record
await _preferencesService?.setSelectedCurrency(currencyCode);
await UserService.instance.updateUser(
  currencyCode: currencyObj.code,
  currencyName: currencyObj.name,
);
```

## Benefits

1. **Consistency**: Currency is always in sync between user profile and settings
2. **Better UX**: Shows currency names instead of just codes
3. **Data Integrity**: User record is the single source of truth
4. **Backward Compatibility**: Existing functionality continues to work
5. **Error Resilience**: Graceful fallbacks if operations fail
