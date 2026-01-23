import 'package:flutter/material.dart';
import '../../dataset/dataset.dart';
import '../../dataset/field_descriptor.dart';
import 'data/pair_plot_data_builder.dart';
import 'data/scatter_data.dart';
import 'hoverable_scatter_cell.dart';
import 'layout/plot_layout.dart';
import 'layout/scatter_layout.dart';
import 'painters/histogram_painter.dart';
import 'painters/categorical_histogram_painter.dart';
import 'painters/strip_plot_painter.dart';
import 'pair_plot_config.dart';
import 'pair_plot_controller.dart';
import 'utils/plot_mapper.dart';

class PairPlotCell extends StatelessWidget {
  final Dataset dataset;
  final FieldDescriptor x;
  final FieldDescriptor y;
  final PairPlotConfig config;
  final PairPlotController controller;
  final bool isDiagonal;
  final bool showXAxis;
  final bool showYAxis;

  const PairPlotCell({
    super.key,
    required this.dataset,
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
      child: isDiagonal
          ? _buildDiagonalPlot()
          : _buildScatterPlot(),
    );
  }

  Widget _buildDiagonalPlot() {
    if (x.type == FieldType.categorical) {
      return _buildCategoricalHistogram();
    }

    if (!config.style.showHistDiagonal) {
      return _empty('—');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final values = _numericValues(x);
        if (values.isEmpty) return _empty('Нет данных');

        return CustomPaint(
          painter: HistogramPainter(
            values: values,
            label: x.label,
          ),
          size: constraints.biggest,
        );
      },
    );
  }

  Widget _buildCategoricalHistogram() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final values = dataset.rows
            .map((r) => r[x.key])
            .whereType<String>()
            .toList();

        if (values.isEmpty) return _empty('Нет данных');

        return CustomPaint(
          painter: CategoricalHistogramPainter(
            values: values,
            colorScale: config.colorScale,
          ),
          size: constraints.biggest,
        );
      },
    );
  }

  Widget _buildScatterPlot() {
    if (x.type == FieldType.categorical && y.type == FieldType.categorical) {
      return _empty('N/A');
    }

    if (x.type == FieldType.categorical || y.type == FieldType.categorical) {
      return _buildCategoricalNumericPlot();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final scatterData = PairPlotDataBuilder.buildScatter(
          dataset: dataset,
          x: x,
          y: y,
          hue: config.hue,
          colorScale: config.colorScale,
          computeCorrelation: config.style.showCorrelation,
        );

        if (scatterData.points.isEmpty) {
          return _empty('Нет данных');
        }

        final layout = _buildLayout(scatterData);
        final plotLayout = PlotLayout();
        final plotRect = plotLayout.plotRect(constraints.biggest);

        final mapper = PlotMapper(
          plotRect: plotRect,
          xMin: layout.xMin,
          xMax: layout.xMax,
          yMin: layout.yMin,
          yMax: layout.yMax,
        );

        return HoverableScatterCell(
          data: scatterData,
          mapper: mapper,
          x: x,
          y: y,
          style: config.style,
          colorScale: config.colorScale,
          showXAxis: showXAxis,
          showYAxis: showYAxis,
          plotLayout: plotLayout,
          controller: controller,
        );
      },
    );
  }

  Widget _buildCategoricalNumericPlot() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isXCat = x.type == FieldType.categorical;
        final catField = isXCat ? x : y;
        final numField = isXCat ? y : x;

        final rows = dataset.rows;
        final categories = rows
            .map((r) => r[catField.key])
            .whereType<String>()
            .toSet()
            .toList();

        if (categories.isEmpty) return _empty('Нет данных');

        final plotRect = PlotLayout().plotRect(constraints.biggest);

        return CustomPaint(
          painter: StripPlotPainter(
            rows: rows,
            catField: catField,
            numField: numField,
            categories: categories,
            plotRect: plotRect,
            colorScale: config.colorScale,
            isVertical: isXCat,
          ),
          size: constraints.biggest,
        );
      },
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
    // Здесь нужна реализация получения числовых значений
    // Пока используем временную реализацию:
    return dataset.rows
        .map((r) => r[field.key])
        .whereType<num>()
        .map((e) => e.toDouble())
        .toList();
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