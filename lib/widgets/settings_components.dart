part of 'main.dart';

const Map<String, String> _settingsLanguages = {
  'EN': 'English',
  'DE': 'Deutsch',
  'FR': 'Français',
  'IT': 'Italiano',
  'ES': 'Español',
  'RU': 'Русский',
  'UK': 'Українська',
};

Future<String?> showLanguageSelectorSheet(
  BuildContext context,
  String currentLanguage,
) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: _AppColors.bgMain,
    builder: (_) {
      return SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemBuilder: (context, index) {
            final entry = _settingsLanguages.entries.elementAt(index);
            final isSelected = entry.key == currentLanguage;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(entry.key),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? _AppColors.keyRow1Bg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      entry.value,
                      style: const TextStyle(
                        color: _AppColors.textMain,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(
                        Icons.check,
                        color: _AppColors.textMain,
                      ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: _settingsLanguages.length,
        ),
      );
    },
  );
}

Future<void> showAboutDialogForLanguage(
  BuildContext context,
  String language,
) async {
  await showDialog<void>(
    context: context,
    builder: (_) {
      return AlertDialog(
        backgroundColor: _AppColors.bgMain,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: Text(
            AppStrings.of(language, 'about'),
            style: const TextStyle(
              color: _AppColors.textMain,
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
                color: _AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.of(language, 'versionLabel'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _AppColors.textRate,
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
              style: const TextStyle(color: _AppColors.keyOpBg),
            ),
          ),
        ],
      );
    },
  );
}

class _SettingsBottomSheet extends StatelessWidget {
  const _SettingsBottomSheet({
    required this.onLanguageTap,
    required this.onAboutTap,
    required this.onPrivacyPolicyTap,
    required this.language,
  });

  final VoidCallback onLanguageTap;
  final VoidCallback onAboutTap;
  final VoidCallback onPrivacyPolicyTap;
  final String language;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _AppColors.bgMain,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              _SettingsButton(
                icon: Icons.language,
                label: AppStrings.of(language, 'language'),
                onTap: onLanguageTap,
              ),
              const SizedBox(height: 10),
              _SettingsButton(
                icon: Icons.info_outline,
                label: AppStrings.of(language, 'about'),
                onTap: onAboutTap,
              ),
              const SizedBox(height: 10),
              _SettingsButton(
                icon: Icons.privacy_tip_outlined,
                label: AppStrings.of(language, 'privacyPolicy'),
                onTap: onPrivacyPolicyTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.keyRow1Bg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 54),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Row(
          children: [
            Icon(icon, color: _AppColors.textMain, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _AppColors.textMain,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _AppColors.textMain,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
