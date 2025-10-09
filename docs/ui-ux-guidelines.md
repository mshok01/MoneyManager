# UI/UX Guidelines

## 🎨 Design System

### Color Palette
Based on existing app theme:
- **Primary**: Blue (`Colors.blue`) - Trust, stability, finance
- **Success**: Green - Income, positive actions
- **Warning**: Orange - Accounts, neutral actions  
- **Info**: Purple - Categories, customization
- **Error**: Red - Expenses, negative actions
- **Neutral**: Grey - Secondary text, disabled states

### Typography
- **Headlines**: 28px, Bold - Page titles
- **Subheadings**: 20px, SemiBold - Section headers
- **Body**: 16px, Regular - Main content
- **Caption**: 14px, Regular - Helper text
- **Button**: 16px, Medium - Action labels

### Spacing System
- **XS**: 4px - Tight spacing
- **S**: 8px - Small gaps
- **M**: 16px - Standard spacing
- **L**: 24px - Section spacing
- **XL**: 32px - Page margins
- **XXL**: 48px - Major sections

## 🎯 Authentication Flow UX Principles

### 1. Progressive Disclosure
**Concept**: Reveal information and options gradually to avoid overwhelming users.

**Implementation**:
- Start with simple binary choice
- Show detailed options only after initial selection
- Provide context when introducing new concepts

**Example**:
```
Step 1: "Get Started" vs "I have an account"
Step 2: Currency selection OR Sign-in options
Step 3: Backup options OR Account restoration
```

### 2. Clear Value Proposition
**Concept**: Each option should clearly communicate its benefit.

**Implementation**:
- **Anonymous**: "Start immediately, no setup required"
- **Google**: "Backup and sync across all your devices"
- **Apple**: "Secure sign-in with your Apple ID"
- **Skip Backup**: "You can add this later in Settings"

### 3. Friction Reduction
**Concept**: Minimize steps and cognitive load for primary user flow.

**Implementation**:
- Primary path (anonymous) requires minimal input
- Secondary paths are clearly marked but not prominent
- Skip options available for non-essential steps

### 4. Safety and Trust
**Concept**: Build user confidence through clear communication and safe defaults.

**Implementation**:
- Explain what happens with user data
- Provide easy way to change decisions later
- Use familiar authentication providers (Google, Apple)

## 📱 Screen Design Patterns

### Authentication Choice Screen
```
┌─────────────────────────────┐
│ [Logo/Icon]                 │ ← Visual anchor
│                             │
│ [Headline]                  │ ← Clear value prop
│ [Subheading]                │ ← Supporting context
│                             │
│ [Primary CTA Button]        │ ← Main action
│                             │
│ [Divider with "or"]         │ ← Visual separation
│                             │
│ [Secondary Button]          │ ← Alternative path
│                             │
│ [Footer Text]               │ ← Additional context
└─────────────────────────────┘
```

### Currency Selection Screen
```
┌─────────────────────────────┐
│ [Back] [Title]              │ ← Navigation
│                             │
│ [Currency Grid]             │ ← Visual selection
│ 🇺🇸 USD  🇪🇺 EUR  🇬🇧 GBP   │
│ 🇮🇳 INR  🇯🇵 JPY  🇨🇦 CAD   │
│                             │
│ [Search Bar]                │ ← Quick access
│                             │
│ [Continue Button]           │ ← Progress action
└─────────────────────────────┘
```

### Backup Account Screen
```
┌─────────────────────────────┐
│ [Icon] [Title]              │ ← Clear purpose
│ [Description]               │ ← Value explanation
│                             │
│ [Google Button]             │ ← Primary options
│ [Apple Button]              │
│                             │
│ [Divider]                   │
│                             │
│ [Skip Button]               │ ← Escape hatch
│ [Helper Text]               │ ← Reassurance
└─────────────────────────────┘
```

## 🎭 Micro-Interactions

### Button States
- **Default**: Clear visual hierarchy
- **Hover**: Subtle elevation (web/desktop)
- **Pressed**: Brief scale animation (0.95x)
- **Loading**: Spinner with disabled state
- **Success**: Brief checkmark animation

### Transitions
- **Screen Navigation**: Slide transition (300ms)
- **Modal Appearance**: Fade + scale (250ms)
- **Button Press**: Scale (150ms)
- **Loading States**: Fade (200ms)

### Feedback
- **Success**: Green checkmark + haptic feedback
- **Error**: Red shake animation + haptic feedback
- **Progress**: Linear progress indicator
- **Completion**: Celebration animation (optional)

## ♿ Accessibility Guidelines

### Visual Accessibility
- **Contrast Ratio**: Minimum 4.5:1 for normal text
- **Touch Targets**: Minimum 44pt x 44pt
- **Focus Indicators**: Clear visual focus states
- **Color Independence**: Don't rely solely on color for meaning

### Screen Reader Support
- **Semantic Labels**: Descriptive button and field labels
- **State Announcements**: "Loading", "Selected", "Error"
- **Navigation Hints**: "Button", "Heading", "List"
- **Progress Updates**: Announce completion states

### Motor Accessibility
- **Large Touch Areas**: Easy to tap buttons
- **Gesture Alternatives**: Provide button alternatives to swipes
- **Timeout Extensions**: Allow more time for actions
- **Error Recovery**: Easy ways to fix mistakes

## 📊 Error Handling

### Network Errors
```
┌─────────────────────────────┐
│ 📶 Connection Issue         │
│                             │
│ Check your internet         │
│ connection and try again    │
│                             │
│ [Try Again] [Continue       │
│              Offline]       │
└─────────────────────────────┘
```

### Authentication Errors
```
┌─────────────────────────────┐
│ ⚠️ Sign-in Failed           │
│                             │
│ Unable to sign in with      │
│ Google. Please try again    │
│                             │
│ [Try Again] [Use Different  │
│              Account]       │
└─────────────────────────────┘
```

### Validation Errors
- **Inline**: Show errors next to relevant fields
- **Summary**: List all errors at top of form
- **Prevention**: Validate as user types when possible

## 🔄 Loading States

### Skeleton Screens
Use for content that takes time to load:
- Currency list loading
- Account restoration progress
- User profile information

### Progress Indicators
- **Determinate**: When progress can be measured
- **Indeterminate**: For unknown duration tasks
- **Step Indicators**: Multi-step processes

### Empty States
- **First Use**: Encouraging message with clear next steps
- **No Data**: Helpful suggestions for getting started
- **Error State**: Clear explanation with recovery options

## 📱 Responsive Design

### Mobile First
- Design for smallest screen first
- Progressive enhancement for larger screens
- Touch-friendly interactions

### Breakpoints
- **Mobile**: < 768px
- **Tablet**: 768px - 1024px  
- **Desktop**: > 1024px

### Adaptive Elements
- **Navigation**: Bottom tabs (mobile) → Side nav (desktop)
- **Buttons**: Full width (mobile) → Fixed width (desktop)
- **Modals**: Full screen (mobile) → Centered (desktop)
