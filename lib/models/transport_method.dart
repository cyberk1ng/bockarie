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
    minDays: 1,
    maxDays: 3,
  ),
  TransportMethod.standardAir: TransportMethodInfo(
    type: TransportMethod.standardAir,
    displayName: 'Standard Air',
    icon: '📦',
    description: 'Fast delivery, good value',
    minDays: 3,
    maxDays: 7,
  ),
  TransportMethod.airFreight: TransportMethodInfo(
    type: TransportMethod.airFreight,
    displayName: 'Air Freight',
    icon: '🛫',
    description: 'Economical air shipping',
    minDays: 7,
    maxDays: 15,
  ),
  TransportMethod.seaFreightLCL: TransportMethodInfo(
    type: TransportMethod.seaFreightLCL,
    displayName: 'Sea Freight (LCL)',
    icon: '🚢',
    description: 'Cheapest option, shared container',
    minDays: 25,
    maxDays: 40,
  ),
  TransportMethod.seaFreightFCL: TransportMethodInfo(
    type: TransportMethod.seaFreightFCL,
    displayName: 'Sea Freight (FCL)',
    icon: '🚢',
    description: 'Full container, bulk shipping',
    minDays: 25,
    maxDays: 40,
  ),
  TransportMethod.roadFreight: TransportMethodInfo(
    type: TransportMethod.roadFreight,
    displayName: 'Road Freight',
    icon: '🚛',
    description: 'Ground transportation',
    minDays: 1,
    maxDays: 10,
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
  if (serviceLower.contains('ocean') ||
      serviceLower.contains('sea') ||
      estimatedDays > 20) {
    if (serviceLower.contains('fcl') || serviceLower.contains('container')) {
      return TransportMethod.seaFreightFCL;
    }
    return TransportMethod.seaFreightLCL;
  }

  // Road freight (check before express to handle "Ground Express")
  if (serviceLower.contains('ground') ||
      serviceLower.contains('road') ||
      serviceLower.contains('truck')) {
    return TransportMethod.roadFreight;
  }

  // Express air services (1-3 days)
  if (serviceLower.contains('express') ||
      serviceLower.contains('priority') ||
      serviceLower.contains('next day') ||
      serviceLower.contains('overnight') ||
      serviceLower.contains('worldwide express')) {
    return TransportMethod.expressAir;
  }

  // Air freight (economical)
  if (serviceLower.contains('freight') ||
      carrierLower.contains('forwarder') ||
      estimatedDays > 7) {
    return TransportMethod.airFreight;
  }

  // Standard air (default for most services)
  if (estimatedDays <= 7) {
    return TransportMethod.standardAir;
  }

  // Default to air freight
  return TransportMethod.airFreight;
}
