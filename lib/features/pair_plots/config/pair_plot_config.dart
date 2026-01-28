import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/pair_plots/config/pair_plot_style.dart';

import '../../../dataset/field_descriptor.dart';

/// {@template pair_plot_config}
/// Базовая конфигурация для парных диаграмм (Pair Plot).
///
/// Определяет:
/// - какие поля отображаются
/// - какое поле используется для группировки (hue)
/// - цветовую палитру
/// {@endtemplate}
class PairPlotConfig{
  /// {@macro pair_plot_config}
  const PairPlotConfig({
    required this.style, 
    required this.fields, 
  });

  /// Визуальный стиль
  final PairPlotStyle style;
  
  /// Поля, отображаемые в матрице
  final List<FieldDescriptor> fields;
}

/// Цветовые палитры для визуализации.
enum ColorPalette {
  /// Палитра по умолчанию.
  defaultPalette,

  /// Категориальная палитра.
  categorical,

  /// Последовательная палитра.
  sequential,

  /// Расходящаяся палитра.
  diverging;

  /// Возвращает список цветов для палитры.
  List<Color> get colors {
    switch (this) {
      case ColorPalette.defaultPalette:
        return const [
          Colors.blue,
          Colors.red,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.teal,
        ];
      case ColorPalette.categorical:
        return const [
          Colors.blue,
          Colors.red,
          Colors.green,
          Colors.orange,
          Colors.purple,
          Colors.teal,
          Colors.pink,
          Colors.brown,
        ];
      case ColorPalette.sequential:
        return [
          Colors.blue.shade100,
          Colors.blue.shade300,
          Colors.blue.shade500,
          Colors.blue.shade700,
          Colors.blue.shade900,
        ];
      case ColorPalette.diverging:
        return [
          Colors.blue.shade800,
          Colors.blue.shade400,
          Colors.grey.shade300,
          Colors.red.shade400,
          Colors.red.shade800,
        ];
    }
  }
}
