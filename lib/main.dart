import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/currency_app.dart';
import 'providers/currency_provider.dart';
import 'repositories/currency_repository.dart';
import 'repositories/historical_rates_repository.dart';
import 'services/currency_api.dart';
import 'services/historical_database.dart';
import 'utils/language_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Initialize services
  final api = CurrencyApi();
  final repository = CurrencyRepository(
    api: api,
    prefs: prefs,
  );
  final historicalRepository = HistoricalRatesRepository(
    api: api,
    database: HistoricalDatabase.instance,
    currencyRepository: repository,
  );

  // Initialize database connection (non-blocking for UI)
  // Historical data sync will happen in background after UI loads
  // This ensures historical data is available for offline use
  historicalRepository.initialize().catchError((error) {
    // Silently handle initialization errors - app can work without historical data
    if (kDebugMode) {
      print('Historical repository initialization error: $error');
    }
  });

  final initialLanguage = resolveInitialLanguage(prefs);

  runApp(
    MultiProvider(
      providers: [
        Provider<HistoricalRatesRepository>.value(value: historicalRepository),
        ChangeNotifierProvider(
          create: (_) => CurrencyProvider(repository)..init(),
        ),
      ],
      child: CurrencyApp(
        initialLanguage: initialLanguage,
        prefs: prefs,
      ),
    ),
  );
}
