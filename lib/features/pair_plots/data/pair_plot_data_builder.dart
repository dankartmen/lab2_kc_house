import 'dart:math';

import 'package:flutter/material.dart';

import '../../../dataset/dataset.dart';
import '../../../dataset/field_descriptor.dart';
import '../scales/categorical_color_scale.dart';
import 'scatter_data.dart';

class PairPlotDataBuilder {
  static ScatterData buildScatter({
    required Dataset dataset,
    required FieldDescriptor x,
    required FieldDescriptor y,
    FieldDescriptor? hue,
    CategoricalColorScale? colorScale,
    bool needToComputeCorrelation = true,
    List<double>? cachedXValues,
    List<double>? cachedYValues,
    List<String?>? cachedHueValues,
    List<double>? cachedJitter,
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
    
    for (int i = 0; i < dataset.rows.length; i++) {
      if (i >= xValues.length || i >= yValues.length) continue;
      final row = dataset.rows[i];
      final xv = xValues[i];
      final yv = yValues[i];
      
      final category = hue?.parseCategory(row[hue.key]);

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

    final correlation = (needToComputeCorrelation && xs.length > 2)
        ? computeCorrelation(xs, ys)
        : null;

    return ScatterData(
      points: points,
      correlation: correlation,
    );
  }

  static double computeCorrelation(
    List<double> x,
    List<double> y, {
    int? sample,
  }) {
    final n = min(x.length, y.length);
    if (n < 2) return 0.0;

    final effectiveN = sample != null ? min(sample, n) : n;
    final step = n / effectiveN;

    double sumX = 0, sumY = 0, sumXY = 0;
    double sumX2 = 0, sumY2 = 0;

    for (int i = 0; i < effectiveN; i++) {
      final index = (i * step).round().clamp(0, n - 1);
      final xi = x[index];
      final yi = y[index];

      sumX += xi;
      sumY += yi;
      sumXY += xi * yi;
      sumX2 += xi * xi;
      sumY2 += yi * yi;
    }

    final numerator = effectiveN * sumXY - sumX * sumY;
    final denominator = sqrt(
      (effectiveN * sumX2 - sumX * sumX) *
      (effectiveN * sumY2 - sumY * sumY),
    );

    return denominator == 0 ? 0.0 : numerator / denominator;
  }

}