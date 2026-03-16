import '../entity/aggregated_health_data.dart';
import '../entity/aggregation_period.dart';
import '../entity/metric_type.dart';

abstract class HealthDataRepository {
  Future<bool> requestPermissions();

  Future<bool> hasPermissions();

  Future<List<AggregatedHealthData>> getAggregatedData({
    required MetricType metricType,
    required DateTime start,
    required DateTime end,
    required AggregationPeriod period,
  });
}
