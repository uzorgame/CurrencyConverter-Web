import 'package:flutter/material.dart';

void main() {
  runApp(const CurrencyApp());
}

double getFakeRate(String from, String to) => 0.71;

class CurrencyData {
  const CurrencyData({
    required this.code,
    required this.name,
    required this.flagCode,
  });

  final String code;
  final String name;
  final String flagCode;
}

const List<CurrencyData> _currencies = [
  CurrencyData(code: 'CAD', name: 'Канадський долар', flagCode: 'ca'),
  CurrencyData(code: 'USD', name: 'Долар США', flagCode: 'us'),
  CurrencyData(code: 'CLP', name: 'Чилійський песо', flagCode: 'cl'),
  CurrencyData(code: 'CVE', name: 'Ескудо Кабо-Верде', flagCode: 'cv'),
  CurrencyData(code: 'EUR', name: 'Євро', flagCode: 'eu'),
  CurrencyData(code: 'MXN', name: 'Мексиканський песо', flagCode: 'mx'),
  CurrencyData(code: 'GBP', name: 'Англійський фунт', flagCode: 'gb'),
  CurrencyData(code: 'THB', name: 'Таїландський бат', flagCode: 'th'),
  CurrencyData(code: 'JPY', name: 'Японська єна', flagCode: 'jp'),
  CurrencyData(code: 'INR', name: 'Індійська рупія', flagCode: 'in'),
  CurrencyData(code: 'VND', name: "В'єтнамський донг", flagCode: 'vn'),
  CurrencyData(code: 'AUD', name: 'Австралійський долар', flagCode: 'au'),
  CurrencyData(code: 'BGN', name: 'Болгарський лев', flagCode: 'bg'),
  CurrencyData(code: 'BRL', name: 'Бразильський реал', flagCode: 'br'),
  CurrencyData(code: 'CHF', name: 'Швейцарський франк', flagCode: 'ch'),
  CurrencyData(code: 'CNY', name: 'Китайський юань', flagCode: 'cn'),
  CurrencyData(code: 'CZK', name: 'Чеська крона', flagCode: 'cz'),
  CurrencyData(code: 'DKK', name: 'Данська крона', flagCode: 'dk'),
  CurrencyData(code: 'HKD', name: 'Гонконгський долар', flagCode: 'hk'),
  CurrencyData(code: 'HUF', name: 'Угорський форинт', flagCode: 'hu'),
  CurrencyData(code: 'IDR', name: 'Індонезійська рупія', flagCode: 'id'),
  CurrencyData(code: 'ILS', name: 'Ізраїльський шекель', flagCode: 'il'),
  CurrencyData(code: 'ISK', name: 'Ісландська крона', flagCode: 'is'),
  CurrencyData(code: 'KRW', name: 'Південнокорейська вона', flagCode: 'kr'),
  CurrencyData(code: 'MYR', name: 'Малайзійський рингіт', flagCode: 'my'),
  CurrencyData(code: 'NOK', name: 'Норвезька крона', flagCode: 'no'),
  CurrencyData(code: 'NZD', name: 'Новозеландський долар', flagCode: 'nz'),
  CurrencyData(code: 'PHP', name: 'Філіппінський песо', flagCode: 'ph'),
  CurrencyData(code: 'PLN', name: 'Польський злотий', flagCode: 'pl'),
  CurrencyData(code: 'RON', name: 'Румунський лей', flagCode: 'ro'),
  CurrencyData(code: 'SEK', name: 'Шведська крона', flagCode: 'se'),
  CurrencyData(code: 'SGD', name: 'Сінгапурський долар', flagCode: 'sg'),
  CurrencyData(code: 'TRY', name: 'Турецька ліра', flagCode: 'tr'),
  CurrencyData(code: 'ZAR', name: 'Південноафриканський ренд', flagCode: 'za'),
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
        child: Column(
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

  CurrencyData? _findCurrency(String code) {
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
  late List<CurrencyData> _filteredCurrencies;

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

  final CurrencyData currency;
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
              _FlagIcon(flagCode: widget.currency.flagCode, size: 40),
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
  const _FlagIcon({required this.flagCode, required this.size});

  final String? flagCode;
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
      child: flagCode == null
          ? null
          : Image.network(
              _flagUrl(flagCode!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
    );
  }
}

String _flagUrl(String code) =>
    'https://flagcdn.com/80x80/${code.toLowerCase()}.png';

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

  final CurrencyData? currency;
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
              flagCode: currency?.flagCode,
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
