import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/pair_plots/pair_plot_controller.dart';
import '../../dataset/field_descriptor.dart';
import 'data/scatter_data.dart';
import 'layout/plot_layout.dart';
import 'pair_plot_style.dart';
import 'utils/plot_mapper.dart';
import 'painters/scatter_painter.dart';
import 'utils/axis_painter.dart';
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
  final List<ScatterPoint>? filteredPoints;

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
    this.filteredPoints,
  });

  @override
  State<HoverableScatterCell> createState() => _HoverableScatterCellState();
}

class _HoverableScatterCellState extends State<HoverableScatterCell> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final local = event.localPosition;
        final hit = _hitTest(local);
        if (hit != hoveredIndex) {
          widget.controller.setHoveredIndex(hit);
          setState(() => hoveredIndex = hit);
        }
      },
      onExit: (_) {
        setState(() => hoveredIndex = null);
        widget.controller.setHoveredIndex(null);
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
              hoveredIndex: hoveredIndex,
              activeCategories: widget.controller.activeCategories,
              filteredPoints: widget.filteredPoints,
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
                    widget.mapper.plotRect.width + 16,
                    widget.mapper.plotRect.height + 16,
                  ),
                ),
                orientation: AxisOrientation.horizontal,
                label: widget.x.label,
              ),
              size: Size.infinite,
            ),

          // Ось Y
          if (widget.showYAxis)
            CustomPaint(
              painter: AxisPainter(
                mapper: widget.mapper,
                axisRect: widget.plotLayout.yAxisRect(
                  Size(
                    widget.mapper.plotRect.width + 16,
                    widget.mapper.plotRect.height + 16,
                  ),
                ),
                orientation: AxisOrientation.vertical,
                label: widget.y.label,
              ),
              size: Size.infinite,
            ),

          if (hoveredIndex != null)
            _buildTooltip(context, hoveredIndex!),
        ],
      ),
    );
  }

  int? _hitTest(Offset pos) {
    const radius = 6.0;

    for (final p in widget.data.points) {
      final mapped = widget.mapper.map(p.x, p.y);
      if ((mapped - pos).distance <= radius) {
        return p.rowIndex;
      }
    }
    return null;
  }

  Widget _buildTooltip(BuildContext context, int index) {
    final point = widget.data.points.firstWhere(
      (p) => p.rowIndex == index,
      orElse: () => widget.data.points.first,
    );

    return Positioned(
      left: 4,
      top: 4,
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.x.label}: ${point.x.toStringAsFixed(2)}'),
              Text('${widget.y.label}: ${point.y.toStringAsFixed(2)}'),
              if (point.category != null)
                Text('Group: ${point.category}'),
              Text(
                'Row: ${point.rowIndex}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}