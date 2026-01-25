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
    return MouseRegion(
      onHover: (event) =>
          controller.model.setHoveredRow(_hitTest(event.localPosition)),
      onExit: (_) => controller.model.setHoveredRow(null),
      child: Stack(
        children: [
          CustomPaint(
            painter: ScatterPainter(
              data: data,
              mapper: mapper,
              dotSize: style.dotSize,
              alpha: style.alpha,
              showCorrelation: style.showCorrelation,
              hoveredIndex: controller.model.hoveredRow,
              pointsToDraw: filteredPoints,
            ),
            size: Size.infinite,
          ),

          if (showXAxis)
            CustomPaint(
              painter: AxisPainter(
                mapper: mapper,
                axisRect: plotLayout.xAxisRect(mapper.plotRect.size),
                orientation: AxisOrientation.horizontal,
                label: x.label,
              ),
            ),

          if (showYAxis)
            CustomPaint(
              painter: AxisPainter(
                mapper: mapper,
                axisRect: plotLayout.yAxisRect(mapper.plotRect.size),
                orientation: AxisOrientation.vertical,
                label: y.label,
              ),
            ),

          if (controller.model.hoveredRow != null)
            _tooltip(controller.model.hoveredRow!),
        ],
      ),
    );
  }

  int? _hitTest(Offset pos) {
    for (final p in filteredPoints) {
      final mapped = mapper.map(p.x, p.y);
      if ((mapped - pos).distance < 6) return p.rowIndex;
    }
    return null;
  }

  Widget _tooltip(int row) {
    final point = data.points.firstWhere((p) => p.rowIndex == row);

    return Positioned(
      left: 6,
      top: 6,
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${x.label}: ${point.x.toStringAsFixed(1)}'),
              Text('${y.label}: ${point.y.toStringAsFixed(1)}'),
              if (point.category != null)
                Text(
                  'Категория: ${point.category}',
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
