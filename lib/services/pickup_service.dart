import 'package:bockaire/classes/carton.dart';
import 'package:bockaire/classes/shipment.dart';

/// Carrier information for pickup booking
enum Carrier {
  ups('UPS'),
  dhl('DHL'),
  fedex('FedEx'),
  forwarder('Forwarder');

  final String displayName;
  const Carrier(this.displayName);
}

/// Result of scheduling a pickup
class PickupResult {
  final bool success;
  final String? confirmationNumber;
  final DateTime? pickupDate;
  final String? labelUrl;
  final String? trackingNumber;
  final String? errorMessage;

  const PickupResult({
    required this.success,
    this.confirmationNumber,
    this.pickupDate,
    this.labelUrl,
    this.trackingNumber,
    this.errorMessage,
  });

  factory PickupResult.success({
    required String confirmationNumber,
    required DateTime pickupDate,
    String? labelUrl,
    String? trackingNumber,
  }) {
    return PickupResult(
      success: true,
      confirmationNumber: confirmationNumber,
      pickupDate: pickupDate,
      labelUrl: labelUrl,
      trackingNumber: trackingNumber,
    );
  }

  factory PickupResult.failure(String errorMessage) {
    return PickupResult(success: false, errorMessage: errorMessage);
  }
}

/// Abstract interface for scheduling carrier pickups
///
/// Implementations can use:
/// - Real carrier APIs (UPS, DHL, FedEx API integrations)
/// - Mock service for testing/development
abstract class PickupService {
  /// Schedule a pickup with the specified carrier
  ///
  /// Returns a [PickupResult] with confirmation details or error
  Future<PickupResult> schedulePickup({
    required Shipment shipment,
    required List<Carton> cartons,
    required Carrier carrier,
    required DateTime preferredPickupDate,
    String? specialInstructions,
  });

  /// Cancel a previously scheduled pickup
  ///
  /// Returns true if cancellation was successful
  Future<bool> cancelPickup({
    required String confirmationNumber,
    required Carrier carrier,
  });

  /// Get pickup details by confirmation number
  Future<PickupResult?> getPickupDetails({
    required String confirmationNumber,
    required Carrier carrier,
  });

  /// Check if pickup service is available for the given carrier
  Future<bool> isAvailable(Carrier carrier);
}
