import 'dart:convert';

import 'package:http/http.dart' as http;

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
}
