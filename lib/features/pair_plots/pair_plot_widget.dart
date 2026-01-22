import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/pair_plots/axis_painter.dart';
import 'package:lab2_kc_house/features/pair_plots/layout/plot_layout.dart';
import 'package:lab2_kc_house/features/pair_plots/plot_mapper.dart';
import 'package:lab2_kc_house/features/pair_plots/scales/categorical_color_scale.dart';

import '../../core/data/data_model.dart';

import '../../dataset/dataset.dart';
import '../../dataset/dataset_column.dart';
import '../../dataset/field_descriptor.dart';
import 'layout/scatter_layout.dart';
import 'pair_plot_config.dart';
import 'pair_plot_controller.dart';
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
   final Dataset dataset;

  /// Конфигурация диаграммы.
  final PairPlotConfig config;

  /// Стиль отображения.
  final PairPlotStyle style;

  /// Размер одной ячейки.
  final Size cellSize;
 
  /// Контроллер для управления состоянием.
  final PairPlotController? controller;

  /// {@macro pair_plot}
  const PairPlot({
    super.key,
    required this.dataset,
    required this.config,
    this.style = const PairPlotStyle(),
    this.cellSize = const Size(180, 180),
    this.controller,
  });
  
  @override
  State<PairPlot> createState() => _PairPlotState();
}

class _PairPlotState extends State<PairPlot> {
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
      final hueValues = widget.dataset.rows
        .map((row) => row[hueField.key])
        .where((v) => v != null)
        .map((v) => hueField.parseCategory(v))
        .whereType<String>()
        .toSet()
        .toList();


      if (hueValues.isNotEmpty) {
        colorScale = CategoricalColorScale.fromData(
          values: hueValues,
          palette: widget.config.palette ?? ColorPalette.defaultPalette,
          sort: (a, b) => a.compareTo(b),
          maxCategories: 6,
        );
        
        // Создаем легенду из colorScale
        legend = colorScale.legend;
      }
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

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
          ? _buildDiagonalPlot(x, colorScale)
          : _buildScatterPlot(x, y, colorScale, showYAxis, showXAxis),
    );
  }

  Widget _buildDiagonalPlot(FieldDescriptor field, CategoricalColorScale? colorScale) {
    if (field.type == FieldType.categorical) {
      return _buildCategoricalHistogram(field, colorScale);
    }

    if (!widget.style.showHistDiagonal) {
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

  Widget _buildCategoricalHistogram(FieldDescriptor field, CategoricalColorScale? colorScale) {
    final values = widget.dataset.rows
        .map((r) => r[field.key])
        .whereType<String>()
        .toList();

    if (values.isEmpty) return _empty('Нет данных');

    return CustomPaint(
      painter: _CategoricalHistogramPainter(
        colorScale: colorScale,
        values: values,
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
    if (x.type == FieldType.categorical &&
        y.type == FieldType.categorical) {
      return _empty('N/A');
    }

    if (x.type == FieldType.categorical ||
        y.type == FieldType.categorical) {
      return _buildCategoricalNumericPlot(x, y, colorScale, showXAxis, showYAxis);
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

  Widget _buildCategoricalNumericPlot(
    FieldDescriptor x,
    FieldDescriptor y,
    CategoricalColorScale? colorScale,
    bool showXAxis,
    bool showYAxis,
  ) {
    final isXCat = x.type == FieldType.categorical;
    final catField = isXCat ? x : y;
    final numField = isXCat ? y : x;

    final rows = widget.dataset.rows;

    final categories = rows
        .map((r) => r[catField.key])
        .whereType<String>()
        .toSet()
        .toList();

    if (categories.isEmpty) return _empty('Нет данных');

    final plotRect = PlotLayout().plotRect(widget.cellSize);

    return CustomPaint(
      painter: _StripPlotPainter(
        rows: rows,
        catField: catField,
        numField: numField,
        categories: categories,
        plotRect: plotRect,
        colorScale: colorScale,
        isVertical: isXCat,
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

  Widget _buildLegend(Map<String, Color> legend, Set<String> activeCategories,) {
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
    return DatasetColumn.numeric(widget.dataset, field);
  }

  List<_PlotPoint> _points(
    FieldDescriptor x,
    FieldDescriptor y,
    CategoricalColorScale? colorScale,
  ) {
    final result = <_PlotPoint>[];

    final rows = widget.dataset.rows;

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final xv = row[x.key];
      final yv = row[y.key];

      if (xv is! num || yv is! num) continue;

      final hueValue = widget.config.hue;

      final hue = hueValue?.parseCategory(row[hueValue.key]);

      result.add(
        _PlotPoint(
          x: xv.toDouble(),
          y: yv.toDouble(),
          index: i,
          hue: hue,
          color: colorScale != null && hue != null
              ? colorScale.colorOf(hue)
              : Colors.blue,
        ),
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


class _StripPlotPainter extends CustomPainter {
  final List<Map<String, dynamic>> rows;
  final FieldDescriptor catField;
  final FieldDescriptor numField;
  final List<String> categories;
  final Rect plotRect;
  final bool isVertical;
  final CategoricalColorScale? colorScale;

  _StripPlotPainter({
    required this.rows,
    required this.catField,
    required this.numField,
    required this.categories,
    required this.plotRect,
    required this.isVertical,
    this.colorScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(42);

    final nums = rows
        .map((r) => r[numField.key])
        .whereType<num>()
        .map((e) => e.toDouble())
        .toList();

    if (nums.isEmpty) return;

    final minV = nums.reduce(min);
    final maxV = nums.reduce(max);

    for (final row in rows) {
      final cat = row[catField.key];
      final numValue = row[numField.key];

      if (cat is! String || numValue is! num) continue;

      final catIndex = categories.indexOf(cat);
      if (catIndex == -1) continue;

      final jitter = (rnd.nextDouble() - 0.5) * 0.6;

      final dx = isVertical
          ? plotRect.left +
              (catIndex + 0.5 + jitter) / categories.length * plotRect.width
          : plotRect.left +
              norm(numValue.toDouble(), minV, maxV) * plotRect.width;

      final dy = isVertical
          ? plotRect.bottom -
              norm(numValue.toDouble(), minV, maxV) * plotRect.height
          : plotRect.bottom -
              (catIndex + 0.5 + jitter) / categories.length * plotRect.height;

      final paint = Paint()
        ..color = colorScale?.colorOf(cat) ?? Colors.blue
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dx, dy), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
      if (maxV == minV) return;
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

class _CategoricalHistogramPainter extends CustomPainter {
  final List<String> values;
  final CategoricalColorScale? colorScale;

  _CategoricalHistogramPainter({
    required this.values,
    required this.colorScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // Подсчет частот
    final Map<String, int> counts = {};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }

    final categories = colorScale != null
        ? colorScale!.categories.where((c) => counts.containsKey(c)).toList()
        : counts.keys.toList();
    final maxCount = counts.values.reduce(max).toDouble();

    final barWidth = size.width / categories.length;

    final paint = Paint()
      ..color = Colors.blue.withAlpha((0.6 * 255).toInt())
      ..style = PaintingStyle.fill;

    for (int i = 0; i < categories.length; i++) {
      final count = counts[categories[i]]!;
      final h = count / maxCount * size.height;

      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth,
          size.height - h,
          barWidth * 0.8,
          h,
        ),
        paint..color = colorScale?.colorOf(categories[i]) ?? Colors.blue,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CategoricalHistogramPainter old) {
    return old.values != values;
  }
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

class _HoverableScatterCell extends StatefulWidget {
  final double width;
  final double height;
  final List<_PlotPoint> points;
  final FieldDescriptor x;
  final FieldDescriptor y;
  final PairPlotStyle style;
  final CustomPainter painter;
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
    required this.colorScale,
    required this.showYAxis,
    required this.showXAxis,
    this.onHover,
  });

  @override
  State<_HoverableScatterCell> createState() =>
      _HoverableScatterCellState();
}

class _HoverableScatterCellState
    extends State<_HoverableScatterCell> {

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
                'Row: ${p.index}',
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