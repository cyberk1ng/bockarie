import 'package:flutter/material.dart';
import 'package:bockaire/themes/neon_theme.dart';

/// An animated line widget with moving dots that simulates a route
class AnimatedRouteLine extends StatefulWidget {
  final Color lineColor;
  final double lineWidth;
  final double height;
  final bool animate;
  final int dotCount;
  final Duration animationDuration;

  const AnimatedRouteLine({
    super.key,
    this.lineColor = NeonColors.cyan,
    this.lineWidth = 2.0,
    this.height = 2.0,
    this.animate = true,
    this.dotCount = 3,
    this.animationDuration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedRouteLine> createState() => _AnimatedRouteLineState();
}

class _AnimatedRouteLineState extends State<AnimatedRouteLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedRouteLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.repeat();
    } else if (!widget.animate && oldWidget.animate) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height + 8, // Extra space for dot size
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RouteLinePainter(
              lineColor: widget.lineColor,
              lineWidth: widget.lineWidth,
              animationProgress: _controller.value,
              dotCount: widget.dotCount,
              animate: widget.animate,
            ),
            child: Container(),
          );
        },
      ),
    );
  }
}

class _RouteLinePainter extends CustomPainter {
  final Color lineColor;
  final double lineWidth;
  final double animationProgress;
  final int dotCount;
  final bool animate;

  _RouteLinePainter({
    required this.lineColor,
    required this.lineWidth,
    required this.animationProgress,
    required this.dotCount,
    required this.animate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the main line
    final linePaint = Paint()
      ..color = lineColor.withValues(alpha: 0.3)
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = size.height / 2;

    // Create a curved path
    path.moveTo(0, centerY);

    // Create a gentle curve using quadratic bezier
    final controlPoint1 = Offset(size.width * 0.25, centerY - 10);
    final endPoint1 = Offset(size.width * 0.5, centerY);
    path.quadraticBezierTo(
      controlPoint1.dx,
      controlPoint1.dy,
      endPoint1.dx,
      endPoint1.dy,
    );

    final controlPoint2 = Offset(size.width * 0.75, centerY + 10);
    final endPoint2 = Offset(size.width, centerY);
    path.quadraticBezierTo(
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint2.dx,
      endPoint2.dy,
    );

    canvas.drawPath(path, linePaint);

    // Draw gradient line on top
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withValues(alpha: 0.1),
          lineColor.withValues(alpha: 0.6),
          lineColor.withValues(alpha: 0.1),
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, gradientPaint);

    // Draw moving dots if animation is enabled
    if (animate) {
      final dotPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;

      final glowPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < dotCount; i++) {
        final dotProgress = (animationProgress + (i / dotCount)) % 1.0;
        final dotX = size.width * dotProgress;

        // Calculate Y position on the curve
        double dotY;
        if (dotProgress < 0.5) {
          final t = dotProgress * 2;
          dotY = _quadraticBezier(centerY, controlPoint1.dy, endPoint1.dy, t);
        } else {
          final t = (dotProgress - 0.5) * 2;
          dotY = _quadraticBezier(
            endPoint1.dy,
            controlPoint2.dy,
            endPoint2.dy,
            t,
          );
        }

        final dotPosition = Offset(dotX, dotY);

        // Draw glow
        canvas.drawCircle(dotPosition, 6, glowPaint);

        // Draw dot
        canvas.drawCircle(dotPosition, 3, dotPaint);
      }
    }
  }

  double _quadraticBezier(double p0, double p1, double p2, double t) {
    final oneMinusT = 1 - t;
    return oneMinusT * oneMinusT * p0 + 2 * oneMinusT * t * p1 + t * t * p2;
  }

  @override
  bool shouldRepaint(_RouteLinePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.animate != animate;
  }
}

/// A widget that shows a route between two points with flags/icons
class RouteWithFlags extends StatelessWidget {
  final Widget startFlag;
  final Widget endFlag;
  final Color lineColor;
  final bool animate;

  const RouteWithFlags({
    super.key,
    required this.startFlag,
    required this.endFlag,
    this.lineColor = NeonColors.cyan,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Start flag container
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: lineColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: lineColor.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(child: startFlag),
        ),

        // Animated route line
        Expanded(
          child: AnimatedRouteLine(lineColor: lineColor, animate: animate),
        ),

        // End flag container
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: lineColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: lineColor.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(child: endFlag),
        ),
      ],
    );
  }
}
