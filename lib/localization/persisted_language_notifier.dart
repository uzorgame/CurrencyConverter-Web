import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class PersistedLanguageNotifier extends ValueNotifier<String> {
  PersistedLanguageNotifier(super.value, this.prefs);

  final SharedPreferences prefs;

  @override
  set value(String newValue) {
    if (super.value == newValue) return;
    super.value = newValue;
    prefs.setString(languagePreferenceKey, newValue);
  }
}
