
String formatDateTime(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = twoDigits(dateTime.month);
  final day = twoDigits(dateTime.day);
  return '$year-$month-$day';
}

String twoDigits(int value) => value.toString().padLeft(2, '0');
