import 'dart:math' as math;

import 'package:currency/app/app.dart';
import 'package:currency/models/historical_rate.dart';
import 'package:currency/providers/currency_provider.dart';
import 'package:currency/repositories/currency_repository.dart';
import 'package:currency/repositories/historical_rates_repository.dart';
import 'package:currency/services/currency_api.dart';
import 'package:currency/services/historical_database.dart';
import 'package:currency/utils/active_field.dart';
import 'package:currency/utils/amount_formatter.dart';
import 'package:currency/utils/app_colors.dart';
import 'package:currency/utils/app_strings.dart';
import 'package:currency/utils/currency_utils.dart';
import 'package:currency/utils/date_utils.dart';
import 'package:currency/utils/key_definition.dart';
import 'package:currency/utils/language_utils.dart';
import 'package:currency/widgets/converter_widgets.dart';
import 'package:currency/widgets/settings_components.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final api = CurrencyApi();
  final repository = CurrencyRepository(
    api: api,
    prefs: prefs,
  );
  final historicalRepository = HistoricalRatesRepository(
    api: api,
    database: HistoricalDatabase.instance,
    currencyRepository: repository,
  );

  await historicalRepository.initialize();

  final initialLanguage = resolveInitialLanguage(prefs);

  runApp(
    MultiProvider(
      providers: [
        Provider<HistoricalRatesRepository>.value(value: historicalRepository),
        ChangeNotifierProvider(
          create: (_) => CurrencyProvider(repository)..init(),
        ),
      ],
      child: CurrencyApp(
        initialLanguage: initialLanguage,
        prefs: prefs,
      ),
    ),
  );
}

class HistoryChartBottomSheet extends StatefulWidget {
  const HistoryChartBottomSheet({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.lastUpdated,
    required this.repository,
    required this.language,
    this.latestRate,
  });

  final String baseCurrency;
  final String targetCurrency;
  final double? latestRate;
  final DateTime lastUpdated;
  final HistoricalRatesRepository repository;
  final String language;

  @override
  State<HistoryChartBottomSheet> createState() => _HistoryChartBottomSheetState();
}

class _LabelOverlapTracker {
  _LabelOverlapTracker(this.minSpacing);

  final double minSpacing;
  Rect? _lastBounds;

  bool isOverlapping(Rect nextBounds) {
    if (_lastBounds == null) {
      _lastBounds = nextBounds;
      return false;
    }

    final last = _lastBounds!.inflate(minSpacing / 2);
    final current = nextBounds.inflate(minSpacing / 2);
    final overlaps = last.overlaps(current);
    if (!overlaps) {
      _lastBounds = nextBounds;
    }
    return overlaps;
  }
}

class _HistoryChartBottomSheetState extends State<HistoryChartBottomSheet> {
  final Map<_HistoryInterval, List<HistoricalRate>> _cache = {};
  _HistoryInterval _interval = _HistoryInterval.days30;
  bool _loading = true;
  List<HistoricalRate> _currentRates = const [];

  @override
  void initState() {
    super.initState();
    _loadInterval(_interval);
  }

  Future<void> _loadInterval(_HistoryInterval interval) async {
    final cached = _cache[interval];
    setState(() {
      _interval = interval;
      _loading = cached == null;
      _currentRates = cached ?? _currentRates;
    });

    if (cached != null) return;

    await widget.repository.ensurePairFreshness(
      widget.baseCurrency,
      widget.targetCurrency,
    );

    final rates = await widget.repository.loadLatest(
      base: widget.baseCurrency,
      target: widget.targetCurrency,
      days: interval.days,
    );

    if (!mounted) return;

    setState(() {
      _cache[interval] = rates;
      _currentRates = rates;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.6,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgMain,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildIntervals(),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                child: _buildChartArea(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final subtitle = _formatSubtitle();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.baseCurrency} → ${widget.targetCurrency}',
                style: const TextStyle(
                  color: AppColors.textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textRate,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.close,
              color: AppColors.textMain,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntervals() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _HistoryInterval.values.map((interval) {
        final isActive = interval == _interval;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: interval == _HistoryInterval.values.last ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () => _loadInterval(interval),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.keyOpBg : const Color(0xFF3E3E3E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    interval.label,
                    style: const TextStyle(
                      color: AppColors.textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChartArea() {
    if (_loading) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.textMain),
        ),
      );
    }

    if (_currentRates.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF3E3E3E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.of(widget.language, 'chartNoDataTitle'),
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              AppStrings.of(widget.language, 'chartNoDataSubtitle'),
              style: const TextStyle(
                color: AppColors.textRate,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final minRate = _currentRates.map((r) => r.rate).reduce((a, b) => a < b ? a : b);
    final maxRate = _currentRates.map((r) => r.rate).reduce((a, b) => a > b ? a : b);
    final range = maxRate - minRate;
    final padding = (range * 0.02).clamp(0.0001, double.infinity).toDouble();
    final minY = (minRate - padding).toDouble();
    final maxY = (maxRate + padding).toDouble();

    final spots = _currentRates
        .map((rate) => FlSpot(
              rate.date.millisecondsSinceEpoch.toDouble(),
              rate.rate,
            ))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    final xStart = spots.first.x;
    final xEnd = spots.last.x;
    const minimumLabelSpacing = 4.0;

    List<double> _expandedTitleValues(List<double> values) {
      if (values.length < 2) return values;

      final sorted = [...values]..sort();
      final withMidpoints = <double>{...sorted};
      for (var i = 0; i < sorted.length - 1; i++) {
        withMidpoints.add((sorted[i] + sorted[i + 1]) / 2);
      }
      final result = withMidpoints.toList()..sort();
      return result;
    }

    final xTitleValues = <double>{xStart, xEnd}.toList()..sort();
    final xDeltas = <double>[];
    for (var i = 0; i < xTitleValues.length - 1; i++) {
      xDeltas.add(xTitleValues[i + 1] - xTitleValues[i]);
    }
    final xInterval = xDeltas.isNotEmpty ? xDeltas.reduce(math.min) : 1.0;
    final xTolerance = xInterval * 0.05;
    final relaxedOverlapForX = xTitleValues.length <= 5;

    final yTitleCount = 5;
    final yInterval = yTitleCount > 1 ? (maxY - minY) / (yTitleCount - 1) : 1.0;
    final yTitleValues = _expandedTitleValues(
      List.generate(yTitleCount, (index) => minY + yInterval * index),
    );
    final yTolerance = yInterval * 0.01;

    bool shouldShowTitle(double value, List<double> targets, double tolerance) {
      return targets.any((target) => (value - target).abs() <= tolerance);
    }

    Rect _buildLabelBounds({
      required Size textSize,
      required double position,
      required bool isHorizontal,
    }) {
      final center = isHorizontal
          ? Offset(position, textSize.height / 2)
          : Offset(textSize.width / 2, position);
      return Rect.fromCenter(
        center: center,
        width: textSize.width,
        height: textSize.height,
      );
    }

    double? _calculateAxisPosition({
      required double value,
      required double min,
      required double max,
      required double axisExtent,
    }) {
      if (axisExtent == 0 || min == max) return null;
      final fraction = ((value - min) / (max - min)).clamp(0.0, 1.0);
      return fraction * axisExtent;
    }

    final xLabelTracker =
        _LabelOverlapTracker(relaxedOverlapForX ? 0 : minimumLabelSpacing);
    final yLabelTracker = _LabelOverlapTracker(minimumLabelSpacing);

    return SizedBox(
      height: 320,
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            minX: xStart,
            maxX: xEnd,
            gridData: FlGridData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => const Color(0xFF1E1E1E),
                tooltipRoundedRadius: 12,
                tooltipPadding: const EdgeInsets.all(8),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((barSpot) {
                    final date = DateTime.fromMillisecondsSinceEpoch(barSpot.x.toInt());
                    final formattedDate = _formatFullDate(date);
                    final value = barSpot.y.toStringAsFixed(4);
                    return LineTooltipItem(
                      '$formattedDate — $value',
                      const TextStyle(
                        color: AppColors.textMain,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 56,
                  interval: yInterval,
                  getTitlesWidget: (value, meta) {
                    if (!shouldShowTitle(value, yTitleValues, yTolerance)) {
                      return const SizedBox.shrink();
                    }

                    final label = value.toStringAsFixed(2);
                    const textStyle = TextStyle(
                      color: AppColors.textRate,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    );
                    final painter = TextPainter(
                      text: TextSpan(text: label, style: textStyle),
                      textDirection: TextDirection.ltr,
                    )..layout();

                    final position = _calculateAxisPosition(
                      value: value,
                      min: meta.min,
                      max: meta.max,
                      axisExtent: meta.parentAxisSize,
                    );

                    if (position == null) {
                      return const SizedBox.shrink();
                    }

                    final bounds = _buildLabelBounds(
                      textSize: painter.size,
                      position: position,
                      isHorizontal: false,
                    );

                    if (yLabelTracker.isOverlapping(bounds)) {
                      return const SizedBox.shrink();
                    }

                    return Text(
                      label,
                      style: textStyle,
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  interval: xInterval,
                  getTitlesWidget: (value, meta) {
                    if (!shouldShowTitle(value, xTitleValues, xTolerance)) {
                      return const SizedBox.shrink();
                    }
                    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    final label = _formatShortDate(date);
                    const textStyle = TextStyle(
                      color: AppColors.textRate,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    );

                    final painter = TextPainter(
                      text: TextSpan(text: label, style: textStyle),
                      textDirection: TextDirection.ltr,
                    )..layout();

                    final position = _calculateAxisPosition(
                      value: value,
                      min: meta.min,
                      max: meta.max,
                      axisExtent: meta.parentAxisSize,
                    );

                    if (position == null) {
                      return const SizedBox.shrink();
                    }

                    final bounds = _buildLabelBounds(
                      textSize: painter.size,
                      position: position,
                      isHorizontal: true,
                    );

                    if (!relaxedOverlapForX && xLabelTracker.isOverlapping(bounds)) {
                      return const SizedBox.shrink();
                    }
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 12,
                      child: Text(
                        label,
                        style: textStyle,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                isCurved: true,
                barWidth: 2,
                dotData: const FlDotData(show: false),
                color: AppColors.keyOpBg,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.keyOpBg.withOpacity(0.25),
                      AppColors.keyOpBg.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                spots: spots,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSubtitle() {
    final rateText = widget.latestRate != null
        ? widget.latestRate!.toStringAsFixed(4)
        : '--';
    final updatedText = _formatUpdatedDate(widget.lastUpdated);
    final template = AppStrings.of(widget.language, 'chartSubtitle');
    return template
        .replaceAll('{rate}', rateText)
        .replaceAll('{updated}', updatedText);
  }

  String _formatUpdatedDate(DateTime date) {
    final now = DateTime.now();
    final isToday = now.year == date.year && now.month == date.month && now.day == date.day;
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    final time = '$hours:$minutes';
    if (isToday) {
      return AppStrings.of(widget.language, 'chartUpdatedToday')
          .replaceAll('{time}', time);
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final formattedDate = '$day.$month.${date.year}';
    return AppStrings.of(widget.language, 'chartUpdatedDate')
        .replaceAll('{date}', formattedDate)
        .replaceAll('{time}', time);
  }

  String _formatShortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month';
  }

  String _formatFullDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}

enum _HistoryInterval {
  days30,
  months3,
  months6,
  year1,
}

extension on _HistoryInterval {
  String get label {
    switch (this) {
      case _HistoryInterval.days30:
        return '30d';
      case _HistoryInterval.months3:
        return '3m';
      case _HistoryInterval.months6:
        return '6m';
      case _HistoryInterval.year1:
        return '1y';
    }
  }

  int get days {
    switch (this) {
      case _HistoryInterval.days30:
        return 30;
      case _HistoryInterval.months3:
        return 90;
      case _HistoryInterval.months6:
        return 180;
      case _HistoryInterval.year1:
        return 365;
    }
  }
}

