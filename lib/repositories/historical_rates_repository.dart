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

  // ✅ УПРОЩЕНО: Простая инициализация без сложной логики
  Future<void> initialize() async {
    // Инициализируем БД
    await database.database;
    
    // Загружаем минимальный набор данных для быстрого старта
    final currencySet = <String>{..._defaultCurrencies};

    final savedFrom = currencyRepository.loadLastFromCurrency();
    final savedTo = currencyRepository.loadLastToCurrency();
    final favorites = currencyRepository.loadFavoriteCurrencies();

    if (savedFrom != null) currencySet.add(savedFrom);
    if (savedTo != null) currencySet.add(savedTo);
    currencySet.addAll(favorites);

    final pairs = _buildPairs(currencySet.toList());
    
    // Синхронизируем только приоритетные пары (быстро)
    final priorityPairs = pairs.take(10).toList();
    
    for (final pair in priorityPairs) {
      try {
        await _syncPair(pair.$1, pair.$2);
      } catch (_) {
        // Игнорируем ошибки - продолжаем работу
      }
    }
  }

  // Для обратной совместимости
  Future<void> initializeAsync() => initialize();

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
      await _fetchAndStore(base, target, desiredStart, apiDate);
      return;
    }

    if (bounds.minDate.isAfter(desiredStart)) {
      final missingEnd = bounds.minDate.subtract(const Duration(days: 1));
      await _fetchAndStore(base, target, desiredStart, missingEnd);
    }

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
    final fiveYearsAgo = DateTime(normalized.year - 5, normalized.month, normalized.day);
    final oneYearAgo = normalized.subtract(const Duration(days: 365));
    return fiveYearsAgo.isAfter(oneYearAgo) ? fiveYearsAgo : oneYearAgo;
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
