import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/aggregated_health_data.dart';
import '../../domain/entity/aggregation_period.dart';
import '../../domain/entity/metric_type.dart';

enum ChartStatType { average, median, max, min }

class MetricLineChart extends StatefulWidget {
  final List<AggregatedHealthData> data;
  final MetricType metricType;
  final AggregationPeriod period;

  const MetricLineChart({
    super.key,
    required this.data,
    required this.metricType,
    required this.period,
  });

  @override
  State<MetricLineChart> createState() => _MetricLineChartState();
}

class _MetricLineChartState extends State<MetricLineChart> {
  ChartStatType _selectedStat = ChartStatType.average;

  List<AggregatedHealthData> get data => widget.data;
  MetricType get metricType => widget.metricType;
  AggregationPeriod get period => widget.period;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('データがありません')),
      );
    }

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Column(
      children: [
        _buildStatSelector(context),
        SizedBox(
          height: 220,
          child: Padding(
            padding: const EdgeInsets.only(right: 16, top: 8, bottom: 4),
            child: LineChart(
              LineChartData(
                lineTouchData: _buildTouchData(context),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: _yInterval(),
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: _buildTitlesData(context),
                borderData: FlBorderData(show: false),
                minY: _minY(),
                maxY: _maxY(),
                lineBarsData: [
                  LineChartBarData(
                    spots: _spotsForStat(_selectedStat),
                    isCurved: true,
                    curveSmoothness: 0.2,
                    color: primaryColor,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: data.length <= 31,
                      getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                        radius: 3,
                        color: primaryColor,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryColor.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<ChartStatType>(
        segments: const [
          ButtonSegment(value: ChartStatType.average, label: Text('平均')),
          ButtonSegment(value: ChartStatType.median, label: Text('中央値')),
          ButtonSegment(value: ChartStatType.max, label: Text('最大')),
          ButtonSegment(value: ChartStatType.min, label: Text('最小')),
        ],
        selected: {_selectedStat},
        onSelectionChanged: (selected) {
          setState(() => _selectedStat = selected.first);
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(
            Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ),
    );
  }

  List<FlSpot> _spotsForStat(ChartStatType stat) {
    return List.generate(data.length, (i) {
      final d = data[i];
      final value = switch (stat) {
        ChartStatType.average => d.average,
        ChartStatType.median => d.median,
        ChartStatType.max => d.max,
        ChartStatType.min => d.min,
      };
      return FlSpot(i.toDouble(), value);
    });
  }

  FlTitlesData _buildTitlesData(BuildContext context) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        axisNameWidget: Text(
          _unitFor(metricType),
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        axisNameSize: 20,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 48,
          interval: _yInterval(),
          getTitlesWidget: (value, meta) {
            if (value == meta.max || value == meta.min) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                _formatYValue(value),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: _xInterval(),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= data.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _formatDate(data[index].periodStart),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  LineTouchData _buildTouchData(BuildContext context) {
    final unit = _unitFor(metricType);
    final statLabel = switch (_selectedStat) {
      ChartStatType.average => '平均',
      ChartStatType.median => '中央値',
      ChartStatType.max => '最大',
      ChartStatType.min => '最小',
    };

    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) =>
            Theme.of(context).colorScheme.surfaceContainerHighest,
        tooltipRoundedRadius: 8,
        getTooltipItems: (touchedSpots) {
          return touchedSpots.map((spot) {
            final index = spot.spotIndex;
            if (index < 0 || index >= data.length) return null;

            final item = data[index];
            final value = switch (_selectedStat) {
              ChartStatType.average => item.average,
              ChartStatType.median => item.median,
              ChartStatType.max => item.max,
              ChartStatType.min => item.min,
            };

            return LineTooltipItem(
              '${_formatDate(item.periodStart)}\n'
              '$statLabel: ${value.toStringAsFixed(1)}$unit',
              TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.4,
              ),
            );
          }).toList();
        },
      ),
      handleBuiltInTouches: true,
    );
  }

  String _formatDate(DateTime date) {
    return switch (period) {
      AggregationPeriod.day => DateFormat('M/d').format(date),
      AggregationPeriod.week => '${DateFormat('M/d').format(date)}~',
      AggregationPeriod.month => DateFormat('yyyy/M').format(date),
    };
  }

  String _formatYValue(double value) {
    if (metricType == MetricType.calorieIntake) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  double _yInterval() {
    final range = _maxY() - _minY();
    if (range <= 0) return 1;
    final rawInterval = range / 5;
    if (rawInterval <= 0.5) return 0.5;
    if (rawInterval <= 1) return 1;
    if (rawInterval <= 2) return 2;
    if (rawInterval <= 5) return 5;
    if (rawInterval <= 10) return 10;
    if (rawInterval <= 50) return 50;
    if (rawInterval <= 100) return 100;
    if (rawInterval <= 500) return 500;
    return 1000;
  }

  double _xInterval() {
    if (data.length <= 7) return 1;
    if (data.length <= 14) return 2;
    if (data.length <= 31) return 5;
    return 7;
  }

  double _minY() {
    final values = _spotsForStat(_selectedStat).map((s) => s.y);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxVal - minVal) * 0.1;
    return (minVal - padding).floorToDouble();
  }

  double _maxY() {
    final values = _spotsForStat(_selectedStat).map((s) => s.y);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final padding = (maxVal - minVal) * 0.1;
    return (maxVal + padding).ceilToDouble();
  }

  static String _unitFor(MetricType type) {
    return switch (type) {
      MetricType.weight => 'kg',
      MetricType.bodyFat => '%',
      MetricType.calorieIntake => 'kcal',
    };
  }
}
