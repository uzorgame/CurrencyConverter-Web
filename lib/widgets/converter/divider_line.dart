import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class DividerLine extends StatelessWidget {
  const DividerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1,
      color: AppColors.dividerLine,
    );
  }
}


