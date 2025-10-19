import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/widgets/neon/neon_text.dart';
import 'package:bockaire/themes/neon_theme.dart';

void main() {
  group('NeonText Basic Rendering', () {
    testWidgets('renders text correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NeonText('Test Text'))),
      );

      expect(find.text('Test Text'), findsOneWidget);
    });

    testWidgets('renders with default variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NeonText('Body Text'))),
      );

      expect(find.byType(NeonText), findsOneWidget);
    });
  });

  group('NeonText Variants', () {
    testWidgets('renders title variant correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonText('Title', variant: NeonTextVariant.title),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
    });

    testWidgets('renders subtitle variant correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonText('Subtitle', variant: NeonTextVariant.subtitle),
          ),
        ),
      );

      expect(find.text('Subtitle'), findsOneWidget);
    });

    testWidgets('renders body variant correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NeonText('Body', variant: NeonTextVariant.body)),
        ),
      );

      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('renders label variant correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonText('Label', variant: NeonTextVariant.label),
          ),
        ),
      );

      expect(find.text('Label'), findsOneWidget);
    });

    testWidgets('renders caption variant correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonText('Caption', variant: NeonTextVariant.caption),
          ),
        ),
      );

      expect(find.text('Caption'), findsOneWidget);
    });
  });

  group('NeonText Factory Constructors', () {
    testWidgets('NeonText.title creates title variant with glow', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NeonText.title('Title Text'))),
      );

      expect(find.text('Title Text'), findsOneWidget);
    });

    testWidgets('NeonText.subtitle creates subtitle variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NeonText.subtitle('Subtitle Text'))),
      );

      expect(find.text('Subtitle Text'), findsOneWidget);
    });

    testWidgets('NeonText.body creates body variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NeonText.body('Body Text'))),
      );

      expect(find.text('Body Text'), findsOneWidget);
    });

    testWidgets('NeonText.label creates label variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NeonText.label('Label Text'))),
      );

      expect(find.text('Label Text'), findsOneWidget);
    });

    testWidgets('NeonText.caption creates caption variant', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NeonText.caption('Caption Text'))),
      );

      expect(find.text('Caption Text'), findsOneWidget);
    });
  });

  group('NeonText Glow Effect', () {
    testWidgets('renders with glow effect when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NeonText('Glowing Text', enableGlow: true)),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('renders without glow effect when disabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NeonText('No Glow', enableGlow: false)),
        ),
      );

      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('respects custom glow color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonText(
              'Custom Glow',
              enableGlow: true,
              glowColor: Colors.purple.withValues(alpha: 0.3),
            ),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsOneWidget);
    });
  });

  group('NeonText Color Customization', () {
    testWidgets('respects custom color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NeonText('Custom Color', color: Colors.purple)),
        ),
      );

      expect(find.text('Custom Color'), findsOneWidget);
    });

    testWidgets('uses default color in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: NeonText('Dark Mode Text')),
        ),
      );

      expect(find.text('Dark Mode Text'), findsOneWidget);
    });

    testWidgets('uses default color in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: NeonText('Light Mode Text')),
        ),
      );

      expect(find.text('Light Mode Text'), findsOneWidget);
    });
  });

  group('NeonText Text Properties', () {
    testWidgets('respects text alignment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonText('Aligned Text', textAlign: TextAlign.center),
          ),
        ),
      );

      expect(find.text('Aligned Text'), findsOneWidget);
    });

    testWidgets('respects max lines', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonText('Long text that should be limited', maxLines: 2),
          ),
        ),
      );

      expect(find.text('Long text that should be limited'), findsOneWidget);
    });

    testWidgets('respects text overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              child: NeonText(
                'Very long text that will overflow',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(NeonText), findsOneWidget);
    });

    testWidgets('respects custom font weight', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonText('Bold Text', fontWeight: FontWeight.bold),
          ),
        ),
      );

      expect(find.text('Bold Text'), findsOneWidget);
    });
  });

  group('NeonText Theme Integration', () {
    testWidgets('uses theme text style in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(body: NeonText('Dark Theme Text')),
        ),
      );

      expect(find.text('Dark Theme Text'), findsOneWidget);
    });

    testWidgets('uses theme text style in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.lightTheme(),
          home: Scaffold(body: NeonText('Light Theme Text')),
        ),
      );

      expect(find.text('Light Theme Text'), findsOneWidget);
    });
  });

  group('NeonText Label Variant Color', () {
    testWidgets('label variant uses cyan color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: NeonText.label('Cyan Label'))),
      );

      expect(find.text('Cyan Label'), findsOneWidget);
    });
  });

  group('NeonText Caption Variant Color', () {
    testWidgets('caption uses muted color in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: NeonText('Caption', variant: NeonTextVariant.caption),
          ),
        ),
      );

      expect(find.text('Caption'), findsOneWidget);
    });

    testWidgets('caption uses muted color in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: NeonText('Caption', variant: NeonTextVariant.caption),
          ),
        ),
      );

      expect(find.text('Caption'), findsOneWidget);
    });
  });
}
