import 'package:body_trend/features/health_data/data/dto/health_metric_type.dart';
import 'package:body_trend/features/health_data/data/dto/health_record_dto.dart';
import 'package:body_trend/features/health_data/data/mapper/health_record_mapper.dart';
import 'package:body_trend/features/health_data/domain/entity/metric_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HealthRecordMapper', () {
    test('maps weight DTO to domain entity', () {
      final dto = HealthRecordDto(
        metricType: HealthMetricType.weight,
        numericValue: 70.5,
        dateFrom: DateTime(2024, 1, 1),
        dateTo: DateTime(2024, 1, 1),
        sourceName: 'test',
      );

      final result = HealthRecordMapper.fromDto(dto);

      expect(result.type, MetricType.weight);
      expect(result.value, 70.5);
      expect(result.dateFrom, DateTime(2024, 1, 1));
    });

    test('maps bodyFat DTO to domain entity', () {
      final dto = HealthRecordDto(
        metricType: HealthMetricType.bodyFat,
        numericValue: 15.2,
        dateFrom: DateTime(2024, 1, 1),
        dateTo: DateTime(2024, 1, 1),
        sourceName: 'test',
      );

      final result = HealthRecordMapper.fromDto(dto);
      expect(result.type, MetricType.bodyFat);
      expect(result.value, 15.2);
    });

    test('maps calorieIntake DTO to domain entity', () {
      final dto = HealthRecordDto(
        metricType: HealthMetricType.calorieIntake,
        numericValue: 2000.0,
        dateFrom: DateTime(2024, 1, 1),
        dateTo: DateTime(2024, 1, 1),
        sourceName: 'test',
      );

      final result = HealthRecordMapper.fromDto(dto);
      expect(result.type, MetricType.calorieIntake);
      expect(result.value, 2000.0);
    });
  });
}
