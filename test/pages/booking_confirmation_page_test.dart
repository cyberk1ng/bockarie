import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bockaire/pages/booking_confirmation_page.dart';
import 'package:bockaire/services/book_shipment_service.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    await dotenv.load(fileName: '.env');
  });

  group('BookingConfirmationPage', () {
    late BookingResult testResultWithLabel;
    late BookingResult testResultNoLabel;
    late Quote testQuote;
    late Shipment testShipment;

    setUp(() {
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

      testResultWithLabel = BookingResult(
        shipmentId: 'ship_123',
        labelCreated: true,
        status: 'LABEL_CREATED',
        labelUrl: 'https://example.com/label.pdf',
        trackingNumber: '1234567890',
        trackingUrlProvider: 'https://track.dhl.com/1234567890',
        commercialInvoiceUrl: 'https://example.com/invoice.pdf',
        customsDeclarationId: 'customs_123',
        messages: [],
      );

      testResultNoLabel = BookingResult(
        shipmentId: 'ship_123',
        labelCreated: false,
        status: 'SHIPMENT_CREATED',
        messages: ['Label creation disabled in settings'],
      );
    });

    group('Navigation Blocking', () {
      testWidgets('does not show back button in AppBar', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultWithLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // AppBar should not have a leading back button
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.automaticallyImplyLeading, false);
        expect(find.byIcon(Icons.arrow_back), findsNothing);
      });

      testWidgets('Return to Quotes button pops to first route', (
        tester,
      ) async {
        final navigatorKey = GlobalKey<NavigatorState>();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingConfirmationPage(
                            result: testResultWithLabel,
                            quote: testQuote,
                            shipment: testShipment,
                          ),
                        ),
                      );
                    },
                    child: const Text('Go to Confirmation'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Navigate to confirmation page
        await tester.tap(find.text('Go to Confirmation'));
        await tester.pumpAndSettle();

        // Scroll to find the Return to Quotes button
        await tester.dragUntilVisible(
          find.text('Return to Quotes'),
          find.byType(ListView),
          const Offset(0, -50),
        );

        // Tap Return to Quotes
        await tester.tap(find.text('Return to Quotes'));
        await tester.pumpAndSettle();

        // Should be back at home
        expect(find.text('Go to Confirmation'), findsOneWidget);
        expect(find.byType(BookingConfirmationPage), findsNothing);
      });
    });

    group('Success Banner', () {
      testWidgets('shows green success banner when label created', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultWithLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('✅ Shipment Booked!'), findsOneWidget);
        expect(
          find.text('Your shipping label has been generated'),
          findsOneWidget,
        );
      });

      testWidgets('shows blue info banner when label not created', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultNoLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('📦 Shipment Created'), findsOneWidget);
        expect(
          find.text('Shipment created (No label purchased)'),
          findsOneWidget,
        );
      });
    });

    group('Document Section', () {
      testWidgets('shows label download link when available', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultWithLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Scroll to find the documents section
        await tester.dragUntilVisible(
          find.text('Shipping Label'),
          find.byType(ListView),
          const Offset(0, -50),
        );

        expect(find.text('Shipping Label'), findsOneWidget);
        expect(find.byIcon(Icons.download), findsWidgets);
      });

      testWidgets('shows commercial invoice when available', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultWithLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Scroll to find the commercial invoice
        await tester.dragUntilVisible(
          find.text('Commercial Invoice'),
          find.byType(ListView),
          const Offset(0, -50),
        );

        expect(find.text('Commercial Invoice'), findsOneWidget);
      });

      testWidgets('shows customs declaration ID when available', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultWithLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Scroll to find the customs declaration
        await tester.dragUntilVisible(
          find.text('Customs Declaration (CN22/CN23)'),
          find.byType(ListView),
          const Offset(0, -50),
        );

        expect(find.text('Customs Declaration (CN22/CN23)'), findsOneWidget);
        expect(find.textContaining('customs_123'), findsOneWidget);
      });

      testWidgets('shows no documents message when none available', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultNoLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.text(
            'No documents generated yet. Documents will be available after label purchase.',
          ),
          findsOneWidget,
        );
      });
    });

    group('Tracking Information', () {
      testWidgets('displays tracking number when available', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultWithLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('1234567890'), findsOneWidget);
        expect(find.text('Tracking Number'), findsOneWidget);
      });

      testWidgets('shows Track Shipment button when URL available', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultWithLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Track Shipment'), findsOneWidget);
      });

      testWidgets('hides tracking section when no tracking data', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultNoLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Tracking Number'), findsNothing);
        expect(find.text('Track Shipment'), findsNothing);
      });
    });

    group('Messages Section', () {
      testWidgets('displays messages when present', (tester) async {
        final resultWithMessages = BookingResult(
          shipmentId: 'ship_123',
          labelCreated: false,
          status: 'SHIPMENT_CREATED',
          messages: ['Message 1', 'Message 2', 'Message 3'],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: resultWithMessages,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Scroll to find the messages section
        await tester.dragUntilVisible(
          find.text('Important Information'),
          find.byType(ListView),
          const Offset(0, -50),
        );

        expect(find.text('Important Information'), findsOneWidget);
        expect(find.text('Message 1'), findsOneWidget);
        expect(find.text('Message 2'), findsOneWidget);
        expect(find.text('Message 3'), findsOneWidget);
      });

      testWidgets('hides messages section when empty', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultNoLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // testResultNoLabel has 1 message, so we need result with empty list
        final resultWithoutMessages = BookingResult(
          shipmentId: 'ship_123',
          labelCreated: false,
          status: 'SHIPMENT_CREATED',
          messages: [],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: resultWithoutMessages,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Important Information'), findsNothing);
      });
    });

    group('Label Status Info', () {
      testWidgets('shows live mode message when label created', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultWithLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Scroll to find the label status info section
        await tester.dragUntilVisible(
          find.text('Label Generated (Live Mode)'),
          find.byType(ListView),
          const Offset(0, -50),
        );

        expect(find.text('Label Generated (Live Mode)'), findsOneWidget);
        expect(
          find.text(
            'Your shipping label has been purchased. Print and attach it to your package.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('shows safe mode message when label not created', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultNoLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Scroll to find the label status info section
        await tester.dragUntilVisible(
          find.text('Safe Mode: No Label Purchased'),
          find.byType(ListView),
          const Offset(0, -50),
        );

        expect(find.text('Safe Mode: No Label Purchased'), findsOneWidget);
        expect(
          find.textContaining('ENABLE_SHIPPO_LABELS=false'),
          findsOneWidget,
        );
      });
    });

    group('Shipment Details', () {
      testWidgets('displays carrier and service', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultWithLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('DHL'), findsWidgets);
      });

      testWidgets('displays estimated delivery', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultWithLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('days'), findsWidgets);
      });

      testWidgets('displays total cost', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultWithLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Total Cost'), findsOneWidget);
      });

      testWidgets('displays shipment ID', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: BookingConfirmationPage(
                result: testResultWithLabel,
                quote: testQuote,
                shipment: testShipment,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('ship_123'), findsOneWidget);
      });
    });
  });
}
