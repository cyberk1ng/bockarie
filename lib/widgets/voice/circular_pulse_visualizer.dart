import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bockaire/themes/neon_theme.dart';

/// A custom circular pulse visualizer that creates animated rings
/// Perfect for showing audio recording activity with neon effects
class CircularPulseVisualizer extends StatefulWidget {
  final bool isRecording;
  final double size;

  const CircularPulseVisualizer({
    super.key,
    required this.isRecording,
    this.size = 200,
  });

  @override
  State<CircularPulseVisualizer> createState() =>
      _CircularPulseVisualizerState();
}

class _CircularPulseVisualizerState extends State<CircularPulseVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late List<AnimationController> _ringControllers;

  @override
  void initState() {
    super.initState();

    // Main pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Rotation animation for the rings
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    // Create multiple ring controllers for staggered animation
    _ringControllers = List.generate(
      3,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 2000 + (index * 200)),
      ),
    );

    if (widget.isRecording) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(CircularPulseVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    for (var controller in _ringControllers) {
      controller.repeat();
    }
  }

  void _stopAnimations() {
    _pulseController.stop();
    _rotationController.stop();
    for (var controller in _ringControllers) {
      controller.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    for (var controller in _ringControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseController,
          _rotationController,
          ..._ringControllers,
        ]),
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularPulsePainter(
              pulseValue: _pulseController.value,
              rotationValue: _rotationController.value,
              ringValues: _ringControllers.map((c) => c.value).toList(),
              isRecording: widget.isRecording,
            ),
          );
        },
      ),
    );
  }
}

class _CircularPulsePainter extends CustomPainter {
  final double pulseValue;
  final double rotationValue;
  final List<double> ringValues;
  final bool isRecording;

  _CircularPulsePainter({
    required this.pulseValue,
    required this.rotationValue,
    required this.ringValues,
    required this.isRecording,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width / 4;

    if (!isRecording) {
      // Draw idle state - just a single pulsing ring
      _drawIdleRing(canvas, center, baseRadius);
    } else {
      // Draw recording state - multiple animated rings with particles
      _drawRecordingRings(canvas, center, baseRadius);
      _drawParticles(canvas, center, baseRadius);
    }
  }

  void _drawIdleRing(Canvas canvas, Offset center, double baseRadius) {
    final radius = baseRadius * (0.9 + pulseValue * 0.1);
    final opacity = 0.3 + pulseValue * 0.2;

    final paint = Paint()
      ..color = NeonColors.cyan.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, paint);

    // Add glow effect
    final glowPaint = Paint()
      ..color = NeonColors.cyanGlow.withValues(alpha: opacity * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawCircle(center, radius, glowPaint);
  }

  void _drawRecordingRings(Canvas canvas, Offset center, double baseRadius) {
    // Draw multiple expanding rings with different colors
    final colors = [NeonColors.cyan, NeonColors.purple, NeonColors.green];

    for (int i = 0; i < ringValues.length; i++) {
      final progress = ringValues[i];
      final radius = baseRadius * (0.5 + progress * 1.5);
      final opacity = 1.0 - progress;
      final color = colors[i % colors.length];

      // Main ring
      final paint = Paint()
        ..color = color.withValues(alpha: opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawCircle(center, radius, paint);

      // Glow effect
      final glowPaint = Paint()
        ..color = color.withValues(alpha: opacity * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, radius, glowPaint);
    }

    // Draw pulsing center ring
    final centerRadius = baseRadius * (0.8 + pulseValue * 0.2);
    final centerPaint = Paint()
      ..color = NeonColors.pink.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    canvas.drawCircle(center, centerRadius, centerPaint);

    final centerGlowPaint = Paint()
      ..color = NeonColors.pinkGlow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(center, centerRadius, centerGlowPaint);
  }

  void _drawParticles(Canvas canvas, Offset center, double baseRadius) {
    // Draw rotating particles around the rings
    final particleCount = 12;
    final rotation = rotationValue * 2 * math.pi;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi + rotation;
      final radius = baseRadius * (1.2 + math.sin(pulseValue * math.pi) * 0.2);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      final particleSize = 3.0 + pulseValue * 2.0;
      final color = i % 3 == 0
          ? NeonColors.cyan
          : i % 3 == 1
          ? NeonColors.purple
          : NeonColors.green;

      // Particle glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(Offset(x, y), particleSize * 2, glowPaint);

      // Particle core
      final particlePaint = Paint()..color = color;

      canvas.drawCircle(Offset(x, y), particleSize, particlePaint);
    }
  }

  @override
  bool shouldRepaint(_CircularPulsePainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue ||
        oldDelegate.rotationValue != rotationValue ||
        oldDelegate.ringValues != ringValues ||
        oldDelegate.isRecording != isRecording;
  }
}
