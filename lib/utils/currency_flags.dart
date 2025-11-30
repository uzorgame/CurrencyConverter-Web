import 'dart:math' as math;
import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/material.dart';
import '../constants/currency_data.dart';

Widget buildCurrencyFlag(String currencyCode) {
  if (currencyCode == 'EUR') {
    return buildEurFlag();
  }

  final flagCode = kCurrencyToFlag[currencyCode];

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


