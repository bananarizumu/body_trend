import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entity/aggregated_health_data.dart';
import '../../domain/entity/aggregation_period.dart';
import '../../domain/entity/metric_type.dart';

class MetricLineChart extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(child: Text('データがありません')),
      );
    }

    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final bandColor = primaryColor.withValues(alpha: 0.15);

    return SizedBox(
      height: 250,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16, bottom: 4),
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
              // Min-Max range band (area between min and max)
              LineChartBarData(
                spots: _spotsFrom((d) => d.max),
                isCurved: true,
                curveSmoothness: 0.2,
                color: Colors.transparent,
                barWidth: 0,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
              LineChartBarData(
                spots: _spotsFrom((d) => d.min),
                isCurved: true,
                curveSmoothness: 0.2,
                color: Colors.transparent,
                barWidth: 0,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
              // Average line (main)
              LineChartBarData(
                spots: _spotsFrom((d) => d.average),
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
                belowBarData: BarAreaData(show: false),
              ),
              // Max line (upper bound of band)
              LineChartBarData(
                spots: _spotsFrom((d) => d.max),
                isCurved: true,
                curveSmoothness: 0.2,
                color: bandColor,
                barWidth: 0,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: bandColor,
                ),
              ),
              // Min line (lower bound - subtract band area)
              LineChartBarData(
                spots: _spotsFrom((d) => d.min),
                isCurved: true,
                curveSmoothness: 0.2,
                color: bandColor,
                barWidth: 0,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: theme.scaffoldBackgroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<FlSpot> _spotsFrom(double Function(AggregatedHealthData) getValue) {
    return List.generate(data.length, (i) {
      return FlSpot(i.toDouble(), getValue(data[i]));
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
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (_) =>
            Theme.of(context).colorScheme.surfaceContainerHighest,
        tooltipRoundedRadius: 8,
        getTooltipItems: (touchedSpots) {
          // Only show tooltip for the average line (index 2)
          return touchedSpots.map((spot) {
            if (spot.barIndex != 2) return null;

            final index = spot.spotIndex;
            if (index < 0 || index >= data.length) return null;

            final item = data[index];
            final unit = _unitFor(metricType);

            return LineTooltipItem(
              '${_formatDate(item.periodStart)}\n'
              '平均: ${item.average.toStringAsFixed(1)}$unit\n'
              '中央値: ${item.median.toStringAsFixed(1)}$unit\n'
              '最大: ${item.max.toStringAsFixed(1)}$unit\n'
              '最小: ${item.min.toStringAsFixed(1)}$unit',
              TextStyle(
                fontSize: 11,
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
    // Aim for ~5 grid lines
    final rawInterval = range / 5;
    // Round to a nice number
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
    final minVal = data.map((d) => d.min).reduce((a, b) => a < b ? a : b);
    final padding = (_maxRawY() - minVal) * 0.1;
    return (minVal - padding).floorToDouble();
  }

  double _maxY() {
    final maxVal = _maxRawY();
    final minVal = data.map((d) => d.min).reduce((a, b) => a < b ? a : b);
    final padding = (maxVal - minVal) * 0.1;
    return (maxVal + padding).ceilToDouble();
  }

  double _maxRawY() {
    return data.map((d) => d.max).reduce((a, b) => a > b ? a : b);
  }

  static String _unitFor(MetricType type) {
    return switch (type) {
      MetricType.weight => 'kg',
      MetricType.bodyFat => '%',
      MetricType.calorieIntake => 'kcal',
    };
  }
}
