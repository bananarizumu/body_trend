import 'metric_type.dart';

class AggregatedHealthData {
  final MetricType metricType;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double average;
  final double median;
  final double max;
  final double min;
  final int sampleCount;

  const AggregatedHealthData({
    required this.metricType,
    required this.periodStart,
    required this.periodEnd,
    required this.average,
    required this.median,
    required this.max,
    required this.min,
    required this.sampleCount,
  });
}
