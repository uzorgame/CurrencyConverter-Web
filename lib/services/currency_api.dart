import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class CurrencyApiException implements Exception {
  CurrencyApiException(this.message);
  final String message;

  @override
  String toString() => 'CurrencyApiException: $message';
}

class CurrencyApi {
  CurrencyApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _baseUrl = 'https://api.frankfurter.dev/v1';
  static const _timeout = Duration(seconds: 10);

  Future<Map<String, dynamic>> getLatestRates({String base = 'USD'}) async {
    final uri = Uri.parse('$_baseUrl/latest').replace(queryParameters: {
      'base': base,
    });

    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw CurrencyApiException('Failed to load rates (${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['rates'] == null || (data['rates'] as Map).isEmpty) {
        throw CurrencyApiException('Rates are unavailable');
      }
      return data;
    } on TimeoutException {
      throw CurrencyApiException('Request timed out. Please try again.');
    } on CurrencyApiException {
      rethrow;
    } catch (_) {
      throw CurrencyApiException('Unable to load currency rates.');
    }
  }

  Future<double> convert(String from, String to, double amount) async {
    final latest = await getLatestRates(base: from);
    final rates = latest['rates'] as Map<String, dynamic>;
    final rate = rates[to];
    if (rate == null) {
      throw CurrencyApiException('Currency $to is not available');
    }
    return amount * (rate as num).toDouble();
  }

  Future<Map<String, String>> getCurrencies() async {
    final uri = Uri.parse('$_baseUrl/currencies');
    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) {
        throw CurrencyApiException('Failed to load currencies (${response.statusCode})');
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data.isEmpty) {
        throw CurrencyApiException('Currency list is empty');
      }
      return data.map((key, value) => MapEntry(key, value.toString()));
    } on TimeoutException {
      throw CurrencyApiException('Currency request timed out.');
    } on CurrencyApiException {
      rethrow;
    } catch (_) {
      throw CurrencyApiException('Unable to load currencies.');
    }
  }
}
