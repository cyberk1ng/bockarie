import 'package:bockaire/classes/supported_currency.dart';

class CurrencyService {
  // Base currency is EUR
  // In production, fetch these rates from an API (e.g., exchangerate-api.com, fixer.io)
  static const Map<String, double> _exchangeRates = {
    'EUR': 1.0, // Base
    'USD': 1.08, // 1 EUR = 1.08 USD
    'GBP': 0.86, // 1 EUR = 0.86 GBP
  };

  /// Convert amount from EUR (base currency) to target currency
  double convert({
    required double amountInEur,
    required SupportedCurrency targetCurrency,
  }) {
    final rate = _exchangeRates[targetCurrency.code] ?? 1.0;
    return amountInEur * rate;
  }

  /// Convert from any currency to another
  double convertBetween({
    required double amount,
    required SupportedCurrency fromCurrency,
    required SupportedCurrency toCurrency,
  }) {
    // Convert to EUR first (base currency)
    final fromRate = _exchangeRates[fromCurrency.code] ?? 1.0;
    final amountInEur = amount / fromRate;

    // Then convert to target currency
    final toRate = _exchangeRates[toCurrency.code] ?? 1.0;
    return amountInEur * toRate;
  }

  /// Get exchange rate between two currencies
  double getExchangeRate({
    required SupportedCurrency fromCurrency,
    required SupportedCurrency toCurrency,
  }) {
    final fromRate = _exchangeRates[fromCurrency.code] ?? 1.0;
    final toRate = _exchangeRates[toCurrency.code] ?? 1.0;
    return toRate / fromRate;
  }

  /// Format amount in specific currency
  String formatAmount({
    required double amountInEur,
    required SupportedCurrency currency,
    int decimals = 2,
  }) {
    final convertedAmount = convert(
      amountInEur: amountInEur,
      targetCurrency: currency,
    );
    return currency.format(convertedAmount, decimals: decimals);
  }
}
