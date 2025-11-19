
import 'package:flutter/material.dart';

import '../heart_attack/data/heart_attack_data_model.dart';
import 'pair_plot_config.dart';

class GroupedHeartAttackPairPlotConfig extends PairPlotConfig<HeartAttackDataModel> {
  final List<PairPlotFeature> _features = [
    PairPlotFeature('age', 'Возраст'),
    PairPlotFeature('cholesterol', 'Холестерин'),
    PairPlotFeature('bmi', 'ИМТ'),
    PairPlotFeature('heartRate', 'Пульс'),
    PairPlotFeature('stressLevel', 'Стресс'),
    PairPlotFeature('sleepHoursPerDay', 'Сон (часы/день)'),
    PairPlotFeature('physicalActivityDaysPerWeek', 'Активность (дни/нед)'),
    PairPlotFeature('sedentaryHoursPerDay', 'Сидячий образ жизни'),
    PairPlotFeature('income', 'Доход', divisor: 1000.0),
    PairPlotFeature('exerciseHoursPerWeek', 'Спорт (часы/нед)'),
  ];

  @override
  List<PairPlotFeature> get features => _features;

  // Группы для табов
  List<PairPlotGroup> get groups => [
    PairPlotGroup(
      title: 'Биометрические показатели',
      features: [
        PairPlotFeature('age', 'Возраст'),
        PairPlotFeature('cholesterol', 'Холестерин'),
        PairPlotFeature('bmi', 'ИМТ'),
        PairPlotFeature('heartRate', 'Пульс'),
      ],
    ),
    PairPlotGroup(
      title: 'Образ жизни',
      features: [
        PairPlotFeature('stressLevel', 'Стресс'),
        PairPlotFeature('sleepHoursPerDay', 'Сон (часы/день)'),
        PairPlotFeature('physicalActivityDaysPerWeek', 'Активность (дни/нед)'),
        PairPlotFeature('sedentaryHoursPerDay', 'Сидячий образ жизни'),
      ],
    ),
    PairPlotGroup(
      title: 'Социально-экономические',
      features: [
        PairPlotFeature('income', 'Доход', divisor: 1000.0),
        PairPlotFeature('exerciseHoursPerWeek', 'Спорт (часы/нед)'),
        PairPlotFeature('bmi', 'ИМТ'),
      ],
    ),
  ];

  @override
  double? extractValue(HeartAttackDataModel data, String field) {
    return data.getNumericValue(field);
  }

  @override
  String formatValue(double value, String field) {
    if (field == 'income') return '${value.toStringAsFixed(0)}k';
    if (field == 'bmi') return value.toStringAsFixed(1);
    return value.toStringAsFixed(0);
  }
  
  @override
  Color? getPointColor(HeartAttackDataModel data, String colorField) {
    if (colorField == 'heartAttackRisk') {
      return data.heartAttackRisk == 1 ? Colors.red : Colors.blue;
    }
    return Colors.blue; // Цвет по умолчанию
  }
}

class PairPlotGroup {
  final String title;
  final List<PairPlotFeature> features;
  
  const PairPlotGroup({required this.title, required this.features});
}