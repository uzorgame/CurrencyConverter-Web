import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

Future<String?> showLanguageSelectorSheet(
  BuildContext context,
  String currentLanguage,
) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.bgMain,
    builder: (_) {
      return SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemBuilder: (context, index) {
            final entry = settingsLanguages.entries.elementAt(index);
            final isSelected = entry.key == currentLanguage;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(entry.key),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.keyRow1Bg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      entry.value,
                      style: const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(
                        Icons.check,
                        color: AppColors.textMain,
                      ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: settingsLanguages.length,
        ),
      );
    },
  );
}
