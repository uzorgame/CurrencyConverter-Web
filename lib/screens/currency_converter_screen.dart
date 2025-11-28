import 'package:currency/main.dart';
import 'package:currency/models/historical_rate.dart';
import 'package:currency/providers/currency_provider.dart';
import 'package:currency/repositories/historical_rates_repository.dart';
import 'package:currency/screens/currency_picker_page.dart';
import 'package:currency/screens/privacy_policy_page.dart';
import 'package:currency/screens/settings_page.dart';
import 'package:currency/utils/active_field.dart';
import 'package:currency/utils/amount_formatter.dart';
import 'package:currency/utils/app_colors.dart';
import 'package:currency/utils/app_strings.dart';
import 'package:currency/utils/currency_utils.dart';
import 'package:currency/utils/date_utils.dart';
import 'package:currency/utils/key_definition.dart';
import 'package:currency/widgets/converter_widgets.dart';
import 'package:currency/widgets/settings_components.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                const StatusTime(),
                const SizedBox(height: 12),
                CurrencyRow(
                  currency: fromCurrency,
                  valueText: _topDisplay,
                  onTap: () => _openCurrencyPicker(ActiveField.top),
                ),
                const SizedBox(height: 10),
                const DividerLine(),
                const SizedBox(height: 10),
                CurrencyRow(
                  currency: toCurrency,
                  valueText: _bottomDisplay,
                  onTap: () => _openCurrencyPicker(ActiveField.bottom),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Keypad(
                    onKeyPressed: _handleKeyPress,
                  ),
                ),
                SafeArea(
                  bottom: true,
                  child: RatePanel(
                    dateTimeText: dateTimeText,
                    rateText: rateText,
                    onTap: _openHistorySheet,
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
                  onTap: _openSettingsSheet,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Icon(
                      Icons.settings,
                      color: AppColors.textMain,
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

    return currencies;
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
    final language = widget.languageNotifier.value;
    final currencies = _availableCurrencies(context.read<CurrencyProvider>());
    final selected = await Navigator.of(context).push<String>(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => CurrencyPickerPage(
          currencies: currencies,
          language: language,
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

  void _openSettingsSheet() {
    final language = widget.languageNotifier.value;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SettingsBottomSheet(
          language: language,
          onLanguageTap: () async {
            Navigator.of(sheetContext).pop();
            final selected =
                await showLanguageSelectorSheet(context, language);
            if (selected != null) {
              widget.languageNotifier.value = selected;
            }
          },
          onAboutTap: () async {
            Navigator.of(sheetContext).pop();
            await showAboutDialogForLanguage(context, language);
          },
          onPrivacyPolicyTap: () {
            Navigator.of(sheetContext).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PrivacyPolicyPage(language: language),
              ),
            );
          },
        );
      },
    );
  }

  void _openHistorySheet() {
    final provider = context.read<CurrencyProvider>();
    final repository = context.read<HistoricalRatesRepository>();
    final rate = _computeRate(_fromCurrency, _toCurrency);
    final language = widget.languageNotifier.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: false,
      builder: (_) => HistoryChartBottomSheet(
        baseCurrency: _fromCurrency,
        targetCurrency: _toCurrency,
        latestRate: rate,
        lastUpdated: provider.lastUpdated,
        repository: repository,
        language: language,
      ),
    );
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

    return formatDateTime(dateTime);
  }
}

class CurrencyPickerPage extends StatefulWidget {
  const CurrencyPickerPage({
    required this.initialCode,
    required this.currencies,
    required this.language,
    super.key,
  });

  final String initialCode;
  final List<Currency> currencies;
  final String language;

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
    final language = widget.language;
    final favoriteCodes = currencyProvider.favoriteCurrencies.toSet();

    final favoriteCurrencies = _filteredCurrencies
        .where((currency) => favoriteCodes.contains(currency.code))
        .toList();
    final otherCurrencies = _filteredCurrencies
        .where((currency) => !favoriteCodes.contains(currency.code))
        .toList();

    final tiles = <Widget>[
      if (favoriteCurrencies.isNotEmpty) ...[
        _FavoritesHeader(language: language),
        const SizedBox(height: 10),
        ..._buildTiles(favoriteCurrencies, currencyProvider),
        if (otherCurrencies.isNotEmpty) const SizedBox(height: 16),
      ],
      ..._buildTiles(otherCurrencies, currencyProvider),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _PickerHeader(
              language: language,
              onBack: Navigator.of(context).pop,
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 11),
              child: _SearchField(
                controller: _searchController,
                language: language,
              ),
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
  const _PickerHeader({
    required this.onBack,
    required this.language,
  });

  final VoidCallback onBack;
  final String language;

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
                    color: AppColors.textMain,
                    size: 22,
                  ),
                ),
              ),
            ),
            Text(
              AppStrings.of(language, 'currenciesTitle'),
              style: const TextStyle(
                color: AppColors.textMain,
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
  const _SearchField({
    required this.controller,
    required this.language,
  });

  final TextEditingController controller;
  final String language;

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
          color: AppColors.textMain,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: AppColors.textMain,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
          hintText: AppStrings.of(language, 'searchHint'),
          hintStyle: const TextStyle(
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
                    color: AppColors.textMain,
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
  const _FavoritesHeader({required this.language});

  final String language;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          AppStrings.of(language, 'favorites'),
          style: const TextStyle(
            color: AppColors.textMain,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

