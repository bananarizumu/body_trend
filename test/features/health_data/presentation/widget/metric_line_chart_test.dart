import 'package:body_trend/features/health_data/domain/entity/aggregated_health_data.dart';
import 'package:body_trend/features/health_data/domain/entity/aggregation_period.dart';
import 'package:body_trend/features/health_data/domain/entity/metric_type.dart';
import 'package:body_trend/features/health_data/presentation/widget/metric_line_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

List<AggregatedHealthData> _sampleData({
  MetricType type = MetricType.weight,
  int count = 7,
}) {
  return List.generate(count, (i) {
    final start = DateTime(2026, 3, 1 + i);
    return AggregatedHealthData(
      metricType: type,
      periodStart: start,
      periodEnd: start.add(const Duration(days: 1)),
      average: 70.0 + i * 0.5,
      median: 70.0 + i * 0.4,
      max: 71.0 + i * 0.5,
      min: 69.0 + i * 0.5,
      sampleCount: 3,
    );
  });
}

void main() {
  group('MetricLineChart', () {
    testWidgets('shows empty message when data is empty', (tester) async {
      await tester.pumpWidget(_wrap(
        const MetricLineChart(
          data: [],
          metricType: MetricType.weight,
          period: AggregationPeriod.day,
        ),
      ));

      expect(find.text('データがありません'), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('renders LineChart when data is provided', (tester) async {
      await tester.pumpWidget(_wrap(
        MetricLineChart(
          data: _sampleData(),
          metricType: MetricType.weight,
          period: AggregationPeriod.day,
        ),
      ));

      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text('データがありません'), findsNothing);
    });

    testWidgets('displays unit label for weight', (tester) async {
      await tester.pumpWidget(_wrap(
        MetricLineChart(
          data: _sampleData(type: MetricType.weight),
          metricType: MetricType.weight,
          period: AggregationPeriod.day,
        ),
      ));

      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('displays unit label for body fat', (tester) async {
      await tester.pumpWidget(_wrap(
        MetricLineChart(
          data: _sampleData(type: MetricType.bodyFat),
          metricType: MetricType.bodyFat,
          period: AggregationPeriod.day,
        ),
      ));

      expect(find.text('%'), findsOneWidget);
    });

    testWidgets('displays unit label for calorie intake', (tester) async {
      await tester.pumpWidget(_wrap(
        MetricLineChart(
          data: _sampleData(type: MetricType.calorieIntake),
          metricType: MetricType.calorieIntake,
          period: AggregationPeriod.day,
        ),
      ));

      expect(find.text('kcal'), findsOneWidget);
    });

    testWidgets('renders chart with single data point', (tester) async {
      await tester.pumpWidget(_wrap(
        MetricLineChart(
          data: _sampleData(count: 1),
          metricType: MetricType.weight,
          period: AggregationPeriod.day,
        ),
      ));

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('shows stat selector with all options', (tester) async {
      await tester.pumpWidget(_wrap(
        MetricLineChart(
          data: _sampleData(),
          metricType: MetricType.weight,
          period: AggregationPeriod.day,
        ),
      ));

      expect(find.text('平均'), findsOneWidget);
      expect(find.text('中央値'), findsOneWidget);
      expect(find.text('最大'), findsOneWidget);
      expect(find.text('最小'), findsOneWidget);
    });

    testWidgets('switches stat type on tap', (tester) async {
      await tester.pumpWidget(_wrap(
        MetricLineChart(
          data: _sampleData(),
          metricType: MetricType.weight,
          period: AggregationPeriod.day,
        ),
      ));

      // Default is average, tap median
      await tester.tap(find.text('中央値'));
      await tester.pumpAndSettle();

      // Chart should still be rendered
      expect(find.byType(LineChart), findsOneWidget);
    });
  });
}
