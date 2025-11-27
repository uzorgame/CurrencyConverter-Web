import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/historical_rate.dart';
import '../services/currency_api.dart';
import '../services/historical_database.dart';
import 'currency_repository.dart';

class HistoricalRatesRepository {
  HistoricalRatesRepository({
    required this.api,
    required this.database,
    required this.currencyRepository,
    required this.prefs,
  });

  final CurrencyApi api;
  final HistoricalDatabase database;
  final CurrencyRepository currencyRepository;
  final SharedPreferences prefs;

  static const _lastSyncPrefix = 'history_last_sync';
  static const _defaultCurrencies = ['USD', 'EUR', 'PLN', 'GBP', 'TRY'];

  Future<void> initialize() async {
    await database.database;
    final currencySet = <String>{..._defaultCurrencies};

    final savedFrom = currencyRepository.loadLastFromCurrency();
    final savedTo = currencyRepository.loadLastToCurrency();
    final favorites = currencyRepository.loadFavoriteCurrencies();

    if (savedFrom != null) currencySet.add(savedFrom);
    if (savedTo != null) currencySet.add(savedTo);
    currencySet.addAll(favorites);

    final pairs = _buildPairs(currencySet.toList());
    for (final pair in pairs) {
      try {
        await _syncPair(pair.$1, pair.$2);
      } catch (_) {}
    }
  }

  Future<List<HistoricalRate>> loadLatest({
    required String base,
    required String target,
    required int days,
  }) async {
    final cached = await database.loadLatest(base: base, target: target, limit: days);
    return cached.reversed.toList();
  }

  Future<void> ensurePairFreshness(String base, String target) async {
    await _syncPair(base, target);
  }

  List<(String, String)> _buildPairs(List<String> currencies) {
    final pairs = <(String, String)>[];
    for (var i = 0; i < currencies.length; i++) {
      for (var j = i + 1; j < currencies.length; j++) {
        final first = currencies[i];
        final second = currencies[j];
        pairs.add((first, second));
        pairs.add((second, first));
      }
    }
    return pairs;
  }

  Future<void> _syncPair(String base, String target) async {
    final today = DateTime.now();
    final endDate = DateTime(today.year, today.month, today.day);

    final lastSyncString = prefs.getString(_pairKey(base, target));
    final lastSync = lastSyncString != null ? DateTime.tryParse(lastSyncString) : null;
    if (lastSync != null && !lastSync.isBefore(endDate)) {
      return;
    }

    final desiredStart = endDate.subtract(const Duration(days: 364));
    final bounds = await database.fetchDateBounds(base: base, target: target);

    if (bounds == null) {
      await _fetchAndStore(base, target, desiredStart, endDate);
    } else {
      if (bounds.minDate.isAfter(desiredStart)) {
        final missingEnd = bounds.minDate.subtract(const Duration(days: 1));
        await _fetchAndStore(base, target, desiredStart, missingEnd);
      }

      if (bounds.maxDate.isBefore(endDate)) {
        final missingStart = bounds.maxDate.add(const Duration(days: 1));
        await _fetchAndStore(base, target, missingStart, endDate);
      }
    }

    await prefs.setString(_pairKey(base, target), endDate.toIso8601String());
  }

  Future<void> _fetchAndStore(
    String base,
    String target,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (startDate.isAfter(endDate)) return;
    final fetched = await api.getHistoricalRates(
      base: base,
      target: target,
      startDate: startDate,
      endDate: endDate,
    );
    await database.upsertRates(fetched);
  }

  String _pairKey(String base, String target) => '${_lastSyncPrefix}_${base}_$target';
}
