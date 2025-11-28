part of 'package:currency/main.dart';

class CurrencyApp extends StatefulWidget {
  const CurrencyApp({
    super.key,
    required this.initialLanguage,
    required this.prefs,
  });

  final String initialLanguage;
  final SharedPreferences prefs;

  @override
  State<CurrencyApp> createState() => _CurrencyAppState();
}

class _CurrencyAppState extends State<CurrencyApp> {
  late final PersistedLanguageNotifier _languageNotifier =
      PersistedLanguageNotifier(widget.initialLanguage, widget.prefs);

  @override
  void dispose() {
    _languageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _languageNotifier,
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
            languageNotifier: _languageNotifier,
          ),
        );
      },
    );
  }
}
