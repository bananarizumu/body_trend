import 'metric_type.dart';

class HealthMetric {
  final MetricType type;
  final double value;
  final DateTime dateFrom;
  final DateTime dateTo;

  const HealthMetric({
    required this.type,
    required this.value,
    required this.dateFrom,
    required this.dateTo,
  });
}
