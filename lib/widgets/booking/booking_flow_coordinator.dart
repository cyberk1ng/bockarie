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
import 'package:bockaire/widgets/booking/booking_review_modal.dart';
import 'package:bockaire/config/shippo_config.dart';

/// Coordinates the entire booking flow
///
/// Flow:
/// 1. Check if international → Show customs form
/// 2. Show review modal (pre-commitment, reversible)
/// 3. Show safety confirmation (if labels enabled)
/// 4. Create shipment + customs (if international)
/// 5. Optionally create label (if safety enabled + user confirms)
/// 6. Show confirmation screen (post-commitment, no back button)
class BookingFlowCoordinator {
  final BuildContext context;
  final WidgetRef ref;
  final Quote quote;
  final Shipment shipment;

  /// Prevents double-booking by tracking if booking is in progress
  bool _isBookingInProgress = false;

  BookingFlowCoordinator({
    required this.context,
    required this.ref,
    required this.quote,
    required this.shipment,
  });

  /// Start the booking flow
  Future<void> start() async {
    // Prevent double-booking
    if (_isBookingInProgress) {
      _showError('A booking is already in progress');
      return;
    }

    _isBookingInProgress = true;

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
          if (!shouldContinue || !context.mounted) {
            _isBookingInProgress = false;
            return;
          }

          // Reload customs packet
          customsPacket = await ref.read(
            customsPacketProvider(shipment.id).future,
          );

          if (customsPacket == null) {
            _showError(
              'Customs information is required for international shipments',
            );
            _isBookingInProgress = false;
            return;
          }
        }
      }

      // Step 2: Show pre-booking review modal (pre-commitment)
      final confirmed = await _showPreBookingReviewModal(
        isInternational: isInternational,
        hasCustoms: customsPacket != null,
      );
      if (!confirmed || !context.mounted) {
        _isBookingInProgress = false;
        return;
      }

      // Step 3: Determine if label should be created
      bool createLabel = false;
      if (ShippoConfig.isLabelPurchaseEnabled) {
        // Show safety confirmation (high-friction check)
        final labelConfirmed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => const SafetyConfirmationDialog(),
        );
        createLabel = labelConfirmed == true;

        // User canceled at safety confirmation
        if (!labelConfirmed!) {
          _isBookingInProgress = false;
          return;
        }
      }

      if (!context.mounted) {
        _isBookingInProgress = false;
        return;
      }

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

      if (!context.mounted) {
        _isBookingInProgress = false;
        return;
      }
      Navigator.of(context).pop(); // Close loading dialog

      // Step 6: Show confirmation page (post-commitment, no back button)
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
    } finally {
      _isBookingInProgress = false;
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

  /// Show pre-booking review modal (Phase 1: Pre-Commitment, Reversible)
  Future<bool> _showPreBookingReviewModal({
    required bool isInternational,
    required bool hasCustoms,
  }) async {
    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          isDismissible: true, // Can swipe down to cancel
          enableDrag: true,
          backgroundColor: Colors.transparent,
          builder: (context) => BookingReviewModal(
            quote: quote,
            shipment: shipment,
            isInternational: isInternational,
            hasCustoms: hasCustoms,
            onEdit: () {
              // Optional: Navigate to edit page
              // For now, just closes the modal
            },
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
