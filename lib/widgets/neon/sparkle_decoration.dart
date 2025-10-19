import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bockaire/themes/neon_theme.dart';

/// A widget that adds sparkle/star decorations to the background
class SparkleDecoration extends StatefulWidget {
  final int sparkleCount;
  final Color? sparkleColor;
  final double minSize;
  final double maxSize;

  const SparkleDecoration({
    super.key,
    this.sparkleCount = 20,
    this.sparkleColor,
    this.minSize = 2,
    this.maxSize = 6,
  });

  @override
  State<SparkleDecoration> createState() => _SparkleDecorationState();
}

class _SparkleDecorationState extends State<SparkleDecoration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Sparkle> _sparkles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _generateSparkles();
  }

  void _generateSparkles() {
    final random = math.Random();
    _sparkles = List.generate(widget.sparkleCount, (index) {
      return Sparkle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size:
            widget.minSize +
            random.nextDouble() * (widget.maxSize - widget.minSize),
        twinkleDuration: 1.0 + random.nextDouble() * 2.0,
        delay: random.nextDouble(),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sparkleColor =
        widget.sparkleColor ??
        (isDark
            ? NeonColors.cyan.withValues(alpha: 0.6)
            : NeonColors.cyan.withValues(alpha: 0.3));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SparklePainter(
            sparkles: _sparkles,
            animationValue: _controller.value,
            sparkleColor: sparkleColor,
          ),
          child: Container(),
        );
      },
    );
  }
}

class Sparkle {
  final double x;
  final double y;
  final double size;
  final double twinkleDuration;
  final double delay;

  Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.twinkleDuration,
    required this.delay,
  });
}

class _SparklePainter extends CustomPainter {
  final List<Sparkle> sparkles;
  final double animationValue;
  final Color sparkleColor;

  _SparklePainter({
    required this.sparkles,
    required this.animationValue,
    required this.sparkleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final sparkle in sparkles) {
      final position = Offset(sparkle.x * size.width, sparkle.y * size.height);

      // Calculate opacity based on twinkle animation
      final adjustedTime = (animationValue + sparkle.delay) % 1.0;
      final progress = adjustedTime / sparkle.twinkleDuration;
      final opacity = (math.sin(progress * math.pi * 2) + 1) / 2;

      // Draw sparkle glow
      final glowPaint = Paint()
        ..color = sparkleColor.withValues(alpha: opacity * 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, sparkle.size);

      canvas.drawCircle(position, sparkle.size, glowPaint);

      // Draw sparkle core
      final corePaint = Paint()
        ..color = sparkleColor.withValues(alpha: opacity);

      canvas.drawCircle(position, sparkle.size / 2, corePaint);

      // Draw cross pattern for star effect
      if (opacity > 0.5) {
        final linePaint = Paint()
          ..color = sparkleColor.withValues(alpha: opacity)
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.round;

        final lineLength = sparkle.size * 2;

        // Horizontal line
        canvas.drawLine(
          Offset(position.dx - lineLength, position.dy),
          Offset(position.dx + lineLength, position.dy),
          linePaint,
        );

        // Vertical line
        canvas.drawLine(
          Offset(position.dx, position.dy - lineLength),
          Offset(position.dx, position.dy + lineLength),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SparklePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
