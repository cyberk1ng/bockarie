import 'package:bockaire/config/transport_constants.dart';

enum TransportMethod {
  expressAir,
  standardAir,
  airFreight,
  seaFreightLCL,
  seaFreightFCL,
  roadFreight,
}

class TransportMethodInfo {
  final TransportMethod type;
  final String displayName;
  final String icon;
  final String description;
  final int minDays;
  final int maxDays;

  const TransportMethodInfo({
    required this.type,
    required this.displayName,
    required this.icon,
    required this.description,
    required this.minDays,
    required this.maxDays,
  });
}

const transportMethods = {
  TransportMethod.expressAir: TransportMethodInfo(
    type: TransportMethod.expressAir,
    displayName: 'Express Air',
    icon: '✈️',
    description: 'Fastest delivery, premium service',
    minDays: TransportConstants.expressAirMinDays,
    maxDays: TransportConstants.expressAirMaxDays,
  ),
  TransportMethod.standardAir: TransportMethodInfo(
    type: TransportMethod.standardAir,
    displayName: 'Standard Air',
    icon: '📦',
    description: 'Fast delivery, good value',
    minDays: TransportConstants.standardAirMinDays,
    maxDays: TransportConstants.standardAirMaxDays,
  ),
  TransportMethod.airFreight: TransportMethodInfo(
    type: TransportMethod.airFreight,
    displayName: 'Air Freight',
    icon: '🛫',
    description: 'Economical air shipping',
    minDays: TransportConstants.airFreightMinDays,
    maxDays: TransportConstants.airFreightMaxDays,
  ),
  TransportMethod.seaFreightLCL: TransportMethodInfo(
    type: TransportMethod.seaFreightLCL,
    displayName: 'Sea Freight (LCL)',
    icon: '🚢',
    description: 'Cheapest option, shared container',
    minDays: TransportConstants.seaFreightMinDays,
    maxDays: TransportConstants.seaFreightMaxDays,
  ),
  TransportMethod.seaFreightFCL: TransportMethodInfo(
    type: TransportMethod.seaFreightFCL,
    displayName: 'Sea Freight (FCL)',
    icon: '🚢',
    description: 'Full container, bulk shipping',
    minDays: TransportConstants.seaFreightMinDays,
    maxDays: TransportConstants.seaFreightMaxDays,
  ),
  TransportMethod.roadFreight: TransportMethodInfo(
    type: TransportMethod.roadFreight,
    displayName: 'Road Freight',
    icon: '🚛',
    description: 'Ground transportation',
    minDays: TransportConstants.roadFreightMinDays,
    maxDays: TransportConstants.roadFreightMaxDays,
  ),
};

TransportMethod classifyTransportMethod(
  String carrier,
  String service,
  int estimatedDays,
) {
  final serviceLower = service.toLowerCase();
  final carrierLower = carrier.toLowerCase();

  // Check for specific transport types BEFORE generic keywords like "express"

  // Sea freight (highest priority - most specific)
  if (TransportConstants.seaFreightKeywords.any(
        (k) => serviceLower.contains(k),
      ) ||
      estimatedDays > TransportConstants.seaFreightThresholdDays) {
    if (serviceLower.contains('fcl') || serviceLower.contains('container')) {
      return TransportMethod.seaFreightFCL;
    }
    return TransportMethod.seaFreightLCL;
  }

  // Road freight (check before express to handle "Ground Express")
  if (TransportConstants.roadFreightKeywords.any(
    (k) => serviceLower.contains(k),
  )) {
    return TransportMethod.roadFreight;
  }

  // Express air services (1-3 days)
  if (TransportConstants.expressKeywords.any((k) => serviceLower.contains(k))) {
    return TransportMethod.expressAir;
  }

  // Air freight (economical)
  if (TransportConstants.freightKeywords.any(
        (k) => serviceLower.contains(k) || carrierLower.contains(k),
      ) ||
      estimatedDays > TransportConstants.airFreightThresholdDays) {
    return TransportMethod.airFreight;
  }

  // Standard air (default for most services)
  if (estimatedDays <= TransportConstants.airFreightThresholdDays) {
    return TransportMethod.standardAir;
  }

  // Default to air freight
  return TransportMethod.airFreight;
}
