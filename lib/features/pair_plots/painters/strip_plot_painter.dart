import 'dart:math';
import 'package:flutter/material.dart';
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

  /// Кешированные числовые значения и их мин/макс
  late final List<double> _cachedNumericValues;
  late final double _cachedMinV;
  late final double _cachedMaxV;
  bool _isCacheInitialized = false;

  StripPlotPainter({
    required this.rows,
    required this.catField,
    required this.numField,
    required this.categories,
    required this.plotRect,
    required this.isVertical,
    this.colorScale,
  }){
    _initializeCache();
  }


  void _initializeCache() {
    _cachedNumericValues = rows
        .map((r) => r[numField.key])
        .whereType<num>()
        .map((e) => e.toDouble())
        .toList();

    if (_cachedNumericValues.isNotEmpty) {
      _cachedMinV = _cachedNumericValues.reduce((a, b) => a < b ? a : b);
      _cachedMaxV = _cachedNumericValues.reduce((a, b) => a > b ? a : b);
    } else {
      _cachedMinV = 0;
      _cachedMaxV = 0;
    }
    
    _isCacheInitialized = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!_isCacheInitialized || _cachedNumericValues.isEmpty) return;

    final rnd = Random(42);

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
              _norm(numValue.toDouble(), _cachedMinV, _cachedMaxV) * plotRect.width;

      final dy = isVertical
          ? plotRect.bottom -
              _norm(numValue.toDouble(), _cachedMinV, _cachedMaxV) * plotRect.height
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
  bool shouldRepaint(covariant StripPlotPainter oldDelegate) => true;
}