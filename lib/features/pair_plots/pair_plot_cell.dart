import 'package:flutter/material.dart';
import '../../dataset/field_descriptor.dart';
import 'hoverable_scatter_cell.dart';
import 'layout/plot_layout.dart';
import 'painters/histogram_painter.dart';
import 'painters/categorical_histogram_painter.dart';
import 'painters/strip_plot_painter.dart';
import 'pair_plot_config.dart';
import 'pair_plot_controller.dart';
import 'pair_plot_detail_page.dart';
import 'utils/plot_mapper.dart';

/// Одна ячейка pair plot матрицы
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
    // Полностью пустые комбинации не рисуем
    if (_isTrulyEmpty()) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: isDiagonal
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PairPlotDetailPage(
                    x: x,
                    y: y,
                    controller: controller,
                    config: config,
                  ),
                ),
              );
            },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: isDiagonal ? _buildDiagonal() : _buildOffDiagonal(),
      ),
    );
  }

  /// Проверка: имеет ли ячейка смысл
  bool _isTrulyEmpty() {
    if (!isDiagonal &&
        x.type == FieldType.categorical &&
        y.type == FieldType.categorical) {
      return true;
    }
    return false;
  }

  Widget _buildDiagonal() {
    // Категориальная диагональ — гистограмма категорий
    if (x.type == FieldType.categorical) {
      return _buildCategoricalHistogram();
    }

    // Числовая диагональ — обычная гистограмма
    if (!config.style.showHistDiagonal) {
      return const SizedBox.shrink();
    }

    final values = controller.getNumericValues(x);
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (_, constraints) {
        return CustomPaint(
          painter: HistogramPainter(
            values: values,
          ),
          size: constraints.biggest,
        );
      },
    );
  }

  Widget _buildCategoricalHistogram() {
    final values = controller.getCategoricalValues(x);
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

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
    // Категория × категория — не рисуем вообще
    if (x.type == FieldType.categorical &&
        y.type == FieldType.categorical) {
      return const SizedBox.shrink();
    }

    // Категория × число → strip plot
    if (x.type == FieldType.categorical ||
        y.type == FieldType.categorical) {
      return _buildCategoricalNumeric();
    }

    // Число × число → scatter
    return _buildScatter();
  }

  Widget _buildScatter() {
    return LayoutBuilder(
      builder: (_, constraints) {
        final data = controller.getScatterData(
          x,
          y,
          computeCorrelation: true, // correlation считаем, но почти не показываем
        );

        if (data.points.isEmpty) {
          return const SizedBox.shrink();
        }

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

        return Stack(
          children: [
            HoverableScatterCell(
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
            ),

            // Минимальный индикатор корреляции
            if (data.correlation != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'r=${data.correlation!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
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
        if (rows.isEmpty) {
          return const SizedBox.shrink();
        }

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
}
