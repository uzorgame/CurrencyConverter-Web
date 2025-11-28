import 'package:currency/screens/currency_converter_screen.dart';
import 'package:currency/utils/app_colors.dart';
import 'package:currency/utils/app_strings.dart';
import 'package:currency/utils/language_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
            scaffoldBackgroundColor: AppColors.bgMain,
            fontFamily: 'SF Pro Display',
            colorScheme: const ColorScheme.dark(background: AppColors.bgMain),
          ),
          home: CurrencyConverterScreen(
            languageNotifier: _languageNotifier,
          ),
        );
      },
    );
  }
}
