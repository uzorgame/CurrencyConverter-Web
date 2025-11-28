import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'constants/app_constants.dart';
import 'providers/currency_provider.dart';
import 'repositories/currency_repository.dart';
import 'repositories/historical_rates_repository.dart';
import 'services/currency_api.dart';
import 'services/historical_database.dart';

String resolveInitialLanguage(SharedPreferences prefs) {
  final savedLanguage = prefs.getString(languagePreferenceKey);
  if (savedLanguage != null && kSupportedLanguages.contains(savedLanguage)) {
    return savedLanguage;
  }

  final deviceLanguage = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  final matchedLanguage = deviceLanguageToAppLanguage[deviceLanguage.toLowerCase()];
  if (matchedLanguage != null && kSupportedLanguages.contains(matchedLanguage)) {
    return matchedLanguage;
  }

  return 'EN';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
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

  await historicalRepository.initialize();

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
