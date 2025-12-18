import '../../histograms/histogram_config.dart';
import '../data/heart_attack_data_model.dart';

/// Конфигурация гистограмм для датасета о сердечных приступах.
class HeartAttackHistogramConfig extends HistogramConfig<HeartAttackDataModel> {
  @override
  List<HistogramFeature> get features => [
        HistogramFeature('Возраст', 'age', 1.0, 'лет', binCount: 24),
        HistogramFeature('Холестерин', 'cholesterol', 1.0, 'мг/дл', binCount: 12),
        HistogramFeature('Индекс массы тела', 'bmi', 1.0, 'кг/м²', binCount: 10),
        HistogramFeature('Уровень стресса', 'stressLevel', 1.0, 'из 10', binCount: 10),
        HistogramFeature('Часы сна', 'sleepHoursPerDay', 1.0, 'ч', binCount: 8),
        HistogramFeature('Частота сердцебиения', 'heartRate', 1, 'уд/мин', binCount: 10),
        HistogramFeature('Физическая активность', 'physicalActivity', 1.0, 'ч/нед', binCount: 10),
      ];

  @override
  double? extractValue(HeartAttackDataModel data, String field) {
    return data.getNumericValue(field);
  }

  String formatValue(double value, String field) {
    // Форматирование для отображения значений
    return field == 'bmi' || field == 'physicalActivity'
        ? value.toStringAsFixed(1)
        : value.toStringAsFixed(0);
  }
}