# Currency Selection Screen Usage Guide

## Overview

The `CurrencySelectionScreen` is now reusable and can be used in two contexts:
1. **Onboarding Flow** - During initial app setup
2. **Settings Screen** - For changing currency preferences

## Usage Examples

### 1. Onboarding Flow (Default)

```dart
// Navigate to currency selection during onboarding
Navigator.of(context).pushNamed('/currency-selection');
```

**Behavior:**
- Shows "Skip" button in app bar
- Auto-detects currency based on device locale
- "Continue" button navigates to backup account screen
- "Skip" button uses auto-detected currency and continues

### 2. Settings Screen

```dart
// Navigate to currency selection from settings
final selectedCurrency = await Navigator.of(context).pushNamed(
  '/currency-selection-settings',
  arguments: {
    'currentCurrency': 'USD', // Current user's currency
  },
);

if (selectedCurrency != null) {
  // Handle the selected currency
  print('User selected: $selectedCurrency');
  // Save to preferences, update UI, etc.
}
```

**Behavior:**
- No "Skip" button in app bar
- Pre-selects the current user's currency
- "Save" button returns selected currency to caller
- Back button cancels selection

### 3. Direct Widget Usage

```dart
// Use as a direct widget with parameters
CurrencySelectionScreen(
  isFromSettings: true,
  currentCurrency: 'EUR',
)
```

## Parameters

### `isFromSettings` (bool)
- **Default:** `false`
- **Purpose:** Determines the screen behavior and UI
- **true:** Settings mode (Save button, no Skip, returns result)
- **false:** Onboarding mode (Continue button, Skip available, navigates forward)

### `currentCurrency` (String?)
- **Default:** `null`
- **Purpose:** Pre-selects a currency when coming from settings
- **Example:** `'USD'`, `'EUR'`, `'GBP'`
- **Behavior:** If provided and `isFromSettings` is true, this currency will be highlighted

## Navigation Routes

### Standard Route
```dart
'/currency-selection' // For onboarding flow
```

### Settings Route
```dart
'/currency-selection-settings' // For settings context
```

## Return Values

### Onboarding Flow
- No return value
- Navigates to next screen in flow

### Settings Flow
- Returns `String?` with selected currency code
- Returns `null` if user cancels (back button)
- Example return values: `'USD'`, `'EUR'`, `'GBP'`, etc.

## Complete Settings Integration Example

```dart
class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String currentCurrency = 'USD'; // Load from preferences

  Future<void> _changeCurrency() async {
    final selectedCurrency = await Navigator.of(context).pushNamed(
      '/currency-selection-settings',
      arguments: {
        'currentCurrency': currentCurrency,
      },
    );

    if (selectedCurrency != null && selectedCurrency != currentCurrency) {
      setState(() {
        currentCurrency = selectedCurrency;
      });
      
      // Save to preferences
      // await _saveToPreferences(selectedCurrency);
      
      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Currency changed to $selectedCurrency'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Currency'),
            subtitle: Text(currentCurrency),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: _changeCurrency,
          ),
          // Other settings...
        ],
      ),
    );
  }
}
```

## Available Currencies

The screen now includes **120+ currencies** from around the world, organized by region:

### Major Currencies
- USD (US Dollar), EUR (Euro), GBP (British Pound), JPY (Japanese Yen)
- CHF (Swiss Franc), CAD (Canadian Dollar), AUD (Australian Dollar), CNY (Chinese Yuan)

### Regional Coverage
- **Europe:** 15+ currencies including SEK, NOK, DKK, PLN, CZK, HUF, RON, BGN, etc.
- **Asia:** 20+ currencies including INR, KRW, SGD, HKD, THB, MYR, IDR, PHP, VND, etc.
- **Middle East & Africa:** 25+ currencies including AED, SAR, EGP, NGN, ZAR, KES, etc.
- **Americas:** 20+ currencies including BRL, MXN, ARS, CLP, COP, PEN, etc.
- **Oceania:** 7+ currencies including NZD, FJD, TOP, WST, etc.
- **Cryptocurrencies:** BTC (Bitcoin), ETH (Ethereum)

### Auto-Detection Support

The screen automatically detects and pre-selects currencies based on device locale for 50+ countries/regions.

## Features

### Search Functionality
- Search by currency code (USD, EUR)
- Search by currency name (US Dollar, Euro)
- Search by country code (US, EU, GB)
- **Auto-scroll to Selected**: Automatically scrolls to selected currency when search is cleared

### Smart Scrolling
- **Auto-scroll on Load**: Automatically scrolls to auto-detected currency when screen loads
- **Scroll on Selection**: Smoothly scrolls to newly selected currency
- **Search Integration**: Returns to selected currency when search is cleared
- **Responsive Calculation**: Scroll position adapts to different screen sizes and grid layouts

### Persistent Storage
- **SharedPreferences Integration**: Automatically saves selected currency to device storage
- **Smart Loading**: Loads previously saved currency on app restart
- **Onboarding vs Settings**: Different behavior based on context:
  - **Onboarding**: Loads saved currency or auto-detects if none saved
  - **Settings**: Shows current currency passed as parameter
- **Automatic Persistence**: All currency selections are automatically saved

### Responsive Design
- **Adaptive Grid Layout**: Automatically adjusts columns based on screen width
  - Large Desktop (>1200px): 4 columns
  - Tablet/Small Desktop (800-1200px): 3 columns
  - Large Mobile/Small Tablet (600-800px): 2 columns
  - Mobile (<600px): 2 columns
- **Optimized Aspect Ratios**: Different ratios for different screen sizes
- **No Overflow Issues**: Proper spacing and sizing for all devices
- **Scrollable Grid Layout**: Smooth scrolling on all platforms

### Enhanced Display
- **Currency Symbols**: Shows both currency code and symbol (e.g., "USD $", "EUR €")
- **Country Codes**: Displays 2-letter country codes for easy identification
- **Full Currency Names**: Complete currency names with proper truncation

### Accessibility
- Proper semantic labels
- High contrast support
- Large touch targets

## Best Practices

1. **Always handle null returns** when using from settings
2. **Save currency preferences** immediately after selection
3. **Show confirmation feedback** to users
4. **Validate currency codes** before saving
5. **Provide fallback currency** if saved preference is invalid

## Migration Notes

If you're updating from the previous version:
- Old navigation still works for onboarding flow
- Add new settings route for currency changes
- Update any direct widget usage to include new parameters
- Test both onboarding and settings flows

## Technical Implementation

### Dependencies
- `flutter/material.dart` - Material Design components
- `flutter_gen/gen_l10n/app_localizations.dart` - Internationalization
- `shared_preferences` - Persistent storage for currency selection
- `../services/preferences_service.dart` - Custom preferences management service

### PreferencesService API
```dart
// Get singleton instance
final prefsService = await PreferencesService.getInstance();

// Currency operations
await prefsService.setSelectedCurrency('USD');
String? currency = prefsService.getSelectedCurrency();
bool hasCurrency = prefsService.hasCurrencySet();
await prefsService.clearSelectedCurrency();

// Onboarding operations
await prefsService.setOnboardingComplete(true);
bool isComplete = prefsService.isOnboardingComplete();

// Utility operations
await prefsService.clearAll();
Map<String, dynamic> allPrefs = prefsService.getAllPreferences();
```

### Storage Keys
- `selected_currency` - Stores the user's selected currency code
- `is_onboarding_complete` - Tracks onboarding completion status

### Persistence Flow
1. **On Currency Selection**: Automatically saves to SharedPreferences
2. **On App Launch**: Loads saved currency if available
3. **Fallback**: Auto-detects based on locale if no saved currency
4. **Settings Mode**: Uses passed current currency parameter
