import 'package:flutter/material.dart';

/// 统一色彩常量，便于在设计稿和代码中对齐。
class AppColors {
  const AppColors._();

  // Light palette
  static const Color primaryLight = Color(0xFF5B6CFF);
  static const Color secondaryLight = Color(0xFF7A86A8);
  static const Color backgroundLight = Color(0xFFF3EEF7);
  static const Color surfaceLight = Color(0xFFFBFAFF);
  static const Color accentLight = Color(0xFF46B3A5);
  static const Color errorLight = Color(0xFFD45B6A);
  static const Color textPrimaryLight = Color(0xFF1F2430);
  static const Color textSecondaryLight = Color(0xFF5F6B7A);
  static const Color textDisabledLight = Color(0xFF9CA6B4);

  // Dark palette
  static const Color primaryDark = Color(0xFF95A1FF);
  static const Color secondaryDark = Color(0xFFA3AEC9);
  static const Color backgroundDark = Color(0xFF111420);
  static const Color surfaceDark = Color(0xFF1A1F2E);
  static const Color accentDark = Color(0xFF6AD7C8);
  static const Color errorDark = Color(0xFFFF8A98);
  static const Color textPrimaryDark = Color(0xFFE8ECF3);
  static const Color textSecondaryDark = Color(0xFFB8C0CF);
  static const Color textDisabledDark = Color(0xFF7D8798);
}

class AppTheme {
  const AppTheme._();

  static final ColorScheme lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    secondary: AppColors.secondaryLight,
    onSecondary: Colors.white,
    error: AppColors.errorLight,
    onError: Colors.white,
    background: AppColors.backgroundLight,
    onBackground: AppColors.textPrimaryLight,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    tertiary: AppColors.accentLight,
    onTertiary: Colors.white,
    primaryContainer: Color(0xFFE7EAFF),
    onPrimaryContainer: Color(0xFF1D2766),
    secondaryContainer: Color(0xFFE8ECF6),
    onSecondaryContainer: Color(0xFF2F3950),
    tertiaryContainer: Color(0xFFDBF5F1),
    onTertiaryContainer: Color(0xFF0B4B44),
    errorContainer: Color(0xFFFEE8EB),
    onErrorContainer: Color(0xFF5A1A23),
    surfaceVariant: Color(0xFFEEF1F7),
    onSurfaceVariant: AppColors.textSecondaryLight,
    outline: Color(0xFFD1D8E5),
    outlineVariant: Color(0xFFE3E8F2),
    shadow: Color(0x1A0F172A),
    scrim: Color(0x660F172A),
    inverseSurface: Color(0xFF2A3142),
    onInverseSurface: Color(0xFFF1F4FA),
    inversePrimary: Color(0xFFB9C0FF),
    surfaceTint: AppColors.primaryLight,
  );

  static final ColorScheme darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onPrimary: Color(0xFF21274B),
    secondary: AppColors.secondaryDark,
    onSecondary: Color(0xFF1F2638),
    error: AppColors.errorDark,
    onError: Color(0xFF4B111A),
    background: AppColors.backgroundDark,
    onBackground: AppColors.textPrimaryDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    tertiary: AppColors.accentDark,
    onTertiary: Color(0xFF0E3E38),
    primaryContainer: Color(0xFF333F7A),
    onPrimaryContainer: Color(0xFFDDE1FF),
    secondaryContainer: Color(0xFF343D56),
    onSecondaryContainer: Color(0xFFDDE3F6),
    tertiaryContainer: Color(0xFF23564F),
    onTertiaryContainer: Color(0xFFC8F4EE),
    errorContainer: Color(0xFF5E2230),
    onErrorContainer: Color(0xFFFFDADF),
    surfaceVariant: Color(0xFF232A3B),
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: Color(0xFF495066),
    outlineVariant: Color(0xFF31384C),
    shadow: Color(0x66000000),
    scrim: Color(0x99000000),
    inverseSurface: Color(0xFFE8ECF3),
    onInverseSurface: Color(0xFF1C2231),
    inversePrimary: Color(0xFF5B6CFF),
    surfaceTint: AppColors.primaryDark,
  );

  static ThemeData get lightTheme => _buildTheme(lightColorScheme);
  static ThemeData get darkTheme => _buildTheme(darkColorScheme);

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final bool isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      textTheme: _textTheme(colorScheme),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shadowColor: colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
        hintStyle: TextStyle(
            color: isDark
                ? AppColors.textDisabledDark
                : AppColors.textDisabledLight),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: colorScheme.secondaryContainer,
        selectedColor: colorScheme.primaryContainer,
        disabledColor: colorScheme.surfaceVariant,
        labelStyle: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme colorScheme) {
    return TextTheme(
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: colorScheme.onBackground,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.4,
        color: colorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.4,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimary,
      ),
    );
  }
}
