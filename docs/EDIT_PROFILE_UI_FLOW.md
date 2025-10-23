# Edit User Profile - UI Flow & Wireframes

## 📱 Screen Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    USER PROFILE SCREEN                      │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ User Profile                              [✎ Edit]  │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                                                     │  │
│  │              ┌──────────────────┐                  │  │
│  │              │   Profile Pic    │                  │  │
│  │              │   (120x120)      │                  │  │
│  │              └──────────────────┘                  │  │
│  │                                                     │  │
│  │              John Doe                              │  │
│  │                                                     │  │
│  │              john@example.com                      │  │
│  │                                                     │  │
│  │  ┌──────────────────────────────────────────────┐ │  │
│  │  │ Add Backup Account                           │ │  │
│  │  └──────────────────────────────────────────────┘ │  │
│  │                                                     │  │
│  │  ┌──────────────────────────────────────────────┐ │  │
│  │  │ [Logout]                                     │ │  │
│  │  └──────────────────────────────────────────────┘ │  │
│  │                                                     │  │
│  │  ┌──────────────────────────────────────────────┐ │  │
│  │  │ [Delete Account]                             │ │  │
│  │  └──────────────────────────────────────────────┘ │  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓ [Click Edit]
┌─────────────────────────────────────────────────────────────┐
│                  EDIT PROFILE SCREEN                        │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ Edit Profile                                    [←] │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                                                     │  │
│  │              ┌──────────────────┐                  │  │
│  │              │   Profile Pic    │                  │  │
│  │              │   (120x120)      │                  │  │
│  │              │   [Camera Icon]  │                  │  │
│  │              └──────────────────┘                  │  │
│  │                                                     │  │
│  │         Tap to select picture                      │  │
│  │                                                     │  │
│  │  ┌──────────────────────────────────────────────┐ │  │
│  │  │ Name                                         │ │  │
│  │  │ [👤] John Doe                               │ │  │
│  │  └──────────────────────────────────────────────┘ │  │
│  │                                                     │  │
│  │  ┌──────────────────────────────────────────────┐ │  │
│  │  │ [💾 Save]                                    │ │  │
│  │  └──────────────────────────────────────────────┘ │  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓ [Tap Picture]
┌─────────────────────────────────────────────────────────────┐
│              PROFILE PICTURE SELECTOR MODAL                 │
│                                                             │
│  Choose Profile Picture                                    │
│                                                             │
│  ┌──────┬──────┬──────┬──────┐                            │
│  │ 💼   │ 🏠   │ 🏢   │ 💰   │                            │
│  │Wallet│ Home │Biz   │Savings                            │
│  ├──────┼──────┼──────┼──────┤                            │
│  │ 💳   │ 🏦   │ 🛒   │ 🚗   │                            │
│  │Credit│ Bank │Shop  │Vehicle                            │
│  ├──────┼──────┼──────┼──────┤                            │
│  │ 👤   │ ⭐   │      │      │                            │
│  │Avatar│ Star │      │      │                            │
│  └──────┴──────┴──────┴──────┘                            │
│                                                             │
│  ┌──────────────────┬──────────────────┐                  │
│  │ [Remove]         │ [Done]           │                  │
│  └──────────────────┴──────────────────┘                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓ [Select Icon]
                    (Modal Closes)
                            ↓ [Click Save]
┌─────────────────────────────────────────────────────────────┐
│                  SAVING STATE                               │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                                                     │  │
│  │              ┌──────────────────┐                  │  │
│  │              │   Profile Pic    │                  │  │
│  │              │   (120x120)      │                  │  │
│  │              │   [Camera Icon]  │                  │  │
│  │              └──────────────────┘                  │  │
│  │                                                     │  │
│  │  ┌──────────────────────────────────────────────┐ │  │
│  │  │ Name                                         │ │  │
│  │  │ [👤] John Doe                               │ │  │
│  │  └──────────────────────────────────────────────┘ │  │
│  │                                                     │  │
│  │  ┌──────────────────────────────────────────────┐ │  │
│  │  │ [⟳ Saving...]                               │ │  │
│  │  └──────────────────────────────────────────────┘ │  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓ [Save Complete]
┌─────────────────────────────────────────────────────────────┐
│                  SUCCESS MESSAGE                            │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ ✓ Profile updated successfully                      │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  (Auto-dismiss after 2 seconds)                            │
│  (Navigate back to User Profile Screen)                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓ [Auto-navigate]
┌─────────────────────────────────────────────────────────────┐
│                    USER PROFILE SCREEN                      │
│                    (UPDATED WITH NEW DATA)                  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │ User Profile                              [✎ Edit]  │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐  │
│  │                                                     │  │
│  │              ┌──────────────────┐                  │  │
│  │              │   NEW Profile    │                  │  │
│  │              │   Picture (⭐)   │                  │  │
│  │              └──────────────────┘                  │  │
│  │                                                     │  │
│  │              Jane Doe (UPDATED)                    │  │
│  │                                                     │  │
│  │              jane@example.com                      │  │
│  │                                                     │  │
│  └─────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🎨 Component Details

### User Profile Screen - AppBar
```
┌─────────────────────────────────────────────────────────┐
│ ← User Profile                              [✎ Edit]    │
└─────────────────────────────────────────────────────────┘
```

**Elements**:
- Back button (if navigated from elsewhere)
- Title: "User Profile"
- Edit button (pencil icon) - only if user exists

### Edit Profile Screen - Profile Picture Section
```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│              ┌──────────────────┐                       │
│              │   Profile Pic    │                       │
│              │   (120x120)      │                       │
│              │   [Camera Icon]  │                       │
│              └──────────────────┘                       │
│                                                         │
│         Tap to select picture                           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Features**:
- Circular profile picture (120x120)
- Camera icon overlay (bottom-right)
- Tap to open selector
- Helper text below

### Edit Profile Screen - Name Input
```
┌─────────────────────────────────────────────────────────┐
│ Name                                                    │
│ ┌───────────────────────────────────────────────────┐  │
│ │ [👤] John Doe                                    │  │
│ └───────────────────────────────────────────────────┘  │
│ e.g., PayPal, Venmo                                    │
└─────────────────────────────────────────────────────────┘
```

**Features**:
- Label: "Name"
- Prefix icon: Person
- Outline border
- Hint text
- Full width

### Profile Picture Selector Modal
```
┌─────────────────────────────────────────────────────────┐
│ Choose Profile Picture                                  │
│                                                         │
│ ┌──────┬──────┬──────┬──────┐                          │
│ │ 💼   │ 🏠   │ 🏢   │ 💰   │                          │
│ │Wallet│ Home │Biz   │Savings                          │
│ ├──────┼──────┼──────┼──────┤                          │
│ │ 💳   │ 🏦   │ 🛒   │ 🚗   │                          │
│ │Credit│ Bank │Shop  │Vehicle                          │
│ ├──────┼──────┼──────┼──────┤                          │
│ │ 👤   │ ⭐   │      │      │                          │
│ │Avatar│ Star │      │      │                          │
│ └──────┴──────┴──────┴──────┘                          │
│                                                         │
│ ┌──────────────────┬──────────────────┐                │
│ │ [Remove]         │ [Done]           │                │
│ └──────────────────┴──────────────────┘                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Features**:
- 4-column grid layout
- 10 icon options
- Selection indicator (border)
- Remove button
- Done button

## 🔄 State Transitions

### Normal Flow
```
User Profile Screen
    ↓ [Edit Button]
Edit Profile Screen (Pre-filled with current data)
    ↓ [Modify Data]
Edit Profile Screen (Modified state)
    ↓ [Save Button]
Loading State (Saving indicator)
    ↓ [Save Complete]
Success Message (SnackBar)
    ↓ [Auto-dismiss]
User Profile Screen (Updated data)
```

### Error Flow
```
Edit Profile Screen
    ↓ [Save Button]
Validation Error
    ↓ [Show Error SnackBar]
Edit Profile Screen (Error state)
    ↓ [User Corrects]
Edit Profile Screen (Modified state)
    ↓ [Save Button]
Loading State
    ↓ [Save Complete]
Success Message
    ↓ [Auto-dismiss]
User Profile Screen (Updated data)
```

### Picture Selection Flow
```
Edit Profile Screen
    ↓ [Tap Picture]
Modal Opens
    ↓ [Select Icon]
Modal Closes (Picture Updated)
    ↓ [Save Button]
Loading State
    ↓ [Save Complete]
Success Message
    ↓ [Auto-dismiss]
User Profile Screen (New Picture)
```

## 📐 Dimensions & Spacing

### Profile Picture
- Size: 120x120 dp
- Border: 3 dp
- Camera Icon: 20x20 dp
- Radius: 60 dp (circular)

### Modal Grid
- Columns: 4
- Item Size: ~60x60 dp
- Cross Spacing: 16 dp
- Main Spacing: 16 dp

### Buttons
- Height: 48 dp (standard)
- Padding: 16 dp (horizontal)
- Border Radius: 8 dp

### Text Fields
- Height: 56 dp (standard)
- Padding: 16 dp (horizontal)
- Border Radius: 8 dp

## 🎨 Colors & Styling

### Profile Picture Container
- Background: Primary color (10% opacity)
- Border: Primary color (3 dp)

### Selected Picture Option
- Border: Primary color (3 dp)
- Background: Icon color (20% opacity)

### Buttons
- Primary: Elevated Button (primary color)
- Secondary: Outlined Button (outline color)

### Text
- Title: 24 sp, Bold (700)
- Label: 14 sp, Medium (500)
- Hint: 12 sp, Regular (400)

## ♿ Accessibility

- ✅ All buttons have tooltips
- ✅ Text fields have labels
- ✅ Icons have semantic meaning
- ✅ Color not only indicator
- ✅ Touch targets ≥ 48 dp
- ✅ Proper contrast ratios
- ✅ Loading states announced

---

**Last Updated**: 2025-10-23

