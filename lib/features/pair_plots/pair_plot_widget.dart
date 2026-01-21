import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/pair_plots/axis_painter.dart';
import 'package:lab2_kc_house/features/pair_plots/layout/plot_layout.dart';
import 'package:lab2_kc_house/features/pair_plots/plot_mapper.dart';
import 'package:lab2_kc_house/features/pair_plots/scales/categorical_color_scale.dart';

import '../../core/data/data_model.dart';
import '../../core/data/field_descriptor.dart';
import 'layout/scatter_layout.dart';
import 'pair_plot_config.dart';
import 'pair_plot_style.dart';
import 'statistics_utils.dart';

/// {@template pair_plot}
/// Виджет для отображения матрицы парных диаграмм (Pair Plot).
///
/// Использует [FieldDescriptor] для:
/// - корректной интерпретации типов данных
/// - безопасной цветовой группировки
/// - отображения подписей осей
/// {@endtemplate}
class PairPlot<T extends DataModel> extends StatefulWidget {
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
  State<PairPlot<T>> createState() => _PairPlotState<T>();
}

class _PairPlotState<T extends DataModel> extends State<PairPlot<T>> {
  int? hoveredIndex;
  Set<String> activeCategories = {};

  void setHoveredIndex(int? index) {
    if (hoveredIndex != index) {
      setState(() {
        hoveredIndex = index;
      });
    }
  }

  void toggleCategory(String category) {
    setState(() {
      if (activeCategories.contains(category)) {
        activeCategories.remove(category);
      } else {
        activeCategories.add(category);
      }
    });
  }

  bool isCategoryActive(String? category) {
    if (category == null) return true;
    if (activeCategories.isEmpty) return true;
    return activeCategories.contains(category);
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.config.fields;
    final hueField = widget.config.hue;
    
    CategoricalColorScale? colorScale;
    Map<String, Color>? legend;

    if (hueField != null) {
      final hueValues = widget.data
          .map((e) => e.getCategoricalValue(hueField.key))
          .whereType<String>()
          .toList();

      if (hueValues.isNotEmpty) {
        colorScale = CategoricalColorScale.fromData(
          values: hueValues,
          palette: widget.config.palette ?? ColorPalette.defaultPalette,
          sort: (a, b) => a.compareTo(b),
          maxCategories: 6,
        );
        
        // Создаем легенду из colorScale
        legend = colorScale.colors;
      }
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (legend != null && legend.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildLegend(legend, activeCategories),
            ],

            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: widget.cellSize.width * fields.length,
                child: _buildMatrix(fields, colorScale, hoveredIndex),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrix(List<FieldDescriptor> fields, CategoricalColorScale? colorScale, int? hoveredIndex) {
    final n = fields.length;

    // Строит матрицу графиков размером n×n, где n - количество числовых полей
    // На диагонали - гистограммы, вне диагонали - диаграммы рассеяния
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: n,
        childAspectRatio: widget.cellSize.width / widget.cellSize.height,
      ),
      itemCount: n * n,
      itemBuilder: (context, index) {
        final row = index ~/ n;
        final col = index % n;

        final x = fields[col];
        final y = fields[row];

        // Определяем, нужно ли рисовать оси
        final showYAxis = col == 0;        // Только первая колонка
        final showXAxis = row == n - 1;    // Только последняя строка

        return _buildCell(
          x: x,
          y: y,
          isDiagonal: row == col,
          colorScale: colorScale,
          showXAxis: showXAxis,
          showYAxis: showYAxis,
        );
      },
    );
  }

  Widget _buildCell({
    required FieldDescriptor x,
    required FieldDescriptor y,
    required bool isDiagonal,
    required CategoricalColorScale? colorScale,
    required bool showYAxis,
    required bool showXAxis,
  }) {
    return Container(
      width: widget.cellSize.width,
      height: widget.cellSize.height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: isDiagonal
          ? _buildDiagonalPlot(x)
          : _buildScatterPlot(x, y, colorScale, showYAxis, showXAxis),
    );
  }

  Widget _buildDiagonalPlot(FieldDescriptor field) {
    if (!widget.style.showHistDiagonal ||
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
    CategoricalColorScale? colorScale,
    bool showYAxis,
    bool showXAxis,
  ) {
    if (x.type == FieldType.categorical ||
        y.type == FieldType.categorical) {
      return _empty('N/A');
    }

    final points = _points(x, y, colorScale);
    if (points.isEmpty) {
      return _empty('Нет данных');
    }

    final layout = ScatterLayout(
      xMin: points.map((e) => e.x).reduce(min),
      xMax: points.map((e) => e.x).reduce(max),
      yMin: points.map((e) => e.y).reduce(min),
      yMax: points.map((e) => e.y).reduce(max),
    );

    final plotRect = PlotLayout().plotRect(widget.cellSize);
    final mapper = PlotMapper(
      plotRect: plotRect,
      xMin: layout.xMin,
      xMax: layout.xMax,
      yMin: layout.yMin,
      yMax: layout.yMax,
    );

    return _HoverableScatterCell(
      layout: layout,
      mapper: mapper,
      width: widget.cellSize.width,
      height: widget.cellSize.height,
      data: widget.data,
      points: points,
      x: x,
      y: y,
      style: widget.style,
      colorScale: colorScale,
      showXAxis: showXAxis,
      showYAxis: showYAxis,
      onHover: setHoveredIndex,
      painter: _ScatterPainter(
        layout: layout,
        mapper: mapper,
        points: points,
        xLabel: x.label,
        yLabel: y.label,
        style: widget.style,
        colorScale: colorScale,
        hoveredIndex: hoveredIndex,
        activeCategories: activeCategories
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

  Widget _buildLegend(Map<String, Color> legend, Set<String> activeCategories) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: legend.entries.map((e) {
        final isActive = activeCategories.isEmpty ||
            activeCategories.contains(e.key);
  
        return GestureDetector(
          onTap: () => toggleCategory(e.key),
          child: Opacity(
            opacity: isActive ? 1.0 : 0.3,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: e.value,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  e.key,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  List<double> _numericValues(FieldDescriptor field) {
    return widget.data
        .map((e) => e.getNumericValue(field.key))
        .whereType<double>()
        .toList();
  }

  List<_PlotPoint> _points(
    FieldDescriptor x,
    FieldDescriptor y,
    CategoricalColorScale? colorScale,
  ) {
    final result = <_PlotPoint>[];

    for (int i = 0; i < widget.data.length; i++) {
      final item = widget.data[i];
      final xv = item.getNumericValue(x.key);
      final yv = item.getNumericValue(y.key);
      final hue = widget.config.hue != null
          ? item.getCategoricalValue(widget.config.hue!.key)
          : null;
      if (xv == null || yv == null) continue;

      result.add(
        _PlotPoint(
          x: xv,
          y: yv,
          index: i,
          hue: hue,
          color: colorScale != null
              ? colorScale.colorOf(hue!)
              : Colors.blue,
        ),
      );
    }

    if (result.length > widget.style.maxPoints) {
      final step = result.length / widget.style.maxPoints;
      return List.generate(
        widget.style.maxPoints,
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
  final int index;
  final Color color;


  const _PlotPoint({
    required this.x,
    required this.y,
    required this.index,
    required this.color,
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

    final paint = Paint()..color = Colors.blue.withAlpha((0.6 * 255).toInt());

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
  final ScatterLayout layout;
  final PlotMapper mapper;
  final List<_PlotPoint> points;
  final String xLabel;
  final String yLabel;
  final PairPlotStyle style;
  final CategoricalColorScale? colorScale;
  final int? hoveredIndex;
  final Set<String> activeCategories;

  _ScatterPainter({
    required this.layout,
    required this.mapper,
    required this.points,
    required this.xLabel,
    required this.yLabel,
    required this.style,
    required this.colorScale,
    required this.activeCategories,
    this.hoveredIndex,
  });

  
  @override
  void paint(Canvas canvas, Size size) {
    // Рисуем точки
    for (final p in points) {
      final isActiveCategory = activeCategories.isEmpty || (p.hue != null && activeCategories.contains(p.hue));

      final isHovered = hoveredIndex != null && p.index == hoveredIndex;

      final alpha = isHovered
          ? 1.0
          : isActiveCategory
              ? style.alpha
              : 0.1;

      final color = isHovered 
        ? Colors.yellow
        : colorScale != null && p.hue != null
          ? colorScale!.colorOf(p.hue!)
          : Colors.blue;

      final paint = Paint()
        ..color = color.withAlpha((alpha * 255).toInt())
        ..style = PaintingStyle.fill;

      final pos = mapper.map(p.x, p.y);
      canvas.drawCircle(pos, style.dotSize, paint);
    }

    // Рисуем корреляцию
    if (style.showCorrelation && points.length > 2) {
      final xs = points.map((e) => e.x).toList();
      final ys = points.map((e) => e.y).toList();
      final r = StatisticsUtils.pearson(xs, ys);

      final textPainter = TextPainter(
        text: TextSpan(
          text: 'r = ${r.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 10,
            color: Colors.black.withAlpha((0.7 * 255).toInt()),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas, const Offset(4, 4));
    }
  } 

  @override
  bool shouldRepaint(covariant _ScatterPainter old) {
    return old.points != points ||
           old.layout != layout ||
           old.style != style ||
           old.colorScale != colorScale ||
           old.hoveredIndex != hoveredIndex ||
           old.activeCategories != activeCategories;
  }
}

class _HoverableScatterCell<T extends DataModel> extends StatefulWidget {
  final double width;
  final double height;
  final List<_PlotPoint> points;
  final FieldDescriptor x;
  final FieldDescriptor y;
  final PairPlotStyle style;
  final CustomPainter painter;
  final List<T> data;
  final ScatterLayout layout;
  final PlotMapper mapper;
  final CategoricalColorScale? colorScale;
  final bool showYAxis;
  final bool showXAxis;
  final void Function(int?)? onHover;

  const _HoverableScatterCell({
    required this.layout,
    required this.mapper,
    required this.width,
    required this.height,
    required this.points,
    required this.x,
    required this.y,
    required this.style,
    required this.painter,
    required this.data,
    required this.colorScale,
    required this.showYAxis,
    required this.showXAxis,
    this.onHover,
  });

  @override
  State<_HoverableScatterCell<T>> createState() =>
      _HoverableScatterCellState<T>();
}

class _HoverableScatterCellState<T extends DataModel>
    extends State<_HoverableScatterCell<T>> {

  _PlotPoint? hovered;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) {
        final local = event.localPosition;
        final hit = _hitTest(local);
        if (hit != hovered) {
          widget.onHover?.call(hit?.index);
          setState(() => hovered = hit);
        }
      },
      onExit: (_) { 
        setState(() => hovered = null);
        widget.onHover?.call(null);
      },
      child: Stack(
        children: [
          // Основной слой с точками
          CustomPaint(
            painter: widget.painter,
            size: Size.infinite,
          ),
          
          // Ось X
          if (widget.showXAxis)
            CustomPaint(
              painter: AxisPainter(
                mapper: widget.mapper,
                axisRect: PlotLayout().xAxisRect(Size(
                  widget.width,
                  widget.height,
                )),
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
                axisRect: PlotLayout().yAxisRect(Size(
                  widget.width,
                  widget.height,
                )),
                orientation: AxisOrientation.vertical,
                label: widget.y.label,
              ),
              size: Size.infinite,
            ),

          if (hovered != null)
            _buildTooltip(context, hovered!),
        ],
      ),
    );
  }

  _PlotPoint? _hitTest(Offset pos) {
    const radius = 6.0;

    for (final p in widget.points) {
      final mapped = widget.mapper.map(p.x, p.y);
      if ((mapped - pos).distance <= radius) {
        return p;
      }
    }
    return null;
  }

  Widget _buildTooltip(BuildContext context, _PlotPoint p) {
    final item = widget.data[p.index];

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
              Text('${widget.x.label}: ${p.x.toStringAsFixed(2)}'),
              Text('${widget.y.label}: ${p.y.toStringAsFixed(2)}'),
              if (p.hue != null)
                Text('Group: ${p.hue}'),
              Text(
                item.getDisplayName(),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

double norm(double v, double min, double max) {
  if (max == min) return 0.5;
  return (v - min) / (max - min);
}

class Viewport {
  double xMin;
  double xMax;
  double yMin;
  double yMax;

  Viewport({
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
  });

  double get xRange => xMax - xMin;
  double get yRange => yMax - yMin;
}