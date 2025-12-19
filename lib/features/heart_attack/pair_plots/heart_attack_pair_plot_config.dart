import '../../pair_plots/pair_plot_config.dart';
import '../../heart_attack/data/heart_attack_data_model.dart';

/// {@template heart_attack_pair_plot_config}
/// Конфигурация диаграмм рассеяния для данных о рисках сердечных приступов.
/// {@endtemplate}
class HeartAttackPairPlotConfig extends PairPlotConfig<HeartAttackDataModel> {
  /// Основные числовые поля для анализа
  @override
  List<String> get numericFields => [
    'age',
    'cholesterol',
    'bmi',
    'heartRate',
    'stressLevel',
    'triglycerides',
  ];

  /// Группировка по риску сердечного приступа
  @override
  String? get hueField => 'heartAttackRisk';

  /// Используем расходящуюся палитру для контраста между группами риска
  @override
  ColorPalette? get palette => ColorPalette.diverging;

  /// Дополнительные настройки стиля
  PairPlotStyle get style => const PairPlotStyle(
    dotSize: 3.0,
    alpha: 0.7,
    showHistDiagonal: true,
    showKdeDiagonal: false,
    showCorrelation: true,
  );
}

/// Дополнительная конфигурация для всех числовых полей
class FullHeartAttackPairPlotConfig extends PairPlotConfig<HeartAttackDataModel> {
  @override
  List<String> get numericFields => [
    'age',
    'cholesterol',
    'bmi',
    'heartRate',
    'stressLevel',
    'triglycerides',
    'exerciseHoursPerWeek',
    'sedentaryHoursPerDay',
    'income',
    'physicalActivityDaysPerWeek',
    'sleepHoursPerDay',
    'heartAttackRisk', // Включаем целевую переменную
  ];

  @override
  String? get hueField => 'heartAttackRisk';

  @override
  ColorPalette? get palette => ColorPalette.categorical;
}

/// Конфигурация для анализа факторов образа жизни
class LifestylePairPlotConfig extends PairPlotConfig<HeartAttackDataModel> {
  @override
  List<String> get numericFields => [
    'exerciseHoursPerWeek',
    'sedentaryHoursPerDay',
    'sleepHoursPerDay',
    'stressLevel',
    'bmi',
    'alcoholConsumption', // Двоичная переменная как числовая
  ];

  @override
  String? get hueField => 'heartAttackRisk';

  @override
  ColorPalette? get palette => ColorPalette.categorical;

  String? get additionalInfo => '''
Анализ факторов образа жизни:
• Физическая активность (exerciseHoursPerWeek)
• Сидячий образ жизни (sedentaryHoursPerDay)
• Качество сна (sleepHoursPerDay)
• Уровень стресса (stressLevel)
• Индекс массы тела (bmi)
• Потребление алкоголя (alcoholConsumption)
''';
}

/// Конфигурация для биохимических показателей
class BiochemicalPairPlotConfig extends PairPlotConfig<HeartAttackDataModel> {
  @override
  List<String> get numericFields => [
    'cholesterol',
    'triglycerides',
    'bmi',
    'heartRate',
    'age',
    'heartAttackRisk',
  ];

  @override
  String? get hueField => 'heartAttackRisk';

  @override
  ColorPalette? get palette => ColorPalette.diverging;

  PairPlotStyle get style => const PairPlotStyle(
    dotSize: 4.0,
    alpha: 0.6,
    showHistDiagonal: true,
    showKdeDiagonal: true, // Показываем KDE для гладких распределений
    showCorrelation: true,
  );
}