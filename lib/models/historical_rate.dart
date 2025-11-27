class HistoricalRate {
  const HistoricalRate({
    required this.date,
    required this.base,
    required this.target,
    required this.rate,
  });

  final DateTime date;
  final String base;
  final String target;
  final double rate;

  Map<String, dynamic> toMap() {
    final dateString = date.toIso8601String().split('T').first;
    return {
      'date': dateString,
      'base': base,
      'target': target,
      'rate': rate,
    };
  }

  factory HistoricalRate.fromMap(Map<String, Object?> map) {
    return HistoricalRate(
      date: DateTime.parse(map['date']! as String),
      base: map['base']! as String,
      target: map['target']! as String,
      rate: (map['rate']! as num).toDouble(),
    );
  }
}
