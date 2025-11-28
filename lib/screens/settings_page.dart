part of 'package:currency/main.dart';

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

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({
    super.key,
    required this.language,
  });

  final String language;

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final privacyPolicyUri = Uri.parse(AppStrings.of(language, 'privacyPolicyUrl'));

    if (!await launchUrl(privacyPolicyUri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(language, 'linkOpenError')),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            _SimpleHeader(
              title: AppStrings.of(language, 'privacyPolicy'),
              onBack: Navigator.of(context).pop,
            ),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...AppStrings.privacyParagraphs(language).map(
                      (paragraph) => Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          paragraph,
                          style: const TextStyle(
                            color: _AppColors.textMain,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        text: AppStrings.of(language, 'privacyFullDetails'),
                        children: [
                          const TextSpan(text: '\n'),
                          TextSpan(
                            text: AppStrings.of(language, 'privacyPolicyUrl'),
                            style: const TextStyle(
                              color: _AppColors.textDate,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _openPrivacyPolicy(context),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        color: _AppColors.textMain,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleHeader extends StatelessWidget {
  const _SimpleHeader({required this.title, required this.onBack});

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
