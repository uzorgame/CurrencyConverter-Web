String formatAmount(double value) {
  if (value.isNaN || value.isInfinite) {
    return '0';
  }

  final isNegative = value < 0;
  final absValue = value.abs();

  if (absValue < 1000) {
    // Форматируем с 2 знаками после запятой
    final fixed = absValue.toStringAsFixed(2);
    
    // Убираем завершающие нули, но оставляем минимум 1 знак если есть дробная часть
    final trimmed = _trimTrailingZerosSafe(fixed);
    
    // Добавляем знак минус если нужно
    return isNegative ? '-' + trimmed : trimmed;
  }

  return _formatInteger(value.toInt());
}

/// Форматирует курс валют с точностью до 4 знаков после запятой
/// Всегда показывает минимум 2 знака после запятой
String formatExchangeRate(double rate) {
  if (rate.isNaN || rate.isInfinite) {
    return '--';
  }

  // Обрабатываем случай, когда курс равен 0 или очень мал
  if (rate == 0) {
    return '0.00';
  }

  // Форматируем с 4 знаками после запятой для точности
  final formatted = rate.toStringAsFixed(4);
  
  // Разделяем на целую и дробную части
  if (!formatted.contains('.')) {
    return '${formatted}.00';
  }
  
  final parts = formatted.split('.');
  if (parts.length != 2) {
    // Если что-то пошло не так, возвращаем исходное значение с 2 знаками
    return rate.toStringAsFixed(2);
  }
  
  final integerPart = parts[0];
  var decimalPart = parts[1];
  
  // Убираем завершающие нули, но оставляем минимум 2 знака
  while (decimalPart.length > 2 && decimalPart.endsWith('0')) {
    decimalPart = decimalPart.substring(0, decimalPart.length - 1);
  }
  
  // Гарантируем минимум 2 знака после запятой
  if (decimalPart.length < 2) {
    decimalPart = decimalPart.padRight(2, '0');
  }
  
  // Используем явную конкатенацию для избежания проблем с интерполяцией
  return integerPart + '.' + decimalPart;
}

/// Безопасная функция для удаления завершающих нулей
/// Избегает проблем с регулярными выражениями
String _trimTrailingZerosSafe(String value) {
  if (!value.contains('.')) return value;

  final parts = value.split('.');
  if (parts.length != 2) return value;

  final integerPart = parts[0];
  var decimalPart = parts[1];

  // Убираем завершающие нули
  while (decimalPart.isNotEmpty && decimalPart.endsWith('0')) {
    decimalPart = decimalPart.substring(0, decimalPart.length - 1);
  }

  // Если осталась только точка, возвращаем целую часть
  if (decimalPart.isEmpty) {
    return integerPart;
  }

  // Возвращаем с точкой и оставшимися знаками
  return integerPart + '.' + decimalPart;
}

String _trimTrailingZeros(String value) {
  if (!value.contains('.')) return value;

  var trimmed = value.replaceFirst(RegExp(r'\.0+$'), '');
  trimmed = trimmed.replaceFirst(RegExp(r'(\.\d*?[1-9])0+$'), r'$1');

  if (trimmed.endsWith('.')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }

  return trimmed;
}

String _formatInteger(int value) {
  final isNegative = value < 0;
  final digits = value.abs().toString().split('').reversed.toList();
  final buffer = StringBuffer();

  for (int i = 0; i < digits.length; i++) {
    if (i != 0 && i % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }

  final formatted = buffer.toString().split('').reversed.join();
  return isNegative ? '-$formatted' : formatted;
}
