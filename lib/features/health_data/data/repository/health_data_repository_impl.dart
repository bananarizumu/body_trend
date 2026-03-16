import '../../domain/entity/aggregated_health_data.dart';
import '../../domain/entity/aggregation_period.dart';
import '../../domain/entity/metric_type.dart';
import '../../domain/repository/health_data_repository.dart';
import '../../domain/service/period_grouper.dart';
import '../../domain/service/statistics_calculator.dart';
import '../datasource/health_data_source.dart';
import '../dto/health_record_dto.dart';
import '../mapper/health_record_mapper.dart';

class HealthDataRepositoryImpl implements HealthDataRepository {
  final HealthDataSource _dataSource;

  const HealthDataRepositoryImpl(this._dataSource);

  @override
  Future<bool> requestPermissions() => _dataSource.requestPermissions();

  @override
  Future<bool> hasPermissions() => _dataSource.hasPermissions();

  @override
  Future<List<AggregatedHealthData>> getAggregatedData({
    required MetricType metricType,
    required DateTime start,
    required DateTime end,
    required AggregationPeriod period,
  }) async {
    final dtos = await _fetchByType(metricType, start, end);
    final metrics = dtos.map(HealthRecordMapper.fromDto).toList();

    final grouped = PeriodGrouper.group(
      records: metrics,
      period: period,
      rangeStart: start,
      rangeEnd: end,
    );

    final results = <AggregatedHealthData>[];
    for (final entry in grouped.entries) {
      if (entry.value.isEmpty) continue;

      final periodEnd = PeriodGrouper.nextPeriod(entry.key, period);
      final stat = StatisticsCalculator.calculate(
        metricType: metricType,
        periodStart: entry.key,
        periodEnd: periodEnd,
        values: entry.value.map((m) => m.value).toList(),
      );
      if (stat != null) results.add(stat);
    }

    return results;
  }

  Future<List<HealthRecordDto>> _fetchByType(
    MetricType type,
    DateTime start,
    DateTime end,
  ) {
    return switch (type) {
      MetricType.weight => _dataSource.getWeightRecords(start, end),
      MetricType.bodyFat => _dataSource.getBodyFatRecords(start, end),
      MetricType.calorieIntake => _dataSource.getCalorieIntakeRecords(
        start,
        end,
      ),
    };
  }
}
