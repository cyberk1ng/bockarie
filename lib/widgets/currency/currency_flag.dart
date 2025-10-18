import 'package:country_flags/country_flags.dart';
import 'package:flutter/widgets.dart';
import 'package:bockaire/classes/supported_currency.dart';

Widget buildCurrencyFlag({
  required SupportedCurrency currency,
  required double height,
  required double width,
  Key? key,
}) {
  return CountryFlag.fromCountryCode(
    currency.countryCode,
    height: height,
    width: width,
    key: key ?? ValueKey('currency-flag-${currency.code}'),
  );
}
