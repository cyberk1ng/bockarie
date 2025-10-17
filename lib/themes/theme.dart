import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

const fontSizeSmall = 12.0;
const fontSizeMedium = 16.0;
const fontSizeLarge = 20.0;

class AppTheme {
  // Modern card layout constants
  static const double cardBorderRadius = 16;
  static const double cardPadding = 16;
  static const double cardElevation = 2;
  static const double cardSpacing = 12;

  // Icon container constants
  static const double iconContainerSize = 44;
  static const double iconContainerBorderRadius = 12;
  static const double iconSize = 22;

  // Spacing constants
  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;

  // Input constants
  static const double inputBorderRadius = 12;
  static const double focusedBorderWidth = 2;

  // Animation constants
  static const int animationDuration = 250;
  static const Curve animationCurve = Curves.easeOutCubic;

  // Button constants
  static const double buttonBorderRadius = 12;
  static const double buttonHeight = 48;
  static const double buttonPaddingHorizontal = 24;
  static const double buttonPaddingVertical = 12;
}

// Modal-specific constants
class ModalTheme {
  static const double padding = 24;
  static const double navBarHeight = 65;
  static const double iconPadding = 12;
  static const double iconSize = 20;
  static const double pageBreakpoint = 560;
}

ThemeData createAppTheme({required Brightness brightness}) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: brightness,
  );

  final baseTheme = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    brightness: brightness,
  );

  return baseTheme
      .copyWith(
        cardTheme: baseTheme.cardTheme.copyWith(
          clipBehavior: Clip.hardEdge,
          elevation: AppTheme.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
          ),
        ),
        appBarTheme: baseTheme.appBarTheme.copyWith(
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          clipBehavior: Clip.hardEdge,
          elevation: 0,
          backgroundColor: colorScheme.surfaceContainerHigh,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
            borderSide: BorderSide(color: colorScheme.outline.withAlpha(80)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
            borderSide: BorderSide(color: colorScheme.outline.withAlpha(80)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: AppTheme.focusedBorderWidth,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
            borderSide: BorderSide(color: colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: AppTheme.focusedBorderWidth,
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            elevation: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.pressed) ? 1 : 2;
            }),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.buttonBorderRadius,
                ),
              ),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(
                horizontal: AppTheme.buttonPaddingHorizontal,
                vertical: AppTheme.buttonPaddingVertical,
              ),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      )
      .copyWith(
        extensions: {
          const WoltModalSheetThemeData(
            animationStyle: WoltModalSheetAnimationStyle(
              paginationAnimationStyle: WoltModalSheetPaginationAnimationStyle(
                modalSheetHeightTransitionCurve: Interval(0, 0.1),
              ),
            ),
          ),
        },
      );
}

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
}
