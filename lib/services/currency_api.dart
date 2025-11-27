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

  static const _baseUrl = 'https://api.frankfurter.app';

  final http.Client _client;
  Map<String, double>? _latestRates;

  Future<LatestRatesResponse> getLatestRates() async {
    final uri = Uri.parse('$_baseUrl/latest');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw http.ClientException('Failed to fetch rates', uri);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final rates = Map<String, double>.from(
      (decoded['rates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );

    final date = DateTime.parse(decoded['date'] as String);
    final base = decoded['base'] as String;

    _latestRates = {...rates, base: 1.0};

    return LatestRatesResponse(
      rates: _latestRates!,
      date: date,
      base: base,
    );
  }

  Future<HistoricalRate> getLatestRateForPair({
    required String base,
    required String target,
  }) async {
    final uri = Uri.parse('$_baseUrl/latest?from=$base&to=$target');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw http.ClientException('Failed to fetch latest pair rate', uri);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final date = DateTime.parse(decoded['date'] as String);
    final rates = decoded['rates'] as Map<String, dynamic>;
    final rate = (rates[target] as num).toDouble();

    return HistoricalRate(
      date: date,
      base: base,
      target: target,
      rate: rate,
    );
  }

  Future<Map<String, String>> getCurrencies() async {
    final uri = Uri.parse('$_baseUrl/currencies');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw http.ClientException('Failed to fetch currencies', uri);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
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
    final uri = Uri.parse('$_baseUrl/$start..$end?from=$base&to=$target');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw http.ClientException('Failed to fetch historical rates', uri);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final rawRates = decoded['rates'] as Map<String, dynamic>;

    final result = <HistoricalRate>[];
    rawRates.forEach((dateString, value) {
      final rateValue = (value as Map<String, dynamic>)[target];
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
    });

    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }

  String _formatDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');
    return '${normalized.year}-$month-$day';
  }
}
