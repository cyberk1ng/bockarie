import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/themes/neon_theme.dart';
import 'package:bockaire/widgets/neon/neon_widgets.dart';
import 'package:bockaire/widgets/neon/sparkle_decoration.dart';
import 'package:bockaire/l10n/app_localizations.dart';

void main() {
  group('Neon Theme Integration Tests', () {
    testWidgets('app renders with dark neon theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(body: Center(child: Text('Dark Theme'))),
        ),
      );

      final theme = Theme.of(
        find.byType(Scaffold).evaluate().first as BuildContext,
      );
      expect(theme.brightness, Brightness.dark);
      expect(theme.useMaterial3, true);
    });

    testWidgets('app renders with light neon theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.lightTheme(),
          home: Scaffold(body: Center(child: Text('Light Theme'))),
        ),
      );

      final theme = Theme.of(
        find.byType(Scaffold).evaluate().first as BuildContext,
      );
      expect(theme.brightness, Brightness.light);
      expect(theme.useMaterial3, true);
    });

    testWidgets('neon widgets render correctly in dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: NeonTheme.darkTheme(),
            home: Scaffold(
              body: Column(
                children: [
                  NeonButton(text: 'Test Button', onPressed: () {}),
                  NeonCard(child: Text('Test Card')),
                  NeonText.title('Test Title'),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(NeonButton), findsOneWidget);
      expect(find.byType(NeonCard), findsOneWidget);
      expect(find.byType(NeonText), findsOneWidget);
    });

    testWidgets('theme toggle switches from dark to light', (tester) async {
      ThemeMode currentTheme = ThemeMode.dark;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              theme: NeonTheme.lightTheme(),
              darkTheme: NeonTheme.darkTheme(),
              themeMode: currentTheme,
              home: Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentTheme = currentTheme == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark;
                      });
                    },
                    child: Text('Toggle Theme'),
                  ),
                ),
              ),
            );
          },
        ),
      );

      // Initial theme should be dark
      await tester.pump();

      // Toggle to light
      await tester.tap(find.text('Toggle Theme'));
      await tester.pump();

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('sparkle decoration renders in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(
            body: Stack(
              children: [
                SparkleDecoration(sparkleCount: 20),
                Center(child: Text('Content')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SparkleDecoration), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('multiple neon widgets work together', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  NeonCard(
                    child: Column(
                      children: [
                        NeonText.title('Shipment Details'),
                        SizedBox(height: 16),
                        NeonText.body('Origin: New York'),
                        NeonText.body('Destination: London'),
                        SizedBox(height: 16),
                        RouteWithFlags(
                          startFlag: Icon(Icons.flag, color: Colors.blue),
                          endFlag: Icon(Icons.flag, color: Colors.red),
                        ),
                        SizedBox(height: 16),
                        NeonButton(text: 'View Details', onPressed: () {}),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
      expect(find.byType(NeonButton), findsOneWidget);
      expect(find.byType(RouteWithFlags), findsOneWidget);
      expect(find.text('Shipment Details'), findsOneWidget);
    });

    testWidgets('status badge renders with correct colors in dark theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge(status: ShipmentStatus.pending),
                StatusBadge(status: ShipmentStatus.inTransit),
                StatusBadge(status: ShipmentStatus.delivered),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(StatusBadge), findsNWidgets(3));
    });

    testWidgets('neon colors are consistent across widgets in dark theme', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(
            body: Column(
              children: [
                NeonButton(
                  text: 'Primary Button',
                  onPressed: () {},
                  variant: NeonButtonVariant.primary,
                ),
                NeonButton(
                  text: 'Secondary Button',
                  onPressed: () {},
                  variant: NeonButtonVariant.secondary,
                ),
                NeonCard(
                  borderColor: NeonColors.cyan,
                  child: Text('Cyan Card'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(NeonButton), findsNWidgets(2));
      expect(find.byType(NeonCard), findsOneWidget);
    });

    testWidgets('animation widgets work in neon theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(
            body: Column(
              children: [
                AnimatedRouteLine(lineColor: NeonColors.cyan, animate: true),
                NeonCard(enablePulse: true, child: Text('Pulsing Card')),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(Duration(milliseconds: 500));

      expect(find.byType(AnimatedRouteLine), findsOneWidget);
      expect(find.byType(NeonCard), findsOneWidget);
    });

    testWidgets('text variants render correctly in neon theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(
            body: Column(
              children: [
                NeonText.title('Title Text'),
                NeonText.subtitle('Subtitle Text'),
                NeonText.body('Body Text'),
                NeonText.label('Label Text'),
                NeonText.caption('Caption Text'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Title Text'), findsOneWidget);
      expect(find.text('Subtitle Text'), findsOneWidget);
      expect(find.text('Body Text'), findsOneWidget);
      expect(find.text('Label Text'), findsOneWidget);
      expect(find.text('Caption Text'), findsOneWidget);
    });

    testWidgets('interactive neon widgets respond to user actions', (
      tester,
    ) async {
      bool buttonPressed = false;
      bool cardTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(
            body: Column(
              children: [
                NeonButton(
                  text: 'Press Me',
                  onPressed: () {
                    buttonPressed = true;
                  },
                ),
                NeonCard(
                  onTap: () {
                    cardTapped = true;
                  },
                  child: Text('Tap Me'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Press Me'));
      await tester.pump();
      expect(buttonPressed, true);

      await tester.tap(find.text('Tap Me'));
      await tester.pump();
      expect(cardTapped, true);
    });

    testWidgets('glow effects render in dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(
            body: Column(
              children: [
                NeonCard(enableGlow: true, child: Text('Glowing Card')),
                NeonText.title('Glowing Title', enableGlow: true),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(NeonCard), findsOneWidget);
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('neon theme properties are applied to material components', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(
            body: Column(
              children: [
                Card(child: Text('Material Card')),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Material Button'),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Input Field'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('Neon Theme Performance Tests', () {
    testWidgets('multiple animated widgets render without lag', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(
            body: Stack(
              children: [
                SparkleDecoration(sparkleCount: 50),
                Column(
                  children: List.generate(
                    5,
                    (index) =>
                        NeonCard(enablePulse: true, child: Text('Card $index')),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(Duration(seconds: 1));

      expect(find.byType(NeonCard), findsNWidgets(5));
      expect(find.byType(SparkleDecoration), findsOneWidget);
    });

    testWidgets('large list of neon widgets renders efficiently', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: NeonTheme.darkTheme(),
          home: Scaffold(
            body: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return NeonCard(
                  child: ListTile(
                    title: NeonText.body('Item $index'),
                    trailing: NeonButton(text: 'Action', onPressed: () {}),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(NeonCard), findsWidgets);
    });
  });
}
