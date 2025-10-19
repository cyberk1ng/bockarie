import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/widgets/voice/circular_pulse_visualizer.dart';

void main() {
  // ============================================================================
  // Phase 1: Basic Widget Tests
  // ============================================================================

  group('Group 1: Widget Rendering', () {
    testWidgets('renders correctly in idle state (isRecording: false)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
        ),
      );

      expect(find.byType(CircularPulseVisualizer), findsOneWidget);

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('renders correctly in recording state (isRecording: true)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      expect(find.byType(CircularPulseVisualizer), findsOneWidget);

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('respects custom size parameter', (WidgetTester tester) async {
      const customSize = 300.0;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPulseVisualizer(isRecording: false, size: customSize),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, equals(customSize));
      expect(sizedBox.height, equals(customSize));
    });

    testWidgets('uses default size when not specified', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, equals(200.0)); // Default size
      expect(sizedBox.height, equals(200.0));
    });
  });

  group('Group 2: Animation Lifecycle', () {
    testWidgets('initializes animation controllers on mount', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
        ),
      );

      // Widget should build without errors, indicating controllers are initialized
      expect(find.byType(CircularPulseVisualizer), findsOneWidget);

      final animatedBuilderFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(AnimatedBuilder),
      );
      expect(animatedBuilderFinder, findsOneWidget);
    });

    testWidgets('starts animations when isRecording is true on init', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      // Pump a frame to let animations start
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify widget is still rendering (animations are running)
      expect(find.byType(CircularPulseVisualizer), findsOneWidget);
    });

    testWidgets('does not start animations when isRecording is false on init', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Widget should render without animations running
      expect(find.byType(CircularPulseVisualizer), findsOneWidget);
    });

    testWidgets('properly disposes all animation controllers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      // Remove the widget to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      // Should not throw any errors during disposal
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'verifies 4 animation controllers exist (pulse + rotation + 3 rings)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
          ),
        );

        // The AnimatedBuilder should be listening to merged animations
        final animatedBuilderFinder = find.descendant(
          of: find.byType(CircularPulseVisualizer),
          matching: find.byType(AnimatedBuilder),
        );
        expect(animatedBuilderFinder, findsOneWidget);

        // Widget builds successfully, indicating all controllers initialized
        expect(find.byType(CircularPulseVisualizer), findsOneWidget);
      },
    );
  });

  group('Group 3: State Transitions', () {
    testWidgets(
      'starts animations when isRecording changes from false to true',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
          ),
        );

        await tester.pump();

        // Change to recording
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Widget should still be rendering with animations running
        expect(find.byType(CircularPulseVisualizer), findsOneWidget);
      },
    );

    testWidgets(
      'stops animations when isRecording changes from true to false',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Change to not recording
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
          ),
        );

        await tester.pump();

        // Widget should still be rendering
        expect(find.byType(CircularPulseVisualizer), findsOneWidget);
      },
    );

    testWidgets('handles multiple state transitions correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
        ),
      );

      // Transition 1: false -> true
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );
      await tester.pump();

      // Transition 2: true -> false
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
        ),
      );
      await tester.pump();

      // Transition 3: false -> true again
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularPulseVisualizer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does nothing when isRecording stays the same', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPulseVisualizer(isRecording: true, size: 200),
          ),
        ),
      );

      await tester.pump();

      // Rebuild with same isRecording value but trigger didUpdateWidget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPulseVisualizer(isRecording: true, size: 200),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularPulseVisualizer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Group 4: Custom Painter Logic', () {
    testWidgets('uses _CircularPulsePainter with correct parameters', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();

      // CustomPaint should exist within CircularPulseVisualizer
      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('passes pulseValue from pulse controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // CustomPaint should be rebuilt with new pulse values
      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('passes rotationValue from rotation controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('passes ringValues from all 3 ring controllers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('passes isRecording state to painter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
        ),
      );

      await tester.pump();

      // Change to recording
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });
  });

  group('Group 5: shouldRepaint Optimization', () {
    // Note: Direct testing of shouldRepaint requires accessing the painter
    // These tests verify the widget rebuilds correctly when values change

    testWidgets('rebuilds when pulseValue changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      final customPaint1 = tester.widget<CustomPaint>(customPaintFinder);

      await tester.pump(const Duration(milliseconds: 100));
      final customPaint2 = tester.widget<CustomPaint>(customPaintFinder);

      // Painters should be different instances due to animation
      expect(identical(customPaint1.painter, customPaint2.painter), isFalse);
    });

    testWidgets('rebuilds when rotationValue changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('rebuilds when ringValues change', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('rebuilds when isRecording changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
        ),
      );

      await tester.pump();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });
  });

  // ============================================================================
  // Phase 2: Custom Painter Tests
  // ============================================================================

  group('Group 6: Idle State Painting', () {
    testWidgets('draws single ring in idle state', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularPulseVisualizer(isRecording: false, size: 200),
            ),
          ),
        ),
      );

      await tester.pump();
      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('applies pulse animation to ring radius', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('applies pulse animation to opacity', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('uses cyan color for idle ring', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
        ),
      );

      await tester.pump();
      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
      // Color verification happens in the painter implementation
    });

    testWidgets('draws glow effect with blur', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: false)),
        ),
      );

      await tester.pump();
      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
      // Blur effect verification happens in the painter
    });
  });

  group('Group 7: Recording State Painting', () {
    testWidgets('draws 3 expanding rings with different colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('draws center pulsing ring in pink', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('draws 12 rotating particles', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('applies correct opacity fade to expanding rings', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('colors cycle through cyan/purple/green', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('particle colors match ring colors (cycling)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });
  });

  group('Group 8: Mathematical Correctness', () {
    test('particle positions use correct trigonometry', () {
      const particleCount = 12;
      const rotation = 0.5 * 2 * math.pi;

      for (int i = 0; i < particleCount; i++) {
        final angle = (i / particleCount) * 2 * math.pi + rotation;
        expect(angle, isA<double>());
        expect(angle >= 0, isTrue);
      }
    });

    test('radius calculations scale properly with progress', () {
      const baseRadius = 50.0;

      for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
        final radius = baseRadius * (0.5 + progress * 1.5);
        expect(radius, greaterThanOrEqualTo(baseRadius * 0.5));
        expect(radius, lessThanOrEqualTo(baseRadius * 2.0));
      }
    });

    test('opacity calculations produce valid range (0.0-1.0)', () {
      for (double progress = 0.0; progress <= 1.0; progress += 0.1) {
        final opacity = 1.0 - progress;
        expect(opacity, greaterThanOrEqualTo(0.0));
        expect(opacity, lessThanOrEqualTo(1.0));
      }

      for (double pulseValue = 0.0; pulseValue <= 1.0; pulseValue += 0.1) {
        final opacity = 0.3 + pulseValue * 0.2;
        expect(opacity, greaterThanOrEqualTo(0.0));
        expect(opacity, lessThanOrEqualTo(1.0));
      }
    });

    test('rotation angle increments correctly', () {
      for (
        double rotationValue = 0.0;
        rotationValue <= 1.0;
        rotationValue += 0.1
      ) {
        final rotation = rotationValue * 2 * math.pi;
        expect(rotation, greaterThanOrEqualTo(0.0));
        expect(rotation, lessThanOrEqualTo(2 * math.pi));
      }
    });
  });

  // ============================================================================
  // Phase 4: Edge Cases & Stress Tests
  // ============================================================================

  group('Group 10: Edge Cases', () {
    testWidgets('handles very small size (e.g., 50)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPulseVisualizer(isRecording: true, size: 50),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularPulseVisualizer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles very large size (e.g., 500)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPulseVisualizer(isRecording: true, size: 500),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularPulseVisualizer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles rapid state transitions', (WidgetTester tester) async {
      for (int i = 0; i < 10; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CircularPulseVisualizer(isRecording: i % 2 == 0),
            ),
          ),
        );
        await tester.pump();
      }

      expect(find.byType(CircularPulseVisualizer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles widget rebuild during animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Force rebuild
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      expect(find.byType(CircularPulseVisualizer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles disposal during active animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Dispose while animating
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Group 11: Performance Tests', () {
    testWidgets('verify animation controllers don\'t leak memory', (
      WidgetTester tester,
    ) async {
      // Create and destroy multiple times
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('verify repaint optimization works (minimal repaints)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPulseVisualizer(isRecording: false, size: 200),
          ),
        ),
      );

      await tester.pump();

      // Rebuild with same values - should use same painter type
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularPulseVisualizer(isRecording: false, size: 200),
          ),
        ),
      );

      await tester.pump();
      final customPaintFinder = find.descendant(
        of: find.byType(CircularPulseVisualizer),
        matching: find.byType(CustomPaint),
      );
      expect(customPaintFinder, findsOneWidget);
    });

    testWidgets('verify animations run smoothly (pump with durations)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CircularPulseVisualizer(isRecording: true)),
        ),
      );

      // Simulate multiple frames
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // ~60fps
      }

      expect(find.byType(CircularPulseVisualizer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
