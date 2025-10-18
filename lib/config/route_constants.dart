/// Navigation route paths
class RouteConstants {
  RouteConstants._();

  static const String home = '/';
  static const String newShipment = '/new-shipment';
  static const String optimizer = '/optimizer/:shipmentId';
  static const String quotes = '/quotes/:shipmentId';
  static const String settings = '/settings';

  // Helper methods for parameterized routes
  static String optimizerWithId(String shipmentId) => '/optimizer/$shipmentId';
  static String quotesWithId(String shipmentId) => '/quotes/$shipmentId';
}
