import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Neon color palette for the futuristic theme
class NeonColors {
  // Primary neon accent colors
  static const cyan = Color(0xFF00D9FF);
  static const green = Color(0xFF00FF94);
  static const purple = Color(0xFFB24BF3);
  static const pink = Color(0xFFFF006E);

  // Glow colors (with opacity for effects)
  static const cyanGlow = Color(0x4000D9FF);
  static const greenGlow = Color(0x4000FF94);
  static const purpleGlow = Color(0x40B24BF3);
  static const pinkGlow = Color(0x40FF006E);

  // Dark theme backgrounds
  static const darkBackground = Color(0xFF0A0E27);
  static const darkSurface = Color(0xFF131829);
  static const darkCard = Color(0xFF1A1F3A);

  // Light theme backgrounds
  static const lightBackground = Color(0xFFF5F7FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);

  // Grid and subtle accents
  static const gridDark = Color(0xFF1E2541);
  static const gridLight = Color(0xFFE1E8F0);

  // Text colors
  static const darkText = Color(0xFFE8EAF6);
  static const lightText = Color(0xFF1A1F3A);
  static const mutedTextDark = Color(0xFF8B92B0);
  static const mutedTextLight = Color(0xFF6B7280);
}

/// Theme configuration for neon design system
class NeonTheme {
  // Border and corner constants
  static const double borderRadius = 24.0;
  static const double borderWidth = 1.5;

  // Glow and shadow constants
  static const double glowBlurRadius = 16.0;
  static const double glowSpreadRadius = 2.0;

  // Card constants
  static const double cardPadding = 20.0;
  static const double cardMargin = 12.0;

  // Button constants
  static const double buttonHeight = 52.0;
  static const double buttonBorderRadius = 16.0;

  // Animation constants
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration pulseAnimationDuration = Duration(milliseconds: 2000);
  static const Curve animationCurve = Curves.easeInOut;

  /// Creates the dark theme with neon accents
  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: NeonColors.cyan,
      secondary: NeonColors.purple,
      tertiary: NeonColors.green,
      error: NeonColors.pink,
      surface: NeonColors.darkSurface,
      onSurface: NeonColors.darkText,
      onPrimary: NeonColors.darkBackground,
      onSecondary: NeonColors.darkText,
      outline: NeonColors.cyan.withValues(alpha: 0.3),
      shadow: NeonColors.cyanGlow,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NeonColors.darkBackground,

      // Typography
      textTheme: _createTextTheme(isDark: true),

      // Card theme
      cardTheme: CardThemeData(
        color: NeonColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: NeonColors.cyan.withValues(alpha: 0.3),
            width: borderWidth,
          ),
        ),
        shadowColor: NeonColors.cyanGlow,
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: NeonColors.darkBackground,
        foregroundColor: NeonColors.darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: NeonColors.darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeonColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: NeonColors.cyan.withValues(alpha: 0.3),
            width: borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: NeonColors.cyan.withValues(alpha: 0.3),
            width: borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: NeonColors.cyan,
            width: borderWidth * 1.5,
          ),
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeonColors.darkCard,
          foregroundColor: NeonColors.cyan,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
            side: BorderSide(
              color: NeonColors.cyan.withValues(alpha: 0.5),
              width: borderWidth,
            ),
          ),
          shadowColor: NeonColors.cyanGlow,
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: NeonColors.cyan,
        foregroundColor: NeonColors.darkBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Creates the light theme with subtle neon accents
  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.light(
      brightness: Brightness.light,
      primary: NeonColors.cyan,
      secondary: NeonColors.purple,
      tertiary: NeonColors.green,
      error: NeonColors.pink,
      surface: NeonColors.lightSurface,
      onSurface: NeonColors.lightText,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      outline: NeonColors.cyan.withValues(alpha: 0.2),
      shadow: NeonColors.cyan.withValues(alpha: 0.1),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: NeonColors.lightBackground,

      // Typography
      textTheme: _createTextTheme(isDark: false),

      // Card theme
      cardTheme: CardThemeData(
        color: NeonColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(
            color: NeonColors.cyan.withValues(alpha: 02),
            width: borderWidth,
          ),
        ),
        shadowColor: NeonColors.cyan.withValues(alpha: 005),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: NeonColors.lightBackground,
        foregroundColor: NeonColors.lightText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: NeonColors.lightText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NeonColors.lightCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: NeonColors.cyan.withValues(alpha: 02),
            width: borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: NeonColors.cyan.withValues(alpha: 02),
            width: borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: NeonColors.cyan,
            width: borderWidth * 1.5,
          ),
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NeonColors.lightCard,
          foregroundColor: NeonColors.cyan,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
            side: BorderSide(
              color: NeonColors.cyan.withValues(alpha: 0.3),
              width: borderWidth,
            ),
          ),
        ),
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: NeonColors.cyan,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Creates custom text theme with Inter font
  static TextTheme _createTextTheme({required bool isDark}) {
    final baseColor = isDark ? NeonColors.darkText : NeonColors.lightText;
    final mutedColor = isDark
        ? NeonColors.mutedTextDark
        : NeonColors.mutedTextLight;

    return GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: baseColor,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: baseColor,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: baseColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: baseColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: baseColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: mutedColor,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: baseColor,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: mutedColor,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: mutedColor,
        ),
      ),
    );
  }
}
