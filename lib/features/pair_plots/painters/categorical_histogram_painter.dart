import 'package:flutter/material.dart';
import '../scales/categorical_color_scale.dart';

class CategoricalHistogramPainter extends CustomPainter {
  final List<String> values;
  final CategoricalColorScale? colorScale;

  CategoricalHistogramPainter({
    required this.values,
    required this.colorScale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final Map<String, int> counts = {};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }

    final categories = colorScale != null
        ? colorScale!.categories.where((c) => counts.containsKey(c)).toList()
        : counts.keys.toList();
    
    if (categories.isEmpty) return;
    
    final maxCount = categories
        .map((c) => counts[c] ?? 0)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    final barWidth = size.width / categories.length;

    for (int i = 0; i < categories.length; i++) {
      final count = counts[categories[i]] ?? 0;
      if (maxCount == 0) continue;
      final h = count / maxCount * size.height;

      final paint = Paint()
        ..color = colorScale?.colorOf(categories[i]) ?? Colors.blue
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          i * barWidth,
          size.height - h,
          barWidth * 0.8,
          h,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CategoricalHistogramPainter old) {
    return old.values != values || old.colorScale != colorScale;
  }
}