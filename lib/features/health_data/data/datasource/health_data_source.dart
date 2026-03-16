import '../dto/health_record_dto.dart';

abstract class HealthDataSource {
  Future<bool> requestPermissions();

  Future<bool> hasPermissions();

  Future<List<HealthRecordDto>> getWeightRecords(DateTime start, DateTime end);

  Future<List<HealthRecordDto>> getBodyFatRecords(DateTime start, DateTime end);

  Future<List<HealthRecordDto>> getCalorieIntakeRecords(
    DateTime start,
    DateTime end,
  );
}
