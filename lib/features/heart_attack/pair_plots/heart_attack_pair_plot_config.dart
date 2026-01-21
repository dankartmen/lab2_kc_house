import 'package:lab2_kc_house/core/data/field_descriptor.dart';

import '../../pair_plots/pair_plot_config.dart';
import '../../heart_attack/data/heart_attack_data_model.dart';
import '../../pair_plots/pair_plot_style.dart';

/// {@template heart_attack_pair_plot_config}
/// Конфигурация диаграмм рассеяния для данных о рисках сердечных приступов.
/// {@endtemplate}
class HeartAttackPairPlotConfig extends PairPlotConfig<HeartAttackDataModel> {


  /// Используем расходящуюся палитру для контраста между группами риска
  @override
  ColorPalette? get palette => ColorPalette.categorical;

  /// Дополнительные настройки стиля
  PairPlotStyle get style => const PairPlotStyle(
    dotSize: 3.0,
    alpha: 0.7,
    showHistDiagonal: true,
    showCorrelation: true,
    simplified: true, 
    maxPoints: 1000,
  );

  @override
  List<FieldDescriptor> get fields => [
    FieldDescriptor(
      key: 'age',
      label: 'Возраст',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'cholesterol',
      label: 'Холестерин',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'bmi',
      label: 'ИМТ',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'heartRate',
      label: 'ЧСС',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'stressLevel',
      label: 'Уровень стресса',
      type: FieldType.continuous,
    ),
    FieldDescriptor(
      key: 'triglycerides',
      label: 'Триглицериды',
      type: FieldType.continuous,
    ),
  ];

  @override
  FieldDescriptor? get hue => FieldDescriptor.binary(
    key: 'heartAttackRisk',
    label: 'Риск сердечного приступа',
  );
}

/// Дополнительная конфигурация для всех числовых полей
class FullHeartAttackPairPlotConfig extends PairPlotConfig<HeartAttackDataModel> {

  @override
  ColorPalette? get palette => ColorPalette.categorical;
  
  @override
  List<FieldDescriptor> get fields => [
    FieldDescriptor.numeric(
      key: 'age',
      label: 'Возраст',
    ),
    FieldDescriptor.numeric(
      key: 'cholesterol',
      label: 'Холестерин',
    ),
    FieldDescriptor.numeric(
      key: 'bmi',
      label: 'ИМТ',
    ),
    FieldDescriptor.numeric(
      key: 'heartRate',
      label: 'ЧСС',
    ),
    FieldDescriptor.numeric(
      key: 'stressLevel',
      label: 'Уровень стресса',
    ),
    FieldDescriptor.numeric(
      key: 'triglycerides',
      label: 'Триглицериды',
    ),

  ];
  
  @override
  FieldDescriptor? get hue => FieldDescriptor.numeric(
    key: 'heartAttackRisk',
    label: 'Риск сердечного приступа',
  );
}

/// Конфигурация для анализа факторов образа жизни
class LifestylePairPlotConfig extends PairPlotConfig<HeartAttackDataModel> {

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

  @override
  List<FieldDescriptor> get fields => [
    FieldDescriptor.numeric(
      key: 'exerciseHoursPerWeek',
      label: 'Часы упражнений в неделю',
    ),
    FieldDescriptor.numeric(
      key: 'sedentaryHoursPerDay',
      label: 'Сидячие часы в день',
    ),
    FieldDescriptor.numeric(
      key: 'sleepHoursPerDay',
      label: 'Часы сна в день',
    ),
    FieldDescriptor.numeric(
      key: 'stressLevel',
      label: 'Уровень стресса',
    ),
    FieldDescriptor.numeric(
      key: 'bmi',
      label: 'ИМТ',
    ),
    FieldDescriptor.numeric(
      key: 'alcoholConsumption',
      label: 'Потребление алкоголя',
    ),
  ];

  @override
  FieldDescriptor? get hue => FieldDescriptor.numeric(
    key: 'heartAttackRisk',
    label: 'Риск сердечного приступа',
  );
}

/// Конфигурация для биохимических показателей
class BiochemicalPairPlotConfig extends PairPlotConfig<HeartAttackDataModel> {

  @override

  @override
  ColorPalette? get palette => ColorPalette.diverging;

  PairPlotStyle get style => const PairPlotStyle(
    dotSize: 4.0,
    alpha: 0.6,
    showHistDiagonal: true,
    showCorrelation: true,
  );
  
  @override
  List<FieldDescriptor> get fields => [
    FieldDescriptor.numeric(
      key: 'cholesterol',
      label: 'Холестерин',
    ),
    FieldDescriptor.numeric(
      key: 'triglycerides',
      label: 'Триглицериды',
    ),
    FieldDescriptor.numeric(
      key: 'heartRate',
      label: 'ЧСС',
    ),
  ] ;
  
  @override
  FieldDescriptor? get hue => FieldDescriptor.numeric(
    key: 'heartAttackRisk',
    label: 'Риск сердечного приступа',
  );
}