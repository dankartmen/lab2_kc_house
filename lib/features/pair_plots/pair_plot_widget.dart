import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/data/data_model.dart';
import '../../core/data/field_descriptor.dart';
import 'pair_plot_config.dart';
import 'pair_plot_style.dart';

/// {@template pair_plot}
/// Виджет для отображения матрицы парных диаграмм (Pair Plot).
///
/// Использует [FieldDescriptor] для:
/// - корректной интерпретации типов данных
/// - безопасной цветовой группировки
/// - отображения подписей осей
/// {@endtemplate}
class PairPlot<T extends DataModel> extends StatelessWidget {
  /// Набор данных.
  final List<T> data;

  /// Конфигурация диаграммы.
  final PairPlotConfig<T> config;

  /// Заголовок.
  final String title;

  /// Стиль отображения.
  final PairPlotStyle style;

  /// Размер одной ячейки.
  final Size cellSize;

  /// {@macro pair_plot}
  const PairPlot({
    super.key,
    required this.data,
    required this.config,
    required this.title,
    this.style = const PairPlotStyle(),
    this.cellSize = const Size(180, 180),
  });

  @override
  Widget build(BuildContext context) {
    final fields = config.fields;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildMatrix(fields),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrix(List<FieldDescriptor> fields) {
    final n = fields.length;

    return Column(
      children: List.generate(n, (row) {
        return Row(
          children: List.generate(n, (col) {
            final x = fields[col];
            final y = fields[row];

            return _buildCell(
              x: x,
              y: y,
              isDiagonal: row == col,
            );
          }),
        );
      }),
    );
  }

  Widget _buildCell({
    required FieldDescriptor x,
    required FieldDescriptor y,
    required bool isDiagonal,
  }) {
    return Container(
      width: cellSize.width,
      height: cellSize.height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: isDiagonal
          ? _buildDiagonalPlot(x)
          : _buildScatterPlot(x, y),
    );
  }

  Widget _buildDiagonalPlot(FieldDescriptor field) {
    if (!style.showHistDiagonal ||
        field.type == FieldType.categorical) {
      return _empty('—');
    }

    final values = _numericValues(field);

    if (values.isEmpty) {
      return _empty('Нет данных');
    }

    return CustomPaint(
      painter: _HistogramPainter(
        values: values,
        label: field.label,
      ),
    );
  }

  Widget _buildScatterPlot(
    FieldDescriptor x,
    FieldDescriptor y,
  ) {
    if (x.type == FieldType.categorical ||
        y.type == FieldType.categorical) {
      return _empty('N/A');
    }

    final points = _points(x, y);
    if (points.isEmpty) {
      return _empty('Нет данных');
    }

    return CustomPaint(
      painter: _ScatterPainter(
        points: points,
        xLabel: x.label,
        yLabel: y.label,
        hue: config.hue,
        palette: config.palette,
        style: style,
      ),
    );
  }

  Widget _empty(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
        ),
      ),
    );
  }

  List<double> _numericValues(FieldDescriptor field) {
    return data
        .map((e) => e.getNumericValue(field.key))
        .whereType<double>()
        .toList();
  }

  List<_PlotPoint> _points(
    FieldDescriptor x,
    FieldDescriptor y,
  ) {
    final result = <_PlotPoint>[];

    for (final item in data) {
      final xv = item.getNumericValue(x.key);
      final yv = item.getNumericValue(y.key);

      if (xv == null || yv == null) continue;

      result.add(
        _PlotPoint(
          x: xv,
          y: yv,
          hue: config.hue != null
              ? item.getCategoricalValue(config.hue!.key)
              : null,
        ),
      );
    }

    if (result.length > style.maxPoints) {
      final step = result.length / style.maxPoints;
      return List.generate(
        style.maxPoints,
        (i) => result[(i * step).floor()],
      );
    }

    return result;
  }
}

/// Внутренняя модель точки.
class _PlotPoint {
  final double x;
  final double y;
  final String? hue;

  const _PlotPoint({
    required this.x,
    required this.y,
    this.hue,
  });
}

class _HistogramPainter extends CustomPainter {
  final List<double> values;
  final String label;

  _HistogramPainter({
    required this.values,
    required this.label,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minV = values.reduce(min);
    final maxV = values.reduce(max);
    final bins = 10;
    final counts = List<int>.filled(bins, 0);

    for (final v in values) {
      final i = ((v - minV) / (maxV - minV) * (bins - 1))
          .clamp(0, bins - 1)
          .toInt();
      counts[i]++;
    }

    final maxCount = counts.reduce(max).toDouble();
    final barWidth = size.width / bins;

    final paint = Paint()..color = Colors.blue.withOpacity(0.6);

    for (int i = 0; i < bins; i++) {
      final h = counts[i] / maxCount * size.height;
      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth,
          size.height - h,
          barWidth * 0.9,
          h,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HistogramPainter old) =>
      values != old.values;
}

class _ScatterPainter extends CustomPainter {
  final List<_PlotPoint> points;
  final String xLabel;
  final String yLabel;
  final FieldDescriptor? hue;
  final ColorPalette? palette;
  final PairPlotStyle style;

  _ScatterPainter({
    required this.points,
    required this.xLabel,
    required this.yLabel,
    required this.hue,
    required this.palette,
    required this.style,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final xs = points.map((e) => e.x).toList();
    final ys = points.map((e) => e.y).toList();

    final xMin = xs.reduce(min);
    final xMax = xs.reduce(max);
    final yMin = ys.reduce(min);
    final yMax = ys.reduce(max);

    Offset map(double x, double y) => Offset(
          (x - xMin) / (xMax - xMin) * size.width,
          size.height -
              (y - yMin) / (yMax - yMin) * size.height,
        );

    for (final p in points) {
      final paint = Paint()
        ..color = Colors.blue.withOpacity(style.alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        map(p.x, p.y),
        style.dotSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScatterPainter old) =>
      points != old.points;
}
