import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
  static const _lastRatesTimestampKey = 'last_rates_timestamp';
  static const _lastFromCurrencyKey = 'last_from_currency';
  static const _lastToCurrencyKey = 'last_to_currency';
  static const _lastAmountKey = 'last_amount';
  static const _favoriteCurrenciesKey = 'favorite_currencies';

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
    final now = DateTime.now();
    final cachedTimestamp = prefs.getInt(_lastRatesTimestampKey);
    final cachedDate = cachedTimestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(cachedTimestamp)
        : null;
    final storedLastUpdated = _restoreLastUpdatedDate();

    // Step 1: Load cache first (if available) to show data immediately
    // This ensures UI can display data even if API fails
    // This is critical for offline functionality
    final hasCache = _restoreRatesFromCache(
      dateOverride: storedLastUpdated ?? cachedDate,
    );

    // Step 2: Always try to fetch fresh data from API on every app launch
    // This ensures we check for updates and get the latest rates
    // If API is unavailable (weekend, no internet), we'll use cached data
    try {
      final latest = await api.getLatestRates();
      
      // Validate that we got valid rates
      if (latest.rates.isEmpty) {
        throw FormatException('API returned empty rates');
      }
      
      _rates = latest.rates;
      _lastUpdated = latest.date;
      
      // Cache the fresh data for offline use
      await _cacheRates(now, lastUpdatedDate: latest.date);
      await prefs.setInt(
        _lastRatesTimestampKey,
        now.millisecondsSinceEpoch,
      );
      
      // Success: fresh data loaded and cached
      if (kDebugMode) {
        print('Successfully loaded rates from API for date: ${latest.date}');
      }
      return;
    } on TimeoutException catch (error) {
      // Network timeout - use cache if available
      if (hasCache) {
        if (kDebugMode) {
          print('API timeout, using cached data: $error');
        }
        return;
      }
      // No cache and timeout - try to restore any available cache
      _restoreRatesFromCache(dateOverride: storedLastUpdated ?? cachedDate);
    } on http.ClientException catch (error) {
      // Network or API error - use cache if available
      if (hasCache) {
        if (kDebugMode) {
          print('API error, using cached data: $error');
        }
        return;
      }
      // No cache and API error - try to restore any available cache
      _restoreRatesFromCache(dateOverride: storedLastUpdated ?? cachedDate);
    } catch (error) {
      // Any other error - use cache if available
      if (hasCache) {
        if (kDebugMode) {
          print('API update failed, using cached data: $error');
        }
        return;
      }

      // No cache available and API failed
      // Try to restore from any available cache as last resort
      final restored = _restoreRatesFromCache(
        dateOverride: storedLastUpdated ?? cachedDate,
      );

      if (!restored) {
        // No cache at all - this is first launch without internet
        // Don't throw - let the app work with empty rates
        // The UI will handle this gracefully
        if (kDebugMode) {
          print('No cache available and API failed: $error');
        }
      }
    }
  }

  Future<void> loadCurrencies() async {
    // Step 1: Load from cache first (if available)
    final cached = prefs.getString(_currenciesKey);
    final cachedNames = prefs.getString(_currencyNamesKey);
    if (cached != null && cachedNames != null) {
      try {
        _currencies = List<String>.from(jsonDecode(cached) as List<dynamic>);
        final decodedNames = jsonDecode(cachedNames) as Map<String, dynamic>;
        _currencyNames = _filterSupportedCurrencies(
          decodedNames.map(
            (key, value) => MapEntry(key, value as String),
          ),
        );
        _currencies = _currencyNames.keys.toList()..sort();
      } catch (e) {
        if (kDebugMode) {
          print('Failed to parse cached currencies: $e');
        }
      }
    }

    // Step 2: Try to fetch fresh data from API
    try {
      final loaded = await api.getCurrencies();
      _currencyNames = _filterSupportedCurrencies(loaded);
      _currencies = _currencyNames.keys.toList()..sort();
      await prefs.setString(_currenciesKey, jsonEncode(_currencies));
      await prefs.setString(_currencyNamesKey, jsonEncode(_currencyNames));
    } catch (error) {
      // API failed - if we have cache, use it (already loaded in step 1)
      if (cached == null || cachedNames == null) {
        // No cache available - this is first launch without internet
        // Use default supported currencies as fallback
        _currencies = _supportedCurrencies.toList()..sort();
        _currencyNames = _currencies.asMap().map(
          (index, code) => MapEntry(code, code),
        );
        if (kDebugMode) {
          print('No cache and API failed, using default currencies: $error');
        }
      } else {
        // Cache was already loaded in step 1, so we're good
        if (kDebugMode) {
          print('API update failed, using cached currencies: $error');
        }
      }
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

  String? loadLastFromCurrency() => prefs.getString(_lastFromCurrencyKey);

  String? loadLastToCurrency() => prefs.getString(_lastToCurrencyKey);

  String? loadLastAmount() => prefs.getString(_lastAmountKey);

  Future<void> saveLastFromCurrency(String code) =>
      prefs.setString(_lastFromCurrencyKey, code);

  Future<void> saveLastToCurrency(String code) =>
      prefs.setString(_lastToCurrencyKey, code);

  Future<void> saveLastAmount(String amount) =>
      prefs.setString(_lastAmountKey, amount);

  List<String> loadFavoriteCurrencies() {
    final favorites = prefs.getStringList(_favoriteCurrenciesKey) ?? [];
    return favorites
        .where((code) => _supportedCurrencies.contains(code))
        .toList();
  }

  Future<void> saveFavoriteCurrencies(List<String> favorites) =>
      prefs.setStringList(_favoriteCurrenciesKey, favorites);

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
