import 'package:flutter/material.dart';

import '../../dataset/dataset.dart';
import '../../dataset/field_descriptor.dart';
import 'data/pair_plot_data_builder.dart';
import 'data/scatter_data.dart';
import 'layout/scatter_layout.dart';
import 'painters/scatter_painter.dart';
import 'pair_plot_config.dart';
import 'plot_mapper.dart';
import 'scales/categorical_color_scale.dart';

class PairPlotCell extends StatelessWidget {
  final Dataset dataset;
  final FieldDescriptor x;
  final FieldDescriptor y;
  final PairPlotConfig config;

  const PairPlotCell({
    required this.dataset,
    required this.x,
    required this.y,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    //  Строим color scale, если есть hue
    final colorScale = _buildColorScale();

    //  Готовим scatter data
    final scatterData = PairPlotDataBuilder.buildScatter(
      dataset: dataset,
      x: x,
      y: y,
      hue: config.hue,
      colorScale: colorScale,
      computeCorrelation: config.style.showCorrelation,
    );

    if (scatterData.points.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = _buildLayout(scatterData);

        final mapper = PlotMapper(
          plotRect: Rect.fromLTWH(
            8,
            8,
            constraints.maxWidth - 16,
            constraints.maxHeight - 16,
          ),
          xMin: layout.xMin,
          xMax: layout.xMax,
          yMin: layout.yMin,
          yMax: layout.yMax,
        );

        return CustomPaint(
          painter: ScatterPainter(
            data: scatterData,
            mapper: mapper,
            dotSize: config.style.dotSize,
            alpha: config.style.alpha,
            showCorrelation: config.style.showCorrelation,
          ),
        );
      },
    );
  }

  CategoricalColorScale? _buildColorScale() {
    final hue = config.hue;
    final palette = config.palette;

    if (hue == null || palette == null) return null;

    final values = dataset.rows
        .map((row) => row[hue.key])
        .where((v) => v != null)
        .map((v) => hue.parse(v))
        .whereType<String>()
        .toList();

    if (values.isEmpty) return null;

    return CategoricalColorScale.fromData(
      values: values,
      palette: palette,
    );
  }

  ScatterLayout _buildLayout(ScatterData data) {
    final xs = data.points.map((p) => p.x);
    final ys = data.points.map((p) => p.y);

    return ScatterLayout(
      xMin: xs.reduce((a, b) => a < b ? a : b),
      xMax: xs.reduce((a, b) => a > b ? a : b),
      yMin: ys.reduce((a, b) => a < b ? a : b),
      yMax: ys.reduce((a, b) => a > b ? a : b),
    );
  }
}
