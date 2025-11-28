part of '../app/app.dart';

class _RatePanel extends StatelessWidget {
  const _RatePanel({
    required this.dateTimeText,
    required this.rateText,
    required this.onTap,
  });

  final String dateTimeText;
  final String rateText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: _AppColors.bgMain,
        padding: const EdgeInsets.fromLTRB(22, 15, 22, 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dateTimeText,
                style: const TextStyle(
                  color: _AppColors.textDate,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  rateText,
                  key: ValueKey(rateText),
                  style: const TextStyle(
                    color: _AppColors.textRate,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
