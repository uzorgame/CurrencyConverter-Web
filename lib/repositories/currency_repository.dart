import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/currency_api.dart';

class CurrencyRepository {
  CurrencyRepository({required this.api, required this.prefs});

  final CurrencyApi api;
  final SharedPreferences prefs;

  static const _ratesKey = 'cached_rates';
  static const _ratesDateKey = 'cached_rates_date';
  static const _currenciesKey = 'cached_currencies';

  Map<String, double> _rates = {};
  List<String> _currencies = [];
  DateTime? _lastUpdated;

  Map<String, double> get rates => _rates;
  List<String> get currencies => _currencies;
  DateTime get lastUpdated =>
      _lastUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> loadRates() async {
    try {
      final latest = await api.getLatestRates();
      _rates = latest.rates;
      _lastUpdated = latest.date;
      await _cacheRates();
    } catch (_) {
      final restored = _restoreRatesFromCache();
      if (!restored) rethrow;
    }
  }

  Future<void> loadCurrencies() async {
    try {
      final loaded = await api.getCurrencies();
      _currencies = loaded.keys.toList()..sort();
      await prefs.setString(_currenciesKey, jsonEncode(_currencies));
    } catch (_) {
      final cached = prefs.getString(_currenciesKey);
      if (cached == null) rethrow;
      _currencies = List<String>.from(jsonDecode(cached) as List<dynamic>);
    }
  }

  double convert(String from, String to, double amount) {
    if (_rates.isEmpty) {
      throw StateError('Rates are not loaded');
    }

    final fromRate = _rates[from];
    final toRate = _rates[to];

    if (fromRate == null || toRate == null) {
      throw ArgumentError('Unknown currency code: $from or $to');
    }

    return amount * (toRate / fromRate);
  }

  Future<void> _cacheRates() async {
    await prefs.setString(_ratesKey, jsonEncode(_rates));
    await prefs.setString(
      _ratesDateKey,
      _lastUpdated?.toIso8601String() ?? '',
    );
  }

  bool _restoreRatesFromCache() {
    final cachedRates = prefs.getString(_ratesKey);
    if (cachedRates == null) return false;

    final cachedDate = prefs.getString(_ratesDateKey);

    final decoded = jsonDecode(cachedRates) as Map<String, dynamic>;
    _rates = decoded.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
    if (cachedDate != null && cachedDate.isNotEmpty) {
      _lastUpdated = DateTime.tryParse(cachedDate);
    }

    return true;
  }
}
