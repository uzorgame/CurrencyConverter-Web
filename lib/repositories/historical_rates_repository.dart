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

  // ⚡ ОПТИМИЗАЦИЯ: Добавлен флаг инициализации
  bool _isInitialized = false;
  Completer<void>? _initCompleter;

  // ⚡ ОПТИМИЗАЦИЯ: Старый метод для совместимости (теперь не блокирующий)
  @Deprecated('Use initializeAsync() for background init')
  Future<void> initialize() async {
    return initializeAsync();
  }

  // ⚡ ОПТИМИЗАЦИЯ: Асинхронная инициализация (не блокирует UI)
  Future<void> initializeAsync() async {
    if (_isInitialized) return;
    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<void>();

    try {
      // 🔧 ИСПРАВЛЕНО: Сначала инициализируем БД (быстро)
      await database.database;
      
      // Сразу помечаем как инициализированную после создания БД
      _isInitialized = true;
      _initCompleter!.complete();
      
      // Теперь загружаем данные в фоне (медленно, но не блокирует)
      _preloadHistoricalData();
    } catch (e) {
      _initCompleter!.completeError(e);
      _initCompleter = null;
      _isInitialized = false;
      rethrow;
    }
  }
  
  // 🔧 ИСПРАВЛЕНО: Предзагрузка данных в фоне (не блокирует)
  void _preloadHistoricalData() {
    // Запускаем в фоне без await
    Future(() async {
      try {
        final currencySet = <String>{..._defaultCurrencies};

        final savedFrom = currencyRepository.loadLastFromCurrency();
        final savedTo = currencyRepository.loadLastToCurrency();
        final favorites = currencyRepository.loadFavoriteCurrencies();

        if (savedFrom != null) currencySet.add(savedFrom);
        if (savedTo != null) currencySet.add(savedTo);
        currencySet.addAll(favorites);

        final pairs = _buildPairs(currencySet.toList());
        
        // Ограничиваем количество пар для быстрой предзагрузки
        final priorityPairs = pairs.take(10).toList();
        
        for (final pair in priorityPairs) {
          try {
            await _syncPair(pair.$1, pair.$2);
          } catch (_) {
            // Игнорируем ошибки при фоновой загрузке
          }
        }
      } catch (_) {
        // Игнорируем ошибки предзагрузки
      }
    });
  }

  // ⚡ ОПТИМИЗАЦИЯ: Ленивая загрузка - инициализация при первом использовании
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    
    // 🔧 ИСПРАВЛЕНО: Простая логика - либо ждём либо запускаем
    if (_initCompleter != null) {
      try {
        await _initCompleter!.future;
      } catch (_) {
        _initCompleter = null;
        _isInitialized = false;
      }
    }
    
    if (!_isInitialized) {
      await initializeAsync();
    }
  }

  Future<List<HistoricalRate>> loadLatest({
    required String base,
    required String target,
    required int days,
  }) async {
    // 🔧 ИСПРАВЛЕНО: Обязательно инициализируем БД перед запросом
    await _ensureInitialized();
    final cached = await database.loadLatest(base: base, target: target, days: days);
    return cached.reversed.toList();
  }

  Future<void> ensurePairFreshness(String base, String target) async {
    // 🔧 ИСПРАВЛЕНО: Обязательно инициализируем БД перед синхронизацией
    await _ensureInitialized();
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
