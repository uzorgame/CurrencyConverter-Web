import '../constants/app_constants.dart';

class AppStrings {
  static const Set<String> _englishOnlyKeys = {
    'about',
    'aboutCompany',
    'privacyPolicy',
    'privacyIntro',
    'privacyNoAds',
    'privacyFirebase',
    'privacyCurrencyApi',
    'privacyNoSell',
    'privacyFullDetails',
    'privacyPolicyUrl',
    'versionLabel',
  };

  static const Map<String, String> _englishOnlyValues = {
    'about': 'About',
    'privacyPolicy': 'Privacy Policy',
    'aboutCompany': 'UzorGame Inc',
    'versionLabel': 'Version $kAppVersion',
    'privacyIntro':
        'The app does not collect personal data. We do not ask for your name, email, phone number, contacts, or precise location.',
    'privacyNoAds':
        'We do not run ads, do not create accounts, and do not upload your data to our servers. All settings stay locally on your device.',
    'privacyFirebase':
        'The app uses Firebase Analytics to understand basic usage (e.g., crashes, screen views). This includes technical data such as device type, app version, and country (coarse). Firebase does not provide us with your identity or IP address.',
    'privacyCurrencyApi':
        'The app requests exchange rates from an external Currency API. These requests do not include personal information or identifiers.',
    'privacyNoSell': 'We do not sell or share user data.',
    'privacyFullDetails':
        'For full details, please read our complete Privacy Policy at:',
    'privacyPolicyUrl': 'https://uzorgame.github.io/privacy-policy-converter',
  };

  static const Map<String, Map<String, String>> _values = {
    'EN': {
      ..._englishOnlyValues,
      'appTitle': 'Currency Converter+',
      'settingsTitle': 'Settings',
      'language': 'Language',
      'currenciesTitle': 'Currencies',
      'favorites': 'Favorites',
      'searchHint': 'Search',
      'ok': 'OK',
      'linkOpenError': 'Could not open the link',
      'chartSubtitle': 'Current rate: {rate} | Updated: {updated}',
      'chartUpdatedToday': 'today at {time}',
      'chartUpdatedDate': '{date} at {time}',
      'chartNoDataTitle': 'Not enough data to display the chart.',
      'chartNoDataSubtitle': 'Try a different period.',
    },
    'DE': {
      ..._englishOnlyValues,
      'appTitle': 'Währungsrechner+',
      'settingsTitle': 'Einstellungen',
      'language': 'Sprache',
      'currenciesTitle': 'Währungen',
      'favorites': 'Favoriten',
      'searchHint': 'Suche',
      'ok': 'OK',
      'linkOpenError': 'Link konnte nicht geöffnet werden',
      'chartSubtitle': 'Aktueller Kurs: {rate} | Aktualisiert: {updated}',
      'chartUpdatedToday': 'heute um {time}',
      'chartUpdatedDate': '{date} um {time}',
      'chartNoDataTitle': 'Nicht genügend Daten, um das Diagramm anzuzeigen.',
      'chartNoDataSubtitle': 'Versuche einen anderen Zeitraum.',
    },
    'FR': {
      ..._englishOnlyValues,
      'appTitle': 'Convertisseur de devises+',
      'settingsTitle': 'Paramètres',
      'language': 'Langue',
      'currenciesTitle': 'Devises',
      'favorites': 'Favoris',
      'searchHint': 'Recherche',
      'ok': 'OK',
      'linkOpenError': 'Impossible d' 'ouvrir le lien',
      'chartSubtitle': 'Taux actuel : {rate} | Mis à jour : {updated}',
      'chartUpdatedToday': 'aujourd' 'hui à {time}',
      'chartUpdatedDate': '{date} à {time}',
      'chartNoDataTitle': 'Pas assez de données pour afficher le graphique.',
      'chartNoDataSubtitle': 'Essayez une autre période.',
    },
    'IT': {
      ..._englishOnlyValues,
      'appTitle': 'Convertitore di valuta+',
      'settingsTitle': 'Impostazioni',
      'language': 'Lingua',
      'currenciesTitle': 'Valute',
      'favorites': 'Preferiti',
      'searchHint': 'Cerca',
      'ok': 'OK',
      'linkOpenError': 'Impossibile aprire il link',
      'chartSubtitle': 'Tasso attuale: {rate} | Aggiornato: {updated}',
      'chartUpdatedToday': 'oggi alle {time}',
      'chartUpdatedDate': '{date} alle {time}',
      'chartNoDataTitle': 'Dati insufficienti per visualizzare il grafico.',
      'chartNoDataSubtitle': 'Prova un altro periodo.',
    },
    'ES': {
      ..._englishOnlyValues,
      'appTitle': 'Convertidor de divisas+',
      'settingsTitle': 'Configuración',
      'language': 'Idioma',
      'currenciesTitle': 'Monedas',
      'favorites': 'Favoritos',
      'searchHint': 'Buscar',
      'ok': 'OK',
      'linkOpenError': 'No se pudo abrir el enlace',
      'chartSubtitle': 'Tasa actual: {rate} | Actualizado: {updated}',
      'chartUpdatedToday': 'hoy a las {time}',
      'chartUpdatedDate': '{date} a las {time}',
      'chartNoDataTitle': 'Datos insuficientes para mostrar el gráfico.',
      'chartNoDataSubtitle': 'Prueba con otro período.',
    },
    'RU': {
      ..._englishOnlyValues,
      'appTitle': 'Конвертер валют+',
      'settingsTitle': 'Настройки',
      'language': 'Язык',
      'currenciesTitle': 'Валюты',
      'favorites': 'Избранное',
      'searchHint': 'Поиск',
      'ok': 'ОК',
      'linkOpenError': 'Не удалось открыть ссылку',
      'chartSubtitle': 'Текущий курс: {rate} | Обновлено: {updated}',
      'chartUpdatedToday': 'сегодня в {time}',
      'chartUpdatedDate': '{date} в {time}',
      'chartNoDataTitle': 'Недостаточно данных для отображения графика.',
      'chartNoDataSubtitle': 'Попробуйте другой период.',
    },
    'UK': {
      ..._englishOnlyValues,
      'appTitle': 'Конвертер валют',
      'settingsTitle': 'Налаштування',
      'language': 'Мова',
      'currenciesTitle': 'Валюти',
      'favorites': 'Вибрані',
      'searchHint': 'Пошук',
      'ok': 'ОК',
      'linkOpenError': 'Не вдалося відкрити посилання',
      'chartSubtitle': 'Поточний курс: {rate} | Оновлено: {updated}',
      'chartUpdatedToday': 'сьогодні о {time}',
      'chartUpdatedDate': '{date} о {time}',
      'chartNoDataTitle': 'Недостатньо даних для відображення графіка.',
      'chartNoDataSubtitle': 'Спробуйте інший період.',
    },
  };

  static String of(String language, String key) {
    final targetLanguage = _englishOnlyKeys.contains(key) ? 'EN' : language;
    return _values[targetLanguage]?[key] ?? _values['EN']?[key] ?? key;
  }

  static List<String> privacyParagraphs(String language) => [
        of(language, 'privacyIntro'),
        of(language, 'privacyNoAds'),
        of(language, 'privacyFirebase'),
        of(language, 'privacyCurrencyApi'),
        of(language, 'privacyNoSell'),
      ];
}


