part of '../app/app.dart';

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
              style: const TextStyle(
                color: _AppColors.textMain,
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

class _SettingsBottomSheet extends StatelessWidget {
  const _SettingsBottomSheet({
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
          color: _AppColors.bgMain,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SettingsSheetTile(
                icon: Icons.language,
                title: AppStrings.of(language, 'language'),
                onTap: onLanguageTap,
              ),
              const SizedBox(height: 12),
              _SettingsSheetTile(
                icon: Icons.info_outline,
                title: AppStrings.of(language, 'about'),
                onTap: onAboutTap,
              ),
              const SizedBox(height: 12),
              _SettingsSheetTile(
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

class _SettingsSheetTile extends StatelessWidget {
  const _SettingsSheetTile({
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
              color: _AppColors.textMain,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: _AppColors.textMain,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: _AppColors.textMain,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.languageNotifier,
  });

  final ValueNotifier<String> languageNotifier;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.languageNotifier,
      builder: (context, language, _) {
        return Scaffold(
          backgroundColor: _AppColors.bgMain,
          body: SafeArea(
            child: Column(
              children: [
                _SettingsHeader(
                  title: AppStrings.of(language, 'settingsTitle'),
                  onBack: Navigator.of(context).pop,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(11, 0, 11, 16),
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return _SettingsTile(
                            title: AppStrings.of(language, 'language'),
                            trailingText:
                                _settingsLanguages[language] ?? language,
                            onTap: () => _showLanguageSelector(language),
                          );
                        case 1:
                          return _SettingsTile(
                            title: AppStrings.of(language, 'about'),
                            onTap: () => _showAboutDialog(language),
                          );
                        case 2:
                          return _SettingsTile(
                            title: AppStrings.of(language, 'privacyPolicy'),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PrivacyPolicyPage(
                                    language: language,
                                  ),
                                ),
                              );
                            },
                          );
                      }
                      return const SizedBox.shrink();
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemCount: 3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSelector(String currentLanguage) async {
    final selected = await showLanguageSelectorSheet(context, currentLanguage);

    if (selected == null) return;

    widget.languageNotifier.value = selected;
  }

  Future<void> _showAboutDialog(String language) async {
    await showAboutDialogForLanguage(context, language);
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

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
                    color: _AppColors.textMain,
                    size: 22,
                  ),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: _AppColors.textMain,
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

class _SettingsTile extends StatefulWidget {
  const _SettingsTile({
    required this.title,
    this.trailingText,
    required this.onTap,
  });

  final String title;
  final String? trailingText;
  final VoidCallback onTap;

  @override
  State<_SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<_SettingsTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 80),
      opacity: _pressed ? 0.9 : 1,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {
          setState(() => _pressed = false);
          widget.onTap();
        },
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: _AppColors.textMain,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.trailingText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    widget.trailingText!,
                    style: const TextStyle(
                      color: Color(0xFF8F8F8F),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Color(0xFF8F8F8F),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
