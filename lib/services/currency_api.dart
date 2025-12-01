import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/historical_rate.dart';

class LatestRatesResponse {
  LatestRatesResponse({
    required this.rates,
    required this.date,
    required this.base,
  });

  final Map<String, double> rates;
  final DateTime date;
  final String base;
}

class CurrencyApi {
  CurrencyApi({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://api.frankfurter.dev/v1';
  static const _timeoutDuration = Duration(seconds: 15);

  final http.Client _client;
  Map<String, double>? _latestRates;

  Future<LatestRatesResponse> getLatestRates() async {
    final uri = Uri.parse('$_baseUrl/latest');
    
    try {
      final response = await _client
          .get(uri)
          .timeout(_timeoutDuration, onTimeout: () {
        throw TimeoutException('Request timeout', _timeoutDuration);
      });

      if (response.statusCode != 200) {
        throw http.ClientException(
          'Failed to fetch rates: ${response.statusCode}',
          uri,
        );
      }

      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Validate response structure
        if (!decoded.containsKey('rates') || !decoded.containsKey('date')) {
          throw FormatException('Invalid API response structure');
        }
        
        final rates = Map<String, double>.from(
          (decoded['rates'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ),
        );

        if (rates.isEmpty) {
          throw FormatException('API returned empty rates');
        }

        final date = DateTime.parse(decoded['date'] as String);
        final base = decoded['base'] as String;

        // Include base currency in rates with value 1.0
        _latestRates = {...rates, base: 1.0};

        return LatestRatesResponse(
          rates: _latestRates!,
          date: date,
          base: base,
        );
      } catch (e) {
        if (e is FormatException) rethrow;
        throw FormatException('Failed to parse API response: $e');
      }
    } on TimeoutException {
      rethrow;
    } on http.ClientException {
      rethrow;
    } catch (e) {
      throw http.ClientException('Unexpected error fetching rates: $e', uri);
    }
  }

  Future<HistoricalRate> getLatestRateForPair({
    required String base,
    required String target,
  }) async {
    // New API uses 'base' and 'symbols' parameters
    final uri = Uri.parse('$_baseUrl/latest?base=$base&symbols=$target');
    
    try {
      final response = await _client
          .get(uri)
          .timeout(_timeoutDuration, onTimeout: () {
        throw TimeoutException('Request timeout', _timeoutDuration);
      });

      if (response.statusCode != 200) {
        throw http.ClientException(
          'Failed to fetch latest pair rate: ${response.statusCode}',
          uri,
        );
      }

      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Validate response structure
        if (!decoded.containsKey('rates') || !decoded.containsKey('date')) {
          throw FormatException('Invalid API response structure');
        }
        
        final date = DateTime.parse(decoded['date'] as String);
        final rates = decoded['rates'] as Map<String, dynamic>;
        
        if (!rates.containsKey(target)) {
          throw FormatException('Target currency not found in response');
        }
        
        final rate = (rates[target] as num).toDouble();

        return HistoricalRate(
          date: date,
          base: base,
          target: target,
          rate: rate,
        );
      } catch (e) {
        if (e is FormatException) rethrow;
        throw FormatException('Failed to parse API response: $e');
      }
    } on TimeoutException {
      rethrow;
    } on http.ClientException {
      rethrow;
    } catch (e) {
      throw http.ClientException('Unexpected error fetching pair rate: $e', uri);
    }
  }

  Future<Map<String, String>> getCurrencies() async {
    final uri = Uri.parse('$_baseUrl/currencies');
    final response = await _client
        .get(uri)
        .timeout(_timeoutDuration, onTimeout: () {
      throw TimeoutException('Request timeout', _timeoutDuration);
    });

    if (response.statusCode != 200) {
      throw http.ClientException('Failed to fetch currencies: ${response.statusCode}', uri);
    }

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      // API returns map of currency codes to names
      return decoded.map((key, value) => MapEntry(key, value as String));
    } catch (e) {
      throw FormatException('Failed to parse API response: $e');
    }
  }

  double convert(String from, String to, double amount) {
    final rates = _latestRates;
    if (rates == null) {
      throw StateError('Rates have not been loaded');
    }

    final fromRate = rates[from];
    final toRate = rates[to];

    if (fromRate == null || toRate == null) {
      throw ArgumentError('Unknown currency code: $from or $to');
    }

    return amount * (toRate / fromRate);
  }

  Future<List<HistoricalRate>> getHistoricalRates({
    required String base,
    required String target,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final start = _formatDate(startDate);
    final end = _formatDate(endDate);
    // New API uses 'base' and 'symbols' parameters
    final uri = Uri.parse('$_baseUrl/$start..$end?base=$base&symbols=$target');
    
    try {
      final response = await _client
          .get(uri)
          .timeout(_timeoutDuration, onTimeout: () {
        throw TimeoutException('Request timeout', _timeoutDuration);
      });

      if (response.statusCode != 200) {
        throw http.ClientException(
          'Failed to fetch historical rates: ${response.statusCode}',
          uri,
        );
      }

      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Validate response structure
        if (!decoded.containsKey('rates')) {
          throw FormatException('Invalid API response structure');
        }
        
        final rawRates = decoded['rates'] as Map<String, dynamic>;

        if (rawRates.isEmpty) {
          // Return empty list if no rates found (might be weekend/holiday)
          return <HistoricalRate>[];
        }

        final result = <HistoricalRate>[];
        rawRates.forEach((dateString, value) {
          try {
            final rateMap = value as Map<String, dynamic>;
            final rateValue = rateMap[target];
            if (rateValue != null) {
              result.add(
                HistoricalRate(
                  date: DateTime.parse(dateString as String),
                  base: base,
                  target: target,
                  rate: (rateValue as num).toDouble(),
                ),
              );
            }
          } catch (e) {
            // Skip invalid entries, continue processing
          }
        });

        result.sort((a, b) => a.date.compareTo(b.date));
        return result;
      } catch (e) {
        if (e is FormatException) rethrow;
        throw FormatException('Failed to parse API response: $e');
      }
    } on TimeoutException {
      rethrow;
    } on http.ClientException {
      rethrow;
    } catch (e) {
      throw http.ClientException('Unexpected error fetching historical rates: $e', uri);
    }
  }

  String _formatDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }
}
