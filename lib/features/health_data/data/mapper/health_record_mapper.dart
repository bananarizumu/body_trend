import '../../domain/entity/health_metric.dart';
import '../../domain/entity/metric_type.dart';
import '../dto/health_metric_type.dart';
import '../dto/health_record_dto.dart';

class HealthRecordMapper {
  static HealthMetric fromDto(HealthRecordDto dto) {
    return HealthMetric(
      type: _mapMetricType(dto.metricType),
      value: dto.numericValue,
      dateFrom: dto.dateFrom,
      dateTo: dto.dateTo,
    );
  }

  static MetricType _mapMetricType(HealthMetricType type) {
    return switch (type) {
      HealthMetricType.weight => MetricType.weight,
      HealthMetricType.bodyFat => MetricType.bodyFat,
      HealthMetricType.calorieIntake => MetricType.calorieIntake,
    };
  }
}
