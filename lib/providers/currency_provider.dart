import 'package:flutter/foundation.dart';

import '../repositories/currency_repository.dart';

enum CurrencyStatus { loading, loaded, error }

class CurrencyProvider extends ChangeNotifier {
  CurrencyProvider(this.repository);

  final CurrencyRepository repository;

  Map<String, double> rates = {};
  List<String> currencies = [];
  String fromCurrency = '';
  String toCurrency = '';
  double amount = 0;
  double result = 0;
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

      fromCurrency = currencies.isNotEmpty ? currencies.first : '';
      toCurrency = currencies.length > 1 ? currencies[1] : fromCurrency;

      _recalculateInternal();
      status = CurrencyStatus.loaded;
    } catch (_) {
      status = CurrencyStatus.error;
    }

    notifyListeners();
  }

  void setFromCurrency(String value) {
    fromCurrency = value;
    _recalculateInternal();
    notifyListeners();
  }

  void setToCurrency(String value) {
    toCurrency = value;
    _recalculateInternal();
    notifyListeners();
  }

  void setAmount(double value) {
    amount = value;
    _recalculateInternal();
    notifyListeners();
  }

  void recalculate() {
    _recalculateInternal();
    notifyListeners();
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
