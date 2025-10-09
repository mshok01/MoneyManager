# Authentication Flow Documentation

## 🎯 Overview

MoneyManager uses a progressive disclosure approach for user authentication, prioritizing quick access while offering optional backup and sync capabilities. The flow is designed to minimize friction while providing clear value propositions for each authentication option.

## 🔄 Complete User Flow

### 1. App Launch → Intro Screen
- User sees the existing 4-page intro carousel
- Pages showcase: Welcome, Track Income/Expenses, Multiple Accounts, Custom Categories
- User can skip or navigate through all pages
- Final page leads to authentication choice

### 2. Authentication Choice Screen
**Layout**: Simple binary choice
```
┌─────────────────────────────┐
│     💰 Money Manager        │
│   Take control of your      │
│      finances today         │
│                             │
│  ┌─────────────────────┐    │
│  │    Get Started      │    │ ← Primary CTA
│  └─────────────────────┘    │
│                             │
│     ─── or ───              │
│                             │
│  ┌─────────────────────┐    │
│  │  I have an account  │    │ ← Secondary option
│  └─────────────────────┘    │
└─────────────────────────────┘
```

**User Actions**:
- **"Get Started"** → Proceeds to currency selection (anonymous flow)
- **"I have an account"** → Shows Google/Apple sign-in options

### 3A. New User Flow (Anonymous)

#### Step 1: Currency Selection
```
┌─────────────────────────────┐
│    Choose Your Currency     │
│                             │
│  🇺🇸 USD  🇪🇺 EUR  🇬🇧 GBP  │
│  🇮🇳 INR  🇯🇵 JPY  🇨🇦 CAD  │
│  🇦🇺 AUD  🇨🇭 CHF  🇨🇳 CNY  │
│                             │
│  ┌─────────────────────┐    │
│  │      🔍 Search      │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │     Continue        │    │
│  └─────────────────────┘    │
└─────────────────────────────┘
```

#### Step 2: Add Backup Account (NEW)
**After currency selection, before home screen**
```
┌─────────────────────────────┐
│    Secure Your Data        │
│                             │
│   💾 Add a backup account   │
│   to sync across devices    │
│                             │
│  ┌─────────────────────┐    │
│  │  📱 Google Sign-in  │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │  🍎 Apple Sign-in   │    │
│  └─────────────────────┘    │
│                             │
│     ─── or ───              │
│                             │
│  ┌─────────────────────┐    │
│  │  Skip for now       │    │ ← Skip option
│  └─────────────────────┘    │
│                             │
│  "You can add this later    │
│   in Settings"              │
└─────────────────────────────┘
```

#### Step 3: Home Screen
- User reaches main app interface
- Anonymous Firebase account created in background
- Currency preference saved locally

### 3B. Returning User Flow

#### Step 1: Sign-in Options
```
┌─────────────────────────────┐
│      Welcome Back!          │
│                             │
│  ┌─────────────────────┐    │
│  │  📱 Google Sign-in  │    │
│  │  Restore your data  │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │  🍎 Apple Sign-in   │    │
│  │  Secure & private   │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │   Start Fresh       │    │ ← Fallback to anonymous
│  └─────────────────────┘    │
└─────────────────────────────┘
```

#### Step 2A: Successful Authentication
- User profile detected
- Show restoration progress
- Navigate to home with existing data

#### Step 2B: Account Detection
**If user has existing cloud backup**:
```
┌─────────────────────────────┐
│    Account Found!           │
│                             │
│  👤 John Doe                │
│  📧 john@example.com        │
│                             │
│  💾 Last backup: 2 days ago │
│                             │
│  ┌─────────────────────┐    │
│  │  Restore My Data    │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │   Start Fresh       │    │
│  └─────────────────────┘    │
│                             │
│  "Not you? Sign in with     │
│   different account"        │
└─────────────────────────────┘
```

## 🎨 Design Principles

### Visual Hierarchy
1. **Primary Action**: Large, prominent button for main flow
2. **Secondary Actions**: Smaller, less prominent alternatives
3. **Tertiary Actions**: Text links for edge cases

### Progressive Disclosure
- **Step 1**: Simple binary choice (start vs. existing account)
- **Step 2**: Specific options based on choice
- **Step 3**: Additional context and alternatives

### Value Communication
- **Anonymous**: "Start immediately, no setup required"
- **Google**: "Backup and sync across devices"
- **Apple**: "Secure and private sign-in"

## 🔧 Technical Implementation

### Firebase Authentication
- **Anonymous**: `signInAnonymously()`
- **Google**: `signInWithGoogle()`
- **Apple**: `signInWithApple()`

### Account Linking
- Anonymous accounts can be linked to Google/Apple later
- Use `linkWithCredential()` for seamless upgrade

### Data Migration
- Local data preserved during account linking
- Cloud data merged with local data when restoring

### State Management
```dart
enum AuthState {
  initial,
  anonymous,
  authenticated,
  linking,
  restoring
}
```

## 📱 Screen Transitions

```
IntroScreen → AuthChoiceScreen → [Currency/SignIn] → BackupScreen → HomeScreen
     ↓              ↓                    ↓              ↓           ↓
  (existing)    (new screen)      (currency new)   (new screen)  (existing)
```

## 🎯 Success Metrics

### User Experience
- **Time to first transaction**: < 2 minutes from app launch
- **Authentication completion rate**: > 80% for primary flow
- **Backup adoption**: > 30% of anonymous users add backup within 7 days

### Technical
- **Authentication errors**: < 2%
- **Data sync success**: > 99%
- **Account linking success**: > 95%

## 🔄 Future Enhancements

1. **Social Proof**: Show number of users or transactions
2. **Onboarding Tips**: Contextual hints during first use
3. **Smart Defaults**: Pre-select currency based on location
4. **Biometric Auth**: Face ID/Fingerprint for quick access
5. **Guest Mode**: Temporary access without any account creation
