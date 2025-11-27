import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/currency_api.dart';

class CurrencyRepository {
  CurrencyRepository({required this.api, required this.prefs});

  final CurrencyApi api;
  final SharedPreferences prefs;

  static const _supportedCurrencies = {
    'AUD',
    'BGN',
    'BRL',
    'CAD',
    'CHF',
    'CNY',
    'CZK',
    'DKK',
    'EUR',
    'GBP',
    'HKD',
    'HUF',
    'IDR',
    'ILS',
    'INR',
    'ISK',
    'JPY',
    'KRW',
    'MXN',
    'MYR',
    'NOK',
    'NZD',
    'PHP',
    'PLN',
    'RON',
    'SEK',
    'SGD',
    'THB',
    'TRY',
    'USD',
    'ZAR',
  };

  static const _ratesDateKey = 'cached_rates_date';
  static const _ratesCacheKey = 'cached_rates_cache_key';
  static const _currenciesKey = 'cached_currencies';
  static const _currencyNamesKey = 'cached_currency_names';

  Map<String, double> _rates = {};
  List<String> _currencies = [];
  Map<String, String> _currencyNames = {};
  DateTime? _lastUpdated;

  Map<String, double> get rates => _rates;
  List<String> get currencies => _currencies;
  Map<String, String> get currencyNames => _currencyNames;
  DateTime get lastUpdated =>
      _lastUpdated ?? DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> loadRates() async {
    final today = DateTime.now();
    final todayKey = _ratesKeyForDate(today);

    if (_restoreRatesFromCache(
      key: todayKey,
      dateOverride: _restoreLastUpdatedDate() ?? today,
    )) {
      return;
    }

    try {
      final latest = await api.getLatestRates();
      _rates = latest.rates;
      _lastUpdated = latest.date;
      await _cacheRates(today, lastUpdatedDate: latest.date);
    } catch (_) {
      final restored = _restoreRatesFromCache(
        dateOverride: _restoreLastUpdatedDate(),
      );
      if (!restored) rethrow;
    }
  }

  Future<void> loadCurrencies() async {
    try {
      final loaded = await api.getCurrencies();
      _currencyNames = _filterSupportedCurrencies(loaded);
      _currencies = _currencyNames.keys.toList()..sort();
      await prefs.setString(_currenciesKey, jsonEncode(_currencies));
      await prefs.setString(_currencyNamesKey, jsonEncode(_currencyNames));
    } catch (_) {
      final cached = prefs.getString(_currenciesKey);
      final cachedNames = prefs.getString(_currencyNamesKey);
      if (cached == null || cachedNames == null) rethrow;
      _currencies = List<String>.from(jsonDecode(cached) as List<dynamic>);
      final decodedNames = jsonDecode(cachedNames) as Map<String, dynamic>;
      _currencyNames = _filterSupportedCurrencies(
        decodedNames.map(
          (key, value) => MapEntry(key, value as String),
        ),
      );
      _currencies = _currencyNames.keys.toList()..sort();
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

  Map<String, String> _filterSupportedCurrencies(Map<String, String> source) {
    return Map.fromEntries(
      source.entries.where((entry) => _supportedCurrencies.contains(entry.key)),
    );
  }

  Future<void> _cacheRates(DateTime cacheDate, {DateTime? lastUpdatedDate}) async {
    final key = _ratesKeyForDate(cacheDate);
    await prefs.setString(key, jsonEncode(_rates));
    await prefs.setString(_ratesCacheKey, key);
    await prefs.setString(
      _ratesDateKey,
      (lastUpdatedDate ?? cacheDate).toIso8601String(),
    );
  }

  bool _restoreRatesFromCache({String? key, DateTime? dateOverride}) {
    final cacheKey = key ?? prefs.getString(_ratesCacheKey);

    if (cacheKey == null) return false;

    final cachedRates = prefs.getString(cacheKey);

    if (cachedRates == null) return false;

    final decoded = jsonDecode(cachedRates) as Map<String, dynamic>;
    _rates = decoded.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
    _lastUpdated = dateOverride ?? _restoreLastUpdatedDate();

    return true;
  }

  String _ratesKeyForDate(DateTime date) {
    final dateString = date.toIso8601String().split('T').first;
    return 'currency_rates_$dateString';
  }

  DateTime? _restoreLastUpdatedDate() {
    final cachedDateString = prefs.getString(_ratesDateKey);
    if (cachedDateString == null || cachedDateString.isEmpty) return null;

    return DateTime.tryParse(cachedDateString);
  }
}
