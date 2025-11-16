import '../../../core/data/data_model.dart';
import '../../box_plots/box_plot_config.dart';
import '../data/heart_attack_data_model.dart';

/// Конфигурация box plots для датасета о сердечных приступах.
class HeartAttackBoxPlotConfig extends BoxPlotConfig<HeartAttackDataModel> {
  @override
  List<BoxPlotFeature> get features => [
        BoxPlotFeature('Возраст по полу', 'age', groupBy: 'sex', divisor: 1.0),
        BoxPlotFeature('BMI по континенту', 'bmi', groupBy: 'continent', divisor: 1.0),
        BoxPlotFeature('Холестерин', 'cholesterol', divisor: 1.0),
      ];

  @override
  double? extractValue(HeartAttackDataModel data, String field) {
    return data.getNumericValue(field);
  }

  @override
  String formatValue(double value, String field) {
    return field == 'bmi' ? value.toStringAsFixed(1) : value.toStringAsFixed(0);
  }
}