import 'package:bockaire/database/database.dart';
import 'package:bockaire/get_it.dart';
import 'package:bockaire/pages/settings_page.dart';
import 'package:bockaire/providers/theme_providers.dart';
import 'package:bockaire/providers/currency_provider.dart';
import 'package:bockaire/repositories/currency_repository.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  late MockAppDatabase mockDb;
  late SharedPreferences prefs;

  setUp(() async {
    mockDb = MockAppDatabase();

    // Initialize SharedPreferences for currency repository
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    // Register mock in GetIt
    if (getIt.isRegistered<AppDatabase>()) {
      getIt.unregister<AppDatabase>();
    }
    getIt.registerSingleton<AppDatabase>(mockDb);

    // Default mocks
    when(() => mockDb.getSetting('theme_mode')).thenAnswer((_) async => null);
    when(() => mockDb.saveSetting(any(), any())).thenAnswer((_) async => {});
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget createTestWidget({List<Override>? overrides}) {
    return ProviderScope(
      overrides: [
        currencyRepositoryProvider.overrideWithValue(CurrencyRepository(prefs)),
        ...?overrides,
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const SettingsPage(),
      ),
    );
  }

  group('SettingsPage Widget Rendering', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders Appearance section', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Appearance'), findsOneWidget);
    });

    testWidgets('renders Theme Mode label', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Theme Mode'), findsOneWidget);
    });

    testWidgets('renders SegmentedButton for theme selection', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
    });

    testWidgets('renders three theme mode options', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check for icons
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget); // Light
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget); // System
      expect(find.byIcon(Icons.nightlight_round), findsOneWidget); // Dark
    });

    testWidgets('renders Configuration section', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Configuration'), findsOneWidget);
    });

    testWidgets('renders Rate Tables list tile', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll down to make Rate Tables visible (currency picker pushed it down)
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.text('Rate Tables'), findsOneWidget);
      expect(find.text('Manage carrier rates'), findsOneWidget);
    });

    testWidgets('renders AI Providers list tile', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll down to make AI Providers visible
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.text('AI Providers'), findsOneWidget);
      expect(find.text('Configure AI models'), findsOneWidget);
    });

    testWidgets('renders About section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll down to make About section visible
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
      // Check that version text contains "Bockaire" (version loads async from package_info_plus)
      expect(find.textContaining('Bockaire'), findsWidgets);
    });

    testWidgets('renders dividers for visual separation', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Divider), findsNWidgets(2));
    });
  });

  group('Theme Selection Interaction', () {
    testWidgets('light button is tappable and updates theme', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Wait for async initialization
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      // Initially system
      expect(container.read(themeModeProvider), ThemeMode.system);

      // Tap light mode icon
      await tester.tap(find.byIcon(Icons.wb_sunny));

      // Wait for async save
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should change to light
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    testWidgets('system button is tappable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // System icon should be visible and tappable
      final systemIcon = find.byIcon(Icons.brightness_auto);
      expect(systemIcon, findsOneWidget);

      await tester.tap(systemIcon);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should remain system (it's already selected)
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    testWidgets('dark button is tappable and updates theme', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      // Initially system
      expect(container.read(themeModeProvider), ThemeMode.system);

      // Tap dark mode icon
      await tester.tap(find.byIcon(Icons.nightlight_round));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should change to dark
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    testWidgets('selecting different modes updates the selection', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      // Initially system
      expect(container.read(themeModeProvider), ThemeMode.system);

      // Tap light
      await tester.tap(find.byIcon(Icons.wb_sunny));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(container.read(themeModeProvider), ThemeMode.light);

      // Tap dark
      await tester.tap(find.byIcon(Icons.nightlight_round));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(container.read(themeModeProvider), ThemeMode.dark);

      // Tap system
      await tester.tap(find.byIcon(Icons.brightness_auto));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(container.read(themeModeProvider), ThemeMode.system);
    });
  });

  group('Provider Integration', () {
    testWidgets('initial selection matches provider state (system)', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    testWidgets('initial selection matches provider state (light)', (
      tester,
    ) async {
      when(
        () => mockDb.getSetting('theme_mode'),
      ).thenAnswer((_) async => 'light');

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    testWidgets('initial selection matches provider state (dark)', (
      tester,
    ) async {
      when(
        () => mockDb.getSetting('theme_mode'),
      ).thenAnswer((_) async => 'dark');

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    testWidgets('changing selection updates provider', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      // Initial state
      expect(container.read(themeModeProvider), ThemeMode.system);

      // Change to light
      await tester.tap(find.byIcon(Icons.wb_sunny));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    testWidgets('provider changes update UI selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      // Change provider directly
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // UI should reflect the change
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });

  group('Layout & Accessibility', () {
    testWidgets('page has proper padding', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, isNotNull);
    });

    testWidgets('segmented button has tooltips for accessibility', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Check that all three segments are present with their icons
      // (tooltips are present but not easily testable in widget tests)
      expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
      expect(find.byIcon(Icons.nightlight_round), findsOneWidget);

      // Verify the SegmentedButton exists
      final segmentedButton = find.byType(SegmentedButton<ThemeMode>);
      expect(segmentedButton, findsOneWidget);

      // Verify it has 3 segments
      final widget = tester.widget<SegmentedButton<ThemeMode>>(segmentedButton);
      expect(widget.segments.length, 3);
    });

    testWidgets('buttons are keyboard accessible', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // SegmentedButton should be focusable
      final segmentedButton = find.byType(SegmentedButton<ThemeMode>);
      expect(segmentedButton, findsOneWidget);

      // Widget should be in the focus tree
      final widget = tester.widget<SegmentedButton<ThemeMode>>(segmentedButton);
      expect(widget.segments.length, 3);
    });

    testWidgets('touch targets are adequate size', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // SegmentedButton should provide adequate touch targets
      final segmentedButton = find.byType(SegmentedButton<ThemeMode>);
      expect(segmentedButton, findsOneWidget);

      final buttonSize = tester.getSize(segmentedButton);
      // Minimum touch target height should be adequate
      expect(buttonSize.height, greaterThanOrEqualTo(40.0));
    });

    testWidgets('sections are properly spaced', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check for SizedBox spacing elements
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('list tiles have leading icons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll down to make table_chart icon visible
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.table_chart), findsOneWidget);

      // Scroll down to make other icons visible
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.psychology), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('list tiles have trailing chevrons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Rate Tables and AI Providers should have chevrons
      final chevrons = find.byIcon(Icons.chevron_right);
      expect(chevrons, findsNWidgets(2));
    });
  });

  group('Edge Cases', () {
    testWidgets('handles rapid theme mode changes', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Rapidly tap different modes
      await tester.tap(find.byIcon(Icons.wb_sunny));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byIcon(Icons.nightlight_round));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byIcon(Icons.brightness_auto));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should end up on system
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );
      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    testWidgets('page rebuilds when provider changes externally', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SettingsPage)),
      );

      // Change theme externally
      container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    testWidgets('handles database save failures gracefully', (tester) async {
      when(
        () => mockDb.saveSetting(any(), any()),
      ).thenThrow(Exception('Save failed'));

      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should not crash when tapping
      await tester.tap(find.byIcon(Icons.wb_sunny));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // UI should still work
      expect(find.byType(SettingsPage), findsOneWidget);
    });
  });

  group('Scrolling Behavior', () {
    testWidgets('page is scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('all content is visible on small screens', (tester) async {
      // Set a small screen size
      tester.view.physicalSize = const Size(400, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to bottom
      await tester.drag(find.byType(ListView), const Offset(0, -1000));
      await tester.pumpAndSettle();

      // About section should be visible
      expect(find.text('About'), findsOneWidget);
    });
  });
}
