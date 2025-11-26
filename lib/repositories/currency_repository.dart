import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/currency_api.dart';

class CurrencyRepository {
  CurrencyRepository({required this.api, required this.preferences});

  final CurrencyApi api;
  final SharedPreferences preferences;

  static const _ratesKeyPrefix = 'rates_';
  static const _ratesDateKeyPrefix = 'rates_date_';
  static const _currenciesKey = 'currencies_map';
  static const cacheDuration = Duration(hours: 2);

  Map<String, double> _rates = {};
  List<String> _currencies = [];
  String _base = 'USD';
  DateTime? _lastUpdated;
  bool _usedCache = false;

  DateTime? get lastUpdated => _lastUpdated;
  bool get usedCache => _usedCache;

  Future<void> loadRates(String base) async {
    _base = base;
    _usedCache = false;
    await _ensureCurrencies();

    final cacheKey = '$_ratesKeyPrefix$base';
    final cacheDateKey = '$_ratesDateKeyPrefix$base';
    final cachedRates = preferences.getString(cacheKey);
    final cachedDateString = preferences.getString(cacheDateKey);

    if (cachedRates != null && cachedDateString != null) {
      final cachedDate = DateTime.tryParse(cachedDateString);
      if (cachedDate != null && DateTime.now().difference(cachedDate) < cacheDuration) {
        _loadFromCache(cachedRates, cachedDate);
        return;
      }
    }

    try {
      final latest = await api.getLatestRates(base: base);
      final date = DateTime.tryParse(latest['date'] as String? ?? '');
      final rates = (latest['rates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
      _rates = rates;
      _lastUpdated = date ?? DateTime.now();

      await preferences.setString(cacheKey, jsonEncode(rates));
      await preferences.setString(cacheDateKey, _lastUpdated!.toIso8601String());
    } on CurrencyApiException {
      if (cachedRates != null && cachedDateString != null) {
        final cachedDate = DateTime.tryParse(cachedDateString);
        if (cachedDate != null) {
          _usedCache = true;
          _loadFromCache(cachedRates, cachedDate);
          return;
        }
      }
      rethrow;
    }
  }

  void _loadFromCache(String cachedRates, DateTime cachedDate) {
    final decoded = jsonDecode(cachedRates) as Map<String, dynamic>;
    _rates = decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
    _lastUpdated = cachedDate;
  }

  double getRate(String currency) {
    if (_base == currency) {
      return 1.0;
    }
    final rate = _rates[currency];
    if (rate == null) {
      throw CurrencyApiException('Currency $currency is not available');
    }
    return rate;
  }

  List<String> get supportedCurrencies {
    if (_currencies.isNotEmpty) {
      return _currencies;
    }
    final currencies = _rates.keys.toSet()..add(_base);
    return currencies.toList()..sort();
  }

  double convert(double amount, String from, String to) {
    if (from == to) return amount;

    final fromRate = getRate(from);
    final toRate = getRate(to);
    return amount / fromRate * toRate;
  }

  Future<void> _ensureCurrencies() async {
    if (_currencies.isNotEmpty) return;
    final cached = preferences.getString(_currenciesKey);
    if (cached != null) {
      final data = (jsonDecode(cached) as Map<String, dynamic>).keys.toList();
      _currencies = data..sort();
      return;
    }

    try {
      final currencies = await api.getCurrencies();
      _currencies = currencies.keys.toList()..sort();
      await preferences.setString(_currenciesKey, jsonEncode(currencies));
    } on CurrencyApiException {
      if (_currencies.isNotEmpty) return;
      if (cached != null) {
        final data = (jsonDecode(cached) as Map<String, dynamic>).keys.toList();
        _currencies = data..sort();
        return;
      }
      rethrow;
    }
  }
}
