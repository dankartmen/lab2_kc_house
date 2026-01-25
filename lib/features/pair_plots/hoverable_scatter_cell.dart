import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/pair_plots/pair_plot_controller.dart';
import '../../dataset/field_descriptor.dart';
import 'data/scatter_data.dart';
import 'layout/plot_layout.dart';
import 'pair_plot_style.dart';
import 'utils/plot_mapper.dart';
import 'painters/scatter_painter.dart';
import 'painters/axis_painter.dart';
import 'scales/categorical_color_scale.dart';

class HoverableScatterCell extends StatefulWidget {
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
  State<HoverableScatterCell> createState() => _HoverableScatterCellState();
}

class _HoverableScatterCellState extends State<HoverableScatterCell> {

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        widget.controller.model.setHoveredRow(
          _hitTest(event.localPosition)
        );
      },
      onExit: (_) {
        widget.controller.model.setHoveredRow(null);
      },
      child: Stack(
        children: [
          // Основной слой с точками
          CustomPaint(
            painter: ScatterPainter(
              data: widget.data,
              mapper: widget.mapper,
              dotSize: widget.style.dotSize,
              alpha: widget.style.alpha,
              showCorrelation: widget.style.showCorrelation,
              hoveredIndex: widget.controller.model.hoveredRow,
              pointsToDraw: widget.filteredPoints,
            ),
            size: Size.infinite,
          ),

          // Ось X
          if (widget.showXAxis)
            CustomPaint(
              painter: AxisPainter(
                mapper: widget.mapper,
                axisRect: widget.plotLayout.xAxisRect(
                  Size(
                    widget.mapper.plotRect.width +
                        widget.plotLayout.paddingLeft +
                        widget.plotLayout.paddingRight,
                    widget.mapper.plotRect.height +
                        widget.plotLayout.paddingTop +
                        widget.plotLayout.paddingBottom,
                  ),
                ),
                orientation: AxisOrientation.horizontal,
                label: widget.x.label,
              ),
            ),

          // Ось Y
          if (widget.showYAxis)
            CustomPaint(
              painter: AxisPainter(
                mapper: widget.mapper,
                axisRect: widget.plotLayout.xAxisRect(
                  Size(
                    widget.mapper.plotRect.width +
                        widget.plotLayout.paddingLeft +
                        widget.plotLayout.paddingRight,
                    widget.mapper.plotRect.height +
                        widget.plotLayout.paddingTop +
                        widget.plotLayout.paddingBottom,
                  ),
                ),
                orientation: AxisOrientation.vertical,
                label: widget.y.label,
              ),
              size: Size.infinite,
            ),

          if (widget.controller.model.hoveredRow != null)
            _tooltip(widget.controller.model.hoveredRow!),
        ],
      ),
    );
  }

  int? _hitTest(Offset pos) {
    for (final p in widget.filteredPoints) {
      final mapped = widget.mapper.map(p.x, p.y);
      if ((mapped - pos).distance < 6) return p.rowIndex;
    }
    return null;
  }

  Widget _tooltip(int row) {
    final point = widget.data.points.firstWhere(
      (p) => p.rowIndex == row,
    );

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
              Text(
                '${widget.x.label}: ${point.x.toStringAsFixed(1)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${widget.y.label}: ${point.y.toStringAsFixed(1)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
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