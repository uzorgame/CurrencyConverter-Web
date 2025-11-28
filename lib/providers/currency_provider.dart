import 'package:flutter/foundation.dart';

import '../repositories/currency_repository.dart';

enum CurrencyStatus { loading, loaded, error }

class CurrencyProvider extends ChangeNotifier {
  CurrencyProvider(this.repository);

  final CurrencyRepository repository;

  Map<String, double> rates = {};
  List<String> currencies = [];
  Map<String, String> currencyNames = {};
  String fromCurrency = '';
  String toCurrency = '';
  String amountInput = '0';
  double amount = 0;
  double result = 0;
  List<String> favoriteCurrencies = [];
  CurrencyStatus status = CurrencyStatus.loading;

  DateTime get lastUpdated => repository.lastUpdated;

  Future<void> init() async {
    status = CurrencyStatus.loading;
    notifyListeners();

    try {
      await Future.wait([
        repository.loadRates(),
        repository.loadCurrencies(),
      ]);

      rates = repository.rates;
      currencies = repository.currencies;
      currencyNames = repository.currencyNames;

      favoriteCurrencies = repository
          .loadFavoriteCurrencies()
          .where((code) => rates.containsKey(code))
          .toList();

      final savedFrom = repository.loadLastFromCurrency();
      final savedTo = repository.loadLastToCurrency();
      final savedAmount = repository.loadLastAmount();

      fromCurrency = _validateCurrency(savedFrom) ??
          (currencies.isNotEmpty ? currencies.first : '');
      toCurrency = _validateCurrency(savedTo) ??
          (currencies.length > 1 ? currencies[1] : fromCurrency);
      amountInput = savedAmount ?? '0';
      amount = _parseAmount(amountInput);

      _recalculateInternal();
      status = CurrencyStatus.loaded;
    } catch (_) {
      status = CurrencyStatus.error;
    }

    notifyListeners();
  }

  void setFromCurrency(String value) {
    fromCurrency = value;
    repository.saveLastFromCurrency(value);
    _recalculateInternal();
    notifyListeners();
  }

  void setToCurrency(String value) {
    toCurrency = value;
    repository.saveLastToCurrency(value);
    _recalculateInternal();
    notifyListeners();
  }

  void setAmount(double value) {
    amount = value;
    amountInput = value.toString();
    repository.saveLastAmount(amountInput);
    _recalculateInternal();
    notifyListeners();
  }

  void recalculate() {
    _recalculateInternal();
    notifyListeners();
  }

  void setAmountInput(String value) {
    amountInput = value;
    amount = _parseAmount(value);
    repository.saveLastAmount(value);
    _recalculateInternal();
    notifyListeners();
  }

  void toggleFavorite(String code) {
    if (favoriteCurrencies.contains(code)) {
      favoriteCurrencies =
          favoriteCurrencies.where((element) => element != code).toList();
    } else {
      favoriteCurrencies = [...favoriteCurrencies, code];
    }

    repository.saveFavoriteCurrencies(favoriteCurrencies);
    notifyListeners();
  }

  bool isFavorite(String code) => favoriteCurrencies.contains(code);

  String? _validateCurrency(String? code) {
    if (code == null || code.isEmpty) return null;
    if (!rates.containsKey(code)) return null;
    if (currencies.isNotEmpty && !currencies.contains(code)) return null;
    return code;
  }

  double _parseAmount(String value) {
    var normalized = value.replaceAll(',', '');
    if (normalized.endsWith('.')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return double.tryParse(normalized) ?? 0;
  }

  void _recalculateInternal() {
    if (status == CurrencyStatus.error || repository.rates.isEmpty) {
      result = 0;
      return;
    }

    try {
      result = repository.convert(fromCurrency, toCurrency, amount);
    } catch (_) {
      result = 0;
    }
  }
}
