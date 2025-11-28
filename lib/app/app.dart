import 'dart:math' as math;

import 'package:circle_flags/circle_flags.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/historical_rate.dart';
import '../providers/currency_provider.dart';
import '../repositories/currency_repository.dart';
import '../repositories/historical_rates_repository.dart';
import '../services/currency_api.dart';
import '../services/historical_database.dart';
import '../utils/amount_formatter.dart';

part '../utils/app_colors.dart';
part '../utils/app_strings.dart';
part '../utils/formatters.dart';
part '../utils/flag_utils.dart';
part '../widgets/keypad.dart';
part '../widgets/currency_input_card.dart';
part '../widgets/currency_button.dart';
part '../widgets/amount_display.dart';
part '../widgets/exchange_rate_panel.dart';
part '../widgets/historical_chart.dart';
part '../screens/converter_screen.dart';
part '../screens/currency_picker_page.dart';
part '../screens/settings_page.dart';
part '../screens/privacy_policy_page.dart';

const List<String> kSupportedLanguages = ['EN', 'DE', 'FR', 'IT', 'ES', 'RU', 'UK'];
const Map<String, String> _deviceLanguageToAppLanguage = {
  'en': 'EN',
  'de': 'DE',
  'fr': 'FR',
  'it': 'IT',
  'es': 'ES',
  'ru': 'RU',
  'uk': 'UK',
  'ua': 'UK',
};
const String _languagePreferenceKey = 'selectedLanguage';

String _resolveInitialLanguage(SharedPreferences prefs) {
  final savedLanguage = prefs.getString(_languagePreferenceKey);
  if (savedLanguage != null && kSupportedLanguages.contains(savedLanguage)) {
    return savedLanguage;
  }

  final deviceLanguage = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  final matchedLanguage = _deviceLanguageToAppLanguage[deviceLanguage.toLowerCase()];
  if (matchedLanguage != null && kSupportedLanguages.contains(matchedLanguage)) {
    return matchedLanguage;
  }

  return 'EN';
}

class _AppBootstrapData {
  const _AppBootstrapData({
    required this.language,
    required this.prefs,
    required this.repository,
    required this.historicalRepository,
  });

  final String language;
  final SharedPreferences prefs;
  final CurrencyRepository repository;
  final HistoricalRatesRepository historicalRepository;
}

class CurrencyApp extends StatefulWidget {
  const CurrencyApp({super.key});

  @override
  State<CurrencyApp> createState() => _CurrencyAppState();
}

class _CurrencyAppState extends State<CurrencyApp> {
  late final Future<_AppBootstrapData> _initialization;
  PersistedLanguageNotifier? _languageNotifier;

  @override
  void initState() {
    super.initState();
    _initialization = _initializeApp();
  }

  @override
  void dispose() {
    _languageNotifier?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppBootstrapData>(
      future: _initialization,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!;
        _languageNotifier ??= PersistedLanguageNotifier(data.language, data.prefs);

        return MultiProvider(
          providers: [
            Provider<HistoricalRatesRepository>.value(value: data.historicalRepository),
            ChangeNotifierProvider(
              create: (_) => CurrencyProvider(data.repository)..init(),
            ),
          ],
          child: _CurrencyAppView(
            languageNotifier: _languageNotifier!,
          ),
        );
      },
    );
  }

  Future<_AppBootstrapData> _initializeApp() async {
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

    final initialLanguage = _resolveInitialLanguage(prefs);

    return _AppBootstrapData(
      language: initialLanguage,
      prefs: prefs,
      repository: repository,
      historicalRepository: historicalRepository,
    );
  }
}

class _CurrencyAppView extends StatefulWidget {
  const _CurrencyAppView({
    required this.languageNotifier,
  });

  final ValueNotifier<String> languageNotifier;

  @override
  State<_CurrencyAppView> createState() => _CurrencyAppViewState();
}

class _CurrencyAppViewState extends State<_CurrencyAppView> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.languageNotifier,
      builder: (context, language, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.of(language, 'appTitle'),
          theme: ThemeData(
            scaffoldBackgroundColor: _AppColors.bgMain,
            fontFamily: 'SF Pro Display',
            colorScheme: const ColorScheme.dark(background: _AppColors.bgMain),
          ),
          home: CurrencyConverterScreen(
            languageNotifier: widget.languageNotifier,
          ),
        );
      },
    );
  }
}

class PersistedLanguageNotifier extends ValueNotifier<String> {
  PersistedLanguageNotifier(super.value, this.prefs);

  final SharedPreferences prefs;

  @override
  set value(String newValue) {
    if (super.value == newValue) return;
    super.value = newValue;
    prefs.setString(_languagePreferenceKey, newValue);
  }
}
