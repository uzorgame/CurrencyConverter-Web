part of '../app/app.dart';

String _formatDateTime(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = _twoDigits(dateTime.month);
  final day = _twoDigits(dateTime.day);
  return '$year-$month-$day';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');
