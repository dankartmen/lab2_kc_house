import '../../dataset/dataset.dart';
import '../../dataset/field_descriptor.dart';

class FieldStatistics {
  final double? min;
  final double? max;
  final double? mean;
  final int count;

  const FieldStatistics({
    this.min,
    this.max,
    this.mean,
    required this.count,
  });
}

class BIAnalyticsService {
  final Dataset dataset;

  BIAnalyticsService(this.dataset);

  FieldStatistics numericStats(FieldDescriptor field) {
    final values = dataset
        .column(field.key)
        .whereType<num>()
        .map((e) => e.toDouble())
        .toList();

    if (values.isEmpty) {
      return const FieldStatistics(count: 0);
    }

    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final mean = values.reduce((a, b) => a + b) / values.length;

    return FieldStatistics(
      min: min,
      max: max,
      mean: mean,
      count: values.length,
    );
  }
}
