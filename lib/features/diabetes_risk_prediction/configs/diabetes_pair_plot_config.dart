import '../../pair_plots/pair_plot_config.dart';
import '../data/diabetes_risk_prediction_data_model.dart';

/// {@template diabetes_pair_plot_config}
/// Конфигурация диаграмм рассеяния для данных о рисках диабета.
/// {@endtemplate}
class DiabetesPairPlotConfig extends PairPlotConfig<DiabetesRiskPredictionDataModel> {
  /// Основные поля для анализа
  @override
  List<String> get numericFields => [
    'age',
    'result', // Результат как числовая переменная (Positive/Negative -> 1/0)
  ];

  /// Группировка по результату теста
  @override
  String? get hueField => 'result';

  /// Используем расходящуюся палитру для контраста
  @override
  ColorPalette? get palette => ColorPalette.diverging;

  /// Дополнительные настройки стиля
  PairPlotStyle get style => const PairPlotStyle(
    dotSize: 4.0,
    alpha: 0.7,
    showHistDiagonal: true,
    showKdeDiagonal: false,
    showCorrelation: true,
    maxPoints: 1000,
  );
}

/// Конфигурация для анализа всех симптомов
class SymptomsPairPlotConfig extends PairPlotConfig<DiabetesRiskPredictionDataModel> {
  @override
  List<String> get numericFields => [
    'age',
    'polyuria',
    'polydipsia',
    'suddenWeightLoss',
    'weakness',
    'polyphagia',
    'obesity',
    'result',
  ];

  @override
  String? get hueField => 'result';

  @override
  ColorPalette? get palette => ColorPalette.categorical;

  String? get additionalInfo => '''
Анализ симптомов диабета:
• Возраст (age)
• Полиурия (polyuria)
• Полидипсия (polydipsia)
• Внезапная потеря веса (suddenWeightLoss)
• Слабость (weakness)
• Полифагия (polyphagia)
• Ожирение (obesity)
• Результат теста (result)
''';
}

/// Конфигурация для анализа всех бинарных симптомов
class AllSymptomsPairPlotConfig extends PairPlotConfig<DiabetesRiskPredictionDataModel> {
  @override
  List<String> get numericFields {
    // Используем все бинарные поля для анализа
    return [
      'age',
      'polyuria',
      'polydipsia',
      'suddenWeightLoss',
      'weakness',
      'polyphagia',
      'genitalThrush',
      'visualBlurring',
      'itching',
      'irritability',
      'delayedHealing',
      'partialParesis',
      'muscleStiffness',
      'alopecia',
      'obesity',
      'result',
    ];
  }

  @override
  String? get hueField => 'result';

  @override
  ColorPalette? get palette => ColorPalette.categorical;
}
