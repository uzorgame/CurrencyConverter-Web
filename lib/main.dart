import 'package:flutter/material.dart';

void main() {
  runApp(const CurrencyApp());
}

double getFakeRate(String from, String to) => 0.71;

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

class CurrencyApp extends StatelessWidget {
  const CurrencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Currency Converter',
      theme: ThemeData(
        scaffoldBackgroundColor: _AppColors.bgMain,
        fontFamily: 'SF Pro Display',
        colorScheme: const ColorScheme.dark(background: _AppColors.bgMain),
      ),
      home: const CurrencyConverterScreen(),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

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
  String _dateTimeText = _formatDateTime(DateTime.now());

  @override
  Widget build(BuildContext context) {
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
                  currency: _findCurrency(_fromCurrency),
                  valueText: _topDisplay,
                  onTap: () => _openCurrencyPicker(ActiveField.top),
                ),
                const SizedBox(height: 10),
                const _DividerLine(),
                const SizedBox(height: 10),
                _CurrencyRow(
                  currency: _findCurrency(_toCurrency),
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
                    dateTimeText: _dateTimeText,
                    rateText:
                        '1 $_fromCurrency = ${getFakeRate(_fromCurrency, _toCurrency).toStringAsFixed(2)} $_toCurrency',
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
                        builder: (_) => const SettingsPage(),
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
  }

  void _handleClear() {
    setState(() {
      _activeField = ActiveField.top;
      _topDisplay = '0';
      _bottomDisplay = '0';
      _selectedOperation = null;
      _firstOperand = 0;
      _awaitingSecondOperand = false;
      _updateTimestamp();
    });
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
  }

  void _handleSwap() {
    setState(() {
      final tempCurrency = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = tempCurrency;

      final tempValue = _topDisplay;
      _topDisplay = _bottomDisplay;
      _bottomDisplay = tempValue;

      _activeField = ActiveField.top;
      _recalculateLinkedValue();
    });
  }

  void _handleOperation(String op) {
    setState(() {
      _firstOperand = _getActiveValue();
      _selectedOperation = op;
      _awaitingSecondOperand = true;
      _activeField = ActiveField.top;
      _setActiveDisplay('0');
    });
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
  }

  Future<void> _openCurrencyPicker(ActiveField field) async {
    final selected = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => CurrencyPickerPage(
          initialCode:
              field == ActiveField.top ? _fromCurrency : _toCurrency,
        ),
      ),
    );

    if (selected == null) return;

    setState(() {
      if (field == ActiveField.top) {
        _fromCurrency = selected;
      } else {
        _toCurrency = selected;
      }
      _activeField = ActiveField.top;
      _recalculateLinkedValue();
    });
  }

  void _recalculateLinkedValue() {
    final rate = getFakeRate(_fromCurrency, _toCurrency);
    final topValue = _parseDisplayValue(_topDisplay);
    _bottomDisplay = _formatNumber(topValue * rate);
    _updateTimestamp();
  }

  Currency? _findCurrency(String code) {
    for (final currency in _currencies) {
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
    if (value.endsWith('.')) {
      value = value.substring(0, value.length - 1);
    }
    return double.tryParse(value) ?? 0;
  }

  String _sanitizeNumberString(String value) {
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
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    var text = value.toStringAsFixed(6);
    text = text.replaceFirst(RegExp(r'0+$'), '');
    if (text.endsWith('.')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
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

  void _updateTimestamp() {
    _dateTimeText = _formatDateTime(DateTime.now());
  }
}

class CurrencyPickerPage extends StatefulWidget {
  const CurrencyPickerPage({required this.initialCode, super.key});

  final String initialCode;

  @override
  State<CurrencyPickerPage> createState() => _CurrencyPickerPageState();
}

class _CurrencyPickerPageState extends State<CurrencyPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  late List<Currency> _filteredCurrencies;

  @override
  void initState() {
    super.initState();
    _filteredCurrencies = List.of(_currencies);
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
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(11, 0, 11, 16),
                itemBuilder: (context, index) {
                  final currency = _filteredCurrencies[index];
                  return _CurrencyTile(
                    currency: currency,
                    onTap: () => Navigator.of(context).pop(currency.code),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: _filteredCurrencies.length,
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
        _filteredCurrencies = List.of(_currencies);
      } else {
        _filteredCurrencies = _currencies.where((currency) {
          final name = currency.name.toLowerCase();
          final code = currency.code.toLowerCase();
          return name.contains(query) || code.contains(query);
        }).toList();
      }
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
  });

  final Currency currency;
  final VoidCallback onTap;

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
              _FlagIcon(flag: widget.currency.flag, size: 40),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _FlagIcon extends StatelessWidget {
  const _FlagIcon({required this.flag, required this.size});

  final String? flag;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF4A4A4A),
      ),
      clipBehavior: Clip.antiAlias,
      child: flag == null || flag!.isEmpty
          ? null
          : Image.network(
              flag!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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
            _FlagIcon(
              flag: currency?.flag,
              size: 44,
            ),
            const SizedBox(width: 10),
            Text(
              currency?.code ?? '',
              style: const TextStyle(
                color: _AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w600,
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

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        color: backgroundColor,
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: _AppColors.textMain,
              fontSize: 32,
              fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
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
            Text(
              rateText,
              style: const TextStyle(
                color: _AppColors.textRate,
                fontSize: 16,
                fontWeight: FontWeight.w500,
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
  final hours = _twoDigits(dateTime.hour);
  final minutes = _twoDigits(dateTime.minute);
  return '$year-$month-$day, $hours:$minutes';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

enum ActiveField { top, bottom }

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Map<String, String> _languages = {
    'EN': 'English',
    'UK': 'Українська',
  };

  String _selectedLanguage = _languages.keys.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _SettingsHeader(onBack: Navigator.of(context).pop),
            const SizedBox(height: 18),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(11, 0, 11, 16),
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return _SettingsTile(
                        title: 'Мова',
                        trailingText: _languages[_selectedLanguage] ?? _selectedLanguage,
                        onTap: _showLanguageSelector,
                      );
                    case 1:
                      return _SettingsTile(
                        title: 'Про додаток',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AboutPage(),
                            ),
                          );
                        },
                      );
                    case 2:
                      return _SettingsTile(
                        title: 'Політика конфіденційності',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyPage(),
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
  }

  void _showLanguageSelector() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _AppColors.bgMain,
      builder: (_) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemBuilder: (context, index) {
              final entry = _languages.entries.elementAt(index);
              final isSelected = entry.key == _selectedLanguage;
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

    setState(() {
      _selectedLanguage = selected;
    });
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.onBack});

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
              'Налаштування',
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

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _SimpleHeader(
              title: 'About',
              onBack: Navigator.of(context).pop,
            ),
            const SizedBox(height: 40),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'UzorGame Inc',
                      style: TextStyle(
                        color: _AppColors.textMain,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: _AppColors.textRate,
                        fontSize: 16,
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

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _SimpleHeader(
              title: 'Privacy Policy',
              onBack: Navigator.of(context).pop,
            ),
            const SizedBox(height: 40),
            const Expanded(
              child: Center(
                child: Text(
                  'Privacy policy content will be added soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
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
