import 'package:flutter/material.dart';

class JaxxColors {
  JaxxColors._();

  static const background = Color(0xFF05070D);
  static const surface = Color(0xFF0B1220);
  static const surfaceHigh = Color(0xFF111B2E);
  static const cyan = Color(0xFF00E5FF);
  static const electricBlue = Color(0xFF2979FF);
  static const purple = Color(0xFF9D4EDD);
  static const textPrimary = Color(0xFFE6F7FF);
  static const textMuted = Color(0xFF7A8BA6);
  static const danger = Color(0xFFFF5370);
}

class JaxxTheme {
  JaxxTheme._();

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: JaxxColors.cyan,
      brightness: Brightness.dark,
    ).copyWith(
      primary: JaxxColors.cyan,
      secondary: JaxxColors.electricBlue,
      tertiary: JaxxColors.purple,
      surface: JaxxColors.surface,
      onSurface: JaxxColors.textPrimary,
      error: JaxxColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: JaxxColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: JaxxColors.background,
        foregroundColor: JaxxColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: JaxxColors.surfaceHigh,
        hintStyle: const TextStyle(color: JaxxColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }
}
