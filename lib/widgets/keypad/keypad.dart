import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/enums.dart';
import 'key_button.dart';

class Keypad extends StatelessWidget {
  const Keypad({super.key, required this.onKeyPressed});

  final void Function(String) onKeyPressed;

  // ⚡ ОПТИМИЗАЦИЯ: const List для избежания пересоздания
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
