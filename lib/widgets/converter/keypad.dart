import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'key_button.dart';

class Keypad extends StatelessWidget {
  const Keypad({super.key, required this.onKeyPressed});

  final void Function(String) onKeyPressed;

  static const List<_KeyDefinition> _keys = [
    _KeyDefinition('C', AppColors.keyRow1Bg),
    _KeyDefinition('←', AppColors.keyRow1Bg),
    _KeyDefinition('↑↓', AppColors.keyRow1Bg),
    _KeyDefinition('÷', AppColors.keyOpBg),
    _KeyDefinition('7', AppColors.keyNumBg),
    _KeyDefinition('8', AppColors.keyNumBg),
    _KeyDefinition('9', AppColors.keyNumBg),
    _KeyDefinition('×', AppColors.keyOpBg),
    _KeyDefinition('4', AppColors.keyNumBg),
    _KeyDefinition('5', AppColors.keyNumBg),
    _KeyDefinition('6', AppColors.keyNumBg),
    _KeyDefinition('−', AppColors.keyOpBg),
    _KeyDefinition('1', AppColors.keyNumBg),
    _KeyDefinition('2', AppColors.keyNumBg),
    _KeyDefinition('3', AppColors.keyNumBg),
    _KeyDefinition('+', AppColors.keyOpBg),
    _KeyDefinition('0', AppColors.keyNumBg),
    _KeyDefinition('.', AppColors.keyNumBg),
    _KeyDefinition('%', AppColors.keyNumBg),
    _KeyDefinition('=', AppColors.keyOpBg),
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

class _KeyDefinition {
  const _KeyDefinition(this.label, this.color);

  final String label;
  final Color color;
}


