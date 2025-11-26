import 'package:flutter/material.dart';

void main() {
  runApp(const CurrencyApp());
}

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

class CurrencyConverterScreen extends StatelessWidget {
  const CurrencyConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDateTime = _formatDateTime(now);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _StatusTime(),
            const SizedBox(height: 12),
            const _CurrencyRow(code: 'CAD', flag: '🇨🇦'),
            const SizedBox(height: 10),
            const _DividerLine(),
            const SizedBox(height: 10),
            const _CurrencyRow(code: 'USD', flag: '🇺🇸'),
            const SizedBox(height: 16),
            const Expanded(child: _Keypad()),
            _RatePanel(
              dateTimeText: formattedDateTime,
              rateText: '1 CAD = 0.71 USD',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusTime extends StatelessWidget {
  const _StatusTime();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeText = _twoDigits(now.hour) + ':' + _twoDigits(now.minute);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              timeText,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: _AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.signal_cellular_alt,
            color: _AppColors.textMain,
            size: 18,
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.wifi,
            color: _AppColors.textMain,
            size: 18,
          ),
          const SizedBox(width: 6),
          Container(
            width: 26,
            height: 14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _AppColors.textMain, width: 1.5),
            ),
            alignment: Alignment.center,
            child: const Text(
              '60%',
              style: TextStyle(
                color: _AppColors.textMain,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyRow extends StatelessWidget {
  const _CurrencyRow({required this.code, required this.flag});

  final String code;
  final String flag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.transparent,
            child: Text(
              flag,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            code,
            style: const TextStyle(
              color: _AppColors.textMain,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          const Text(
            '0',
            style: TextStyle(
              color: _AppColors.textMain,
              fontSize: 48,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
  const _Keypad();

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
          return _KeyButton(label: key.label, backgroundColor: key.color);
        },
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.backgroundColor});

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class _RatePanel extends StatelessWidget {
  const _RatePanel({required this.dateTimeText, required this.rateText});

  final String dateTimeText;
  final String rateText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 290,
      color: _AppColors.bgMain,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.refresh,
            color: _AppColors.textMain,
            size: 28,
          ),
          Column(
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
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _AppColors.textMain, width: 2),
            ),
            child: const Icon(
              Icons.circle,
              color: _AppColors.textMain,
              size: 18,
            ),
          ),
        ],
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
