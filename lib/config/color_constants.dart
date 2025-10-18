import 'package:flutter/material.dart';

/// Color constants for transport methods and badges
class ColorConstants {
  ColorConstants._();

  // Transport method colors
  static const Color transportExpressAir = Colors.purple;
  static const Color transportStandardAir = Colors.blue;
  static const Color transportAirFreight = Colors.teal;
  static const Color transportSeaFreight = Colors.indigo;
  static const Color transportRoadFreight = Colors.orange;

  // Badge colors
  static const Color badgeCheapest = Colors.green;
  static const Color badgeFastest = Colors.orange;
  static const Color badgeBest = Colors.blue;

  // Opacity values
  static const double alphaLightest = 0.1;
  static const double alphaLight = 0.2;
  static const double alphaMedium = 0.3;
  static const double alphaMediumHigh = 0.5;
  static const double alphaHigh = 0.8;
  static const double alphaVeryHigh = 0.9;
}
