import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bockaire/database/database.dart';
import 'package:bockaire/models/shippo_models.dart';
import 'package:bockaire/models/customs_models.dart' as models;
import 'package:bockaire/services/book_shipment_service.dart';
import 'package:bockaire/providers/booking_providers.dart';
import 'package:bockaire/pages/customs_form_page.dart';
import 'package:bockaire/pages/booking_confirmation_page.dart';
import 'package:bockaire/widgets/booking/safety_confirmation_dialog.dart';
import 'package:bockaire/config/shippo_config.dart';

/// Coordinates the entire booking flow
///
/// Flow:
/// 1. Check if international → Show customs form
/// 2. Show confirmation with safety warning
/// 3. Create shipment + customs (if international)
/// 4. Optionally create label (if safety enabled + user confirms)
/// 5. Show confirmation screen
class BookingFlowCoordinator {
  final BuildContext context;
  final WidgetRef ref;
  final Quote quote;
  final Shipment shipment;

  BookingFlowCoordinator({
    required this.context,
    required this.ref,
    required this.quote,
    required this.shipment,
  });

  /// Start the booking flow
  Future<void> start() async {
    try {
      // Step 1: Check if international and needs customs
      final isInternational = shipment.originCountry != shipment.destCountry;

      models.CustomsPacket? customsPacket;
      if (isInternational) {
        // Check if customs already exists
        customsPacket = await ref.read(
          customsPacketProvider(shipment.id).future,
        );

        if (customsPacket == null) {
          // Show customs form
          final shouldContinue = await _showCustomsForm();
          if (!shouldContinue || !context.mounted) return;

          // Reload customs packet
          customsPacket = await ref.read(
            customsPacketProvider(shipment.id).future,
          );

          if (customsPacket == null) {
            _showError(
              'Customs information is required for international shipments',
            );
            return;
          }
        }
      }

      // Step 2: Show pre-booking confirmation
      final confirmed = await _showPreBookingConfirmation(
        isInternational: isInternational,
        hasCustoms: customsPacket != null,
      );
      if (!confirmed || !context.mounted) return;

      // Step 3: Determine if label should be created
      bool createLabel = false;
      if (ShippoConfig.isLabelPurchaseEnabled) {
        // Show safety confirmation
        final labelConfirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const SafetyConfirmationDialog(),
        );
        createLabel = labelConfirmed == true;
      }

      if (!context.mounted) return;

      // Step 4: Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Creating shipment...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Step 5: Create shipment
      final result = await _bookShipment(
        customsPacket: customsPacket,
        createLabel: createLabel,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      // Step 6: Show result
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BookingConfirmationPage(
            result: result,
            quote: quote,
            shipment: shipment,
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close any open dialogs
        _showError('Booking failed: $e');
      }
    }
  }

  Future<bool> _showCustomsForm() async {
    return await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => CustomsFormPage(
              shipmentId: shipment.id,
              onComplete: () => Navigator.of(context).pop(true),
            ),
          ),
        ) ??
        false;
  }

  Future<bool> _showPreBookingConfirmation({
    required bool isInternational,
    required bool hasCustoms,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Booking'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Carrier: ${quote.carrier} ${quote.service}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Cost: €${quote.priceEur.toStringAsFixed(2)}'),
                Text('Delivery: ${quote.etaMin}-${quote.etaMax} days'),
                const SizedBox(height: 16),
                if (isInternational) ...[
                  Row(
                    children: [
                      Icon(
                        hasCustoms ? Icons.check_circle : Icons.warning,
                        color: hasCustoms ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          hasCustoms
                              ? 'Customs declaration ready'
                              : 'Customs declaration required',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        ShippoConfig.isLabelPurchaseEnabled
                            ? Icons.warning_amber
                            : Icons.shield,
                        size: 16,
                        color: ShippoConfig.isLabelPurchaseEnabled
                            ? Colors.orange
                            : Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ShippoConfig.isLabelPurchaseEnabled
                              ? 'Label purchase enabled'
                              : 'Safe mode (no labels)',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<BookingResult> _bookShipment({
    models.CustomsPacket? customsPacket,
    required bool createLabel,
  }) async {
    final bookingService = ref.read(bookShipmentServiceProvider);

    // Prepare addresses
    final addressFrom = ShippoAddress(
      name: 'Sender',
      street1: 'Street 1',
      city: shipment.originCity,
      state: shipment.originState,
      zip: shipment.originPostal,
      country: shipment.originCountry,
    );

    final addressTo = ShippoAddress(
      name: 'Recipient',
      street1: 'Street 1',
      city: shipment.destCity,
      state: shipment.destState,
      zip: shipment.destPostal,
      country: shipment.destCountry,
    );

    // Prepare parcels (simplified - in real app would come from cartons)
    final parcels = [
      ShippoParcel(
        length: '30',
        width: '20',
        height: '15',
        weight: '5.0',
        distanceUnit: 'cm',
        massUnit: 'kg',
      ),
    ];

    // Book the shipment
    return await bookingService.bookShipment(
      rateId: quote.id, // Use quote ID as rate ID
      addressFrom: addressFrom,
      addressTo: addressTo,
      parcels: parcels,
      customsPacket: customsPacket,
      createLabel: createLabel,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
