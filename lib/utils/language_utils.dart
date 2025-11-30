import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

String resolveInitialLanguage(SharedPreferences prefs) {
  final savedLanguage = prefs.getString(kLanguagePreferenceKey);
  if (savedLanguage != null && kSupportedLanguages.contains(savedLanguage)) {
    return savedLanguage;
  }

  final deviceLanguage = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  final matchedLanguage = kDeviceLanguageToAppLanguage[deviceLanguage.toLowerCase()];
  if (matchedLanguage != null && kSupportedLanguages.contains(matchedLanguage)) {
    return matchedLanguage;
  }

  return 'EN';
}


