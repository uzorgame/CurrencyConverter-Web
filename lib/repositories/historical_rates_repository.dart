import 'dart:async';

import '../models/historical_rate.dart';
import '../services/currency_api.dart';
import '../services/historical_database.dart';
import 'currency_repository.dart';

class HistoricalRatesRepository {
  HistoricalRatesRepository({
    required this.api,
    required this.database,
    required this.currencyRepository,
  });

  final CurrencyApi api;
  final HistoricalDatabase database;
  final CurrencyRepository currencyRepository;
  static const _defaultCurrencies = ['USD', 'EUR', 'PLN', 'GBP', 'TRY'];

  Future<void> initialize() async {
    try {
      await database.database;
      
      // Check if this is first launch (no historical data exists)
      final isFirstLaunch = !(await database.hasAnyRates());
      
      final currencySet = <String>{..._defaultCurrencies};

      final savedFrom = currencyRepository.loadLastFromCurrency();
      final savedTo = currencyRepository.loadLastToCurrency();
      final favorites = currencyRepository.loadFavoriteCurrencies();

      if (savedFrom != null && savedFrom.isNotEmpty) currencySet.add(savedFrom);
      if (savedTo != null && savedTo.isNotEmpty) currencySet.add(savedTo);
      currencySet.addAll(favorites.where((code) => code.isNotEmpty));

      // On first launch, prioritize loading historical data for last year
      // Limit pairs to prevent excessive API calls on startup
      final limitedSet = currencySet.take(10).toList();
      final pairs = _buildPairs(limitedSet);
      
      // Process pairs with error handling
      for (final pair in pairs) {
        try {
          if (isFirstLaunch) {
            // On first launch, ensure we load at least one year of data
            await _syncPairWithYearHistory(pair.$1, pair.$2).timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                // Skip timeout pairs to prevent blocking
              },
            );
          } else {
            // On subsequent launches, just sync missing data
            await _syncPair(pair.$1, pair.$2).timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                // Skip timeout pairs to prevent blocking
              },
            );
          }
        } catch (_) {
          // Continue with other pairs on error
        }
      }
    } catch (_) {
      // Initialization errors are handled silently
      // App can work without historical data
    }
  }

  Future<List<HistoricalRate>> loadLatest({
    required String base,
    required String target,
    required int days,
  }) async {
    final cached = await database.loadLatest(base: base, target: target, days: days);
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
    final bounds = await database.fetchDateBounds(base: base, target: target);
    final latestRate = await _tryFetchLatestRate(base, target);
    final apiDate = _normalizeDate(latestRate?.date ?? DateTime.now());
    final desiredStart = _historyStartFrom(apiDate);

    if (bounds == null) {
      // No data exists, fetch from one year ago to now
      await _fetchAndStore(base, target, desiredStart, apiDate);
      return;
    }

    // Ensure we have at least one year of data
    if (bounds.minDate.isAfter(desiredStart)) {
      final missingEnd = bounds.minDate.subtract(const Duration(days: 1));
      await _fetchAndStore(base, target, desiredStart, missingEnd);
    }

    // Update recent data if needed
    final lastLocalDate = _normalizeDate(bounds.maxDate);
    if (apiDate.isAfter(lastLocalDate)) {
      final missingStart = lastLocalDate.add(const Duration(days: 1));
      await _fetchAndStore(base, target, missingStart, apiDate);
    }
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

  DateTime _historyStartFrom(DateTime latestDate) {
    final normalized = _normalizeDate(latestDate);
    // Always load at least one year of history
    final oneYearAgo = normalized.subtract(const Duration(days: 365));
    return oneYearAgo;
  }
  
  Future<void> _syncPairWithYearHistory(String base, String target) async {
    // For first launch, ensure we have at least one year of data
    final latestRate = await _tryFetchLatestRate(base, target);
    final apiDate = _normalizeDate(latestRate?.date ?? DateTime.now());
    final oneYearAgo = _historyStartFrom(apiDate);
    
    final bounds = await database.fetchDateBounds(base: base, target: target);
    
    if (bounds == null) {
      // No data exists, fetch full year
      await _fetchAndStore(base, target, oneYearAgo, apiDate);
      return;
    }
    
    // Check if we need to fill gaps or extend history
    if (bounds.minDate.isAfter(oneYearAgo)) {
      // Missing early data, fetch from one year ago to first existing date
      final missingEnd = bounds.minDate.subtract(const Duration(days: 1));
      await _fetchAndStore(base, target, oneYearAgo, missingEnd);
    }
    
    // Check if we need to update recent data
    final lastLocalDate = _normalizeDate(bounds.maxDate);
    if (apiDate.isAfter(lastLocalDate)) {
      final missingStart = lastLocalDate.add(const Duration(days: 1));
      await _fetchAndStore(base, target, missingStart, apiDate);
    }
  }

  DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  Future<HistoricalRate?> _tryFetchLatestRate(String base, String target) async {
    try {
      return await api.getLatestRateForPair(base: base, target: target);
    } catch (_) {
      return null;
    }
  }
}
