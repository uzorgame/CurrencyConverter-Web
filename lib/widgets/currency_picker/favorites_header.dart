import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../localization/app_strings.dart';

class FavoritesHeader extends StatelessWidget {
  const FavoritesHeader({super.key, required this.language});

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
