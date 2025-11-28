part of 'main.dart';

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
    required this.onTap,
  });

  final String dateTimeText;
  final String rateText;
  final VoidCallback onTap;
