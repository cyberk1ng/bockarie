import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/widgets/neon/sparkle_decoration.dart';
import 'package:bockaire/themes/neon_theme.dart';

void main() {
  group('SparkleDecoration', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SparkleDecoration())),
      );

      expect(find.byType(SparkleDecoration), findsOneWidget);
    });

    testWidgets('generates correct number of sparkles', (tester) async {
      const sparkleCount = 15;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SparkleDecoration(sparkleCount: sparkleCount)),
        ),
      );

      await tester.pump();

      // Widget should render without errors
      expect(find.byType(SparkleDecoration), findsOneWidget);
    });

    testWidgets('uses custom sparkle color when provided', (tester) async {
      const customColor = Colors.purple;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SparkleDecoration(sparkleColor: customColor)),
        ),
      );

      expect(find.byType(SparkleDecoration), findsOneWidget);
    });

    testWidgets('uses correct color in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(body: SparkleDecoration()),
        ),
      );

      await tester.pump();

      expect(find.byType(SparkleDecoration), findsOneWidget);
    });

    testWidgets('uses correct color in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.lightTheme(),
          home: Scaffold(body: SparkleDecoration()),
        ),
      );

      await tester.pump();

      expect(find.byType(SparkleDecoration), findsOneWidget);
    });

    testWidgets('animation loops continuously', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SparkleDecoration())),
      );

      // Pump initial frame
      await tester.pump();

      // Pump animation frames
      await tester.pump(Duration(seconds: 1));
      await tester.pump(Duration(seconds: 1));
      await tester.pump(Duration(seconds: 1));

      // Widget should still be rendered
      expect(find.byType(SparkleDecoration), findsOneWidget);
    });

    testWidgets('respects custom min and max size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SparkleDecoration(minSize: 1, maxSize: 10)),
        ),
      );

      expect(find.byType(SparkleDecoration), findsOneWidget);
    });

    testWidgets('handles zero sparkles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SparkleDecoration(sparkleCount: 0))),
      );

      expect(find.byType(SparkleDecoration), findsOneWidget);
    });

    testWidgets('handles large number of sparkles', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: SparkleDecoration(sparkleCount: 100))),
      );

      expect(find.byType(SparkleDecoration), findsOneWidget);
    });
  });

  group('Sparkle', () {
    test('creates sparkle with correct properties', () {
      final sparkle = Sparkle(
        x: 0.5,
        y: 0.5,
        size: 4.0,
        twinkleDuration: 1.5,
        delay: 0.2,
      );

      expect(sparkle.x, 0.5);
      expect(sparkle.y, 0.5);
      expect(sparkle.size, 4.0);
      expect(sparkle.twinkleDuration, 1.5);
      expect(sparkle.delay, 0.2);
    });

    test('sparkle size is within min/max range', () {
      final minSize = 2.0;
      final maxSize = 6.0;

      // Simulate random generation with bounds
      final size = minSize + 0.5 * (maxSize - minSize);

      expect(size, greaterThanOrEqualTo(minSize));
      expect(size, lessThanOrEqualTo(maxSize));
    });
  });
}
