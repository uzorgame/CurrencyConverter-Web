import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../utils/app_strings.dart';
import 'settings_sheet_tile.dart';

class SettingsBottomSheet extends StatelessWidget {
  const SettingsBottomSheet({
    super.key,
    required this.language,
    required this.onLanguageTap,
    required this.onAboutTap,
    required this.onPrivacyPolicyTap,
    required this.onDeveloperWebsiteTap,
  });

  final String language;
  final VoidCallback onLanguageTap;
  final VoidCallback onAboutTap;
  final VoidCallback onPrivacyPolicyTap;
  final VoidCallback onDeveloperWebsiteTap;

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
              const SizedBox(height: 12),
              SettingsSheetTile(
                icon: Icons.web,
                title: "Developer's website",
                onTap: onDeveloperWebsiteTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

