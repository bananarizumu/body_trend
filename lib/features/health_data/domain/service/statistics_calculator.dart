import '../entity/aggregated_health_data.dart';
import '../entity/metric_type.dart';

class StatisticsCalculator {
  static AggregatedHealthData? calculate({
    required MetricType metricType,
    required DateTime periodStart,
    required DateTime periodEnd,
    required List<double> values,
  }) {
    if (values.isEmpty) return null;

    final sorted = List<double>.from(values)..sort();
    final count = sorted.length;
    final sum = sorted.fold(0.0, (a, b) => a + b);

    final double median;
    if (count % 2 == 1) {
      median = sorted[count ~/ 2];
    } else {
      median = (sorted[count ~/ 2 - 1] + sorted[count ~/ 2]) / 2;
    }

    return AggregatedHealthData(
      metricType: metricType,
      periodStart: periodStart,
      periodEnd: periodEnd,
      average: sum / count,
      median: median,
      max: sorted.last,
      min: sorted.first,
      sampleCount: count,
    );
  }
}
