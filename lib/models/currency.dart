import 'package:flutter/foundation.dart';

// ⚡ ОПТИМИЗАЦИЯ: @immutable для const оптимизации
@immutable
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
