import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/app_strings.dart';

class PickerHeader extends StatelessWidget {
  const PickerHeader({
    super.key,
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


