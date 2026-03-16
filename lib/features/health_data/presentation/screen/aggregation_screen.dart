import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entity/aggregated_health_data.dart';
import '../../domain/entity/aggregation_period.dart';
import '../../domain/entity/metric_type.dart';
import '../provider/aggregation_providers.dart';
import '../state/aggregation_screen_state.dart';
import '../widget/metric_line_chart.dart';

class AggregationScreen extends ConsumerWidget {
  const AggregationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aggregationScreenProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Body Trend')),
      body: switch (state) {
        AggregationScreenLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        AggregationScreenPermissionRequired() => _buildPermissionRequired(
          context,
          ref,
        ),
        AggregationScreenError(:final message) => _buildError(
          context,
          ref,
          message,
        ),
        AggregationScreenSuccess(
          :final data,
          :final metricType,
          :final period,
        ) =>
          _buildSuccess(context, ref, data, metricType, period),
      },
    );
  }

  Widget _buildPermissionRequired(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.health_and_safety, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Health Connectのデータにアクセスするには\n権限の許可が必要です',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref
                  .read(aggregationScreenProvider.notifier)
                  .requestPermissions(),
              child: const Text('権限を許可する'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () =>
                  ref.read(aggregationScreenProvider.notifier).load(),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(
    BuildContext context,
    WidgetRef ref,
    List<AggregatedHealthData> data,
    MetricType metricType,
    AggregationPeriod period,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<MetricType>(
            segments: const [
              ButtonSegment(value: MetricType.weight, label: Text('体重')),
              ButtonSegment(value: MetricType.bodyFat, label: Text('体脂肪率')),
              ButtonSegment(
                value: MetricType.calorieIntake,
                label: Text('カロリー'),
              ),
            ],
            selected: {metricType},
            onSelectionChanged: (selected) {
              ref
                  .read(aggregationScreenProvider.notifier)
                  .selectMetricType(selected.first);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<AggregationPeriod>(
            segments: const [
              ButtonSegment(value: AggregationPeriod.day, label: Text('日')),
              ButtonSegment(value: AggregationPeriod.week, label: Text('週')),
              ButtonSegment(value: AggregationPeriod.month, label: Text('月')),
            ],
            selected: {period},
            onSelectionChanged: (selected) {
              ref
                  .read(aggregationScreenProvider.notifier)
                  .selectPeriod(selected.first);
            },
          ),
        ),
        const SizedBox(height: 8),
        MetricLineChart(
          data: data,
          metricType: metricType,
          period: period,
        ),
        const Divider(height: 1),
        Expanded(
          child: data.isEmpty
              ? const SizedBox.shrink()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) =>
                      _buildDataItem(context, data[index], metricType),
                ),
        ),
      ],
    );
  }

  Widget _buildDataItem(
    BuildContext context,
    AggregatedHealthData item,
    MetricType metricType,
  ) {
    final unit = _unitFor(metricType);
    final dateRange = _formatDateRange(item.periodStart, item.periodEnd);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateRange, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              _statChip('平均', item.average, unit),
              _statChip('中央値', item.median, unit),
              _statChip('最大', item.max, unit),
              _statChip('最小', item.min, unit),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${item.sampleCount}件のデータ',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, double value, String unit) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(
            '${value.toStringAsFixed(1)}$unit',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _unitFor(MetricType type) {
    return switch (type) {
      MetricType.weight => 'kg',
      MetricType.bodyFat => '%',
      MetricType.calorieIntake => 'kcal',
    };
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final s = '${start.month}/${start.day}';
    final e = '${end.month}/${end.day}';
    return '$s - $e';
  }
}
