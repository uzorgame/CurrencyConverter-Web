import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../localization/app_strings.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({
    super.key,
    required this.language,
    required this.onLanguageTap,
    required this.onAboutTap,
    required this.onPrivacyPolicyTap,
  });

  final String language;
  final VoidCallback onLanguageTap;
  final VoidCallback onAboutTap;
  final VoidCallback onPrivacyPolicyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: const BoxDecoration(
          color: AppColors.bgMain,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SettingsSheetTile(
                icon: Icons.language,
                title: AppStrings.of(language, 'language'),
                onTap: onLanguageTap,
              ),
              const SizedBox(height: 12),
              SettingsSheetTile(
                icon: Icons.info_outline,
                title: AppStrings.of(language, 'about'),
                onTap: onAboutTap,
              ),
              const SizedBox(height: 12),
              SettingsSheetTile(
                icon: Icons.privacy_tip_outlined,
                title: AppStrings.of(language, 'privacyPolicy'),
                onTap: onPrivacyPolicyTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsSheetTile extends StatelessWidget {
  const SettingsSheetTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.textMain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textMain,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
