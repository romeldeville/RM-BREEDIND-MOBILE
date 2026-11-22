import 'package:flutter/material.dart';

import 'app_tokens.dart';

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppTokens.primary,
    primary: AppTokens.primary,
    secondary: AppTokens.accent,
    surface: AppTokens.surface,
    error: AppTokens.danger,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppTokens.background,
    fontFamily: 'Inter',
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppTokens.surface,
      foregroundColor: AppTokens.text,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppTokens.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        side: const BorderSide(color: AppTokens.border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppTokens.surface,
      labelStyle: const TextStyle(fontSize: AppTokens.fontBase),
      hintStyle: const TextStyle(fontSize: AppTokens.fontSm, color: AppTokens.textMuted),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.space4,
        vertical: AppTokens.space3 + 2,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: const BorderSide(color: AppTokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: const BorderSide(color: AppTokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: const BorderSide(color: AppTokens.info, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppTokens.touchTarget),
        textStyle: const TextStyle(fontSize: AppTokens.fontBase, fontWeight: FontWeight.w600),
        backgroundColor: AppTokens.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppTokens.touchTarget),
        textStyle: const TextStyle(fontSize: AppTokens.fontBase, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppTokens.surface,
      indicatorColor: AppTokens.accent.withValues(alpha: 0.25),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: AppTokens.fontXs, fontWeight: FontWeight.w600),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: AppTokens.fontXl,
        fontWeight: FontWeight.w700,
        color: AppTokens.text,
      ),
      titleLarge: TextStyle(
        fontSize: AppTokens.fontLg + 1,
        fontWeight: FontWeight.w700,
        color: AppTokens.text,
      ),
      titleMedium: TextStyle(
        fontSize: AppTokens.fontLg,
        fontWeight: FontWeight.w600,
        color: AppTokens.text,
      ),
      titleSmall: TextStyle(
        fontSize: AppTokens.fontBase,
        fontWeight: FontWeight.w600,
        color: AppTokens.text,
      ),
      bodyLarge: TextStyle(
        fontSize: AppTokens.fontLg,
        fontWeight: FontWeight.normal,
        color: AppTokens.text,
      ),
      bodyMedium: TextStyle(
        fontSize: AppTokens.fontBase,
        fontWeight: FontWeight.normal,
        color: AppTokens.text,
      ),
      bodySmall: TextStyle(
        fontSize: AppTokens.fontSm,
        fontWeight: FontWeight.normal,
        color: AppTokens.textMuted,
      ),
      labelLarge: TextStyle(
        fontSize: AppTokens.fontBase,
        fontWeight: FontWeight.w600,
        color: AppTokens.text,
      ),
      labelMedium: TextStyle(
        fontSize: AppTokens.fontSm,
        fontWeight: FontWeight.w500,
        color: AppTokens.text,
      ),
      labelSmall: TextStyle(
        fontSize: AppTokens.fontXs,
        fontWeight: FontWeight.w500,
        color: AppTokens.textMuted,
      ),
    ),
  );
}
