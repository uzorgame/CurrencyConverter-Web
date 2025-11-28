import 'package:currency/screens/privacy_policy_page.dart';
import 'package:currency/utils/app_colors.dart';
import 'package:currency/utils/app_strings.dart';
import 'package:currency/widgets/settings_components.dart';
import 'package:flutter/material.dart';

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
          backgroundColor: AppColors.bgMain,
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
                            trailingText: settingsLanguages[language] ?? language,
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
                    color: AppColors.textMain,
                    size: 22,
                  ),
                ),
              ),
            ),
            Text(
              title,
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
                    color: AppColors.textMain,
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

