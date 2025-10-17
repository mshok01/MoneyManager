import 'package:flutter/material.dart';
import 'theme_extensions.dart';

/// App theme configuration class that defines all design tokens
/// including colors, typography, spacing, and component themes.
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ============================================================================
  // COLOR SYSTEM
  // ============================================================================

  /// Primary brand colors
  static const Color _primarySeed = Colors.blue;

  /// Custom color palette (can be expanded later)
  static const Color _successColor = Color(0xFF4CAF50);
  static const Color _warningColor = Color(0xFFFFC107);
  static const Color _errorColor = Color(0xFFF44336);
  static const Color _infoColor = Color(0xFF2196F3);

  // ============================================================================
  // TYPOGRAPHY SYSTEM
  // ============================================================================

  /// Font family (can be customized later)
  static const String _fontFamily = 'Roboto'; // Default Material font

  /// Custom text styles (can be expanded later)
  static const TextStyle _sectionHeaderStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // ============================================================================
  // SPACING SYSTEM
  // ============================================================================

  /// Standard spacing values
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ============================================================================
  // BORDER RADIUS SYSTEM
  // ============================================================================

  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // ============================================================================
  // LIGHT THEME
  // ============================================================================

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: _fontFamily,
      extensions: const [
        AppColorsExtension.light,
        AppTypographyExtension.base,
        AppDimensionsExtension.standard,
      ],

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.inversePrimary,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          fontFamily: _fontFamily,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        contentTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 14),
      ),
    );
  }

  // ============================================================================
  // DARK THEME
  // ============================================================================

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primarySeed,
      brightness: Brightness.dark,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: _fontFamily,
      extensions: const [
        AppColorsExtension.dark,
        AppTypographyExtension.base,
        AppDimensionsExtension.standard,
      ],

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.inversePrimary,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          fontFamily: _fontFamily,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingLg,
            vertical: spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMd,
            vertical: spacingSm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingMd,
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        contentTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 14),
      ),
    );
  }

  // ============================================================================
  // CUSTOM STYLES
  // ============================================================================

  /// Section header text style used in settings and other screens
  static TextStyle sectionHeaderStyle(BuildContext context) {
    return _sectionHeaderStyle.copyWith(
      color: Theme.of(context).colorScheme.primary,
    );
  }

  /// Custom colors that can be accessed throughout the app
  static Color successColor(BuildContext context) => _successColor;
  static Color warningColor(BuildContext context) => _warningColor;
  static Color errorColor(BuildContext context) => _errorColor;
  static Color infoColor(BuildContext context) => _infoColor;
}
