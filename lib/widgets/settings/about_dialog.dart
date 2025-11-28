import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../localization/app_strings.dart';

Future<void> showAboutDialogForLanguage(
  BuildContext context,
  String language,
) async {
  await showDialog<void>(
    context: context,
    builder: (_) {
      return AlertDialog(
        backgroundColor: AppColors.bgMain,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: Text(
            AppStrings.of(language, 'about'),
            style: const TextStyle(
              color: AppColors.textMain,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.of(language, 'aboutCompany'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.of(language, 'versionLabel'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textRate,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(
              AppStrings.of(language, 'ok'),
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    },
  );
}
