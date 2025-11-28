part of '../app/app.dart';

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
          color: _AppColors.bgMain,
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
                  color: _AppColors.textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _AppColors.textRate,
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
              color: _AppColors.textMain,
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
        final isSelected = _interval == interval;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _loadInterval(interval),
          child: Container(
            height: 36,
            width: 64,
            decoration: BoxDecoration(
              color: isSelected ? _AppColors.keyOpBg : const Color(0xFF3D3D3D),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                interval.label,
                style: TextStyle(
                  color: isSelected ? _AppColors.textMain : _AppColors.textRate,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
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
        height: 320,
        child: Center(
          child: CircularProgressIndicator(color: _AppColors.textDate),
        ),
      );
    }

    if (_currentRates.length < 2) {
      return SizedBox(
        height: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.of(widget.language, 'chartNoDataTitle'),
              style: const TextStyle(
                color: _AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppStrings.of(widget.language, 'chartNoDataSubtitle'),
              style: const TextStyle(
                color: _AppColors.textRate,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return _buildChart();
  }

  Widget _buildChart() {
    const minimumLabelSpacing = 4.0;
    final spots = _currentRates.map((rate) {
      return FlSpot(
        rate.date.millisecondsSinceEpoch.toDouble(),
        rate.rate,
      );
    }).toList();

    double minY = spots.first.y;
    double maxY = spots.first.y;
    double minX = spots.first.x;
    double maxX = spots.first.x;

    for (final spot in spots) {
      minY = math.min(minY, spot.y);
      maxY = math.max(maxY, spot.y);
      minX = math.min(minX, spot.x);
      maxX = math.max(maxX, spot.x);
    }

    final yPadding = (maxY - minY) * 0.15;
    minY -= yPadding;
    maxY += yPadding;

    final yRange = maxY - minY;
    final double yInterval = yRange <= 0.1
        ? 0.01
        : yRange <= 0.5
            ? 0.05
            : yRange <= 1
                ? 0.1
                : yRange <= 2
                    ? 0.2
                    : yRange <= 5
                        ? 0.5
                        : yRange <= 10
                            ? 1.0
                            : yRange <= 20
                                ? 2.0
                                : yRange <= 50
                                    ? 5.0
                                    : 10.0;

    final xRange = maxX - minX;
    final double xInterval = xRange <= 5 * 24 * 60 * 60 * 1000
        ? (24 * 60 * 60 * 1000).toDouble()
        : xRange <= 20 * 24 * 60 * 60 * 1000
            ? (5 * 24 * 60 * 60 * 1000).toDouble()
            : xRange <= 60 * 24 * 60 * 60 * 1000
                ? (10 * 24 * 60 * 60 * 1000).toDouble()
                : (30 * 24 * 60 * 60 * 1000).toDouble();

    final yTitleValues = _calculateTitleValues(minY, maxY, yInterval);
    final xTitleValues = _calculateTitleValues(minX, maxX, xInterval);

    final relaxedOverlapForX = _interval == _HistoryInterval.days30;

    final yTolerance = yInterval * 0.05;
    final xTolerance = xInterval * 0.05;

    double? _calculateAxisPosition({
      required double value,
      required double min,
      required double max,
      required double axisExtent,
    }) {
      if (value < min || value > max) return null;
      final fraction = (value - min) / (max - min);
      return fraction * axisExtent;
    }

    Rect _buildLabelBounds({
      required Size textSize,
      required double position,
      required bool isHorizontal,
    }) {
      const padding = 2.0;
      return Rect.fromLTWH(
        isHorizontal ? position - textSize.width / 2 : 0,
        isHorizontal ? 0 : position - textSize.height / 2,
        textSize.width + (isHorizontal ? 0 : padding * 2),
        textSize.height + (isHorizontal ? padding * 2 : 0),
      );
    }

    bool shouldShowTitle(
      double value,
      List<double> titleValues,
      double tolerance,
    ) {
      return titleValues.any((allowed) => (value - allowed).abs() <= tolerance);
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
            minX: minX,
            maxX: maxX,
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
                        color: _AppColors.textMain,
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
                      color: _AppColors.textRate,
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
                      color: _AppColors.textRate,
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
                color: _AppColors.keyOpBg,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      _AppColors.keyOpBg.withOpacity(0.25),
                      _AppColors.keyOpBg.withOpacity(0.05),
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

  List<double> _calculateTitleValues(
    double min,
    double max,
    double interval,
  ) {
    final values = <double>[];
    double current = (min / interval).floorToDouble() * interval;
    if (current < min) {
      current += interval;
    }
    while (current <= max) {
      values.add(current);
      current += interval;
    }
    return values;
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
