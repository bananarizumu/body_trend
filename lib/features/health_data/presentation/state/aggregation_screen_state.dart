import '../../domain/entity/aggregated_health_data.dart';
import '../../domain/entity/aggregation_period.dart';
import '../../domain/entity/metric_type.dart';

sealed class AggregationScreenState {
  const AggregationScreenState();
}

class AggregationScreenLoading extends AggregationScreenState {
  const AggregationScreenLoading();
}

class AggregationScreenSuccess extends AggregationScreenState {
  final List<AggregatedHealthData> data;
  final MetricType metricType;
  final AggregationPeriod period;

  const AggregationScreenSuccess({
    required this.data,
    required this.metricType,
    required this.period,
  });
}

class AggregationScreenPermissionRequired extends AggregationScreenState {
  const AggregationScreenPermissionRequired();
}

class AggregationScreenError extends AggregationScreenState {
  final String message;

  const AggregationScreenError(this.message);
}
