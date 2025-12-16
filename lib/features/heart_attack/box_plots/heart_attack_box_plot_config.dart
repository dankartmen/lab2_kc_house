import '../../box_plots/box_plot_config.dart';
import '../data/heart_attack_data_model.dart';

/// Конфигурация box plots для датасета о сердечных приступах.
class HeartAttackBoxPlotConfig extends BoxPlotConfig<HeartAttackDataModel> {
  @override
  List<BoxPlotFeature> get features => [
        BoxPlotFeature('Возраст', 'age', groupBy: 'heartAttackRisk', divisor: 1.0),
        BoxPlotFeature('Индекс массы тела', 'bmi', groupBy: 'heartAttackRisk', divisor: 1.0),
        BoxPlotFeature('Холестерин', 'cholesterol', groupBy: 'heartAttackRisk', divisor: 1.0),
        BoxPlotFeature('Ежедневная физическая активность в течении недели', 'physicalActivityDaysPerWeek', groupBy: 'heartAttackRisk', divisor: 1.0),
        BoxPlotFeature('Сердечный ритм', 'heartRate', groupBy: 'heartAttackRisk', divisor: 1.0),
        BoxPlotFeature('Уровень стресса', 'stressLevel', groupBy: 'heartAttackRisk', divisor: 1.0),
        BoxPlotFeature('Триглицериды', 'triglycerides', groupBy: 'heartAttackRisk', divisor: 1.0),
        BoxPlotFeature('Часы сна в день', 'sleepHoursPerDay', groupBy: 'heartAttackRisk', divisor: 1.0),
        BoxPlotFeature('Уровень ежедневной сидячей нагрузки', 'sedentaryHoursPerDay', groupBy: 'heartAttackRisk', divisor: 1.0),
      ];

  @override
  double? extractValue(HeartAttackDataModel data, String field) {
    return data.getNumericValue(field);
  }

  @override
  String formatValue(double value, String field) {
    return field == 'bmi' || field == 'physicalActivity' 
        ? value.toStringAsFixed(1) 
        : value.toStringAsFixed(0);
  }
}