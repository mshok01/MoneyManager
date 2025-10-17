import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'theme_extensions.dart';

/// This file contains examples of how to use the new theme system.
/// These examples can be used as reference when implementing UI components.
class ThemeUsageExamples {
  // Private constructor to prevent instantiation
  ThemeUsageExamples._();

  /// Example: Using standard spacing values
  static Widget spacingExample() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            child: const Text('Small spacing below'),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
            child: const Text('Large spacing below'),
          ),
        ],
      ),
    );
  }

  /// Example: Using custom colors from theme extensions
  static Widget customColorsExample(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          color: theme.appColors.success,
          child: const Text('Success color'),
        ),
        Container(
          color: theme.appColors.warning,
          child: const Text('Warning color'),
        ),
        Container(
          color: theme.appColors.incomeColor,
          child: const Text('Income color'),
        ),
        Container(
          color: theme.appColors.expenseColor,
          child: const Text('Expense color'),
        ),
      ],
    );
  }

  /// Example: Using custom typography
  static Widget typographyExample(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Section Header',
          style: theme.appTypography.sectionHeader.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          'Card Title',
          style: theme.appTypography.cardTitle,
        ),
        Text(
          'Card Subtitle',
          style: theme.appTypography.cardSubtitle,
        ),
        Text(
          '\$1,234.56',
          style: theme.appTypography.amountLarge.copyWith(
            color: theme.appColors.incomeColor,
          ),
        ),
      ],
    );
  }

  /// Example: Using section header style (as used in settings)
  static Widget sectionHeaderExample(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
        AppTheme.spacingSm,
      ),
      child: Text(
        'Settings Section',
        style: AppTheme.sectionHeaderStyle(context),
      ),
    );
  }

  /// Example: Using border radius values
  static Widget borderRadiusExample() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: const Center(child: Text('Small radius')),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: const Center(child: Text('Medium radius')),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          width: 100,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: const Center(child: Text('Large radius')),
        ),
      ],
    );
  }

  /// Example: Using custom dimensions
  static Widget dimensionsExample(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Card(
          elevation: theme.appDimensions.cardElevation,
          child: const Padding(
            padding: EdgeInsets.all(AppTheme.spacingMd),
            child: Text('Card with custom elevation'),
          ),
        ),
        Row(
          children: [
            Icon(
              Icons.star,
              size: theme.appDimensions.iconSizeSmall,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Icon(
              Icons.star,
              size: theme.appDimensions.iconSizeMedium,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Icon(
              Icons.star,
              size: theme.appDimensions.iconSizeLarge,
            ),
          ],
        ),
      ],
    );
  }

  /// Example: Complete card component using the theme system
  static Widget themeAwareCard(BuildContext context) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction',
              style: theme.appTypography.cardTitle,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Grocery shopping',
              style: theme.appTypography.cardSubtitle.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  '-\$45.67',
                  style: theme.appTypography.amountMedium.copyWith(
                    color: theme.appColors.expenseColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
