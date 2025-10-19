import 'package:flutter/material.dart';
import 'package:bockaire/themes/neon_theme.dart';

enum NeonTextVariant { title, subtitle, body, label, caption }

/// A text widget with optional neon glow effect
class NeonText extends StatelessWidget {
  final String text;
  final NeonTextVariant variant;
  final Color? color;
  final Color? glowColor;
  final bool enableGlow;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;

  const NeonText(
    this.text, {
    super.key,
    this.variant = NeonTextVariant.body,
    this.color,
    this.glowColor,
    this.enableGlow = false,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.fontWeight,
  });

  /// Factory constructor for title text with glow
  factory NeonText.title(
    String text, {
    Key? key,
    Color? color,
    Color? glowColor,
    bool enableGlow = true,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return NeonText(
      text,
      key: key,
      variant: NeonTextVariant.title,
      color: color,
      glowColor: glowColor,
      enableGlow: enableGlow,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Factory constructor for subtitle text
  factory NeonText.subtitle(
    String text, {
    Key? key,
    Color? color,
    bool enableGlow = false,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return NeonText(
      text,
      key: key,
      variant: NeonTextVariant.subtitle,
      color: color,
      enableGlow: enableGlow,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Factory constructor for body text
  factory NeonText.body(
    String text, {
    Key? key,
    Color? color,
    bool enableGlow = false,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return NeonText(
      text,
      key: key,
      variant: NeonTextVariant.body,
      color: color,
      enableGlow: enableGlow,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Factory constructor for label text
  factory NeonText.label(
    String text, {
    Key? key,
    Color? color,
    Color? glowColor,
    bool enableGlow = false,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return NeonText(
      text,
      key: key,
      variant: NeonTextVariant.label,
      color: color,
      glowColor: glowColor,
      enableGlow: enableGlow,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Factory constructor for caption text
  factory NeonText.caption(
    String text, {
    Key? key,
    Color? color,
    bool enableGlow = false,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return NeonText(
      text,
      key: key,
      variant: NeonTextVariant.caption,
      color: color,
      enableGlow: enableGlow,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textTheme = theme.textTheme;

    // Get base style based on variant
    TextStyle baseStyle = _getBaseStyle(textTheme);

    // Override with custom color if provided
    final finalColor = color ?? _getDefaultColor(isDark);
    final finalGlowColor = glowColor ?? _getDefaultGlowColor();

    // Apply font weight if specified
    if (fontWeight != null) {
      baseStyle = baseStyle.copyWith(fontWeight: fontWeight);
    }

    final textWidget = Text(
      text,
      style: baseStyle.copyWith(color: finalColor),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );

    // Add glow effect if enabled
    if (enableGlow) {
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [finalColor, finalColor.withValues(alpha: 0.8)],
        ).createShader(bounds),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: finalGlowColor, blurRadius: 8, spreadRadius: 2),
            ],
          ),
          child: textWidget,
        ),
      );
    }

    return textWidget;
  }

  TextStyle _getBaseStyle(TextTheme textTheme) {
    switch (variant) {
      case NeonTextVariant.title:
        return textTheme.headlineMedium ??
            TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
      case NeonTextVariant.subtitle:
        return textTheme.titleMedium ??
            TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
      case NeonTextVariant.body:
        return textTheme.bodyMedium ?? TextStyle(fontSize: 14);
      case NeonTextVariant.label:
        return textTheme.labelLarge ??
            TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
      case NeonTextVariant.caption:
        return textTheme.bodySmall ?? TextStyle(fontSize: 12);
    }
  }

  Color _getDefaultColor(bool isDark) {
    switch (variant) {
      case NeonTextVariant.title:
        return isDark ? NeonColors.darkText : NeonColors.lightText;
      case NeonTextVariant.subtitle:
        return isDark ? NeonColors.darkText : NeonColors.lightText;
      case NeonTextVariant.body:
        return isDark ? NeonColors.darkText : NeonColors.lightText;
      case NeonTextVariant.label:
        return NeonColors.cyan;
      case NeonTextVariant.caption:
        return isDark ? NeonColors.mutedTextDark : NeonColors.mutedTextLight;
    }
  }

  Color _getDefaultGlowColor() {
    return glowColor ?? NeonColors.cyanGlow;
  }
}
