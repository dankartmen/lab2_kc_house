import '../../histograms/histogram_config.dart';
import '../data/diabetes_risk_prediction_data_model.dart';

/// Конфигурация гистограмм для датасета о рисках диабета.
class DiabetesHistogramConfig extends HistogramConfig<DiabetesRiskPredictionDataModel> {
  @override
  List<HistogramFeature> get features => [
        HistogramFeature('Возраст', 'age', 1.0, 'лет', binCount: 20),
        HistogramFeature('Результат теста', 'result', 1.0, '', binCount: 2),
        HistogramFeature('Полиурия', 'polyuria', 1.0, '', binCount: 2),
        HistogramFeature('Полидипсия', 'polydipsia', 1.0, '', binCount: 2),
        HistogramFeature('Ожирение', 'obesity', 1.0, '', binCount: 2),
        HistogramFeature('Нечеткое зрение', 'visualBlurring', 1.0, '', binCount: 2),
        HistogramFeature('Замедленное заживление', 'delayedHealing', 1.0, '', binCount: 2),
      ];

  @override
  double? extractValue(DiabetesRiskPredictionDataModel data, String field) {
    if (field == 'age') {
      return data.getNumericValue(field);
    }
    return data.getBinaryValue(field);
  }

  String formatValue(double value, String field) {
    return field == 'age' 
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
  }

  String formatLabel(double value, String field) {    
    // Для бинарных полей показываем текстовые метки
    if (value == 0.0) {
      return field == 'result' ? 'Negative' : 'No';
    } else if (value == 1.0) {
      return field == 'result' ? 'Positive' : 'Yes';
    }
    return value.toString();
  }
}