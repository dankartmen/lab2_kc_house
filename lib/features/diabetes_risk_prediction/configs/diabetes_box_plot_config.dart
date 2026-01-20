import '../../box_plots/box_plot_config.dart';
import '../data/diabetes_risk_prediction_data_model.dart';

/// Конфигурация box plots для датасета о рисках диабета.
class DiabetesBoxPlotConfig extends BoxPlotConfig<DiabetesRiskPredictionDataModel> {
  @override
  List<BoxPlotFeature> get features => [
        BoxPlotFeature('Возраст', 'age', groupBy: 'result', divisor: 1.0),
        BoxPlotFeature('Пол', 'gender', groupBy: 'result', divisor: 1.0),
        BoxPlotFeature('Полиурия', 'polyuria', groupBy: 'result', divisor: 1.0),
        BoxPlotFeature('Полидипсия', 'polydipsia', groupBy: 'result', divisor: 1.0),
        BoxPlotFeature('Внезапная потеря веса', 'suddenWeightLoss', groupBy: 'result', divisor: 1.0),
        BoxPlotFeature('Слабость', 'weakness', groupBy: 'result', divisor: 1.0),
        BoxPlotFeature('Полифагия', 'polyphagia', groupBy: 'result', divisor: 1.0),
        BoxPlotFeature('Ожирение', 'obesity', groupBy: 'result', divisor: 1.0),
      ];

  @override
  double? extractValue(DiabetesRiskPredictionDataModel data, String field) {
    final numericValue = data.getNumericValue(field);
    if (numericValue != null) return numericValue;
    return data.getBinaryValue(field);
  }

  @override
  String formatValue(double value, String field) {
    return value.toStringAsFixed(1);
  }
}