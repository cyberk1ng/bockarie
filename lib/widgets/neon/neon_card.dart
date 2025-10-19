import 'package:flutter/material.dart';
import 'package:bockaire/themes/neon_theme.dart';

/// A card widget with neon border and glow effect
class NeonCard extends StatefulWidget {
  final Widget child;
  final Color? borderColor;
  final Color? glowColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableGlow;
  final bool enablePulse;
  final VoidCallback? onTap;

  const NeonCard({
    super.key,
    required this.child,
    this.borderColor,
    this.glowColor,
    this.borderRadius,
    this.padding,
    this.margin,
    this.enableGlow = true,
    this.enablePulse = false,
    this.onTap,
  });

  @override
  State<NeonCard> createState() => _NeonCardState();
}

class _NeonCardState extends State<NeonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: NeonTheme.pulseAnimationDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.enablePulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(NeonCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enablePulse && !oldWidget.enablePulse) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.enablePulse && oldWidget.enablePulse) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        widget.borderColor ??
        (isDark ? NeonColors.cyan : NeonColors.cyan.withValues(alpha: 0.3));
    final glowColor = widget.glowColor ?? NeonColors.cyanGlow;
    final backgroundColor = isDark ? NeonColors.darkCard : NeonColors.lightCard;

    Widget card = Container(
      margin: widget.margin ?? EdgeInsets.all(NeonTheme.cardMargin),
      padding: widget.padding ?? EdgeInsets.all(NeonTheme.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? NeonTheme.borderRadius,
        ),
        border: Border.all(color: borderColor, width: NeonTheme.borderWidth),
        boxShadow: widget.enableGlow
            ? [
                BoxShadow(
                  color: glowColor,
                  blurRadius: NeonTheme.glowBlurRadius,
                  spreadRadius: widget.enablePulse
                      ? 0
                      : NeonTheme.glowSpreadRadius,
                ),
              ]
            : null,
      ),
      child: widget.child,
    );

    if (widget.enablePulse) {
      card = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            margin: widget.margin ?? EdgeInsets.all(NeonTheme.cardMargin),
            padding: widget.padding ?? EdgeInsets.all(NeonTheme.cardPadding),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? NeonTheme.borderRadius,
              ),
              border: Border.all(
                color: borderColor.withValues(alpha: _pulseAnimation.value),
                width: NeonTheme.borderWidth,
              ),
              boxShadow: widget.enableGlow
                  ? [
                      BoxShadow(
                        color: glowColor.withValues(
                          alpha: _pulseAnimation.value,
                        ),
                        blurRadius: NeonTheme.glowBlurRadius,
                        spreadRadius: NeonTheme.glowSpreadRadius,
                      ),
                    ]
                  : null,
            ),
            child: widget.child,
          );
        },
      );
    }

    if (widget.onTap != null) {
      return InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(
          widget.borderRadius ?? NeonTheme.borderRadius,
        ),
        child: card,
      );
    }

    return card;
  }
}
