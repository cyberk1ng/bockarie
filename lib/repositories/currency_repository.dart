import 'package:shared_preferences/shared_preferences.dart';
import 'package:bockaire/classes/supported_currency.dart';

/// Repository for managing currency persistence
class CurrencyRepository {
  CurrencyRepository(this._prefs);

  final SharedPreferences _prefs;
  static const String _currencyKey = 'app_currency';

  /// Get the saved currency, or null if none saved
  SupportedCurrency? getSavedCurrency() {
    final currencyCode = _prefs.getString(_currencyKey);
    if (currencyCode != null) {
      return SupportedCurrency.fromCode(currencyCode);
    }
    return null;
  }

  /// Save the currency preference
  Future<void> saveCurrency(SupportedCurrency currency) async {
    await _prefs.setString(_currencyKey, currency.code);
  }

  /// Watch for currency changes (returns a Stream)
  Stream<SupportedCurrency?> watchCurrency() async* {
    // Initial value
    yield getSavedCurrency();

    // Note: SharedPreferences doesn't natively support watching
    // For now, we just yield the initial value
    // In a real app, you might use a StreamController or migrate to a database
  }
}
