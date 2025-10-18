/// Transport method classification constants
class TransportConstants {
  TransportConstants._();

  // Duration ranges by transport type (days)
  static const int expressAirMinDays = 1;
  static const int expressAirMaxDays = 3;
  static const int standardAirMinDays = 3;
  static const int standardAirMaxDays = 7;
  static const int airFreightMinDays = 7;
  static const int airFreightMaxDays = 15;
  static const int seaFreightMinDays = 25;
  static const int seaFreightMaxDays = 40;
  static const int roadFreightMinDays = 1;
  static const int roadFreightMaxDays = 10;

  // Classification thresholds
  static const int seaFreightThresholdDays = 20;
  static const int airFreightThresholdDays = 7;

  // Default values
  static const int defaultEstimatedDays = 5;
  static const int defaultEtaMinDays = 5;
  static const int defaultEtaMaxDays = 7;

  // Keywords for transport method detection
  static const List<String> seaFreightKeywords = [
    'ocean',
    'sea',
    'fcl',
    'container',
  ];
  static const List<String> roadFreightKeywords = ['ground', 'road', 'truck'];
  static const List<String> expressKeywords = [
    'express',
    'priority',
    'next day',
    'overnight',
    'worldwide express',
  ];
  static const List<String> freightKeywords = ['freight', 'forwarder'];
}
