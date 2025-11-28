String formatAmount(double value) {
  final absValue = value.abs();

  if (absValue < 1000) {
    final rounded = double.parse(value.toStringAsFixed(2));
    if (rounded.abs() >= 1000) {
      return _formatInteger(rounded.toInt());
    }

    final fixed = rounded.toStringAsFixed(2);
    return _trimTrailingZeros(fixed);
  }

  return _formatInteger(value.toInt());
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
