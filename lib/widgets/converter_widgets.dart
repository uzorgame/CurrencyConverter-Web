import 'package:currency/utils/app_colors.dart';
import 'package:currency/utils/currency_utils.dart';
import 'package:currency/utils/key_definition.dart';
import 'package:flutter/material.dart';

class StatusTime extends StatelessWidget {
  const StatusTime();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 44);
  }
}

class CurrencyRow extends StatelessWidget {
  const CurrencyRow({
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
                      color: AppColors.textMain,
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
                color: AppColors.textMain,
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

class DividerLine extends StatelessWidget {
  const DividerLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
      color: AppColors.dividerLine,
    );
  }
}

class Keypad extends StatelessWidget {
  const Keypad({required this.onKeyPressed});

  final void Function(String) onKeyPressed;

  static const List<KeyDefinition> _keys = [
    KeyDefinition('C', AppColors.keyRow1Bg),
    KeyDefinition('←', AppColors.keyRow1Bg),
    KeyDefinition('↑↓', AppColors.keyRow1Bg),
    KeyDefinition('÷', AppColors.keyOpBg),
    KeyDefinition('7', AppColors.keyNumBg),
    KeyDefinition('8', AppColors.keyNumBg),
    KeyDefinition('9', AppColors.keyNumBg),
    KeyDefinition('×', AppColors.keyOpBg),
    KeyDefinition('4', AppColors.keyNumBg),
    KeyDefinition('5', AppColors.keyNumBg),
    KeyDefinition('6', AppColors.keyNumBg),
    KeyDefinition('−', AppColors.keyOpBg),
    KeyDefinition('1', AppColors.keyNumBg),
    KeyDefinition('2', AppColors.keyNumBg),
    KeyDefinition('3', AppColors.keyNumBg),
    KeyDefinition('+', AppColors.keyOpBg),
    KeyDefinition('0', AppColors.keyNumBg),
    KeyDefinition('.', AppColors.keyNumBg),
    KeyDefinition('%', AppColors.keyNumBg),
    KeyDefinition('=', AppColors.keyOpBg),
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
          return KeyButton(
            label: key.label,
            backgroundColor: key.color,
            onPressed: () => onKeyPressed(key.label),
          );
        },
      ),
    );
  }
}

class KeyButton extends StatefulWidget {
  const KeyButton({
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  State<KeyButton> createState() => KeyButtonState();
}

class KeyButtonState extends State<KeyButton> {
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
                color: AppColors.textMain,
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

class RatePanel extends StatelessWidget {
  const RatePanel({
    required this.dateTimeText,
    required this.rateText,
    required this.onTap,
  });

  final String dateTimeText;
  final String rateText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
        decoration: const BoxDecoration(
          color: AppColors.keyRow1Bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateTimeText,
              style: const TextStyle(
                color: AppColors.textDate,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    rateText,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.query_stats,
                  color: AppColors.textMain,
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
