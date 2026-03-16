import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasource/health_connect_data_source.dart';
import '../../data/repository/health_data_repository_impl.dart';
import '../../domain/entity/aggregation_period.dart';
import '../../domain/entity/metric_type.dart';
import '../../domain/repository/health_data_repository.dart';
import '../../domain/usecase/get_aggregated_health_data.dart';
import '../state/aggregation_screen_state.dart';

final healthDataRepositoryProvider = Provider<HealthDataRepository>((ref) {
  return HealthDataRepositoryImpl(HealthConnectDataSource());
});

final getAggregatedHealthDataProvider = Provider<GetAggregatedHealthData>((
  ref,
) {
  return GetAggregatedHealthData(ref.watch(healthDataRepositoryProvider));
});

final aggregationScreenProvider =
    StateNotifierProvider<AggregationScreenNotifier, AggregationScreenState>((
  ref,
) {
  return AggregationScreenNotifier(
    ref.watch(getAggregatedHealthDataProvider),
    ref.watch(healthDataRepositoryProvider),
  );
});

class AggregationScreenNotifier extends StateNotifier<AggregationScreenState> {
  final GetAggregatedHealthData _getAggregatedHealthData;
  final HealthDataRepository _repository;

  MetricType _metricType = MetricType.weight;
  AggregationPeriod _period = AggregationPeriod.week;

  AggregationScreenNotifier(this._getAggregatedHealthData, this._repository)
      : super(const AggregationScreenLoading()) {
    load();
  }

  Future<void> load() async {
    state = const AggregationScreenLoading();
    try {
      final hasPerms = await _repository.hasPermissions();
      if (!hasPerms) {
        state = const AggregationScreenPermissionRequired();
        return;
      }
      await _fetchData();
    } on UnsupportedError catch (e) {
      state = AggregationScreenError(
        'Health Connectがこのデバイスでサポートされていません: ${e.message}',
      );
    } catch (e) {
      state = AggregationScreenError(e.toString());
    }
  }

  Future<void> requestPermissions() async {
    state = const AggregationScreenLoading();
    try {
      final granted = await _repository.requestPermissions();
      if (!granted) {
        state = const AggregationScreenPermissionRequired();
        return;
      }
      await _fetchData();
    } catch (e) {
      state = AggregationScreenError(e.toString());
    }
  }

  Future<void> _fetchData() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 90));
    final data = await _getAggregatedHealthData(
      metricType: _metricType,
      start: start,
      end: now,
      period: _period,
    );
    state = AggregationScreenSuccess(
      data: data,
      metricType: _metricType,
      period: _period,
    );
  }

  void selectMetricType(MetricType type) {
    _metricType = type;
    load();
  }

  void selectPeriod(AggregationPeriod period) {
    _period = period;
    load();
  }
}
