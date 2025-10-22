# Theme System

This directory contains the comprehensive theme system for the Money Manager app. The theme system is designed to be scalable, maintainable, and consistent across the entire application.

## Architecture

The theme system is organized into several key files:

### Core Files

- **`app_theme.dart`** - Main theme configuration class with design tokens
- **`theme_extensions.dart`** - Custom theme extensions for app-specific properties
- **`theme_usage_examples.dart`** - Examples and reference implementations

### Integration

- **`../services/theme_service.dart`** - Service that manages theme state and persistence

## Design Tokens

### Spacing System
```dart
AppTheme.spacingXs   // 4.0
AppTheme.spacingSm   // 8.0
AppTheme.spacingMd   // 16.0
AppTheme.spacingLg   // 24.0
AppTheme.spacingXl   // 32.0
AppTheme.spacingXxl  // 48.0
```

### Border Radius System
```dart
AppTheme.radiusXs    // 4.0
AppTheme.radiusSm    // 8.0
AppTheme.radiusMd    // 12.0
AppTheme.radiusLg    // 16.0
AppTheme.radiusXl    // 24.0
```

## Theme Extensions

### Custom Colors
Access app-specific colors that aren't part of Material 3:

```dart
final theme = Theme.of(context);

// Financial colors
theme.appColors.incomeColor    // Green for income
theme.appColors.expenseColor   // Red for expenses
theme.appColors.transferColor  // Purple for transfers

// Status colors
theme.appColors.success        // Success green
theme.appColors.warning        // Warning amber
theme.appColors.info          // Info blue
```

### Custom Typography
Access specialized text styles:

```dart
final theme = Theme.of(context);

theme.appTypography.sectionHeader  // For section headers
theme.appTypography.cardTitle      // For card titles
theme.appTypography.cardSubtitle   // For card subtitles
theme.appTypography.amountLarge    // For large amounts
theme.appTypography.amountMedium   // For medium amounts
theme.appTypography.amountSmall    // For small amounts
```

### Custom Dimensions
Access app-specific dimensions:

```dart
final theme = Theme.of(context);

theme.appDimensions.cardElevation   // Standard card elevation
theme.appDimensions.modalElevation  // Modal elevation
theme.appDimensions.fabElevation    // FAB elevation
theme.appDimensions.iconSizeSmall   // Small icon size
theme.appDimensions.iconSizeMedium  // Medium icon size
theme.appDimensions.iconSizeLarge   // Large icon size
```

## Usage Examples

### Section Headers
```dart
Widget _buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(
      AppTheme.spacingMd,
      AppTheme.spacingMd,
      AppTheme.spacingMd,
      AppTheme.spacingSm,
    ),
    child: Text(
      title,
      style: AppTheme.sectionHeaderStyle(context),
    ),
  );
}
```

### Amount Display
```dart
Widget _buildAmount(BuildContext context, double amount, bool isIncome) {
  final theme = Theme.of(context);
  
  return Text(
    '\$${amount.toStringAsFixed(2)}',
    style: theme.appTypography.amountLarge.copyWith(
      color: isIncome 
        ? theme.appColors.incomeColor 
        : theme.appColors.expenseColor,
    ),
  );
}
```

### Themed Card
```dart
Widget _buildCard(BuildContext context) {
  final theme = Theme.of(context);
  
  return Card(
    elevation: theme.appDimensions.cardElevation,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    ),
    margin: const EdgeInsets.symmetric(
      horizontal: AppTheme.spacingMd,
      vertical: AppTheme.spacingSm,
    ),
    child: Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: // Your card content
    ),
  );
}
```

## Adding New Design Tokens

### Adding Colors
1. Add the color to `AppColorsExtension` in `theme_extensions.dart`
2. Define both light and dark variants
3. Update the `copyWith` and `lerp` methods

### Adding Typography
1. Add the text style to `AppTypographyExtension`
2. Update the `copyWith` and `lerp` methods
3. Consider using `FontFeature.tabularFigures()` for numbers

### Adding Dimensions
1. Add the dimension to `AppDimensionsExtension`
2. Update the `copyWith` and `lerp` methods

## Best Practices

1. **Use design tokens consistently** - Always use the predefined spacing, radius, and other values
2. **Leverage theme extensions** - Use custom colors and typography from extensions
3. **Consider both themes** - Ensure your UI works in both light and dark modes
4. **Test theme switching** - Verify that theme changes work correctly
5. **Document new additions** - Update this README when adding new design tokens

## Migration Guide

When migrating existing code to use the new theme system:

1. Replace hardcoded spacing with `AppTheme.spacing*` constants
2. Replace hardcoded border radius with `AppTheme.radius*` constants
3. Use theme extensions for custom colors and typography
4. Update section headers to use `AppTheme.sectionHeaderStyle(context)`

## Future Enhancements

The theme system is designed to be extensible. Future additions might include:

- Custom font families
- Animation durations
- Shadow definitions
- Gradient definitions
- Component-specific themes
- Accessibility-specific tokens
