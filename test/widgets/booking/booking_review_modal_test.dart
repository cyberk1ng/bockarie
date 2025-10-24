import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bockaire/widgets/booking/booking_review_modal.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/providers/currency_provider.dart';
import 'package:bockaire/repositories/currency_repository.dart';
import 'package:bockaire/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  group('BookingReviewModal', () {
    late Quote testQuote;
    late Shipment testShipment;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      testQuote = const Quote(
        id: 'quote_123',
        shipmentId: 'ship_123',
        carrier: 'DHL',
        service: 'Express',
        etaMin: 3,
        etaMax: 5,
        priceEur: 45.20,
        chargeableKg: 5.0,
        transportMethod: 'expressAir',
      );

      testShipment = Shipment(
        id: 'ship_123',
        createdAt: DateTime.now(),
        originCity: 'Shanghai',
        originPostal: '200000',
        originCountry: 'CN',
        originState: '',
        destCity: 'Berlin',
        destPostal: '10115',
        destCountry: 'DE',
        destState: '',
      );
    });

    group('Modal Dismissal', () {
      testWidgets('dismisses on Cancel button tap', (tester) async {
        bool? result;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () async {
                      result = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => BookingReviewModal(
                          quote: testQuote,
                          shipment: testShipment,
                          isInternational: false,
                          hasCustoms: false,
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open modal
        await tester.tap(find.text('Open Modal'));
        await tester.pumpAndSettle();

        // Tap Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert: Modal dismissed, returned false
        expect(result, false);
        expect(find.byType(BookingReviewModal), findsNothing);
      });

      testWidgets('returns true when Confirm Booking tapped', (tester) async {
        bool? result;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () async {
                      result = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => BookingReviewModal(
                          quote: testQuote,
                          shipment: testShipment,
                          isInternational: false,
                          hasCustoms: false,
                        ),
                      );
                    },
                    child: const Text('Open Modal'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Open modal
        await tester.tap(find.text('Open Modal'));
        await tester.pumpAndSettle();

        // Tap Confirm Booking
        await tester.tap(find.text('Confirm Booking'));
        await tester.pumpAndSettle();

        // Assert: returned true
        expect(result, true);
      });
    });

    group('Action Callbacks', () {
      testWidgets('calls onConfirm callback when confirmed', (tester) async {
        bool onConfirmCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: BookingReviewModal(
                  quote: testQuote,
                  shipment: testShipment,
                  isInternational: false,
                  hasCustoms: false,
                  onConfirm: () => onConfirmCalled = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirm Booking'));
        await tester.pump();

        expect(onConfirmCalled, true);
      });

      testWidgets('calls onEdit callback when Edit tapped', (tester) async {
        bool onEditCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: BookingReviewModal(
                  quote: testQuote,
                  shipment: testShipment,
                  isInternational: false,
                  hasCustoms: false,
                  onEdit: () => onEditCalled = true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Edit Shipment Details'));
        await tester.pump();

        expect(onEditCalled, true);
      });

      testWidgets('handles null callbacks gracefully', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: BookingReviewModal(
                  quote: testQuote,
                  shipment: testShipment,
                  isInternational: false,
                  hasCustoms: false,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tap buttons - should not crash
        await tester.tap(find.text('Confirm Booking'));
        await tester.pump();

        // Test passes if no exception thrown
        expect(find.text('Confirm Booking'), findsOneWidget);
      });
    });

    group('Conditional Rendering', () {
      testWidgets('shows customs card for international shipment', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: BookingReviewModal(
                  quote: testQuote,
                  shipment: testShipment,
                  isInternational: true,
                  hasCustoms: false,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Customs Declaration Required'), findsOneWidget);
      });

      testWidgets('hides customs card for domestic shipment', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: BookingReviewModal(
                  quote: testQuote,
                  shipment: testShipment,
                  isInternational: false,
                  hasCustoms: false,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Customs Declaration'), findsNothing);
      });

      testWidgets('shows ready state when customs exists', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: BookingReviewModal(
                  quote: testQuote,
                  shipment: testShipment,
                  isInternational: true,
                  hasCustoms: true,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Customs Declaration Ready'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsWidgets);
      });
    });

    group('Route Display', () {
      testWidgets('displays origin and destination cities', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: BookingReviewModal(
                  quote: testQuote,
                  shipment: testShipment,
                  isInternational: true,
                  hasCustoms: false,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Shanghai'), findsOneWidget);
        expect(find.text('Berlin'), findsOneWidget);
        expect(find.text('CN'), findsOneWidget);
        expect(find.text('DE'), findsOneWidget);
      });

      testWidgets('shows arrow between cities', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: BookingReviewModal(
                  quote: testQuote,
                  shipment: testShipment,
                  isInternational: true,
                  hasCustoms: false,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
      });
    });

    group('Carrier Details', () {
      testWidgets('displays carrier name and service', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: BookingReviewModal(
                  quote: testQuote,
                  shipment: testShipment,
                  isInternational: false,
                  hasCustoms: false,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('DHL'), findsWidgets);
        expect(find.textContaining('Express'), findsWidgets);
      });

      testWidgets('displays estimated delivery range', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              currencyRepositoryProvider.overrideWithValue(
                CurrencyRepository(prefs),
              ),
            ],
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: BookingReviewModal(
                  quote: testQuote,
                  shipment: testShipment,
                  isInternational: false,
                  hasCustoms: false,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('3-5 days'), findsOneWidget);
      });
    });
  });
}
