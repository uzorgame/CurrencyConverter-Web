import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/currency_constants.dart' as constants;
import '../models/currency.dart';
import '../models/enums.dart';
import '../providers/currency_provider.dart';
import '../repositories/historical_rates_repository.dart';
import '../utils/amount_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/common/currency_row.dart';
import '../widgets/common/divider_line.dart';
import '../widgets/common/status_time.dart';
import '../widgets/history_chart/history_chart_bottom_sheet.dart';
import '../widgets/keypad/keypad.dart';
import '../widgets/rate_panel/rate_panel.dart';
import '../widgets/settings/about_dialog.dart';
import '../widgets/settings/language_selector_sheet.dart';
import '../widgets/settings/settings_bottom_sheet.dart';
import 'currency_picker_page.dart';
import 'privacy_policy_page.dart';

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

  // ⚡ ОПТИМИЗАЦИЯ: Кэширование для избежания лишних вычислений
  List<Currency>? _cachedCurrencies;
  Map<String, Currency>? _currencyMap;
  double? _cachedRate;
  String _cachedRateKey = '';
  String _cachedRateText = '';
  
  // ⚡ ОПТИМИЗАЦИЯ: Static RegExp (создаётся один раз)
  static final _digitRegex = RegExp(r'^[0-9]$');

  @override
  Widget build(BuildContext context) {
    // ⚡ ОПТИМИЗАЦИЯ: Используем Selector для частичных обновлений вместо watch
    final status = context.select<CurrencyProvider, CurrencyStatus>(
      (provider) => provider.status
    );
    final rates = context.select<CurrencyProvider, Map<String, double>>(
      (provider) => provider.rates
    );
    final currencyNames = context.select<CurrencyProvider, Map<String, String>>(
      (provider) => provider.currencyNames
    );
    final lastUpdated = context.select<CurrencyProvider, DateTime>(
      (provider) => provider.lastUpdated
    );
    
    final currencyProvider = context.read<CurrencyProvider>();
    final currencies = _availableCurrencies(currencyProvider);
    _maybeSyncWithProvider(currencyProvider, currencies);

    final fromCurrency = _findCurrency(_fromCurrency, currencies);
    final toCurrency = _findCurrency(_toCurrency, currencies);
    final rateText = _formatRateText();
    final dateTimeText = _formatLastUpdated(lastUpdated);

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
                  child: RepaintBoundary(
                    child: Keypad(
                      onKeyPressed: _handleKeyPress,
                    ),
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

  // ⚡ ОПТИМИЗАЦИЯ: Кэшируем список валют чтобы не пересоздавать каждый раз
  List<Currency> _availableCurrencies(CurrencyProvider provider) {
    if (_cachedCurrencies != null) return _cachedCurrencies!;
    
    if (provider.currencyNames.isNotEmpty) {
      final entries = provider.currencyNames.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      _cachedCurrencies = entries
          .map((entry) => Currency(code: entry.key, name: entry.value))
          .toList();
      return _cachedCurrencies!;
    }

    return constants.currencies;
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

  // ⚡ ОПТИМИЗАЦИЯ: Кэшируем вычисления курса
  double? _computeRate(String from, String to) {
    final key = '$from-$to';
    if (_cachedRateKey == key && _cachedRate != null) {
      return _cachedRate;
    }
    
    final provider = context.read<CurrencyProvider>();
    if (provider.status != CurrencyStatus.loaded || provider.rates.isEmpty) {
      return null;
    }

    final fromRate = provider.rates[from];
    final toRate = provider.rates[to];

    if (fromRate == null || toRate == null || fromRate == 0) return null;

    final result = toRate / fromRate;
    _cachedRate = result;
    _cachedRateKey = key;
    return result;
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
