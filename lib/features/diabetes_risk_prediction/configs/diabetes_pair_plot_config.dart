import '../../../core/data/field_descriptor.dart';
import '../../pair_plots/pair_plot_config.dart';
import '../../pair_plots/pair_plot_style.dart';
import '../data/diabetes_risk_prediction_data_model.dart';

/// {@template diabetes_pair_plot_config}
/// Конфигурация диаграмм рассеяния для данных о рисках диабета.
/// {@endtemplate}
class DiabetesPairPlotConfig extends PairPlotConfig<DiabetesRiskPredictionDataModel> {
  @override
  List<FieldDescriptor> get fields => [
    FieldDescriptor(
      key: 'age',
      label: 'Возраст',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'result',
      label: 'Результат теста',
      type: FieldType.continuous,
    ),
  ];

  @override
  FieldDescriptor? get hue => FieldDescriptor(
    key: 'result',
    label: 'Результат теста',
    type: FieldType.categorical,
  );

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
  List<FieldDescriptor> get fields => [
    FieldDescriptor(
      key: 'age',
      label: 'Возраст',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'polyuria',
      label: 'Полиурия',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'polydipsia',
      label: 'Полидипсия',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'suddenWeightLoss',
      label: 'Внезапная потеря веса',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'weakness',
      label: 'Слабость',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'polyphagia',
      label: 'Полифагия',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'obesity',
      label: 'Ожирение',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'result',
      label: 'Результат теста',
      type: FieldType.continuous,
    ),
  ];

  @override
  FieldDescriptor? get hue => FieldDescriptor(
    key: 'result',
    label: 'Результат теста',
    type: FieldType.categorical,
  );

  @override
  ColorPalette? get palette => ColorPalette.categorical;
}