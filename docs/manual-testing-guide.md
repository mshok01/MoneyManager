# Manual Testing Guide - Authentication Flow

## 🎯 Overview

This guide provides step-by-step instructions for manually testing the complete authentication flow implementation in the MoneyManager app.

## 🔄 Test Scenarios

### Scenario 1: New User - Get Started Flow

**Expected Path**: Intro → Auth Choice → Currency Selection → Backup Account → Home

1. **Launch App**
   - ✅ App should start with intro screen
   - ✅ Should see "Welcome to Money Manager" as first page

2. **Navigate Through Intro**
   - ✅ Tap right arrow to go through 4 intro pages
   - ✅ Pages should show: Welcome, Track Income/Expenses, Multiple Accounts, Custom Categories
   - ✅ On last page, tap checkmark button

3. **Authentication Choice Screen**
   - ✅ Should see "Money Manager" title
   - ✅ Should see "Take control of your finances today" subtitle
   - ✅ Should see "Get Started" primary button
   - ✅ Should see "or" divider
   - ✅ Should see "I have an account" secondary button

4. **Tap "Get Started"**
   - ✅ Should navigate to currency selection screen

5. **Currency Selection Screen**
   - ✅ Should see "Choose Your Currency" title
   - ✅ Should see "Skip" button in top-right corner
   - ✅ Should see grid of currencies with codes, names, and country codes (no flags)
   - ✅ Should see search bar at top
   - ✅ A currency should be auto-selected based on device locale
   - ✅ Continue button should be enabled (due to auto-selection)

6. **Test Auto-Detection**
   - ✅ Currency should be automatically highlighted based on device locale
   - ✅ For US devices: USD should be selected
   - ✅ For EU devices: EUR should be selected
   - ✅ For other regions: appropriate currency should be selected

7. **Select Different Currency**
   - ✅ Tap on any currency (e.g., GBP)
   - ✅ Selected currency should be highlighted with blue border
   - ✅ Previous selection should be deselected
   - ✅ Continue button should remain enabled

8. **Test Search Functionality**
   - ✅ Type "EUR" in search bar
   - ✅ Should filter to show only EUR
   - ✅ Search should work for currency code, name, and country code
   - ✅ Clear search to see all currencies again

9. **Test Skip Functionality**
   - ✅ Tap "Skip" button in top-right
   - ✅ Should navigate directly to backup account screen
   - ✅ Should use auto-detected currency as default

10. **Tap "Continue"**
    - ✅ Should navigate to backup account screen

11. **Backup Account Screen**
   - ✅ Should see "Secure Your Data" title
   - ✅ Should see "Add a backup account to sync across devices" description
   - ✅ Should see "Sign in with Google" button with Google icon
   - ✅ Should see "Sign in with Apple" button with Apple icon
   - ✅ Should see "or" divider
   - ✅ Should see "Skip for now" button
   - ✅ Should see "You can add this later in Settings" helper text

12. **Test Backup Options**
    - ✅ Tap "Sign in with Google" - should show snackbar message
    - ✅ Should navigate to home screen after message
    - OR
    - ✅ Tap "Sign in with Apple" - should show snackbar message
    - ✅ Should navigate to home screen after message
    - OR
    - ✅ Tap "Skip for now" - should navigate directly to home screen

13. **Home Screen**
    - ✅ Should see "Welcome to Money Manager!" title
    - ✅ Should see "Your financial tracking journey starts here." subtitle
    - ✅ Should see floating action button

### Scenario 2: Returning User - Sign In Flow

**Expected Path**: Intro → Auth Choice → Sign In → Home

1. **Launch App and Skip Intro**
   - ✅ Tap "Skip" button on intro screen
   - ✅ Should go directly to auth choice screen

2. **Authentication Choice Screen**
   - ✅ Tap "I have an account" button

3. **Sign In Screen**
   - ✅ Should see "Welcome Back!" title
   - ✅ Should see "Sign in to restore your data" description
   - ✅ Should see "Sign in with Google" button with "Restore your data" subtitle
   - ✅ Should see "Sign in with Apple" button with "Secure & private" subtitle
   - ✅ Should see "or" divider
   - ✅ Should see "Start Fresh" button
   - ✅ Should see "Not you? Sign in with different account" helper text

4. **Test Sign In Options**
   - ✅ Tap "Sign in with Google" - should show snackbar and navigate to home
   - OR
   - ✅ Tap "Sign in with Apple" - should show snackbar and navigate to home
   - OR
   - ✅ Tap "Start Fresh" - should navigate to currency selection screen

### Scenario 3: Navigation Testing

**Test Back Navigation**

1. **From Currency Selection**
   - ✅ Navigate to currency selection screen
   - ✅ Tap back arrow in app bar
   - ✅ Should return to auth choice screen

2. **From Sign In Screen**
   - ✅ Navigate to sign in screen
   - ✅ Tap back arrow in app bar
   - ✅ Should return to auth choice screen

3. **Test "Start Fresh" from Sign In**
   - ✅ From sign in screen, tap "Start Fresh"
   - ✅ Should navigate to currency selection screen
   - ✅ Complete currency selection flow
   - ✅ Should reach backup account screen

### Scenario 4: Settings Context Testing

**Test Currency Selection from Settings**

1. **Navigate to Settings Context**
   - ✅ Use route: `/currency-selection-settings`
   - ✅ Pass arguments: `{'currentCurrency': 'USD'}`
   - ✅ Should see "Choose Your Currency" title
   - ✅ Should NOT see "Skip" button in app bar
   - ✅ Should see "Save" button instead of "Continue"

2. **Test Pre-selection**
   - ✅ Current currency (USD) should be pre-selected
   - ✅ Save button should be enabled immediately
   - ✅ Selection should be visually highlighted

3. **Test Currency Change**
   - ✅ Select different currency (e.g., EUR)
   - ✅ Previous selection should be deselected
   - ✅ New selection should be highlighted
   - ✅ Save button should remain enabled

4. **Test Save Functionality**
   - ✅ Tap "Save" button
   - ✅ Should return to previous screen
   - ✅ Should return selected currency code

5. **Test Cancel Functionality**
   - ✅ Tap back arrow in app bar
   - ✅ Should return to previous screen
   - ✅ Should return null (no selection)

### Scenario 5: Extended Currency List

**Test New Currencies**

1. **Search for Regional Currencies**
   - ✅ Search "AED" - should find UAE Dirham
   - ✅ Search "NGN" - should find Nigerian Naira
   - ✅ Search "BTC" - should find Bitcoin
   - ✅ Search "Turkish" - should find Turkish Lira

2. **Test Currency Coverage**
   - ✅ Should see 120+ currencies total
   - ✅ Should include major, regional, and crypto currencies
   - ✅ Each currency should show: Code, Country Code, Full Name

3. **Test Auto-Detection Enhancement**
   - ✅ More countries should have auto-detection
   - ✅ Middle East countries should default to local currency
   - ✅ African countries should default to local currency
   - ✅ Asian countries should default to local currency

### Scenario 6: Error Handling

**Test Responsive Design**

1. **Resize Browser Window**
   - ✅ All screens should be scrollable
   - ✅ No content should be cut off
   - ✅ Buttons should remain accessible

2. **Test Mobile Layout**
   - ✅ Currency grid items should fit properly without overflow
   - ✅ Text should be readable at smaller sizes
   - ✅ No "BOTTOM OVERFLOWED BY X PIXELS" errors should appear
   - ✅ Grid spacing should be appropriate for mobile screens

3. **Test Responsive Grid**
   - ✅ Large desktop (>1200px): Should show 4 columns
   - ✅ Tablet/small desktop (800-1200px): Should show 3 columns
   - ✅ Large mobile (600-800px): Should show 2 columns
   - ✅ Mobile (<600px): Should show 2 columns
   - ✅ Grid items should maintain proper proportions across all sizes

4. **Test Enhanced Display**
   - ✅ Currency items should show: "USD $" format (code + symbol)
   - ✅ Country codes should be visible (US, EU, GB, etc.)
   - ✅ Full currency names should be displayed below
   - ✅ Text should not overflow or be cut off

5. **Test Auto-Scroll Functionality**
   - ✅ Screen should auto-scroll to auto-detected currency on load
   - ✅ Selecting a currency should smoothly scroll it into view
   - ✅ Search for a currency, then clear search - should scroll back to selected currency
   - ✅ Scroll animation should be smooth (500ms duration)
   - ✅ Scroll position should adapt to different screen sizes

6. **Test Currency Persistence**
   - ✅ Select a currency and continue/save - should persist to SharedPreferences
   - ✅ Close and reopen app - should load previously selected currency
   - ✅ Auto-scroll should work with loaded currency
   - ✅ Settings mode should show current currency parameter
   - ✅ Onboarding mode should load saved currency or auto-detect

2. **Test Without Network (for Google logo)**
   - ✅ Google sign-in buttons should show fallback icon
   - ✅ App should not crash or show errors

## 🐛 Known Issues (Expected)

1. **Dummy Authentication**: Google/Apple sign-in buttons show placeholder messages
2. **No Data Persistence**: Selected currency is not saved (will be implemented with Firebase)
3. **Placeholder Icons**: Using fallback icons instead of actual Google/Apple logos

## ✅ Success Criteria

- [ ] All navigation paths work correctly
- [ ] No crashes or compilation errors
- [ ] UI is responsive and scrollable
- [ ] All buttons are functional
- [ ] Proper visual feedback for user interactions
- [ ] Consistent design across all screens
- [ ] Proper localization strings display

## 🔧 Testing Environment

- **Platform**: Web (Chrome)
- **Flutter Version**: Latest stable
- **Test Device**: Desktop browser
- **Screen Sizes**: Test on various browser window sizes

## 📝 Test Results

**Date**: ___________
**Tester**: ___________
**Platform**: ___________

### Scenario 1 Results:
- [ ] Passed
- [ ] Failed - Issues: ___________

### Scenario 2 Results:
- [ ] Passed  
- [ ] Failed - Issues: ___________

### Scenario 3 Results:
- [ ] Passed
- [ ] Failed - Issues: ___________

### Scenario 4 Results:
- [ ] Passed
- [ ] Failed - Issues: ___________

### Overall Assessment:
- [ ] Ready for Firebase integration
- [ ] Needs fixes before proceeding
- [ ] Major issues found

**Notes**: ___________
