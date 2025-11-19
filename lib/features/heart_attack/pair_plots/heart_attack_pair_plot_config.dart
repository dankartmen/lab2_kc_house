
import 'package:flutter/material.dart';

import '../../pair_plots/grouped_pair_plot_config.dart';
import '../../pair_plots/pair_plot_config.dart';
import '../data/heart_attack_data_model.dart';

class HeartAttackPairPlotConfig extends GroupedHeartAttackPairPlotConfig {
  @override
  List<PairPlotFeature> get features => [
    PairPlotFeature('age', 'Возраст'),
    PairPlotFeature('cholesterol', 'Холестерин'),
    PairPlotFeature('bmi', 'ИМТ'),
    PairPlotFeature('income', 'Доход', divisor: 1000.0),
    PairPlotFeature('physicalActivityDaysPerWeek', 'Активность'),
    PairPlotFeature('stressLevel', 'Стресс'),
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
    // Окрашиваем точки по риску сердечного приступа
    if (colorField == 'heartAttackRisk') {
      return data.heartAttackRisk == 1 ? Colors.red : Colors.blue;
    }
    return null;
  }
}