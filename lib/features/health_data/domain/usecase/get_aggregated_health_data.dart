import '../entity/aggregated_health_data.dart';
import '../entity/aggregation_period.dart';
import '../entity/metric_type.dart';
import '../repository/health_data_repository.dart';

class GetAggregatedHealthData {
  final HealthDataRepository _repository;

  const GetAggregatedHealthData(this._repository);

  Future<List<AggregatedHealthData>> call({
    required MetricType metricType,
    required DateTime start,
    required DateTime end,
    required AggregationPeriod period,
  }) {
    return _repository.getAggregatedData(
      metricType: metricType,
      start: start,
      end: end,
      period: period,
    );
  }
}
