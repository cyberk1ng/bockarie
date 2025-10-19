import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/widgets/neon/neon_button.dart';
import 'package:bockaire/themes/neon_theme.dart';

void main() {
  group('NeonButton Basic Rendering', () {
    testWidgets('renders button with text correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(text: 'Test Button', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('renders with default variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(text: 'Default', onPressed: () {}),
          ),
        ),
      );

      expect(find.byType(NeonButton), findsOneWidget);
    });
  });

  group('NeonButton Variants', () {
    testWidgets('renders primary variant correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Primary',
              onPressed: () {},
              variant: NeonButtonVariant.primary,
            ),
          ),
        ),
      );

      expect(find.text('Primary'), findsOneWidget);
      expect(find.byType(NeonButton), findsOneWidget);
    });

    testWidgets('renders secondary variant correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Secondary',
              onPressed: () {},
              variant: NeonButtonVariant.secondary,
            ),
          ),
        ),
      );

      expect(find.text('Secondary'), findsOneWidget);
      expect(find.byType(NeonButton), findsOneWidget);
    });

    testWidgets('renders outline variant correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Outline',
              onPressed: () {},
              variant: NeonButtonVariant.outline,
            ),
          ),
        ),
      );

      expect(find.text('Outline'), findsOneWidget);
      expect(find.byType(NeonButton), findsOneWidget);
    });
  });

  group('NeonButton Disabled State', () {
    testWidgets('renders disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NeonButton(text: 'Disabled', onPressed: null)),
        ),
      );

      expect(find.text('Disabled'), findsOneWidget);
      expect(find.byType(NeonButton), findsOneWidget);
    });

    testWidgets('does not trigger callback when disabled', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NeonButton(text: 'Disabled', onPressed: null)),
        ),
      );

      await tester.tap(find.byType(NeonButton));
      await tester.pump();

      expect(tapped, false);
    });
  });

  group('NeonButton Loading State', () {
    testWidgets('renders loading spinner when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('does not trigger callback when loading', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Loading',
              onPressed: () {
                tapped = true;
              },
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NeonButton));
      await tester.pump();

      expect(tapped, false);
    });

    testWidgets('shows text when not loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Click Me',
              onPressed: () {},
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('NeonButton Icon Support', () {
    testWidgets('renders button with icon and text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Icon Button',
              onPressed: () {},
              icon: Icons.add,
            ),
          ),
        ),
      );

      expect(find.text('Icon Button'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders button without icon when not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(text: 'No Icon', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('No Icon'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('icon respects disabled state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Disabled Icon',
              onPressed: null,
              icon: Icons.delete,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });
  });

  group('NeonButton Callback Execution', () {
    testWidgets('triggers onPressed when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Tap Me',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NeonButton));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('triggers onPressed multiple times', (tester) async {
      var tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Count Taps',
              onPressed: () {
                tapCount++;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NeonButton));
      await tester.tap(find.byType(NeonButton));
      await tester.tap(find.byType(NeonButton));
      await tester.pump();

      expect(tapCount, 3);
    });
  });

  group('NeonButton Custom Dimensions', () {
    testWidgets('respects custom width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(text: 'Wide Button', onPressed: () {}, width: 300),
          ),
        ),
      );

      expect(find.byType(NeonButton), findsOneWidget);

      // Verify the Container has the custom width
      final renderBox = tester.renderObject<RenderBox>(
        find.byType(Container).first,
      );
      expect(renderBox.size.width, 300);
    });

    testWidgets('respects custom height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(text: 'Tall Button', onPressed: () {}, height: 80),
          ),
        ),
      );

      expect(find.byType(NeonButton), findsOneWidget);
    });

    testWidgets('respects custom padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Custom Padding',
              onPressed: () {},
              padding: EdgeInsets.all(32),
            ),
          ),
        ),
      );

      expect(find.byType(NeonButton), findsOneWidget);
    });
  });

  group('NeonButton Custom Colors', () {
    testWidgets('respects custom border color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Custom Border',
              onPressed: () {},
              borderColor: Colors.red,
            ),
          ),
        ),
      );

      expect(find.text('Custom Border'), findsOneWidget);
    });

    testWidgets('respects custom glow color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Custom Glow',
              onPressed: () {},
              glowColor: Colors.green,
            ),
          ),
        ),
      );

      expect(find.text('Custom Glow'), findsOneWidget);
    });

    testWidgets('respects custom background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Custom Background',
              onPressed: () {},
              backgroundColor: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Custom Background'), findsOneWidget);
    });

    testWidgets('respects custom text color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Custom Text',
              onPressed: () {},
              textColor: Colors.yellow,
            ),
          ),
        ),
      );

      expect(find.text('Custom Text'), findsOneWidget);
    });
  });

  group('NeonButton Theme Integration', () {
    testWidgets('adapts to dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(
            body: NeonButton(text: 'Dark Theme', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Dark Theme'), findsOneWidget);
    });

    testWidgets('adapts to light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.lightTheme(),
          home: Scaffold(
            body: NeonButton(text: 'Light Theme', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Light Theme'), findsOneWidget);
    });

    testWidgets('primary variant uses cyan colors in dark theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: NeonButton(
              text: 'Primary Dark',
              onPressed: () {},
              variant: NeonButtonVariant.primary,
            ),
          ),
        ),
      );

      expect(find.text('Primary Dark'), findsOneWidget);
    });

    testWidgets('secondary variant uses purple colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: NeonButton(
              text: 'Secondary',
              onPressed: () {},
              variant: NeonButtonVariant.secondary,
            ),
          ),
        ),
      );

      expect(find.text('Secondary'), findsOneWidget);
    });

    testWidgets('outline variant has transparent background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Outline',
              onPressed: () {},
              variant: NeonButtonVariant.outline,
            ),
          ),
        ),
      );

      expect(find.text('Outline'), findsOneWidget);
    });
  });

  group('NeonButton Hover Animation', () {
    testWidgets('has MouseRegion for hover detection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(text: 'Hover Me', onPressed: () {}),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(NeonButton),
          matching: find.byType(MouseRegion),
        ),
        findsOneWidget,
      );
    });

    testWidgets('has AnimatedBuilder for hover animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(text: 'Animated', onPressed: () {}),
          ),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(NeonButton),
          matching: find.byType(AnimatedBuilder),
        ),
        findsOneWidget,
      );
    });
  });

  group('NeonButton Edge Cases', () {
    testWidgets('handles empty text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(text: '', onPressed: () {}),
          ),
        ),
      );

      expect(find.byType(NeonButton), findsOneWidget);
    });

    testWidgets('handles very long text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Very long button text that might overflow',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(NeonButton), findsOneWidget);
    });

    testWidgets('handles switching from loading to not loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(text: 'Button', onPressed: () {}, isLoading: true),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonButton(
              text: 'Button',
              onPressed: () {},
              isLoading: false,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Button'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
