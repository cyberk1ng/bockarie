import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/themes/neon_theme.dart';

// State notifier for theme mode
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final db = getIt<AppDatabase>();
      final themeModeStr = await db.getSetting('theme_mode');

      if (themeModeStr != null) {
        state = ThemeMode.values.firstWhere(
          (e) => e.name == themeModeStr,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      // If there's an error loading preferences, keep default
    }
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _saveThemeMode();
  }

  Future<void> _saveThemeMode() async {
    try {
      final db = getIt<AppDatabase>();
      await db.saveSetting('theme_mode', state.name);
    } catch (e) {
      // If there's an error saving preferences, silently fail
    }
  }
}

// Provider for theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier();
});

// Provider for light theme (neon design system)
final lightThemeProvider = Provider<ThemeData>((ref) {
  return NeonTheme.lightTheme();
});

// Provider for dark theme (neon design system)
final darkThemeProvider = Provider<ThemeData>((ref) {
  return NeonTheme.darkTheme();
});
