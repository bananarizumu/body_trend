import 'package:health/health.dart';

import '../dto/health_record_dto.dart';
import 'health_data_source.dart';

class HealthConnectDataSource implements HealthDataSource {
  final Health _health;
  bool _configured = false;

  HealthConnectDataSource({Health? health}) : _health = health ?? Health();

  static const _requiredTypes = [
    HealthDataType.WEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,
    HealthDataType.NUTRITION,
  ];

  static const _readPermissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<void> _ensureConfigured() async {
    if (!_configured) {
      await _health.configure();
      _configured = true;
    }
  }

  @override
  Future<bool> requestPermissions() async {
    await _ensureConfigured();
    return _health.requestAuthorization(
      _requiredTypes,
      permissions: _readPermissions,
    );
  }

  @override
  Future<bool> hasPermissions() async {
    await _ensureConfigured();
    return await _health.hasPermissions(_requiredTypes) ?? false;
  }

  @override
  Future<List<HealthRecordDto>> getWeightRecords(DateTime start, DateTime end) {
    return _fetchRecords(start, end, [HealthDataType.WEIGHT]);
  }

  @override
  Future<List<HealthRecordDto>> getBodyFatRecords(
    DateTime start,
    DateTime end,
  ) {
    return _fetchRecords(start, end, [HealthDataType.BODY_FAT_PERCENTAGE]);
  }

  @override
  Future<List<HealthRecordDto>> getCalorieIntakeRecords(
    DateTime start,
    DateTime end,
  ) {
    return _fetchRecords(start, end, [HealthDataType.NUTRITION]);
  }

  Future<List<HealthRecordDto>> _fetchRecords(
    DateTime start,
    DateTime end,
    List<HealthDataType> types,
  ) async {
    await _ensureConfigured();
    final dataPoints = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: end,
      types: types,
    );
    return dataPoints
        .map((point) => HealthRecordDto.fromHealthDataPoint(point))
        .toList();
  }
}
