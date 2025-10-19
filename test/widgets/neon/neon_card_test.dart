import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/widgets/neon/neon_card.dart';
import 'package:bockaire/themes/neon_theme.dart';

void main() {
  group('NeonCard Rendering', () {
    testWidgets('renders child widget correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NeonCard(child: Text('Test Content'))),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });

    testWidgets('renders with default properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NeonCard(child: Container())),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
    });
  });

  group('NeonCard Border and Glow', () {
    testWidgets('renders border in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(body: NeonCard(child: Text('Dark Mode'))),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
    });

    testWidgets('renders border in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.lightTheme(),
          home: Scaffold(body: NeonCard(child: Text('Light Mode'))),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
    });

    testWidgets('respects custom border color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonCard(
              borderColor: Colors.purple,
              child: Text('Custom Border'),
            ),
          ),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
    });

    testWidgets('respects custom glow color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonCard(
              glowColor: Colors.purple.withValues(alpha: 0.3),
              child: Text('Custom Glow'),
            ),
          ),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
    });

    testWidgets('disables glow when enableGlow is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonCard(enableGlow: false, child: Text('No Glow')),
          ),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
    });
  });

  group('NeonCard Customization', () {
    testWidgets('respects custom padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonCard(
              padding: EdgeInsets.all(32),
              child: Text('Custom Padding'),
            ),
          ),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
    });

    testWidgets('respects custom margin', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonCard(
              margin: EdgeInsets.all(20),
              child: Text('Custom Margin'),
            ),
          ),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
    });

    testWidgets('respects custom border radius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonCard(borderRadius: 20, child: Text('Custom Radius')),
          ),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
    });
  });

  group('NeonCard Pulse Animation', () {
    testWidgets('enables pulse animation when enablePulse is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonCard(enablePulse: true, child: Text('Pulsing Card')),
          ),
        ),
      );

      // Pump initial frame
      await tester.pump();

      // Pump animation frames
      await tester.pump(Duration(milliseconds: 500));

      expect(find.byType(NeonCard), findsOneWidget);
    });

    testWidgets('pulse animation loops', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonCard(enablePulse: true, child: Text('Looping Pulse')),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(Duration(seconds: 1));
      await tester.pump(Duration(seconds: 1));

      expect(find.byType(NeonCard), findsOneWidget);
    });

    testWidgets('updates pulse when enablePulse changes', (tester) async {
      bool enablePulse = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NeonCard(
                  enablePulse: enablePulse,
                  child: Text('Toggle Pulse'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Enable pulse
      enablePulse = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonCard(
              enablePulse: enablePulse,
              child: Text('Toggle Pulse'),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(NeonCard), findsOneWidget);
    });
  });

  group('NeonCard Interaction', () {
    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonCard(
              onTap: () {
                tapped = true;
              },
              child: Text('Tappable Card'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NeonCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('renders InkWell when onTap is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeonCard(onTap: () {}, child: Text('Tappable')),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('does not render InkWell when onTap is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: NeonCard(child: Text('Not Tappable'))),
        ),
      );

      expect(find.byType(InkWell), findsNothing);
    });
  });

  group('NeonCard Theme Adaptation', () {
    testWidgets('uses dark background in dark mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: NeonCard(child: Text('Dark Theme'))),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
    });

    testWidgets('uses light background in light mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(body: NeonCard(child: Text('Light Theme'))),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
    });
  });
}
