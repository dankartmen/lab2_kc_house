import 'package:flutter/material.dart';
import '../../dataset/field_descriptor.dart';
import 'data/scatter_data.dart';
import 'layout/plot_layout.dart';
import 'pair_plot_style.dart';
import 'utils/plot_mapper.dart';
import 'painters/scatter_painter.dart';
import 'painters/axis_painter.dart';
import 'scales/categorical_color_scale.dart';
import 'pair_plot_controller.dart';

class HoverableScatterCell extends StatelessWidget {
  final ScatterData data;
  final PlotMapper mapper;
  final FieldDescriptor x;
  final FieldDescriptor y;
  final PairPlotStyle style;
  final CategoricalColorScale? colorScale;
  final bool showYAxis;
  final bool showXAxis;
  final PlotLayout plotLayout;
  final PairPlotController controller;
  final List<ScatterPoint> filteredPoints;

  const HoverableScatterCell({
    super.key,
    required this.data,
    required this.mapper,
    required this.x,
    required this.y,
    required this.style,
    required this.colorScale,
    required this.showYAxis,
    required this.showXAxis,
    required this.plotLayout,
    required this.controller,
    required this.filteredPoints,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final cellSize = constraints.biggest;

        return MouseRegion(
          onHover: (event) =>
              controller.model.setHoveredRow(_hitTest(event.localPosition)),
          onExit: (_) => controller.model.setHoveredRow(null),
          child: Stack(
            children: [
              /// Основной scatter-плот
              CustomPaint(
                painter: ScatterPainter(
                  data: data,
                  mapper: mapper,
                  dotSize: style.dotSize,
                  alpha: style.alpha,
                  showCorrelation: false, // ❗ correlation убираем из painter
                  hoveredIndex: controller.model.hoveredRow,
                  pointsToDraw: filteredPoints,
                ),
                size: cellSize,
              ),

              /// Ось X — ТОЛЬКО в нижнем ряду
              if (showXAxis)
                CustomPaint(
                  painter: AxisPainter(
                    mapper: mapper,
                    axisRect: plotLayout.xAxisRect(cellSize),
                    orientation: AxisOrientation.horizontal,
                    label: x.label,
                  ),
                  size: cellSize,
                ),

              /// Ось Y — ТОЛЬКО в левом столбце
              if (showYAxis)
                CustomPaint(
                  painter: AxisPainter(
                    mapper: mapper,
                    axisRect: plotLayout.yAxisRect(cellSize),
                    orientation: AxisOrientation.vertical,
                    label: y.label,
                  ),
                  size: cellSize,
                ),

              /// Минимальный индикатор корреляции
              if (data.correlation != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
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
          ),
        );
      },
    );
  }

  /// Проверка, навели ли курсор на точку
  int? _hitTest(Offset pos) {
    for (final p in filteredPoints) {
      final mapped = mapper.map(p.x, p.y);
      if ((mapped - pos).distance < 6) return p.rowIndex;
    }
    return null;
  }
}
