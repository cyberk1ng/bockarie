import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bockaire/classes/supported_currency.dart';
import 'package:bockaire/services/currency_service.dart';
import 'package:bockaire/repositories/currency_repository.dart';

part 'currency_provider.g.dart';

/// Provider for CurrencyRepository - must be overridden in tests
@riverpod
CurrencyRepository currencyRepository(Ref ref) {
  throw UnimplementedError(
    'currencyRepository must be overridden with SharedPreferences instance',
  );
}

@riverpod
class CurrencyNotifier extends _$CurrencyNotifier {
  @override
  SupportedCurrency build() {
    // Get repository (will be overridden in tests or initialized in main)
    final repository = ref.read(currencyRepositoryProvider);

    // Load saved currency synchronously from already-initialized SharedPreferences
    final saved = repository.getSavedCurrency();
    return saved ?? SupportedCurrency.defaultCurrency;
  }

  Future<void> setCurrency(SupportedCurrency currency) async {
    state = currency;
    final repository = ref.read(currencyRepositoryProvider);
    await repository.saveCurrency(currency);
  }
}

/// Provider for currency service
@riverpod
CurrencyService currencyService(Ref ref) {
  return CurrencyService();
}

/// Helper provider to format amounts in current currency
@riverpod
String formatCurrency(Ref ref, double amountInEur, {int decimals = 2}) {
  final currency = ref.watch(currencyNotifierProvider);
  final service = ref.watch(currencyServiceProvider);

  return service.formatAmount(
    amountInEur: amountInEur,
    currency: currency,
    decimals: decimals,
  );
}
