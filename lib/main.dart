import 'dart:math' as math;

import 'package:circle_flags/circle_flags.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'providers/currency_provider.dart';
import 'repositories/currency_repository.dart';
import 'services/currency_api.dart';
import 'utils/amount_formatter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final repository = CurrencyRepository(
    api: CurrencyApi(),
    prefs: prefs,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => CurrencyProvider(repository)..init(),
      child: const CurrencyApp(),
    ),
  );
}

const String kAppVersion = '1.0.1+2';

class Currency {
  const Currency({
    required this.code,
    required this.name,
    this.flag,
  });

  final String code;
  final String name;
  final String? flag;
}

const List<Currency> _currencies = [
  Currency(code: 'AUD', name: 'Australian Dollar'),
  Currency(code: 'BGN', name: 'Bulgarian Lev'),
  Currency(code: 'BRL', name: 'Brazilian Real'),
  Currency(code: 'CAD', name: 'Canadian Dollar'),
  Currency(code: 'CHF', name: 'Swiss Franc'),
  Currency(code: 'CNY', name: 'Chinese Renminbi Yuan'),
  Currency(code: 'CZK', name: 'Czech Koruna'),
  Currency(code: 'DKK', name: 'Danish Krone'),
  Currency(code: 'EUR', name: 'Euro'),
  Currency(code: 'GBP', name: 'British Pound'),
  Currency(code: 'HKD', name: 'Hong Kong Dollar'),
  Currency(code: 'HUF', name: 'Hungarian Forint'),
  Currency(code: 'IDR', name: 'Indonesian Rupiah'),
  Currency(code: 'ILS', name: 'Israeli New Sheqel'),
  Currency(code: 'INR', name: 'Indian Rupee'),
  Currency(code: 'ISK', name: 'Icelandic Króna'),
  Currency(code: 'JPY', name: 'Japanese Yen'),
  Currency(code: 'KRW', name: 'South Korean Won'),
  Currency(code: 'MXN', name: 'Mexican Peso'),
  Currency(code: 'MYR', name: 'Malaysia Ringgit'),
  Currency(code: 'NOK', name: 'Norwegian Krone'),
  Currency(code: 'NZD', name: 'New Zealand Dollar'),
  Currency(code: 'PHP', name: 'Philippine Peso'),
  Currency(code: 'PLN', name: 'Polish Złoty'),
  Currency(code: 'RON', name: 'Romanian Leu'),
  Currency(code: 'SEK', name: 'Swedish Krona'),
  Currency(code: 'SGD', name: 'Singapore Dollar'),
  Currency(code: 'THB', name: 'Thai Baht'),
  Currency(code: 'TRY', name: 'Turkish Lira'),
  Currency(code: 'USD', name: 'United States Dollar'),
  Currency(code: 'ZAR', name: 'South African Rand'),
];

const Map<String, String> currencyToFlag = {
  'AUD': 'au',
  'BGN': 'bg',
  'BRL': 'br',
  'CAD': 'ca',
  'CHF': 'ch',
  'CNY': 'cn',
  'CZK': 'cz',
  'DKK': 'dk',
  'EUR': 'eu',
  'GBP': 'gb',
  'HKD': 'hk',
  'HUF': 'hu',
  'IDR': 'id',
  'ILS': 'il',
  'INR': 'in',
  'ISK': 'is',
  'JPY': 'jp',
  'KRW': 'kr',
  'MXN': 'mx',
  'MYR': 'my',
  'NOK': 'no',
  'NZD': 'nz',
  'PHP': 'ph',
  'PLN': 'pl',
  'RON': 'ro',
  'SEK': 'se',
  'SGD': 'sg',
  'THB': 'th',
  'TRY': 'tr',
  'USD': 'us',
  'ZAR': 'za',
};

Widget buildCurrencyFlag(String currencyCode) {
  if (currencyCode == 'EUR') {
    return buildEurFlag();
  }

  final flagCode = currencyToFlag[currencyCode];

  if (flagCode == null) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
    );
  }

  return CircleFlag(
    flagCode,
    size: 40,
  );
}

class EUPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF003399);
    canvas.drawRect(Offset.zero & size, paint);

    final starPaint = Paint()..color = const Color(0xFFFFCC00);
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = size.width * 0.38;
    final starRadius = size.width * 0.06;

    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final dx = center.dx + ringRadius * math.cos(angle);
      final dy = center.dy + ringRadius * math.sin(angle);

      canvas.drawCircle(Offset(dx, dy), starRadius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget buildEurFlag() {
  return ClipOval(
    child: SizedBox(
      width: 40,
      height: 40,
      child: CustomPaint(
        painter: EUPainter(),
      ),
    ),
  );
}

class AppStrings {
  static const Map<String, Map<String, String>> _values = {
    'EN': {
      'appTitle': 'Currency Converter',
      'settingsTitle': 'Settings',
      'language': 'Language',
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
    },
    'UK': {
      'appTitle': 'Конвертер валют',
      'settingsTitle': 'Налаштування',
      'language': 'Мова',
      'about': 'Про додаток',
      'privacyPolicy': 'Політика конфіденційності',
      'aboutCompany': 'UzorGame Inc',
      'versionLabel': 'Версія $kAppVersion',
      'privacyIntro':
          'Додаток не збирає персональні дані. Ми не запитуємо ваше ім’я, email, номер телефону, контакти чи точне місцезнаходження.',
      'privacyNoAds':
          'Ми не показуємо рекламу, не створюємо облікові записи і не завантажуємо ваші дані на наші сервери. Усі налаштування зберігаються локально на вашому пристрої.',
      'privacyFirebase':
          'Додаток використовує Firebase Analytics, щоб розуміти базове використання (наприклад, збої, перегляди екранів). Це включає технічні дані, такі як тип пристрою, версія додатка та країна (приблизно). Firebase не надає нам вашу особу чи IP-адресу.',
      'privacyCurrencyApi':
          'Додаток запитує курси валют у зовнішнього Currency API. Ці запити не містять персональної інформації чи ідентифікаторів.',
      'privacyNoSell': 'Ми не продаємо та не передаємо дані користувачів.',
      'privacyFullDetails': 'Повну версію ви можете прочитати тут:',
      'privacyPolicyUrl': 'https://uzorgame.github.io/privacy-policy-converter',
    },
  };

  static String of(String language, String key) {
    return _values[language]?[key] ?? _values['EN']?[key] ?? key;
  }

  static List<String> privacyParagraphs(String language) => [
        of(language, 'privacyIntro'),
        of(language, 'privacyNoAds'),
        of(language, 'privacyFirebase'),
        of(language, 'privacyCurrencyApi'),
        of(language, 'privacyNoSell'),
      ];
}

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key});

  static final ValueNotifier<String> _languageNotifier =
      ValueNotifier(AppStrings._values.keys.first);

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

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({
    super.key,
    required this.languageNotifier,
  });

  final ValueNotifier<String> languageNotifier;

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  static const _defaultFromCurrency = 'CAD';
  static const _defaultToCurrency = 'USD';

  ActiveField _activeField = ActiveField.top;
  String _fromCurrency = _defaultFromCurrency;
  String _toCurrency = _defaultToCurrency;
  String _topDisplay = '0';
  String _bottomDisplay = '0';
  double _firstOperand = 0;
  String? _selectedOperation;
  bool _awaitingSecondOperand = false;
  bool _syncedWithProvider = false;

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final currencies = _availableCurrencies(currencyProvider);
    _maybeSyncWithProvider(currencyProvider, currencies);

    final fromCurrency = _findCurrency(_fromCurrency, currencies);
    final toCurrency = _findCurrency(_toCurrency, currencies);
    final rateText = _formatRateText();
    final dateTimeText = _formatLastUpdated(currencyProvider.lastUpdated);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                const _StatusTime(),
                const SizedBox(height: 12),
                _CurrencyRow(
                  currency: fromCurrency,
                  valueText: _topDisplay,
                  onTap: () => _openCurrencyPicker(ActiveField.top),
                ),
                const SizedBox(height: 10),
                const _DividerLine(),
                const SizedBox(height: 10),
                _CurrencyRow(
                  currency: toCurrency,
                  valueText: _bottomDisplay,
                  onTap: () => _openCurrencyPicker(ActiveField.bottom),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _Keypad(
                    onKeyPressed: _handleKeyPress,
                  ),
                ),
                SafeArea(
                  bottom: true,
                  child: _RatePanel(
                    dateTimeText: dateTimeText,
                    rateText: rateText,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 10,
              right: 8,
              child: SizedBox(
                height: 44,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SettingsPage(
                          languageNotifier: widget.languageNotifier,
                        ),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(
                      Icons.settings,
                      color: _AppColors.textMain,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Currency> _availableCurrencies(CurrencyProvider provider) {
    if (provider.currencyNames.isNotEmpty) {
      final entries = provider.currencyNames.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      return entries
          .map((entry) => Currency(code: entry.key, name: entry.value))
          .toList();
    }

    return _currencies;
  }

  void _maybeSyncWithProvider(
    CurrencyProvider provider,
    List<Currency> availableCurrencies,
  ) {
    if (_syncedWithProvider || provider.status != CurrencyStatus.loaded) return;

    final availableCodesList =
        availableCurrencies.map((c) => c.code).toList(growable: false);
    final availableCodes = availableCodesList.toSet();
    final defaultFrom = provider.fromCurrency.isNotEmpty
        ? provider.fromCurrency
        : _defaultFromCurrency;
    final defaultTo = provider.toCurrency.isNotEmpty
        ? provider.toCurrency
        : _defaultToCurrency;

    final fallbackFrom = availableCodes.contains(defaultFrom)
        ? defaultFrom
        : (availableCodesList.isNotEmpty ? availableCodesList.first : _fromCurrency);
    final syncedFrom = availableCodes.contains(_fromCurrency)
        ? _fromCurrency
        : fallbackFrom;

    final fallbackTo = availableCodes.contains(defaultTo)
        ? defaultTo
        : (availableCodesList.length > 1
            ? availableCodesList[1]
            : (availableCodesList.isNotEmpty ? availableCodesList.first : _toCurrency));

    final syncedTo = availableCodes.contains(_toCurrency)
        ? _toCurrency
        : fallbackTo;

    final amountInput = provider.amountInput.isNotEmpty
        ? provider.amountInput
        : _topDisplay;

    setState(() {
      _fromCurrency = syncedFrom;
      _toCurrency = syncedTo;
      _topDisplay = _sanitizeNumberString(amountInput);
      _syncedWithProvider = true;
    });

    if (provider.fromCurrency != _fromCurrency) {
      provider.setFromCurrency(_fromCurrency);
    }
    if (provider.toCurrency != _toCurrency) {
      provider.setToCurrency(_toCurrency);
    }

    if (provider.amountInput != _topDisplay) {
      provider.setAmountInput(_topDisplay);
    }

    _recalculateLinkedValue();
  }

  double? _computeRate(String from, String to) {
    final provider = context.read<CurrencyProvider>();
    if (provider.status != CurrencyStatus.loaded || provider.rates.isEmpty) {
      return null;
    }

    final fromRate = provider.rates[from];
    final toRate = provider.rates[to];

    if (fromRate == null || toRate == null || fromRate == 0) return null;

    return toRate / fromRate;
  }

  String _formatRateText() {
    final rate = _computeRate(_fromCurrency, _toCurrency);
    if (rate == null) {
      return '1 $_fromCurrency = -- $_toCurrency';
    }

    return '1 $_fromCurrency = ${formatAmount(rate)} $_toCurrency';
  }

  void _handleKeyPress(String label) {
    if (RegExp(r'^[0-9]$').hasMatch(label)) {
      _handleDigit(label);
      return;
    }

    switch (label) {
      case '.':
        _handleDecimalPoint();
        break;
      case 'C':
        _handleClear();
        break;
      case '←':
        _handleBackspace();
        break;
      case '↑↓':
        _handleSwap();
        break;
      case '+':
      case '−':
      case '×':
      case '÷':
        _handleOperation(label);
        break;
      case '=':
        _handleEquals();
        break;
      case '%':
        _handlePercent();
        break;
    }
  }

  void _handleDigit(String digit) {
    setState(() {
      _activeField = ActiveField.top;
      if (_awaitingSecondOperand) {
        _setActiveDisplay('0');
        _awaitingSecondOperand = false;
      }

      var current = _getActiveDisplay();
      if (current == '0') {
        current = digit;
      } else {
        current += digit;
      }
      current = _sanitizeNumberString(current);
      _setActiveDisplay(current);
      _recalculateLinkedValue();
    });

    _persistTopAmount();
  }

  void _handleDecimalPoint() {
    setState(() {
      _activeField = ActiveField.top;
      if (_awaitingSecondOperand) {
        _setActiveDisplay('0');
        _awaitingSecondOperand = false;
      }

      var current = _getActiveDisplay();
      if (current.contains('.')) return;

      if (current.isEmpty) {
        current = '0.';
      } else {
        current += '.';
      }

      _setActiveDisplay(current);
      _recalculateLinkedValue();
    });

    _persistTopAmount();
  }

  void _handleClear() {
    setState(() {
      _activeField = ActiveField.top;
      _topDisplay = '0';
      _bottomDisplay = '0';
      _selectedOperation = null;
      _firstOperand = 0;
      _awaitingSecondOperand = false;
    });

    _persistTopAmount();
  }

  void _handleBackspace() {
    setState(() {
      _activeField = ActiveField.top;
      var current = _getActiveDisplay();
      if (current.length <= 1) {
        current = '0';
      } else {
        current = current.substring(0, current.length - 1);
      }
      current = _sanitizeNumberString(current);
      _setActiveDisplay(current);
      _recalculateLinkedValue();
    });

    _persistTopAmount();
  }

  void _handleSwap() {
    setState(() {
      final tempCurrency = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = tempCurrency;

      final tempValue = _topDisplay;
      _topDisplay = _sanitizeNumberString(_bottomDisplay);
      _bottomDisplay = formatAmount(_parseDisplayValue(tempValue));

      _activeField = ActiveField.top;
      context.read<CurrencyProvider>().setFromCurrency(_fromCurrency);
      context.read<CurrencyProvider>().setToCurrency(_toCurrency);
      _recalculateLinkedValue();
    });

    _persistTopAmount();
  }

  void _handleOperation(String op) {
    setState(() {
      _firstOperand = _getActiveValue();
      _selectedOperation = op;
      _awaitingSecondOperand = true;
      _activeField = ActiveField.top;
      _setActiveDisplay('0');
    });

    _persistTopAmount();
  }

  void _handleEquals() {
    setState(() {
      if (_selectedOperation == null) return;

      final secondOperand = _getActiveValue();
      final result = _calculateResult(_firstOperand, secondOperand, _selectedOperation!);
      _selectedOperation = null;
      _awaitingSecondOperand = false;
      _activeField = ActiveField.top;
      _setActiveDisplay(_formatNumber(result));
      _recalculateLinkedValue();
    });

    _persistTopAmount();
  }

  void _handlePercent() {
    setState(() {
      double value;
      if (_selectedOperation == null) {
        value = _getActiveValue() / 100;
      } else {
        value = _firstOperand * _getActiveValue() / 100;
      }
      _activeField = ActiveField.top;
      _setActiveDisplay(_formatNumber(value));
      _recalculateLinkedValue();
    });

    _persistTopAmount();
  }

  Future<void> _openCurrencyPicker(ActiveField field) async {
    final currencies = _availableCurrencies(context.read<CurrencyProvider>());
    final selected = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => CurrencyPickerPage(
          currencies: currencies,
          initialCode:
              field == ActiveField.top ? _fromCurrency : _toCurrency,
        ),
        transitionsBuilder: (_, animation, __, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuad;

          final tween = Tween(begin: begin, end: end)
              .chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );

    if (selected == null) return;

    setState(() {
      if (field == ActiveField.top) {
        _fromCurrency = selected;
        context.read<CurrencyProvider>().setFromCurrency(selected);
      } else {
        _toCurrency = selected;
        context.read<CurrencyProvider>().setToCurrency(selected);
      }
      _activeField = ActiveField.top;
      _recalculateLinkedValue();
    });
  }

  void _recalculateLinkedValue() {
    final rate = _computeRate(_fromCurrency, _toCurrency);
    final topValue = _parseDisplayValue(_topDisplay);
    if (rate == null) {
      _bottomDisplay = '0';
    } else {
      _bottomDisplay = formatAmount(topValue * rate);
    }
  }

  void _persistTopAmount() {
    context.read<CurrencyProvider>().setAmountInput(_topDisplay);
  }

  Currency? _findCurrency(String code, List<Currency> availableCurrencies) {
    for (final currency in availableCurrencies) {
      if (currency.code == code) {
        return currency;
      }
    }
    return null;
  }

  double _getActiveValue() => _parseDisplayValue(_getActiveDisplay());

  String _getActiveDisplay() =>
      _activeField == ActiveField.top ? _topDisplay : _bottomDisplay;

  void _setActiveDisplay(String value) {
    if (_activeField == ActiveField.top) {
      _topDisplay = value;
    } else {
      _bottomDisplay = value;
    }
  }

  double _parseDisplayValue(String value) {
    value = value.replaceAll(',', '');

    if (value.endsWith('.')) {
      value = value.substring(0, value.length - 1);
    }
    return double.tryParse(value) ?? 0;
  }

  String _sanitizeNumberString(String value) {
    value = value.replaceAll(',', '');

    if (value.contains('.')) {
      final parts = value.split('.');
      var intPart = parts.first;
      while (intPart.length > 1 && intPart.startsWith('0')) {
        intPart = intPart.substring(1);
      }
      final fractional = parts.sublist(1).join('.');
      return '$intPart.$fractional';
    }

    var cleaned = value;
    while (cleaned.length > 1 && cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1);
    }
    return cleaned.isEmpty ? '0' : cleaned;
  }

  String _formatNumber(double value) {
    return formatAmount(value).replaceAll(',', '');
  }

  double _calculateResult(double a, double b, String operation) {
    switch (operation) {
      case '+':
        return a + b;
      case '−':
        return a - b;
      case '×':
        return a * b;
      case '÷':
        return b == 0 ? 0 : a / b;
    }
    return b;
  }

  String _formatLastUpdated(DateTime dateTime) {
    if (dateTime.millisecondsSinceEpoch == 0) return '--';

    return _formatDateTime(dateTime);
  }
}

class CurrencyPickerPage extends StatefulWidget {
  const CurrencyPickerPage({
    required this.initialCode,
    required this.currencies,
    super.key,
  });

  final String initialCode;
  final List<Currency> currencies;

  @override
  State<CurrencyPickerPage> createState() => _CurrencyPickerPageState();
}

class _CurrencyPickerPageState extends State<CurrencyPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<Currency> _filteredCurrencies;

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = List.of(widget.currencies);
    _searchController.addListener(_handleSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearch);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = context.watch<CurrencyProvider>();
    final favoriteCodes = currencyProvider.favoriteCurrencies.toSet();

    final favoriteCurrencies = _filteredCurrencies
        .where((currency) => favoriteCodes.contains(currency.code))
        .toList();
    final otherCurrencies = _filteredCurrencies
        .where((currency) => !favoriteCodes.contains(currency.code))
        .toList();

    final tiles = <Widget>[
      if (favoriteCurrencies.isNotEmpty) ...[
        const _FavoritesHeader(),
        const SizedBox(height: 10),
        ..._buildTiles(favoriteCurrencies, currencyProvider),
        if (otherCurrencies.isNotEmpty) const SizedBox(height: 16),
      ],
      ..._buildTiles(otherCurrencies, currencyProvider),
    ];

    return Scaffold(
      backgroundColor: _AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _PickerHeader(onBack: Navigator.of(context).pop),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: _SearchField(controller: _searchController),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(11, 0, 11, 16),
                itemBuilder: (context, index) => tiles[index],
                itemCount: tiles.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = List.of(widget.currencies);
      } else {
        _filteredCurrencies = widget.currencies.where((currency) {
          final name = currency.name.toLowerCase();
          final code = currency.code.toLowerCase();
          return name.contains(query) || code.contains(query);
        }).toList();
      }
    });
  }

  List<Widget> _buildTiles(
    List<Currency> currencies,
    CurrencyProvider provider,
  ) {
    return List.generate(currencies.length, (index) {
      final currency = currencies[index];
      final isFavorite = provider.isFavorite(currency.code);
      return Padding(
        padding: EdgeInsets.only(bottom: index == currencies.length - 1 ? 0 : 10),
        child: _CurrencyTile(
          currency: currency,
          isFavorite: isFavorite,
          onTap: () => Navigator.of(context).pop(currency.code),
          onFavoriteToggle: () => provider.toggleFavorite(currency.code),
        ),
      );
    });
  }
}

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _AppColors.textMain,
                    size: 22,
                  ),
                ),
              ),
            ),
            const Text(
              'Валюти',
              style: TextStyle(
                color: _AppColors.textMain,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 47,
      decoration: BoxDecoration(
        color: const Color(0xFF3E3E3E),
        borderRadius: BorderRadius.circular(13),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: _AppColors.textMain,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: _AppColors.textMain,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
          hintText: 'Пошук',
          hintStyle: TextStyle(
            color: Color(0xFF9A9A9A),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _CurrencyTile extends StatefulWidget {
  const _CurrencyTile({
    required this.currency,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isFavorite,
  });

  final Currency currency;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  @override
  State<_CurrencyTile> createState() => _CurrencyTileState();
}

class _CurrencyTileState extends State<_CurrencyTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 80),
      opacity: _pressed ? 0.9 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              buildCurrencyFlag(widget.currency.code),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.currency.name,
                  style: const TextStyle(
                    color: _AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                widget.currency.code,
                style: const TextStyle(
                  color: Color(0xFF8F8F8F),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onFavoriteToggle,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Icon(
                    widget.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: widget.isFavorite
                        ? const Color(0xFFF6C94C)
                        : const Color(0xFF8F8F8F),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 8),
        child: Text(
          'Вибрані',
          style: TextStyle(
            color: _AppColors.textMain,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StatusTime extends StatelessWidget {
  const _StatusTime();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 44);
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({
    required this.currency,
    required this.valueText,
    required this.onTap,
  });

  final Currency? currency;
  final String valueText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildCurrencyFlag(currency?.code ?? ''),
                  const SizedBox(height: 6),
                  Text(
                    currency?.code ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _AppColors.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              valueText,
              style: const TextStyle(
                color: _AppColors.textMain,
                fontSize: 48,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
      color: _AppColors.dividerLine,
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKeyPressed});

  final void Function(String) onKeyPressed;

  static const List<_KeyDefinition> _keys = [
    _KeyDefinition('C', _AppColors.keyRow1Bg),
    _KeyDefinition('←', _AppColors.keyRow1Bg),
    _KeyDefinition('↑↓', _AppColors.keyRow1Bg),
    _KeyDefinition('÷', _AppColors.keyOpBg),
    _KeyDefinition('7', _AppColors.keyNumBg),
    _KeyDefinition('8', _AppColors.keyNumBg),
    _KeyDefinition('9', _AppColors.keyNumBg),
    _KeyDefinition('×', _AppColors.keyOpBg),
    _KeyDefinition('4', _AppColors.keyNumBg),
    _KeyDefinition('5', _AppColors.keyNumBg),
    _KeyDefinition('6', _AppColors.keyNumBg),
    _KeyDefinition('−', _AppColors.keyOpBg),
    _KeyDefinition('1', _AppColors.keyNumBg),
    _KeyDefinition('2', _AppColors.keyNumBg),
    _KeyDefinition('3', _AppColors.keyNumBg),
    _KeyDefinition('+', _AppColors.keyOpBg),
    _KeyDefinition('0', _AppColors.keyNumBg),
    _KeyDefinition('.', _AppColors.keyNumBg),
    _KeyDefinition('%', _AppColors.keyNumBg),
    _KeyDefinition('=', _AppColors.keyOpBg),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemCount: _keys.length,
        itemBuilder: (context, index) {
          final key = _keys[index];
          return _KeyButton(
            label: key.label,
            backgroundColor: key.color,
            onPressed: () => onKeyPressed(key.label),
          );
        },
      ),
    );
  }
}

class _KeyButton extends StatefulWidget {
  const _KeyButton({
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  double _scale = 1.0;

  void _handleTapDown(TapDownDetails details) {
    setState(() => _scale = 0.92);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: Container(
          color: widget.backgroundColor,
          child: Center(
            child: Text(
              widget.label,
              style: const TextStyle(
                color: _AppColors.textMain,
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RatePanel extends StatelessWidget {
  const _RatePanel({
    required this.dateTimeText,
    required this.rateText,
  });

  final String dateTimeText;
  final String rateText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _AppColors.bgMain,
      padding: const EdgeInsets.fromLTRB(22, 15, 22, 24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dateTimeText,
              style: const TextStyle(
                color: _AppColors.textDate,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                rateText,
                key: ValueKey(rateText),
                style: const TextStyle(
                  color: _AppColors.textRate,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyDefinition {
  const _KeyDefinition(this.label, this.color);

  final String label;
  final Color color;
}

class _AppColors {
  static const bgMain = Color(0xFF323232);
  static const keyRow1Bg = Color(0xFF505050);
  static const keyNumBg = Color(0xFF646464);
  static const keyOpBg = Color(0xFFD68D41);
  static const textMain = Color(0xFFF9F9F9);
  static const textDate = Color(0xFF4CA58C);
  static const textRate = Color(0xFF777777);
  static const dividerLine = Color(0xFF4E443A);
}

String _formatDateTime(DateTime dateTime) {
  final year = dateTime.year.toString().padLeft(4, '0');
  final month = _twoDigits(dateTime.month);
  final day = _twoDigits(dateTime.day);
  return '$year-$month-$day';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

enum ActiveField { top, bottom }

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.languageNotifier,
  });

  final ValueNotifier<String> languageNotifier;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Map<String, String> _languages = {
    'EN': 'English',
    'UK': 'Українська',
  };

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.languageNotifier,
      builder: (context, language, _) {
        return Scaffold(
          backgroundColor: _AppColors.bgMain,
          body: SafeArea(
            child: Column(
              children: [
                _SettingsHeader(
                  title: AppStrings.of(language, 'settingsTitle'),
                  onBack: Navigator.of(context).pop,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(11, 0, 11, 16),
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return _SettingsTile(
                            title: AppStrings.of(language, 'language'),
                            trailingText:
                                _languages[language] ?? language,
                            onTap: () =>
                                _showLanguageSelector(language),
                          );
                        case 1:
                          return _SettingsTile(
                            title: AppStrings.of(language, 'about'),
                            onTap: () =>
                                _showAboutDialog(language),
                          );
                        case 2:
                          return _SettingsTile(
                            title: AppStrings.of(language, 'privacyPolicy'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PrivacyPolicyPage(
                                    language: language,
                                  ),
                                ),
                              );
                            },
                          );
                      }
                      return const SizedBox.shrink();
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: 3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSelector(String currentLanguage) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _AppColors.bgMain,
      builder: (_) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemBuilder: (context, index) {
              final entry = _languages.entries.elementAt(index);
              final isSelected = entry.key == currentLanguage;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(entry.key),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? _AppColors.keyRow1Bg : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        entry.value,
                        style: const TextStyle(
                          color: _AppColors.textMain,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check,
                          color: _AppColors.textMain,
                        ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: _languages.length,
          ),
        );
      },
    );

    if (selected == null) return;

    widget.languageNotifier.value = selected;
  }

  Future<void> _showAboutDialog(String language) async {
    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: _AppColors.bgMain,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Center(
            child: Text(
              AppStrings.of(language, 'about'),
              style: const TextStyle(
                color: _AppColors.textMain,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.of(language, 'aboutCompany'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.of(language, 'versionLabel'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _AppColors.textRate,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text(
                'OK',
                style: TextStyle(
                  color: _AppColors.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _AppColors.textMain,
                    size: 22,
                  ),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: _AppColors.textMain,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatefulWidget {
  const _SettingsTile({
    required this.title,
    this.trailingText,
    required this.onTap,
  });

  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 80),
      opacity: _pressed ? 0.9 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: _AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    widget.trailingText!,
                    style: const TextStyle(
                      color: Color(0xFF8F8F8F),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF8F8F8F),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({
    super.key,
    required this.language,
  });

  final String language;

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final privacyPolicyUri = Uri.parse(AppStrings.of(language, 'privacyPolicyUrl'));

    if (!await launchUrl(privacyPolicyUri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _SimpleHeader(
              title: AppStrings.of(language, 'privacyPolicy'),
              onBack: Navigator.of(context).pop,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...AppStrings.privacyParagraphs(language).map(
                      (paragraph) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          paragraph,
                          style: const TextStyle(
                            color: _AppColors.textMain,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: AppStrings.of(language, 'privacyFullDetails'),
                        children: [
                          const TextSpan(text: '\n'),
                          TextSpan(
                            text: AppStrings.of(language, 'privacyPolicyUrl'),
                            style: const TextStyle(
                              color: _AppColors.textDate,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _openPrivacyPolicy(context),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        color: _AppColors.textMain,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBack,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: _AppColors.textMain,
                    size: 22,
                  ),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: _AppColors.textMain,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
