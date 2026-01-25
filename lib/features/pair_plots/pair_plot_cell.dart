import 'package:flutter/material.dart';
import '../../dataset/field_descriptor.dart';
import 'hoverable_scatter_cell.dart';
import 'layout/plot_layout.dart';
import 'painters/histogram_painter.dart';
import 'painters/categorical_histogram_painter.dart';
import 'painters/strip_plot_painter.dart';
import 'pair_plot_config.dart';
import 'pair_plot_controller.dart';
import 'utils/plot_mapper.dart';

class PairPlotCell extends StatelessWidget {
  final FieldDescriptor x;
  final FieldDescriptor y;
  final PairPlotConfig config;
  final PairPlotController controller;
  final bool isDiagonal;
  final bool showXAxis;
  final bool showYAxis;

  const PairPlotCell({
    super.key,
    required this.x,
    required this.y,
    required this.config,
    required this.controller,
    this.isDiagonal = false,
    this.showXAxis = false,
    this.showYAxis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: isDiagonal ? _buildDiagonal() : _buildOffDiagonal(),
    );
  }

  Widget _buildDiagonal() {
    if (x.type == FieldType.categorical) return _buildCategoricalHistogram();
    if (!config.style.showHistDiagonal) return _empty('—');

    final values = controller.getNumericValues(x);
    if (values.isEmpty) return _empty('Нет данных');

    return LayoutBuilder(
      builder: (_, constraints) {
        return CustomPaint(
          painter: HistogramPainter(values: values, label: x.label),
          size: constraints.biggest,
        );
      },
    );
  }

  Widget _buildCategoricalHistogram() {
    final values = controller.getCategoricalValues(x);
    if (values.isEmpty) return _empty('Нет данных');

    return LayoutBuilder(
      builder: (_, constraints) {
        return CustomPaint(
          painter: CategoricalHistogramPainter(
            values: values,
            colorScale: controller.colorScale,
          ),
          size: constraints.biggest,
        );
      },
    );
  }

  Widget _buildOffDiagonal() {
    if (x.type == FieldType.categorical && y.type == FieldType.categorical) {
      return _empty('N/A');
    }
    if (x.type == FieldType.categorical || y.type == FieldType.categorical) {
      return _buildCategoricalNumeric();
    }
    return _buildScatter();
  }

  Widget _buildScatter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final data = controller.getScatterData(
          x,
          y,
          computeCorrelation: config.style.showCorrelation,
        );
        if (data.points.isEmpty) return _empty('Нет данных');

        final plotLayout = PlotLayout();
        final plotRect = plotLayout.plotRect(constraints.biggest);

        final xs = data.points.map((p) => p.x);
        final ys = data.points.map((p) => p.y);

        final mapper = PlotMapper(
          plotRect: plotRect,
          xMin: xs.reduce((a, b) => a < b ? a : b),
          xMax: xs.reduce((a, b) => a > b ? a : b),
          yMin: ys.reduce((a, b) => a < b ? a : b),
          yMax: ys.reduce((a, b) => a > b ? a : b),
        );

        return HoverableScatterCell(
          data: data,
          mapper: mapper,
          x: x,
          y: y,
          style: config.style,
          colorScale: controller.colorScale,
          showXAxis: showXAxis,
          showYAxis: showYAxis,
          plotLayout: plotLayout,
          controller: controller,
          filteredPoints: data.points,
        );
      },
    );
  }

  Widget _buildCategoricalNumeric() {
    return LayoutBuilder(
      builder: (_, constraints) {
        final isXCat = x.type == FieldType.categorical;
        final catField = isXCat ? x : y;
        final numField = isXCat ? y : x;

        final rows = controller.visibleRowsFor(catField, numField);
        if (rows.isEmpty) return _empty('Нет данных');

        final categories = rows
            .map((r) => catField.parseCategory(r[catField.key]))
            .whereType<String>()
            .toSet()
            .toList();

        final plotRect = PlotLayout().plotRect(constraints.biggest);

        return CustomPaint(
          painter: StripPlotPainter(
            rows: rows,
            catField: catField,
            numField: numField,
            categories: categories,
            plotRect: plotRect,
            colorScale: controller.colorScale,
            isVertical: isXCat,
            controller: controller,
          ),
          size: constraints.biggest,
        );
      },
    );
  }

  Widget _empty(String text) => Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      );
}
