import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/historical_rate.dart';

class HistoricalDatabase {
  HistoricalDatabase._();

  static final HistoricalDatabase instance = HistoricalDatabase._();

  static const _dbName = 'historical_rates.db';
  static const _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE historical_rates (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            base TEXT,
            target TEXT,
            rate REAL,
            UNIQUE(date, base, target)
          );
        ''');
        await db.execute(
          'CREATE INDEX idx_rates_base_target_date ON historical_rates(base, target, date);',
        );
      },
    );
  }

  Future<void> upsertRates(List<HistoricalRate> rates) async {
    if (rates.isEmpty) return;
    final db = await database;
    final batch = db.batch();
    for (final rate in rates) {
      batch.insert(
        'historical_rates',
        rate.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<HistoricalRate>> loadLatest({
    required String base,
    required String target,
    required int limit,
  }) async {
    final db = await database;
    final rows = await db.query(
      'historical_rates',
      where: 'base = ? AND target = ?',
      whereArgs: [base, target],
      orderBy: 'date DESC',
      limit: limit,
    );
    return rows.map((row) => HistoricalRate.fromMap(row)).toList();
  }

  Future<_DateBounds?> fetchDateBounds({
    required String base,
    required String target,
  }) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MIN(date) as minDate, MAX(date) as maxDate, COUNT(*) as total FROM historical_rates WHERE base = ? AND target = ?',
      [base, target],
    );

    if (result.isEmpty) return null;
    final row = result.first;
    final total = (row['total'] as int?) ?? 0;
    if (total == 0) return null;

    final minDateString = row['minDate'] as String?;
    final maxDateString = row['maxDate'] as String?;

    if (minDateString == null || maxDateString == null) return null;

    return _DateBounds(
      minDate: DateTime.parse(minDateString),
      maxDate: DateTime.parse(maxDateString),
    );
  }
}

class _DateBounds {
  _DateBounds({required this.minDate, required this.maxDate});

  final DateTime minDate;
  final DateTime maxDate;
}
