import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

String resolveInitialLanguage(SharedPreferences prefs) {
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
