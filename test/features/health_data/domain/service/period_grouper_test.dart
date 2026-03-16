import 'package:body_trend/features/health_data/domain/entity/aggregation_period.dart';
import 'package:body_trend/features/health_data/domain/entity/health_metric.dart';
import 'package:body_trend/features/health_data/domain/entity/metric_type.dart';
import 'package:body_trend/features/health_data/domain/service/period_grouper.dart';
import 'package:flutter_test/flutter_test.dart';

HealthMetric _metric(DateTime date, {double value = 70.0}) {
  return HealthMetric(
    type: MetricType.weight,
    value: value,
    dateFrom: date,
    dateTo: date,
  );
}

void main() {
  group('PeriodGrouper', () {
    group('day grouping', () {
      test('groups records by day', () {
        final records = [
          _metric(DateTime(2024, 1, 1, 8, 0)),
          _metric(DateTime(2024, 1, 1, 20, 0)),
          _metric(DateTime(2024, 1, 2, 9, 0)),
        ];

        final result = PeriodGrouper.group(
          records: records,
          period: AggregationPeriod.day,
          rangeStart: DateTime(2024, 1, 1),
          rangeEnd: DateTime(2024, 1, 3),
        );

        expect(result.length, 2);
        expect(result[DateTime(2024, 1, 1)]!.length, 2);
        expect(result[DateTime(2024, 1, 2)]!.length, 1);
      });

      test('creates empty buckets for days without data', () {
        final result = PeriodGrouper.group(
          records: [_metric(DateTime(2024, 1, 1))],
          period: AggregationPeriod.day,
          rangeStart: DateTime(2024, 1, 1),
          rangeEnd: DateTime(2024, 1, 4),
        );

        expect(result.length, 3);
        expect(result[DateTime(2024, 1, 2)]!.length, 0);
        expect(result[DateTime(2024, 1, 3)]!.length, 0);
      });
    });

    group('week grouping', () {
      test('groups records by ISO week (Monday start)', () {
        // 2024-01-01 is Monday
        final records = [
          _metric(DateTime(2024, 1, 1)),
          _metric(DateTime(2024, 1, 5)), // Friday, same week
          _metric(DateTime(2024, 1, 8)), // Next Monday
        ];

        final result = PeriodGrouper.group(
          records: records,
          period: AggregationPeriod.week,
          rangeStart: DateTime(2024, 1, 1),
          rangeEnd: DateTime(2024, 1, 15),
        );

        expect(result[DateTime(2024, 1, 1)]!.length, 2);
        expect(result[DateTime(2024, 1, 8)]!.length, 1);
      });
    });

    group('month grouping', () {
      test('groups records by month', () {
        final records = [
          _metric(DateTime(2024, 1, 15)),
          _metric(DateTime(2024, 1, 28)),
          _metric(DateTime(2024, 2, 5)),
        ];

        final result = PeriodGrouper.group(
          records: records,
          period: AggregationPeriod.month,
          rangeStart: DateTime(2024, 1, 1),
          rangeEnd: DateTime(2024, 3, 1),
        );

        expect(result[DateTime(2024, 1)]!.length, 2);
        expect(result[DateTime(2024, 2)]!.length, 1);
      });
    });

    group('empty input', () {
      test('returns empty buckets for range with no records', () {
        final result = PeriodGrouper.group(
          records: [],
          period: AggregationPeriod.day,
          rangeStart: DateTime(2024, 1, 1),
          rangeEnd: DateTime(2024, 1, 3),
        );

        expect(result.length, 2);
        expect(result.values.every((list) => list.isEmpty), isTrue);
      });
    });
  });
}
