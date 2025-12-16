import 'dart:ui';

import '../../core/data/data_model.dart';

/// {@template pair_plot_config}
/// Конфигурация для матрицы парных диаграмм (pair plots).
/// {@endtemplate}
abstract class PairPlotConfig<T extends DataModel> {
  /// Список признаков для матрицы pair plots
  List<PairPlotFeature> get features;

  /// Извлекает значение для поля из объекта данных
  double? extractValue(T data, String field);

  /// Форматирует метку для осей
  String formatValue(double value, String field);
  
  /// Получает цвет точки на основе данных (для окрашивания по категориям)
  Color? getPointColor(T data, String colorField);
}

/// {@template pair_plot_feature}
/// Признак для pair plot матрицы
/// {@endtemplate}
class PairPlotFeature {
  /// Поле данных
  final String field;
  
  /// Отображаемое имя
  final String displayName;
  
  /// Делитель для значений
  final double divisor;

  /// {@macro pair_plot_feature}
  const PairPlotFeature(
    this.field,
    this.displayName, {
    this.divisor = 1.0,
  });

  
}
