/// Shipping calculation constants
class ShippingConstants {
  ShippingConstants._(); // Private constructor to prevent instantiation

  // Dimensional weight calculation
  static const double dimensionalWeightDivisor = 5000.0;

  // Size limits
  static const double oversizeThresholdCm = 60.0;
  static const double maxCartonWeightKg = 24.0;

  // Weight breakpoints
  static const double defaultWeightBreakpointKg = 100.0;

  // Standard carton dimensions (cm)
  static const double standardCartonSmallLength = 50.0;
  static const double standardCartonSmallWidth = 40.0;
  static const double standardCartonSmallHeight = 40.0;
  static const double standardCartonLargeLength = 60.0;
  static const double standardCartonLargeWidth = 40.0;
  static const double standardCartonLargeHeight = 40.0;

  // Optimization suggestions
  static const double suggestedDimensionReductionCm = 5.0;

  // Default values
  static const String defaultOriginCountry = 'CN';
  static const String defaultDestCountry = 'DE';
}
