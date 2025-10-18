import 'package:flutter/material.dart';
import 'package:bockaire/l10n/app_localizations.dart';

enum SupportedCurrency {
  eur('EUR', '€', 'Euro', 'de'), // Using Germany flag as EU representative
  usd('USD', '\$', 'US Dollar', 'us'),
  gbp('GBP', '£', 'British Pound', 'gb');

  const SupportedCurrency(this.code, this.symbol, this.name, this.countryCode);

  final String code;
  final String symbol;
  final String name;
  final String countryCode; // For flag display

  static final Map<String, SupportedCurrency> _byCode = {
    for (var currency in values) currency.code: currency,
  };

  static SupportedCurrency? fromCode(String code) {
    return _byCode[code.toUpperCase()];
  }

  static SupportedCurrency get defaultCurrency => SupportedCurrency.eur;

  String localizedName(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return switch (this) {
      SupportedCurrency.eur => localizations.currencyEuro,
      SupportedCurrency.usd => localizations.currencyUsd,
      SupportedCurrency.gbp => localizations.currencyGbp,
    };
  }

  /// Format amount with currency symbol
  String format(double amount, {int decimals = 2}) {
    final formatted = amount.toStringAsFixed(decimals);
    return switch (this) {
      SupportedCurrency.eur => '$symbol$formatted',
      SupportedCurrency.usd => '$symbol$formatted',
      SupportedCurrency.gbp => '$symbol$formatted',
    };
  }

  /// Format with full currency code
  String formatWithCode(double amount, {int decimals = 2}) {
    final formatted = amount.toStringAsFixed(decimals);
    return '$formatted $code';
  }
}
