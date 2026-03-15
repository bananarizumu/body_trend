import 'package:health/health.dart';

import 'health_metric_type.dart';

class HealthRecordDto {
  final HealthMetricType metricType;
  final double numericValue;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String sourceName;

  const HealthRecordDto({
    required this.metricType,
    required this.numericValue,
    required this.dateFrom,
    required this.dateTo,
    required this.sourceName,
  });

  factory HealthRecordDto.fromHealthDataPoint(HealthDataPoint point) {
    final metricType = _resolveMetricType(point.type);
    final numericValue = _extractNumericValue(point);

    return HealthRecordDto(
      metricType: metricType,
      numericValue: numericValue,
      dateFrom: point.dateFrom,
      dateTo: point.dateTo,
      sourceName: point.sourceName,
    );
  }

  static HealthMetricType _resolveMetricType(HealthDataType type) {
    return switch (type) {
      HealthDataType.WEIGHT => HealthMetricType.weight,
      HealthDataType.BODY_FAT_PERCENTAGE => HealthMetricType.bodyFat,
      HealthDataType.NUTRITION => HealthMetricType.calorieIntake,
      _ => throw ArgumentError('Unsupported HealthDataType: $type'),
    };
  }

  static double _extractNumericValue(HealthDataPoint point) {
    final value = point.value;
    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }
    if (value is NutritionHealthValue) {
      return value.calories ?? 0.0;
    }
    throw ArgumentError('Unsupported HealthValue type: ${value.runtimeType}');
  }
}
