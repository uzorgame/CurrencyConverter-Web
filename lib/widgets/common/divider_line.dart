import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class DividerLine extends StatelessWidget {
  const DividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚡ ОПТИМИЗАЦИЯ: const Container для избежания пересоздания
    return const SizedBox(
      width: double.infinity,
      height: 1,
      child: ColoredBox(color: AppColors.dividerLine),
    );
  }
}
