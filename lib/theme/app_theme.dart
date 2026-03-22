import 'package:flutter/material.dart';

import '../state/app_state.dart';

class AppColors {
  static const darkBackground = Color(0xFF1D1D1D);
  static const darkSurface = Color(0xFF000000);
  static const darkCard = Color(0xFF2E2E2E);
  static const darkSoft = Color(0xFF3A3A3A);
  static const accent = Color(0xFFECECEC);
  static const muted = Color(0xFFB8B8B8);
  static const lightBackground = Color(0xFFF2F2F2);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFE1E1E1);
  static const lightSoft = Color(0xFFD3D3D3);
  static const lightText = Color(0xFF181818);
}

class AppTheme {
  static ThemeData darkTheme({
    required AppAccentColor accentColor,
    required AppFontSize fontSize,
  }) {
    final accent = _accentValue(accentColor);
    final textScale = _fontScale(fontSize);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accent.withOpacity(0.75),
        surface: AppColors.darkSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.accent,
          fontSize: 28 * textScale,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: AppColors.accent,
          fontSize: 20 * textScale,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: AppColors.accent,
          fontSize: 16 * textScale,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.accent,
          fontSize: 14 * textScale,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: AppColors.muted,
          fontSize: 12 * textScale,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          color: AppColors.muted,
          fontSize: 10 * textScale,
          height: 1.3,
        ),
      ),
    );
  }

  static ThemeData lightTheme({
    required AppAccentColor accentColor,
    required AppFontSize fontSize,
  }) {
    final accent = _accentValue(accentColor);
    final textScale = _fontScale(fontSize);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: ColorScheme.light(
        primary: accent,
        secondary: accent.withOpacity(0.75),
        surface: AppColors.lightSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.lightText,
          fontSize: 28 * textScale,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: AppColors.lightText,
          fontSize: 20 * textScale,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: AppColors.lightText,
          fontSize: 16 * textScale,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.lightText,
          fontSize: 14 * textScale,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: const Color(0xFF4A4A4A),
          fontSize: 12 * textScale,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          color: const Color(0xFF5B5B5B),
          fontSize: 10 * textScale,
          height: 1.3,
        ),
      ),
    );
  }

  static Color _accentValue(AppAccentColor accentColor) {
    switch (accentColor) {
      case AppAccentColor.blue:
        return const Color(0xFF3B82F6);
      case AppAccentColor.purple:
        return const Color(0xFF8B5CF6);
      case AppAccentColor.red:
        return const Color(0xFFDC2626);
      case AppAccentColor.teal:
        return const Color(0xFF0F766E);
    }
  }

  static double _fontScale(AppFontSize fontSize) {
    switch (fontSize) {
      case AppFontSize.small:
        return 0.92;
      case AppFontSize.medium:
        return 1;
      case AppFontSize.large:
        return 1.12;
    }
  }
}
