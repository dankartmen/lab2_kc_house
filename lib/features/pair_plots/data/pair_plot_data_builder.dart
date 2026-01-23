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
  }) {
    final points = <ScatterPoint>[];
    final xs = <double>[];
    final ys = <double>[];

    for (int i = 0; i < dataset.rows.length; i++) {
      final row = dataset.rows[i];
      final xv = row[x.key];
      final yv = row[y.key];

      if (xv is! num || yv is! num) continue;

      final category =
          hue != null ? hue.parseCategory(row[hue.key]) : null;

      final color = (colorScale != null && category != null)
          ? colorScale.colorOf(category)
          : Colors.blue;

      final dx = xv.toDouble();
      final dy = yv.toDouble();

      points.add(
        ScatterPoint(
          x: dx,
          y: dy,
          rowIndex: i,
          category: category,
          color: color,
        ),
      );

      xs.add(dx);
      ys.add(dy);
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
