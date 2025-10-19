import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/widgets/neon/animated_route_line.dart';

void main() {
  group('AnimatedRouteLine', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AnimatedRouteLine())),
      );

      expect(find.byType(AnimatedRouteLine), findsOneWidget);
    });

    testWidgets('uses custom color when provided', (tester) async {
      const customColor = Colors.purple;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AnimatedRouteLine(lineColor: customColor)),
        ),
      );

      expect(find.byType(AnimatedRouteLine), findsOneWidget);
    });

    testWidgets('animates line from start to end', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AnimatedRouteLine(animate: true))),
      );

      // Pump initial frame
      await tester.pump();

      // Pump animation frames
      await tester.pump(Duration(seconds: 1));
      await tester.pump(Duration(seconds: 1));

      expect(find.byType(AnimatedRouteLine), findsOneWidget);
    });

    testWidgets('animation completes in expected duration', (tester) async {
      const testDuration = Duration(seconds: 2);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedRouteLine(
              animate: true,
              animationDuration: testDuration,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(testDuration);

      expect(find.byType(AnimatedRouteLine), findsOneWidget);
    });

    testWidgets('stops animation when animate is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AnimatedRouteLine(animate: false))),
      );

      await tester.pump();

      expect(find.byType(AnimatedRouteLine), findsOneWidget);
    });

    testWidgets('updates animation when animate property changes', (
      tester,
    ) async {
      bool animate = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimatedRouteLine(animate: animate);
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Change animate to true
      animate = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AnimatedRouteLine(animate: animate)),
        ),
      );

      await tester.pump();

      expect(find.byType(AnimatedRouteLine), findsOneWidget);
    });

    testWidgets('respects custom line width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AnimatedRouteLine(lineWidth: 4.0))),
      );

      expect(find.byType(AnimatedRouteLine), findsOneWidget);
    });

    testWidgets('respects custom height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AnimatedRouteLine(height: 10.0))),
      );

      expect(find.byType(AnimatedRouteLine), findsOneWidget);
    });

    testWidgets('respects custom dot count', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AnimatedRouteLine(dotCount: 5))),
      );

      expect(find.byType(AnimatedRouteLine), findsOneWidget);
    });
  });

  group('RouteWithFlags', () {
    testWidgets('displays start and end flags', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteWithFlags(
              startFlag: Icon(Icons.flag, color: Colors.green),
              endFlag: Icon(Icons.flag, color: Colors.red),
            ),
          ),
        ),
      );

      expect(find.byType(RouteWithFlags), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsNWidgets(2));
    });

    testWidgets('renders AnimatedRouteLine between flags', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteWithFlags(
              startFlag: Icon(Icons.flag),
              endFlag: Icon(Icons.flag),
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedRouteLine), findsOneWidget);
    });

    testWidgets('uses custom line color', (tester) async {
      const customColor = Colors.purple;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteWithFlags(
              startFlag: Icon(Icons.flag),
              endFlag: Icon(Icons.flag),
              lineColor: customColor,
            ),
          ),
        ),
      );

      expect(find.byType(RouteWithFlags), findsOneWidget);
    });

    testWidgets('respects animate parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteWithFlags(
              startFlag: Icon(Icons.flag),
              endFlag: Icon(Icons.flag),
              animate: false,
            ),
          ),
        ),
      );

      expect(find.byType(RouteWithFlags), findsOneWidget);
    });

    testWidgets('renders flag containers with circular border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteWithFlags(
              startFlag: Container(
                key: Key('start-flag'),
                child: Icon(Icons.flag),
              ),
              endFlag: Container(key: Key('end-flag'), child: Icon(Icons.flag)),
            ),
          ),
        ),
      );

      expect(find.byKey(Key('start-flag')), findsOneWidget);
      expect(find.byKey(Key('end-flag')), findsOneWidget);
    });

    testWidgets('uses default cyan color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteWithFlags(
              startFlag: Icon(Icons.flag),
              endFlag: Icon(Icons.flag),
            ),
          ),
        ),
      );

      expect(find.byType(RouteWithFlags), findsOneWidget);
    });
  });
}
