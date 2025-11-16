import '../../histograms/histogram_config.dart';
import '../data/heart_attack_data_model.dart';

/// Конфигурация гистограмм для датасета о сердечных приступах.
class HeartAttackHistogramConfig extends HistogramConfig<HeartAttackDataModel> {
  @override
  List<HistogramFeature> get features => [
        HistogramFeature('Возраст', 'age', 1.0, 'лет'),
        HistogramFeature('Холестерин', 'cholesterol', 1.0, 'мг/дл'),
        HistogramFeature('Индекс массы тела (BMI)', 'bmi', 1.0, ''),
        HistogramFeature('Уровень стресса', 'stressLevel', 1.0, 'из 10'),
        HistogramFeature('Часы сна в день', 'sleepHoursPerDay', 1.0, 'ч'),
      ];

  @override
  double? extractValue(HeartAttackDataModel data, String field) {
    return data.getNumericValue(field);
  }

  @override
  String formatBinLabel(int binIndex, int totalBins, List<double> values) {
    if (values.isEmpty) return '';
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final binWidth = (max - min) / totalBins;
    final label = (min + binIndex * binWidth).toStringAsFixed(0);
    return '$label–${(min + (binIndex + 1) * binWidth).toStringAsFixed(0)}';
  }
}