import 'package:body_trend/features/health_data/domain/entity/metric_type.dart';
import 'package:body_trend/features/health_data/domain/service/statistics_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final periodStart = DateTime(2024, 1, 1);
  final periodEnd = DateTime(2024, 1, 2);

  group('StatisticsCalculator', () {
    test('returns null for empty values', () {
      final result = StatisticsCalculator.calculate(
        metricType: MetricType.weight,
        periodStart: periodStart,
        periodEnd: periodEnd,
        values: [],
      );
      expect(result, isNull);
    });

    test('calculates correctly for single value', () {
      final result = StatisticsCalculator.calculate(
        metricType: MetricType.weight,
        periodStart: periodStart,
        periodEnd: periodEnd,
        values: [70.0],
      );
      expect(result, isNotNull);
      expect(result!.average, 70.0);
      expect(result.median, 70.0);
      expect(result.max, 70.0);
      expect(result.min, 70.0);
      expect(result.sampleCount, 1);
    });

    test('calculates correctly for odd number of values', () {
      final result = StatisticsCalculator.calculate(
        metricType: MetricType.weight,
        periodStart: periodStart,
        periodEnd: periodEnd,
        values: [70.0, 72.0, 68.0],
      );
      expect(result, isNotNull);
      expect(result!.average, 70.0);
      expect(result.median, 70.0);
      expect(result.max, 72.0);
      expect(result.min, 68.0);
      expect(result.sampleCount, 3);
    });

    test('calculates correctly for even number of values', () {
      final result = StatisticsCalculator.calculate(
        metricType: MetricType.weight,
        periodStart: periodStart,
        periodEnd: periodEnd,
        values: [70.0, 72.0, 68.0, 74.0],
      );
      expect(result, isNotNull);
      expect(result!.average, 71.0);
      expect(result.median, 71.0); // (70 + 72) / 2
      expect(result.max, 74.0);
      expect(result.min, 68.0);
      expect(result.sampleCount, 4);
    });

    test('preserves metricType and period info', () {
      final result = StatisticsCalculator.calculate(
        metricType: MetricType.bodyFat,
        periodStart: periodStart,
        periodEnd: periodEnd,
        values: [15.0, 16.0],
      );
      expect(result!.metricType, MetricType.bodyFat);
      expect(result.periodStart, periodStart);
      expect(result.periodEnd, periodEnd);
    });
  });
}
