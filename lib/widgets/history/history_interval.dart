enum HistoryInterval {
  days30,
  months3,
  months6,
  year1,
}

extension HistoryIntervalExtension on HistoryInterval {
  String get label {
    switch (this) {
      case HistoryInterval.days30:
        return '30d';
      case HistoryInterval.months3:
        return '3m';
      case HistoryInterval.months6:
        return '6m';
      case HistoryInterval.year1:
        return '1y';
    }
  }

  int get days {
    switch (this) {
      case HistoryInterval.days30:
        return 30;
      case HistoryInterval.months3:
        return 90;
      case HistoryInterval.months6:
        return 180;
      case HistoryInterval.year1:
        return 365;
    }
  }
}


