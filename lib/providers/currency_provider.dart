import 'package:flutter/material.dart';

import '../repositories/currency_repository.dart';
import '../services/currency_api.dart';

enum CurrencyState { loading, ready, error }

class CurrencyProvider extends ChangeNotifier {
  CurrencyProvider({required this.repository});

  final CurrencyRepository repository;

  CurrencyState state = CurrencyState.loading;
  String? errorMessage;
  String baseCurrency = 'USD';
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double amount = 0;
  double result = 0;
  DateTime? lastUpdated;
  bool usedCache = false;

  List<String> currencies = [];

  Future<void> initialize() async {
    await _load(baseCurrency, silent: false);
  }

  Future<void> _load(String base, {bool silent = true}) async {
    if (!silent) {
      state = CurrencyState.loading;
      notifyListeners();
    }

    try {
      await repository.loadRates(base);
      currencies = repository.supportedCurrencies;
      lastUpdated = repository.lastUpdated;
      usedCache = repository.usedCache;
      baseCurrency = base;
      if (!currencies.contains(fromCurrency)) {
        fromCurrency = base;
      }
      if (!currencies.contains(toCurrency)) {
        toCurrency = currencies.firstWhere(
          (c) => c != fromCurrency,
          orElse: () => base,
        );
      }
      _recalculate();
      state = CurrencyState.ready;
      errorMessage = null;
    } on CurrencyApiException catch (e) {
      state = CurrencyState.error;
      errorMessage = e.message;
    } catch (_) {
      state = CurrencyState.error;
      errorMessage = 'Something went wrong';
    }
    notifyListeners();
  }

  void setAmount(String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.')) ?? 0;
    amount = parsed;
    _recalculate();
    notifyListeners();
  }

  Future<void> setFromCurrency(String value) async {
    fromCurrency = value;
    await _load(value, silent: false);
  }

  Future<void> setToCurrency(String value) async {
    toCurrency = value;
    _recalculate();
    notifyListeners();
  }

  Future<void> swap() async {
    final temp = fromCurrency;
    fromCurrency = toCurrency;
    toCurrency = temp;
    await _load(fromCurrency, silent: false);
  }

  void _recalculate() {
    try {
      result = repository.convert(amount, fromCurrency, toCurrency);
    } catch (e) {
      result = 0;
    }
  }
}
