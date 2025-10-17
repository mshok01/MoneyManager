import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// Custom theme extension for app-specific colors that aren't part of Material 3
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    required this.success,
    required this.warning,
    required this.info,
    required this.incomeColor,
    required this.expenseColor,
    required this.transferColor,
  });

  final Color success;
  final Color warning;
  final Color info;
  final Color incomeColor;
  final Color expenseColor;
  final Color transferColor;

  @override
  AppColorsExtension copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? incomeColor,
    Color? expenseColor,
    Color? transferColor,
  }) {
    return AppColorsExtension(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      incomeColor: incomeColor ?? this.incomeColor,
      expenseColor: expenseColor ?? this.expenseColor,
      transferColor: transferColor ?? this.transferColor,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      incomeColor: Color.lerp(incomeColor, other.incomeColor, t)!,
      expenseColor: Color.lerp(expenseColor, other.expenseColor, t)!,
      transferColor: Color.lerp(transferColor, other.transferColor, t)!,
    );
  }

  /// Light theme colors
  static const light = AppColorsExtension(
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFFC107),
    info: Color(0xFF2196F3),
    incomeColor: Color(0xFF4CAF50),
    expenseColor: Color(0xFFF44336),
    transferColor: Color(0xFF9C27B0),
  );

  /// Dark theme colors
  static const dark = AppColorsExtension(
    success: Color(0xFF66BB6A),
    warning: Color(0xFFFFD54F),
    info: Color(0xFF42A5F5),
    incomeColor: Color(0xFF66BB6A),
    expenseColor: Color(0xFFEF5350),
    transferColor: Color(0xFFBA68C8),
  );
}

/// Custom theme extension for typography that goes beyond Material 3
@immutable
class AppTypographyExtension extends ThemeExtension<AppTypographyExtension> {
  const AppTypographyExtension({
    required this.sectionHeader,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.amountLarge,
    required this.amountMedium,
    required this.amountSmall,
  });

  final TextStyle sectionHeader;
  final TextStyle cardTitle;
  final TextStyle cardSubtitle;
  final TextStyle amountLarge;
  final TextStyle amountMedium;
  final TextStyle amountSmall;

  @override
  AppTypographyExtension copyWith({
    TextStyle? sectionHeader,
    TextStyle? cardTitle,
    TextStyle? cardSubtitle,
    TextStyle? amountLarge,
    TextStyle? amountMedium,
    TextStyle? amountSmall,
  }) {
    return AppTypographyExtension(
      sectionHeader: sectionHeader ?? this.sectionHeader,
      cardTitle: cardTitle ?? this.cardTitle,
      cardSubtitle: cardSubtitle ?? this.cardSubtitle,
      amountLarge: amountLarge ?? this.amountLarge,
      amountMedium: amountMedium ?? this.amountMedium,
      amountSmall: amountSmall ?? this.amountSmall,
    );
  }

  @override
  AppTypographyExtension lerp(AppTypographyExtension? other, double t) {
    if (other is! AppTypographyExtension) {
      return this;
    }
    return AppTypographyExtension(
      sectionHeader: TextStyle.lerp(sectionHeader, other.sectionHeader, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      cardSubtitle: TextStyle.lerp(cardSubtitle, other.cardSubtitle, t)!,
      amountLarge: TextStyle.lerp(amountLarge, other.amountLarge, t)!,
      amountMedium: TextStyle.lerp(amountMedium, other.amountMedium, t)!,
      amountSmall: TextStyle.lerp(amountSmall, other.amountSmall, t)!,
    );
  }

  /// Base typography styles
  static const base = AppTypographyExtension(
    sectionHeader: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    cardTitle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    cardSubtitle: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    amountLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    amountMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    amountSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
  );
}

/// Custom theme extension for spacing and sizing
@immutable
class AppDimensionsExtension extends ThemeExtension<AppDimensionsExtension> {
  const AppDimensionsExtension({
    required this.cardElevation,
    required this.modalElevation,
    required this.fabElevation,
    required this.iconSizeSmall,
    required this.iconSizeMedium,
    required this.iconSizeLarge,
  });

  final double cardElevation;
  final double modalElevation;
  final double fabElevation;
  final double iconSizeSmall;
  final double iconSizeMedium;
  final double iconSizeLarge;

  @override
  AppDimensionsExtension copyWith({
    double? cardElevation,
    double? modalElevation,
    double? fabElevation,
    double? iconSizeSmall,
    double? iconSizeMedium,
    double? iconSizeLarge,
  }) {
    return AppDimensionsExtension(
      cardElevation: cardElevation ?? this.cardElevation,
      modalElevation: modalElevation ?? this.modalElevation,
      fabElevation: fabElevation ?? this.fabElevation,
      iconSizeSmall: iconSizeSmall ?? this.iconSizeSmall,
      iconSizeMedium: iconSizeMedium ?? this.iconSizeMedium,
      iconSizeLarge: iconSizeLarge ?? this.iconSizeLarge,
    );
  }

  @override
  AppDimensionsExtension lerp(AppDimensionsExtension? other, double t) {
    if (other is! AppDimensionsExtension) {
      return this;
    }
    return AppDimensionsExtension(
      cardElevation: lerpDouble(cardElevation, other.cardElevation, t)!,
      modalElevation: lerpDouble(modalElevation, other.modalElevation, t)!,
      fabElevation: lerpDouble(fabElevation, other.fabElevation, t)!,
      iconSizeSmall: lerpDouble(iconSizeSmall, other.iconSizeSmall, t)!,
      iconSizeMedium: lerpDouble(iconSizeMedium, other.iconSizeMedium, t)!,
      iconSizeLarge: lerpDouble(iconSizeLarge, other.iconSizeLarge, t)!,
    );
  }

  /// Standard dimensions
  static const standard = AppDimensionsExtension(
    cardElevation: 2.0,
    modalElevation: 8.0,
    fabElevation: 6.0,
    iconSizeSmall: 16.0,
    iconSizeMedium: 24.0,
    iconSizeLarge: 32.0,
  );
}

/// Extension to easily access custom theme extensions
extension ThemeExtensions on ThemeData {
  AppColorsExtension get appColors =>
      extension<AppColorsExtension>() ?? AppColorsExtension.light;

  AppTypographyExtension get appTypography =>
      extension<AppTypographyExtension>() ?? AppTypographyExtension.base;

  AppDimensionsExtension get appDimensions =>
      extension<AppDimensionsExtension>() ?? AppDimensionsExtension.standard;
}
