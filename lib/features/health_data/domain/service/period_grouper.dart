import '../entity/aggregation_period.dart';
import '../entity/health_metric.dart';

class PeriodGrouper {
  static Map<DateTime, List<HealthMetric>> group({
    required List<HealthMetric> records,
    required AggregationPeriod period,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    final buckets = <DateTime, List<HealthMetric>>{};

    // Generate all bucket keys in the range
    var cursor = truncate(rangeStart, period);
    while (cursor.isBefore(rangeEnd)) {
      buckets[cursor] = [];
      cursor = nextPeriod(cursor, period);
    }

    // Place each record into its bucket
    for (final record in records) {
      final key = truncate(record.dateFrom, period);
      if (buckets.containsKey(key)) {
        buckets[key]!.add(record);
      }
    }

    return buckets;
  }

  static DateTime truncate(DateTime date, AggregationPeriod period) {
    switch (period) {
      case AggregationPeriod.day:
        return DateTime(date.year, date.month, date.day);
      case AggregationPeriod.week:
        // ISO week: Monday start
        final weekday = date.weekday; // 1=Monday, 7=Sunday
        final monday = date.subtract(Duration(days: weekday - 1));
        return DateTime(monday.year, monday.month, monday.day);
      case AggregationPeriod.month:
        return DateTime(date.year, date.month);
    }
  }

  static DateTime nextPeriod(DateTime date, AggregationPeriod period) {
    switch (period) {
      case AggregationPeriod.day:
        return date.add(const Duration(days: 1));
      case AggregationPeriod.week:
        return date.add(const Duration(days: 7));
      case AggregationPeriod.month:
        return DateTime(date.year, date.month + 1);
    }
  }
}
