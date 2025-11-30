import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../utils/app_strings.dart';
import '../widgets/common/simple_header.dart';

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
      backgroundColor: AppColors.bgMain,
      body: SafeArea(
        child: Column(
          children: [
            SimpleHeader(
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
                            color: AppColors.textMain,
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
                              color: AppColors.textDate,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => _openPrivacyPolicy(context),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        color: AppColors.textMain,
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


