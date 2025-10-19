import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bockaire/widgets/neon/status_badge.dart';
import 'package:bockaire/themes/neon_theme.dart';
import 'package:bockaire/l10n/app_localizations.dart';

void main() {
  Widget buildTestWidget(Widget child, {Brightness? brightness}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: brightness == Brightness.light
          ? NeonTheme.lightTheme()
          : NeonTheme.darkTheme(),
      home: Scaffold(body: child),
    );
  }

  group('StatusBadge Basic Rendering', () {
    testWidgets('renders inTransit status correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.inTransit)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    });

    testWidgets('renders delivered status correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.delivered)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('renders pending status correctly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.pending)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusBadge), findsOneWidget);
      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    });
  });

  group('StatusBadge Status Icons', () {
    testWidgets('inTransit shows shipping icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.inTransit)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
    });

    testWidgets('delivered shows check circle icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.delivered)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('pending shows schedule icon', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.pending)),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.schedule_outlined), findsOneWidget);
    });
  });

  group('StatusBadge Localized Text', () {
    testWidgets('inTransit displays localized text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.inTransit)),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(StatusBadge));
      final localizations = AppLocalizations.of(context)!;

      expect(find.text(localizations.statusInTransit), findsOneWidget);
    });

    testWidgets('delivered displays localized text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.delivered)),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(StatusBadge));
      final localizations = AppLocalizations.of(context)!;

      expect(find.text(localizations.statusDelivered), findsOneWidget);
    });

    testWidgets('pending displays localized text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.pending)),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(StatusBadge));
      final localizations = AppLocalizations.of(context)!;

      expect(find.text(localizations.statusPending), findsOneWidget);
    });
  });

  group('StatusBadge Localization in Different Languages', () {
    testWidgets('displays French localization for inTransit', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('fr'),
          home: Scaffold(body: StatusBadge(status: ShipmentStatus.inTransit)),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(StatusBadge));
      final localizations = AppLocalizations.of(context)!;

      expect(find.text(localizations.statusInTransit), findsOneWidget);
    });

    testWidgets('displays Spanish localization for delivered', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('es'),
          home: Scaffold(body: StatusBadge(status: ShipmentStatus.delivered)),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(StatusBadge));
      final localizations = AppLocalizations.of(context)!;

      expect(find.text(localizations.statusDelivered), findsOneWidget);
    });

    testWidgets('displays German localization for pending', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(body: StatusBadge(status: ShipmentStatus.pending)),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(StatusBadge));
      final localizations = AppLocalizations.of(context)!;

      expect(find.text(localizations.statusPending), findsOneWidget);
    });
  });

  group('StatusBadge Status Colors', () {
    testWidgets('inTransit uses cyan color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.inTransit)),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, NeonColors.cyan);
    });

    testWidgets('delivered uses green color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.delivered)),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, NeonColors.green);
    });

    testWidgets('pending uses purple color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.pending)),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, NeonColors.purple);
    });
  });

  group('StatusBadge Custom Color Overrides', () {
    testWidgets('respects custom color override', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          StatusBadge(status: ShipmentStatus.inTransit, color: Colors.red),
        ),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, Colors.red);
    });

    testWidgets('respects custom backgroundColor override', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          StatusBadge(
            status: ShipmentStatus.pending,
            backgroundColor: Colors.blue.withValues(alpha: 0.2),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('custom color overrides default status color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          StatusBadge(status: ShipmentStatus.delivered, color: Colors.orange),
        ),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.color, Colors.orange);
      expect(icon.color, isNot(NeonColors.green));
    });
  });

  group('StatusBadge Theme Adaptation', () {
    testWidgets('adapts background color in dark theme', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          StatusBadge(status: ShipmentStatus.inTransit),
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('adapts background color in light theme', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          StatusBadge(status: ShipmentStatus.delivered),
          brightness: Brightness.light,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('maintains status color across themes', (tester) async {
      // Test in dark theme
      await tester.pumpWidget(
        buildTestWidget(
          StatusBadge(status: ShipmentStatus.pending),
          brightness: Brightness.dark,
        ),
      );
      await tester.pumpAndSettle();

      var icon = tester.widget<Icon>(find.byType(Icon));
      final darkThemeColor = icon.color;

      // Test in light theme
      await tester.pumpWidget(
        buildTestWidget(
          StatusBadge(status: ShipmentStatus.pending),
          brightness: Brightness.light,
        ),
      );
      await tester.pumpAndSettle();

      icon = tester.widget<Icon>(find.byType(Icon));
      final lightThemeColor = icon.color;

      // Status color should be the same regardless of theme
      expect(darkThemeColor, lightThemeColor);
      expect(darkThemeColor, NeonColors.purple);
    });
  });

  group('StatusBadge Layout', () {
    testWidgets('has icon and text in row', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.inTransit)),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('icon appears before text', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.delivered)),
      );
      await tester.pumpAndSettle();

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, 3); // Icon, SizedBox, Text
      expect(row.children[0], isA<Icon>());
      expect(row.children[1], isA<SizedBox>()); // Spacer
      expect(row.children[2], isA<Text>());
    });

    testWidgets('has correct padding', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.pending)),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(Container),
        ),
      );

      expect(
        container.padding,
        EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      );
    });

    testWidgets('has rounded corners', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.inTransit)),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('has border with status color', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.delivered)),
      );
      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(Container),
        ),
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });
  });

  group('StatusBadge Icon Size and Text Style', () {
    testWidgets('icon has correct size', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.inTransit)),
      );
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.size, 14);
    });

    testWidgets('text has correct font size', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.delivered)),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontSize, 12);
    });

    testWidgets('text has correct font weight', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.pending)),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('text has correct letter spacing', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(StatusBadge(status: ShipmentStatus.inTransit)),
      );
      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style?.letterSpacing, 0.3);
    });
  });

  group('StatusBadge All Status Types', () {
    testWidgets('all status types render without errors', (tester) async {
      for (final status in ShipmentStatus.values) {
        await tester.pumpWidget(buildTestWidget(StatusBadge(status: status)));
        await tester.pumpAndSettle();

        expect(find.byType(StatusBadge), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });
  });
}
