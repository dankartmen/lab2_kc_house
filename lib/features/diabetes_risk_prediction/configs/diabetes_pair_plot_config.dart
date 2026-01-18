import '../../../core/data/field_descriptor.dart';
import '../../pair_plots/pair_plot_config.dart';
import '../../pair_plots/pair_plot_style.dart';
import '../data/diabetes_risk_prediction_data_model.dart';

/// {@template diabetes_pair_plot_config}
/// Конфигурация диаграмм рассеяния для данных о рисках диабета.
/// {@endtemplate}
class DiabetesPairPlotConfig extends PairPlotConfig<DiabetesRiskPredictionDataModel> {
  @override
  List<FieldDescriptor> get numericFields => [
    FieldDescriptor.numeric('age', label: 'Возраст'),
    FieldDescriptor.numeric('result', label: 'Результат теста'),
  ];

  @override
  FieldDescriptor? get hue => FieldDescriptor.categorical('result', label: 'Результат теста');

  @override
  ColorPalette? get palette => ColorPalette.diverging;

  PairPlotStyle get style => const PairPlotStyle(
    dotSize: 4.0,
    alpha: 0.7,
    showHistDiagonal: true,
    showCorrelation: true,
    maxPoints: 1000,
  );
}

/// Конфигурация для анализа всех симптомов
class SymptomsPairPlotConfig extends PairPlotConfig<DiabetesRiskPredictionDataModel> {
  @override
  List<FieldDescriptor> get numericFields => [
    FieldDescriptor.numeric('age', label: 'Возраст'),
    FieldDescriptor.numeric('polyuria', label: 'Полиурия'),
    FieldDescriptor.numeric('polydipsia', label: 'Полидипсия'),
    FieldDescriptor.numeric('suddenWeightLoss', label: 'Внезапная потеря веса'),
    FieldDescriptor.numeric('weakness', label: 'Слабость'),
    FieldDescriptor.numeric('polyphagia', label: 'Полифагия'),
    FieldDescriptor.numeric('obesity', label: 'Ожирение'),
    FieldDescriptor.numeric('result', label: 'Результат теста'),
  ];

  @override
  FieldDescriptor? get hue => FieldDescriptor.categorical('result', label: 'Результат теста');

  @override
  ColorPalette? get palette => ColorPalette.categorical;
}
