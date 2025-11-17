import '../../pair_plots/pair_plot_config.dart';
import '../data/heart_attack_data_model.dart';

/// Конфигурация pair plots для датасета о сердечных приступах.
class HeartAttackPairPlotConfig extends PairPlotConfig<HeartAttackDataModel> {
  @override
  List<PairPlotFeature> get features => [
        PairPlotFeature('Возраст vs Холестерин', 'age', 'cholesterol', divisorX: 1.0, divisorY: 1.0),
        PairPlotFeature('BMI vs Риск', 'bmi', 'heartAttackRisk', divisorX: 1.0, divisorY: 1.0),
        PairPlotFeature('Стресс vs Сон', 'stressLevel', 'sleepHoursPerDay', divisorX: 1.0, divisorY: 1.0),
        PairPlotFeature('Доход vs Активность', 'income', 'physicalActivityDaysPerWeek', divisorX: 1000.0, divisorY: 1.0),  // Доход в тыс.
      ];

  @override
  double? extractValue(HeartAttackDataModel data, String field) {
    return data.getNumericValue(field);
  }

  @override
  String formatValue(double value, String field) {
    if (field == 'income') return '${(value / 1000).toStringAsFixed(0)}k';  // Формат для дохода
    return value.toStringAsFixed(field == 'bmi' ? 1 : 0);
  }
}