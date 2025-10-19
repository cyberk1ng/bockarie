import 'package:flutter/material.dart';
import 'package:bockaire/themes/neon_theme.dart';

enum NeonButtonVariant { primary, secondary, outline }

/// A button widget with neon border and glow effect
class NeonButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final NeonButtonVariant variant;
  final Color? borderColor;
  final Color? glowColor;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isLoading;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = NeonButtonVariant.primary,
    this.borderColor,
    this.glowColor,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height,
    this.padding,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: NeonTheme.animationDuration,
      vsync: this,
    );

    _hoverAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _hoverController,
        curve: NeonTheme.animationCurve,
      ),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _handleHoverEnter() {
    _hoverController.forward();
  }

  void _handleHoverExit() {
    _hoverController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    // Determine colors based on variant and theme
    final borderColor = widget.borderColor ?? _getBorderColor(isDark);
    final glowColor = widget.glowColor ?? _getGlowColor(isDark);
    final backgroundColor =
        widget.backgroundColor ?? _getBackgroundColor(isDark);
    final textColor = widget.textColor ?? _getTextColor(isDark);

    return MouseRegion(
      onEnter: (_) => !isDisabled ? _handleHoverEnter() : null,
      onExit: (_) => !isDisabled ? _handleHoverExit() : null,
      cursor: isDisabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return GestureDetector(
            onTap: isDisabled ? null : widget.onPressed,
            child: Container(
              width: widget.width,
              height: widget.height ?? NeonTheme.buttonHeight,
              padding:
                  widget.padding ??
                  EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isDisabled
                    ? backgroundColor.withValues(alpha: 0.5)
                    : backgroundColor,
                borderRadius: BorderRadius.circular(
                  NeonTheme.buttonBorderRadius,
                ),
                border: Border.all(
                  color: isDisabled
                      ? borderColor.withValues(alpha: 0.3)
                      : borderColor.withValues(
                          alpha: 0.5 + (_hoverAnimation.value * 0.5),
                        ),
                  width: NeonTheme.borderWidth,
                ),
                boxShadow: isDisabled
                    ? null
                    : [
                        BoxShadow(
                          color: glowColor.withValues(
                            alpha: 0.3 + (_hoverAnimation.value * 0.3),
                          ),
                          blurRadius:
                              NeonTheme.glowBlurRadius *
                              (0.5 + (_hoverAnimation.value * 0.5)),
                          spreadRadius:
                              NeonTheme.glowSpreadRadius *
                              _hoverAnimation.value,
                        ),
                      ],
              ),
              child: widget.isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: isDisabled
                                ? textColor.withValues(alpha: 0.5)
                                : textColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: isDisabled
                                ? textColor.withValues(alpha: 0.5)
                                : textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Color _getBorderColor(bool isDark) {
    switch (widget.variant) {
      case NeonButtonVariant.primary:
        return NeonColors.cyan;
      case NeonButtonVariant.secondary:
        return NeonColors.purple;
      case NeonButtonVariant.outline:
        return isDark
            ? NeonColors.cyan
            : NeonColors.cyan.withValues(alpha: 0.5);
    }
  }

  Color _getGlowColor(bool isDark) {
    switch (widget.variant) {
      case NeonButtonVariant.primary:
        return NeonColors.cyanGlow;
      case NeonButtonVariant.secondary:
        return NeonColors.purpleGlow;
      case NeonButtonVariant.outline:
        return NeonColors.cyanGlow;
    }
  }

  Color _getBackgroundColor(bool isDark) {
    switch (widget.variant) {
      case NeonButtonVariant.primary:
        return isDark ? NeonColors.darkCard : NeonColors.lightCard;
      case NeonButtonVariant.secondary:
        return isDark ? NeonColors.darkCard : NeonColors.lightCard;
      case NeonButtonVariant.outline:
        return Colors.transparent;
    }
  }

  Color _getTextColor(bool isDark) {
    switch (widget.variant) {
      case NeonButtonVariant.primary:
        return NeonColors.cyan;
      case NeonButtonVariant.secondary:
        return NeonColors.purple;
      case NeonButtonVariant.outline:
        return isDark ? NeonColors.darkText : NeonColors.lightText;
    }
  }
}
