import 'package:country_flags/country_flags.dart';
import 'package:flutter/widgets.dart';

Widget buildLanguageFlag({
  required String languageCode,
  required double height,
  required double width,
  Key? key,
}) {
  const languageCountryOverrides = {
    'zh': 'cn', // Chinese → China flag
    'en': 'gb', // English → UK flag
    'ga': 'ie', // Irish → Ireland flag
    'el': 'gr', // Greek → Greece flag
    'da': 'dk', // Danish → Denmark flag
    'sv': 'se', // Swedish → Sweden flag
    'ar': 'sa', // Arabic → Saudi Arabia flag
    'he': 'il', // Hebrew → Israel flag
    'fa': 'ir', // Persian → Iran flag
  };

  final overrideCountryCode = languageCountryOverrides[languageCode];
  if (overrideCountryCode != null) {
    return CountryFlag.fromCountryCode(
      overrideCountryCode,
      height: height,
      width: width,
      key: key ?? ValueKey('flag-$languageCode'),
    );
  }

  return CountryFlag.fromLanguageCode(
    languageCode,
    height: height,
    width: width,
    key: key ?? ValueKey('flag-$languageCode'),
  );
}
