import 'dart:math' as math;

import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';

class Currency {
  const Currency({
    required this.code,
    required this.name,
    this.flag,
  });

  final String code;
  final String name;
  final String? flag;
}

const List<Currency> currencies = [
  Currency(code: 'AUD', name: 'Australian Dollar'),
  Currency(code: 'BGN', name: 'Bulgarian Lev'),
  Currency(code: 'BRL', name: 'Brazilian Real'),
  Currency(code: 'CAD', name: 'Canadian Dollar'),
  Currency(code: 'CHF', name: 'Swiss Franc'),
  Currency(code: 'CNY', name: 'Chinese Renminbi Yuan'),
  Currency(code: 'CZK', name: 'Czech Koruna'),
  Currency(code: 'DKK', name: 'Danish Krone'),
  Currency(code: 'EUR', name: 'Euro'),
  Currency(code: 'GBP', name: 'British Pound'),
  Currency(code: 'HKD', name: 'Hong Kong Dollar'),
  Currency(code: 'HUF', name: 'Hungarian Forint'),
  Currency(code: 'IDR', name: 'Indonesian Rupiah'),
  Currency(code: 'ILS', name: 'Israeli New Sheqel'),
  Currency(code: 'INR', name: 'Indian Rupee'),
  Currency(code: 'ISK', name: 'Icelandic Króna'),
  Currency(code: 'JPY', name: 'Japanese Yen'),
  Currency(code: 'KRW', name: 'South Korean Won'),
  Currency(code: 'MXN', name: 'Mexican Peso'),
  Currency(code: 'MYR', name: 'Malaysia Ringgit'),
  Currency(code: 'NOK', name: 'Norwegian Krone'),
  Currency(code: 'NZD', name: 'New Zealand Dollar'),
  Currency(code: 'PHP', name: 'Philippine Peso'),
  Currency(code: 'PLN', name: 'Polish Złoty'),
  Currency(code: 'RON', name: 'Romanian Leu'),
  Currency(code: 'SEK', name: 'Swedish Krona'),
  Currency(code: 'SGD', name: 'Singapore Dollar'),
  Currency(code: 'THB', name: 'Thai Baht'),
  Currency(code: 'TRY', name: 'Turkish Lira'),
  Currency(code: 'USD', name: 'United States Dollar'),
  Currency(code: 'ZAR', name: 'South African Rand'),
];

const Map<String, String> currencyToFlag = {
  'AUD': 'au',
  'BGN': 'bg',
  'BRL': 'br',
  'CAD': 'ca',
  'CHF': 'ch',
  'CNY': 'cn',
  'CZK': 'cz',
  'DKK': 'dk',
  'EUR': 'eu',
  'GBP': 'gb',
  'HKD': 'hk',
  'HUF': 'hu',
  'IDR': 'id',
  'ILS': 'il',
  'INR': 'in',
  'ISK': 'is',
  'JPY': 'jp',
  'KRW': 'kr',
  'MXN': 'mx',
  'MYR': 'my',
  'NOK': 'no',
  'NZD': 'nz',
  'PHP': 'ph',
  'PLN': 'pl',
  'RON': 'ro',
  'SEK': 'se',
  'SGD': 'sg',
  'THB': 'th',
  'TRY': 'tr',
  'USD': 'us',
  'ZAR': 'za',
};

Widget buildCurrencyFlag(String currencyCode) {
  if (currencyCode == 'EUR') {
    return buildEurFlag();
  }

  final flagCode = currencyToFlag[currencyCode];

  if (flagCode == null) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
    );
  }

  return CircleFlag(
    flagCode,
    size: 40,
  );
}

class EUPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF003399);
    canvas.drawRect(Offset.zero & size, paint);

    final starPaint = Paint()..color = const Color(0xFFFFCC00);
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = size.width * 0.38;
    final starRadius = size.width * 0.06;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final dx = center.dx + ringRadius * math.cos(angle);
      final dy = center.dy + ringRadius * math.sin(angle);

      canvas.drawCircle(Offset(dx, dy), starRadius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget buildEurFlag() {
  return ClipOval(
    child: SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: EUPainter(),
      ),
    ),
  );
}
