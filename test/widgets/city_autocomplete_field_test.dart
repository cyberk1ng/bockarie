import 'package:bockaire/services/city_autocomplete_service.dart';
import 'package:bockaire/widgets/shipment/city_autocomplete_field.dart';
import 'package:bockaire/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCityAutocompleteService extends Mock
    implements CityAutocompleteService {}

void main() {
  late TextEditingController cityController;
  late TextEditingController postalController;
  late MockCityAutocompleteService mockService;

  setUp(() {
    cityController = TextEditingController();
    postalController = TextEditingController();
    mockService = MockCityAutocompleteService();

    // Default mock behavior
    when(
      () => mockService.searchCities(any(), any()),
    ).thenAnswer((_) async => []);
    when(() => mockService.cancel()).thenReturn(null);
    when(() => mockService.dispose()).thenReturn(null);
  });

  tearDown(() {
    cityController.dispose();
    postalController.dispose();
  });

  Widget createTestWidget({String? Function(String?)? validator}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CityAutocompleteField(
          cityController: cityController,
          postalController: postalController,
          label: 'Test City',
          service: mockService,
          validator: validator,
        ),
      ),
    );
  }

  group('CityAutocompleteField Widget', () {
    testWidgets('renders text field with label', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test City'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('displays entered text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField), 'Hamburg');
      await tester.pump();

      expect(cityController.text, 'Hamburg');
    });

    testWidgets('shows loading indicator while searching', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text to trigger search
      await tester.enterText(find.byType(TextFormField), 'Ham');
      await tester.pump();

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('triggers search when text is entered', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text
      await tester.enterText(find.byType(TextFormField), 'Hamburg');
      await tester.pump();

      // Text should be set
      expect(cityController.text, 'Hamburg');

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 250));

      // Service should be called
      verify(() => mockService.searchCities('Hamburg', any())).called(1);
    });

    testWidgets('controllers can be cleared', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Set text in controllers
      cityController.text = 'Hamburg';
      postalController.text = '20095';
      await tester.pump();

      expect(cityController.text, 'Hamburg');
      expect(postalController.text, '20095');

      // Clear controllers
      cityController.clear();
      postalController.clear();
      await tester.pump();

      expect(cityController.text, isEmpty);
      expect(postalController.text, isEmpty);
    });

    testWidgets('validates empty input when validator is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          validator: (value) =>
              value?.isEmpty ?? true ? 'City is required' : null,
        ),
      );

      // Trigger validation
      final formState = tester.state<FormFieldState>(
        find.byType(TextFormField),
      );
      formState.validate();
      await tester.pump();

      expect(find.text('City is required'), findsOneWidget);
    });

    testWidgets('validator passes with valid input', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          validator: (value) =>
              value?.isEmpty ?? true ? 'City is required' : null,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Hamburg');
      await tester.pump();

      final formState = tester.state<FormFieldState>(
        find.byType(TextFormField),
      );
      formState.validate();
      await tester.pump();

      expect(find.text('City is required'), findsNothing);
    });

    testWidgets('uses custom validator when provided', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          validator: (value) => value != 'Hamburg' ? 'Must be Hamburg' : null,
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Berlin');
      await tester.pump();

      final formState = tester.state<FormFieldState>(
        find.byType(TextFormField),
      );
      formState.validate();
      await tester.pump();

      expect(find.text('Must be Hamburg'), findsOneWidget);
    });

    testWidgets('can tap and interact with field', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap to focus
      await tester.tap(find.byType(TextFormField));
      await tester.pump();

      // Enter text to verify focus
      await tester.enterText(find.byType(TextFormField), 'Hamburg');
      await tester.pump();

      expect(cityController.text, 'Hamburg');
    });

    testWidgets('does not search for empty query', (tester) async {
      when(
        () => mockService.searchCities(any(), any()),
      ).thenAnswer((_) async => []);
      when(() => mockService.dispose()).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField), '');
      await tester.pump(const Duration(milliseconds: 250));

      verifyNever(() => mockService.searchCities(any(), any()));
    });

    testWidgets('text field accepts input correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField), 'Hamburg');
      await tester.pump();

      expect(cityController.text, 'Hamburg');

      // Loading indicator should appear during search
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('CityAutocompleteField Accessibility', () {
    testWidgets('has correct semantics', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final semantics = tester.getSemantics(find.byType(TextFormField));

      expect(semantics.label, contains('Test City'));
    });

    testWidgets('field can be interacted with after text entry', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text via the text field
      await tester.enterText(find.byType(TextFormField), 'Hamburg');
      await tester.pump();

      // Should be able to change the text
      await tester.enterText(find.byType(TextFormField), 'Berlin');
      await tester.pump();

      expect(cityController.text, 'Berlin');
    });
  });

  group('CityAutocompleteField Edge Cases', () {
    testWidgets('handles rapid text changes', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField), 'H');
      await tester.enterText(find.byType(TextFormField), 'Ha');
      await tester.enterText(find.byType(TextFormField), 'Ham');
      await tester.pump();

      // Should debounce and only search for last value
      expect(cityController.text, 'Ham');
    });

    testWidgets('handles very long city names', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final longName = 'A' * 100;
      await tester.enterText(find.byType(TextFormField), longName);
      await tester.pump();

      expect(cityController.text, longName);
    });

    testWidgets('handles special characters', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField), 'Düsseldorf');
      await tester.pump();

      expect(cityController.text, 'Düsseldorf');
    });

    testWidgets('disposes resources properly', (tester) async {
      when(() => mockService.dispose()).thenReturn(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpWidget(const SizedBox()); // Remove widget

      verify(() => mockService.dispose()).called(1);
    });
  });
}
