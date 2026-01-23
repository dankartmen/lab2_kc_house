import 'package:flutter/material.dart';
import 'package:lab2_kc_house/features/pair_plots/pair_plot_controller.dart';
import '../../../dataset/field_descriptor.dart';
import '../scales/categorical_color_scale.dart';

class StripPlotPainter extends CustomPainter {
  final List<Map<String, dynamic>> rows;
  final FieldDescriptor catField;
  final FieldDescriptor numField;
  final List<String> categories;
  final Rect plotRect;
  final bool isVertical;
  final CategoricalColorScale? colorScale;
  final PairPlotController controller;

  /// Кешированные значения
  late final List<double> _numericValues;
  late final double _minV;
  late final double _maxV;
  late final List<double> _jitters;
  late final Map<String, int> _categoryIndexMap;


  StripPlotPainter({
    required this.rows,
    required this.catField,
    required this.numField,
    required this.categories,
    required this.plotRect,
    required this.isVertical,
    required this.controller,
    this.colorScale,
  }){
    _initializeCache();
  }


  void _initializeCache() {
    // Используем кэшированные значения из контроллера
    _numericValues = controller.getNumericValues(numField);
    if (_numericValues.isNotEmpty) {
      _minV = controller.getMinValue(numField);
      _maxV = controller.getMaxValue(numField);
    } else {
      _minV = 0.0;
      _maxV = 0.0;
    }
    
    // Получаем кэшированные jitters
    _jitters = controller.getJitters(rows.length, seed: 42);

    _categoryIndexMap = {
      for (var i = 0; i < categories.length; i++)
        categories[i]: i
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_numericValues.isEmpty) return;

    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final cat = row[catField.key];
      final numValue = row[numField.key];

      if (cat is! String || numValue is! num) continue;

      final catIndex = _categoryIndexMap[cat];
      if (catIndex == null) continue;

      // Используем предварительно рассчитанный jitter
      final jitter = _jitters[i];

      final dx = isVertical
          ? plotRect.left +
              (catIndex + 0.5 + jitter) / categories.length * plotRect.width
          : plotRect.left +
              _norm(numValue.toDouble(), _minV, _maxV) * plotRect.width;

      final dy = isVertical
          ? plotRect.bottom -
              _norm(numValue.toDouble(), _minV, _maxV) * plotRect.height
          : plotRect.bottom -
              (catIndex + 0.5 + jitter) / categories.length * plotRect.height;

      final paint = Paint()
        ..color = colorScale?.colorOf(cat) ?? Colors.blue
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dx, dy), 3, paint);
    }
  }

  double _norm(double v, double min, double max) {
    if (max == min) return 0.5;
    return (v - min) / (max - min);
  }

  @override
  bool shouldRepaint(covariant StripPlotPainter oldDelegate) {
    return oldDelegate.rows != rows ||
           oldDelegate.catField != catField ||
           oldDelegate.numField != numField ||
           oldDelegate.categories != categories ||
           oldDelegate.plotRect != plotRect ||
           oldDelegate.isVertical != isVertical ||
           oldDelegate.colorScale != colorScale;
  }
}