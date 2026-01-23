import 'package:flutter/material.dart';

import '../../../dataset/dataset.dart';
import '../../../dataset/field_descriptor.dart';
import '../scales/categorical_color_scale.dart';
import '../utils/statistics_utils.dart';
import 'scatter_data.dart';

class PairPlotDataBuilder {
  static ScatterData buildScatter({
    required Dataset dataset,
    required FieldDescriptor x,
    required FieldDescriptor y,
    FieldDescriptor? hue,
    CategoricalColorScale? colorScale,
    bool computeCorrelation = true,
    List<double>? cachedXValues,
    List<double>? cachedYValues,
    List<String>? cachedHueValues,
  }) {
    final points = <ScatterPoint>[];
    final xs = <double>[];
    final ys = <double>[];

    // Используем кэшированные значения или вычисляем их
    final xValues = cachedXValues ?? dataset.rows
        .map((r) => r[x.key])
        .whereType<num>()
        .map((e) => e.toDouble())
        .toList();
    
    final yValues = cachedYValues ?? dataset.rows
        .map((r) => r[y.key])
        .whereType<num>()
        .map((e) => e.toDouble())
        .toList();
    
    List<String?>? hueValues;
    if (hue != null) {
      hueValues = cachedHueValues ?? dataset.rows
          .map((r) => r[hue.key])
          .map((v) => hue.parseCategory(v))
          .toList();
    }

    for (int i = 0; i < dataset.rows.length; i++) {
      if (i >= xValues.length || i >= yValues.length) continue;
      
      final xv = xValues[i];
      final yv = yValues[i];
      
      final category = (hue != null && hueValues != null && i < hueValues.length)
          ? hueValues[i]
          : null;

      final color = (colorScale != null && category != null)
          ? colorScale.colorOf(category)
          : Colors.blue;

      points.add(
        ScatterPoint(
          x: xv,
          y: yv,
          rowIndex: i,
          category: category,
          color: color,
        ),
      );

      xs.add(xv);
      ys.add(yv);
    }

    final correlation = (computeCorrelation && xs.length > 2)
        ? StatisticsUtils.pearsonCorrelation(xs, ys)
        : null;

    return ScatterData(
      points: points,
      correlation: correlation,
    );
  }
}