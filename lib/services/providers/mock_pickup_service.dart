import 'package:bockaire/classes/carton.dart';
import 'package:bockaire/classes/shipment.dart';
import 'package:bockaire/services/pickup_service.dart';
import 'package:uuid/uuid.dart';

/// Mock implementation of PickupService for development/testing
///
/// Returns fake confirmation numbers and labels
/// TODO: Replace with real carrier API integrations
class MockPickupService implements PickupService {
  final Map<String, PickupResult> _scheduledPickups = {};
  final _uuid = const Uuid();

  @override
  Future<PickupResult> schedulePickup({
    required Shipment shipment,
    required List<Carton> cartons,
    required Carrier carrier,
    required DateTime preferredPickupDate,
    String? specialInstructions,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate mock data
    final confirmationNumber =
        'MOCK-${_uuid.v4().substring(0, 8).toUpperCase()}';
    final trackingNumber =
        '${carrier.name.toUpperCase()}${DateTime.now().millisecondsSinceEpoch}';

    final result = PickupResult.success(
      confirmationNumber: confirmationNumber,
      pickupDate: preferredPickupDate,
      trackingNumber: trackingNumber,
      labelUrl: 'https://example.com/labels/$trackingNumber.pdf',
    );

    // Store for later retrieval
    _scheduledPickups[confirmationNumber] = result;

    return result;
  }

  @override
  Future<bool> cancelPickup({
    required String confirmationNumber,
    required Carrier carrier,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Remove from stored pickups
    final existed = _scheduledPickups.remove(confirmationNumber) != null;
    return existed;
  }

  @override
  Future<PickupResult?> getPickupDetails({
    required String confirmationNumber,
    required Carrier carrier,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 200));

    return _scheduledPickups[confirmationNumber];
  }

  @override
  Future<bool> isAvailable(Carrier carrier) async {
    // Mock service is always available
    return true;
  }
}
